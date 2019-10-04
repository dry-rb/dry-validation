---
title: Optional Keys and Values
layout: gem-single
name: dry-validation
---

We make a clear distinction between specifying an optional `key` and an optional `value`. This gives you a way of being very specific about validation rules. You can define a schema which can give you precise errors when a key was missing or key was present but the value was nil.

This also comes with the benefit of being explicit about the type expectation. In the example below we explicitly state that `:age` *can be omitted* or if present it *must be an integer* and it *must be greater than 18*.

You can define which keys are optional and define rules for their values:

``` ruby
require 'dry-validation'

schema = Dry::Validation.Schema do
  required(:email).filled

  optional(:age).filled(:int?, gt?: 18)
end

errors = schema.call(email: 'jane@doe.org').messages

puts errors.inspect
# {}

errors = schema.call(email: 'jane@doe.org', age: 17).messages

puts errors.inspect
# { :age => ["must be greater than 18"] }
```

## Optional Values

When it is valid for a given value to be `nil` you can use `maybe` macro:

``` ruby
require 'dry-validation'

schema = Dry::Validation.Schema do
  required(:email).filled

  optional(:age).maybe(:int?, gt?: 18)
end

errors = schema.call(email: 'jane@doe.org', age: nil).messages

puts errors.inspect
# {}

errors = schema.call(email: 'jane@doe.org', age: 19).messages

puts errors.inspect
# {}

errors = schema.call(email: 'jane@doe.org', age: 17).messages

puts errors.inspect
# { :age => ["must be greater than 18"] }
```
