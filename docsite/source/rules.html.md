---
title: Rules
layout: gem-single
name: dry-validation
---

Rules in contracts are meant to perform domain-specific validation of the data already processed by the contract's schema. This way, you can define rules that can focus purely on their validation logic without having to worry about type-related details.

When you apply a contract, it will process the input data using its schema, and then apply its rules one-by-one, in the same order as you defined them.

If a rule specifies that it depends on certain keys from the input data, it **will be executed only when the schema successfuly processed those keys**.

### Defining a rule

To define a rule on a contract, use the `rule` method.

Let's say we want to validate that an event's start date is in the future. We'll define a contract for event data with a `start_date` key that must be provided as a valid `Date` object. Then we'll define a rule to check that it's in the future:

```ruby
class EventContract < Dry::Validation::Contract
  params do
    required(:start_date).value(:date)
  end

  rule(:start_date) do
    key.failure('must be in the future') if value <= Date.today
  end
end

contract = EventContract.new
```

Notice that if we apply your contract with an input that doesn't include a date under `start_date` key, the rule **will not be executed**:

```ruby
contract.call(start_date: 'oops').errors.to_h
# => {:start_date=>["must be a date"]}
```

When `start_date` is a `Date`, the rule will be executed:

```ruby
contract.call(start_date: Date.today - 1).errors.to_h
# => {:start_date=>["must be in the future"]}
```

### Depending on more than one key

In our previous example, we defined a simple rule that depends on a single key. To depend on more than one key, we can specify a list of keys. Let's extend the previous example and change our rule to validate that an `end_date` should be after the `start_date`:

```ruby
class EventContract < Dry::Validation::Contract
  params do
    required(:start_date).value(:date)
    required(:end_date).value(:date)
  end

  rule(:end_date, :start_date) do
    key.failure('must be after start date') if values[:end_date] < values[:start_date]
  end
end

contract = EventContract.new

contract.call(start_date: Date.today, end_date: Date.today - 1).errors.to_h
# => {:end_date=>["must be after start date"]}
```

### Key path syntax

You can define key dependencies for rules using a *key path* syntax. Here's a list of supported key paths:

- Using a hash: `rule(address: :city) do ...`
- The same, but using *dot notation*: `rule("address.city") do ...`
- Specifying multiple nested keys using a hash: `rule(address: [:city, :street]) do ...`

### Key failures

The only responsibility of a rule is to set a failure message when the validation didn't pass. In the previous examples, we used `key.failure` to manually set messages. Use this if you want to set a failure message that should be accessible under a specific key.

When you use `key.failure` without any specific key arguments, it uses *the first key specified with the rule*:

``` ruby
rule(:start_date) do
  key.failure('oops')
  # ^ is the equivalent of
  key(:start_date).failure('oops')
end
```

You *do not have to use keys matching those specified with the rule*. For example, this is perfectly fine:

``` ruby
rule(:start_date) do
  key(:event_errors).failure('oops')
end
```

### Base failures

Unlike key failures, base failures are not associated with a specific key, instead they are associated with the whole input. To set a base failure, use the `base` method, which has the same API as `key`. For example:

``` ruby
class EventContract < Dry::Validation::Contract
  option :today, default: Date.method(:today)

  params do
    required(:start_date).value(:date)
    required(:end_date).value(:date)
  end

  rule do
    if today.saturday? || today.sunday?
      base.failure('creating events is allowed only on weekdays')
    end
  end
end

contract = EventContract.new
```

Now when you try to apply this contract during a weekend, you'll get a base error:

``` ruby
contract.call(start_date: Date.today+1, end_date: Date.today+2).errors.to_h
# => {nil=>["creating events is allowed only on weekdays"]}
```

Notice that the hash representation of errors includes a `nil` key to indicate the base errors. There's also a specific API for finding all base errors, if you prefer that:

``` ruby
contract.call(start_date: Date.today+1, end_date: Date.today+2).errors.filter(:base?).map(&:to_s)
# => ["creating events is allowed only on weekdays"]
```

> Curious about that `option` method that we used to set `today` value? You can learn about it in [the external dependencies](/gems/dry-validation/external-dependencies) section.

### Reading rule values

For convenience, you can use `value` method to easily access the value under rule's default key. This works with all key specifications, including nested keys, and specifying a path to multiple values.

``` ruby
rule(:start_date) do
  value
  # returns values[:start_date]
end

rule(date: :start) do
  value
  # returns values[:date][:start]
end

rule(dates: [:start, :stop]) do
  value
  # returns an array: [values[:dates][:start], values[:dates][:stop]]
end
```

### Checking if the value is present

When you're not sure if the value is actually available, you can use `key?` method. It returns `true` when a value under rule's key is present, `false` otherwise.

A common use case is when your rules depend on optional keys, here's an example:

``` ruby
class NewUserContract < Dry::Validation::Contract
  params do
    required(:email).value(:string)
    optional(:login).value(:string)
    optional(:password).value(:string)
  end

  rule(:password) do
    key.failure('password is required') if key? && values[:login] && value.length < 12
  end
end

contract = NewUserContract.new

contract.call(email: 'jane@doe.org', login: 'jane', password: "").errors.to_h
# => {:password=>["password is required"]}
```

### Defining a rule for each element of an array

To check each element of an array you can simply use `Rule#each` shortcut. It works just like a normal rule, which means it's only applied when a value passed schema checks and supports setting failure messages in the standard way.

Here's a simple example:

``` ruby
class NewUserContract < Dry::Validation::Contract
  params do
    required(:email).value(:string)
    optional(:phone_numbers).array(:string)
  end

  rule(:phone_numbers).each do
    key.failure('is not valid') unless value.start_with?('00-')
  end
end

contract = NewUserContract.new

contract.call(email: 'jane@doe.org', phone_numbers: nil).errors.to_h
# => {:phone_numbers=>["must be an array"]}

contract.call(email: 'jane@doe.org', phone_numbers: ['00-123-456-789', nil]).errors.to_h
# => {:phone_numbers=>{1=>["must be a string"]}}

contract.call(email: 'jane@doe.org', phone_numbers: ['00-123-456-789', '987-654-321']).errors.to_h
# => {:phone_numbers=>{1=>["is not valid"]}}
```
