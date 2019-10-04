---
title: Error Messages
layout: gem-single
name: dry-validation
---

By default `dry-validation` comes with a set of pre-defined error messages for every built-in predicate. They are defined in [a yaml file](https://github.com/dry-rb/dry-validation/blob/master/config/errors.yml) which is shipped with the gem. This file is compatible with `I18n` format.

You can provide your own messages and configure your schemas to use it like that:

``` ruby
schema = Dry::Validation.Schema do
  configure { config.messages_file = '/path/to/my/errors.yml' }
end
```

You can also provide a namespace per-schema that will be used by default:

``` ruby
schema = Dry::Validation.Schema do
  configure { config.namespace = :user }
end
```

Lookup rules:

``` yaml
en:
  errors:
    size?:
      arg:
        default: "size must be %{num}"
        range: "size must be within %{left} - %{right}"

      value:
        string:
          arg:
            default: "length must be %{num}"
            range: "length must be within %{left} - %{right}"

    filled?: "must be filled"

    included_in?: "must be one of %{list}"
    excluded_from?: "must not be one of: %{list}"

    rules:
      email:
        filled?: "the email is missing"

      user:
        filled?: "name cannot be blank"

        rules:
          address:
            filled?: "You gotta tell us where you live"
```

Given the yaml file above, messages lookup works as follows:

``` ruby
messages = Dry::Validation::Messages::YAML.load(%w(/path/to/our/errors.yml))

# matching arg type for size? predicate
messages[:size?, rule: :name, arg_type: Fixnum] # => "size must be %{num}"
messages[:size?, rule: :name, arg_type: Range] # => "size must be within %{left} - %{right}"

# matching val type for size? predicate
messages[:size?, rule: :name, val_type: String] # => "length must be %{num}"

# matching predicate
messages[:filled?, rule: :age] # => "must be filled"
messages[:filled?, rule: :address] # => "must be filled"

# matching predicate for a specific rule
messages[:filled?, rule: :email] # => "the email is missing"

# with namespaced messages
user_messages = messages.namespaced(:user)

user_messages[:filled?, rule: :age] # "cannot be blank"
user_messages[:filled?, rule: :address] # "You gotta tell us where you live"
```

By configuring `messages_file` and/or `namespace` in a schema, default messages are going to be automatically merged with your overrides and/or namespaced.

## I18n Integration

If you are using `i18n` gem and load it before `dry-validation` then you'll be able to configure a schema to use `i18n` messages:

``` ruby
require 'i18n'
require 'dry-validation'

schema = Dry::Validation.Schema do
  configure { config.messages = :i18n }

  required(:email).filled
end

# return default translations
schema.call(email: '').messages
{ :email => ["must be filled"] }

# return other translations (assuming you have it :))
puts schema.call(email: '').messages(locale: :pl)
{ :email => ["musi być wypełniony"] }
```

Important: I18n must be initialized before using a schema, `dry-validation` does not try to do it for you, it only sets its default error translations automatically.

## Full Messages

By default, messages do not include a rule's name, if you want it to be included simply use `:full` option:

``` ruby
schema.call(email: '').messages(full: true)
{ :email => ["email must be filled"] }
```

## Finding the right key

`dry-validation` has one error key for each kind of validation (Refer to [`errors.yml`](https://github.com/dry-rb/dry-validation/blob/master/config/errors.yml) for the full list). `key?` and `filled?` can usually be mistaken for eachother, so pay attention to them:

- `key?`: a required parameter is missing in the `params` hash.
- `filled?`: a required parameter is in the `params` hash but has an empty value.
