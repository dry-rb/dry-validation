---
title: Basics
layout: gem-single
name: dry-validation
sections:
  - predicate-logic
  - built-in-predicates
  - macros
  - working-with-schemas
---

Here's a basic example where we validate the following things:

* The input *must have a key* called `:email`
  * Provided the email key is present, its value *must be filled*
* The input *must have a key* called `:age`
  * Provided the age key is present, its value *must be an integer* and it *must be greater than 18*

This can be easily expressed through the DSL:

``` ruby
require 'dry-validation'

schema = Dry::Validation.Schema do
  required(:email).filled(:str?)
  required(:age).filled(:int?, gt?: 18)
end

errors = schema.call(email: 'jane@doe.org', age: 19).messages

puts errors.inspect
# []

schema.call(email: nil, age: 19).messages
# { :email => ["must be filled"] }
```

Learn more:

  * [Predicate logic](/gems/dry-validation/0.13/basics/predicate-logic)
  * [Macros](/gems/dry-validation/0.13/basics/macros)
  * [Working With Schemas](/gems/dry-validation/0.13/basics/working-with-schemas)
