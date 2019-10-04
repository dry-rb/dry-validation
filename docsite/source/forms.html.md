---
title: Form Validation
layout: gem-single
name: dry-validation
---

Probably the most common use case is to validate form params. This is a special kind of a validation for a couple of reasons:

* The input is a hash with stringified keys
* The input can include values that are strings, hashes or arrays
* Prior to validation, we need to coerce values and symbolize keys based on the information in the rules

For that reason, `dry-validation` ships with `Params` validation:

``` ruby
schema = Dry::Validation.Params do
  required(:email).filled(:str?)

  required(:age).filled(:int?, gt?: 18)
end

errors = schema.call('email' => '', 'age' => '18').messages

puts errors.inspect
# {
#   :email => ["must be filled"],
#   :age => ["must be greater than 18"]
# }
```

> Form-specific value coercion is handled by a hash-schema using `dry-types`. It is built automatically for you based on the type expectations and used prior to applying the validation rules.

## Handling Empty Strings

Your schema will automatically coerce empty strings to `nil` provided that you allow a value to be nil:

``` ruby
schema = Dry::Validation.Params do
  required(:email).filled(:str?)

  required(:age).maybe(:int?, gt?: 18)
end

result = schema.call('email' => 'jane@doe.org', 'age' => '')

puts result.output
# {:email=>'jane@doe.org', :age=>nil}
```
