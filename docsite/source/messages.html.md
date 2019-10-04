---
title: Messages
layout: gem-single
name: dry-validation
---

Messages in failure API can be set in 4 different ways:

- By passing a message string explicitly - the simplest way; however, using locales is a cleaner solution even if you don't have a multi-language system
- By passing a message `identifier` that will be used to retrieve a corresponding message template that will be evaluated using provided (optional) data
- By passing a hash with message text and arbitrary meta-data - this can be useful when you want to provide additional information in addition to message text, ie error codes etc.

> Examples in this section will use `key` failures exclusively, but keep in mind that the exact same API is available when you use `base` failures

### Explicit messages

To set a failure message explicitly, pass a message string:

```ruby
class NewUserContract < Dry::Validation::Contract
  params do
    required(:age).value(:integer)
  end

  rule(:age) do
    key.failure('must be greater than 18') if values[:age] < 18
  end
end

contract = NewUserContract.new

contract.call(age: 17).errors.to_h
# => {:age=>["must be greater than 18"]}
```

### Passing additional meta-data

If you want to set additional meta-data, pass a hash with `:text` key:

```ruby
class NewUserContract < Dry::Validation::Contract
  params do
    required(:age).value(:integer)
  end

  rule(:age) do
    key.failure(text: 'must be greater than 18', code: 123) if values[:age] < 18
  end
end

contract = NewUserContract.new

contract.call(age: 17).errors.to_h
# => {:age=>[{:text=>"must be greater than 18", :code=>123}]}
```

### Using localized messages backend

If you enable the `:i18n` or `:yaml` messages backend in the [configuration](/gems/dry-validation/configuration), you can define messages in a yaml file and use their identifiers instead of plain strings. Here's a sample yaml with a message for our `age` error:

```yaml
en:
  dry_validation:
    errors:
      rules:
        age:
          invalid: 'must be greater than 18'
```

Provided we [configure our contract to use a custom messages file](/gems/dry-validation/1.0/configuration#example), we can now write this:

```ruby
class NewUserContract < Dry::Validation::Contract
  params do
    required(:age).value(:integer)
  end

  rule(:age) do
    key.failure(:invalid) if values[:age] < 18
  end
end

contract = NewUserContract.new

contract.call(age: 17).errors.to_h
# => {:age=>["must be greater than 18"]}
```

> Schema messages **use the same top-level namespace** as rule messages, remember about this if you want to customize messages for schema predicate failures.

### Learn more

- [Rules with key and base failures](/gems/dry-validation/1.0/rules#key-failures)
