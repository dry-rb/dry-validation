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

> Curious about that `option` method that we used to set `today` value? You can learn about it in [the external dependencies](docs::external-dependencies) section.

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

The `key?` method supports passing an explicit key name for rules that have multiple keys.

```ruby
class DistanceContract < Dry::Validation::Contract
  schema do
    optional(:kilometers).value(:integer)
    optional(:miles).value(:integer)
  end

  rule(:kilometers, :miles) do
    if key?(:kilometers) && key?(:miles)
      base.failure("must only contain one of: kilometers, miles")
    end
  end
end
```

### Checking for previous errors

Sometimes you may be interested in adding an error when some other error has happened.

With `#schema_error?(key)` you can check whether the schema has an error for a given key:

```ruby
class PersonContract < Dry::Validation::Contract
  schema do
    required(:email).filled(:string)
    required(:name).filled(:string)
  end

  rule(:name) do
    key.failure('first introduce a valid email') if schema_error?(:email)
  end
end

PersonContract.new.(email: nil, name: 'foo').errors.to_h
# { email: ['must be a string'], name: ['first introduce a valid email'] }
```

In complex rules you may be interested to know whether the current rule already had an error. For that, you can use `#rule_error?`

```ruby
class FooContract < Dry::Validation::Contract
  schema do
    required(:foo).filled(:string)
  end

  rule(:foo) do
    key.failure('failure added')
    key.failure('failure added after checking') if rule_error?
  end
end

FooContract.new.(foo: 'foo').errors.to_h
# { foo: ['failure added', 'failure added after checking'] }
```

Also it is possible for checking other rule error by passing explicit argument to `rule_error?` method

```ruby
class PersonContract < Dry::Validation::Contract
  schema do
    required(:email).filled(:string)
    required(:name).filled(:string)
  end

  rule(:name) do
    key.failure('name rule error')
  end

  rule(:email) do
    key.failure('email rule error') if rule_error?(:name)
  end
end

PersonContract.new.call(email: 'bar', name: 'foo').errors.to_h
# {name: ['name rule error'], email: ['email rule error']}
```

If you want to check if any base rule error has already occured, you can use `base_rule_error?`.

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

  rule do 
    base.failure('base failure added after checking') if base_rule_error?
  end
end

contract = EventContract.new
contract.call(start_date: Date.today+1, end_date: Date.today+2).errors.to_h
# => {nil=>["creating events is allowed only on weekdays", "base failure added after checking"]}
```

### Rules context

Rules context is convenient for sharing data between rules or return data in the validation result. It can be used, for example, to return the data that was fetched from DB.

For example:

```ruby
class UpdateUserContract < Dry::Validation::Contract
  option :user_repo, optional: true

  params do
    required(:user_id).filled(:string)
  end

  rule(:user_id) do |context:|
    context[:user] ||= user_repo.find(value)
    key.failure(:not_found) unless context[:user]
  end
end

contract = UpdateUserContract.new(user_repo: UserRepo.new)
contract.call(user_id: 42).context.each.to_h
# => {user: #<User id: 42>}
```

Initial context can be passed as the second argument to the contract and in this case, the contract is not going to fetch user from the repo (we don't even need to pass the repo instance as a dependency because this code will not be executed here):

```ruby
user = UserRepo.new.find(42)
contract = UpdateUserContract.new
contract.call({user_id: 42}, user: user).context.each.to_h
# => {user: #<User id: 42>}
```

Also, default context can be provided on contract initialization:

```ruby
user = UserRepo.new.find(42)
contract = UpdateUserContract.new(default_context: {user: user})
contract.call(user_id: 42).context.each.to_h
# => {user: #<User id: 42>}
```

Context passed to the `call` method overrides keys from `default_context`.

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

When using `Rule#each` you have access to the `index` of each member, it is useful if you want to change the key of the returned errors, here's an example:

```ruby
class PropsContract < Dry::Validation::Contract
  params do
    required(:contacts).value(:array, min_size?: 1).each do
      hash do
        required(:name).filled(:string)
        required(:email).filled(:string)
        required(:phone).filled(:string)
      end
    end
  end

  rule(:contacts).each do |index:|
    key([:contacts, :email, index]).failure('email not valid') unless value[:email].include?('@')
  end
end

contract = PropsContract.new

contract.call(
  contacts: [
    { name: 'Jane', email: 'jane@doe.org', phone: '123' },
    { name: 'John', email: 'oops', phone: '123' }
  ]
).errors.to_h
# => {:contacts=>{:email=>{1=>["email not valid"]}}}
```
