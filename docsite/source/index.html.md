---
title: Introduction
description: Powerful data validation based on predicate logic
layout: gem-single
type: gem
name: dry-validation
sections:
  - basics
  - predicates
  - optional-keys-and-values
  - nested-data
  - array-as-input
  - reusing-schemas
  - forms
  - high-level-rules
  - custom-validation-blocks
  - dynamic-predicate-arguments
  - input-preprocessing
  - type-specs
  - error-messages
  - comparison-with-activemodel
  - extensions
---

Unlike other, well known, validation solutions in Ruby, `dry-validation` takes a different approach and focuses a lot on explicitness, clarity and precision of validation logic. It is designed to work with any data input, whether it's a simple hash, an array or a complex object with deeply nested data.

It is based on the idea that each validation is encapsulated by a simple, stateless predicate that receives some input and returns either `true` or `false`.  Those predicates are encapsulated by `rules` which can be composed together using `predicate logic`. This means you can use the common logic operators to build up a validation `schema`.

Validations can be described with great precision, `dry-validation` eliminates ambiguous concepts like `presence` validation where we can't really say whether some attribute or key is *missing* or it's just that the value is `nil`.

In `dry-validation` type-safety is a first-class feature, something that's completely missing in other validation libraries, and it's an important and useful feature. It means you can compose a validation that relies on the type of a given value. For example it makes no sense to validate each element of an array when it turns out to be an empty string.

### The DSL

`dry-validation`'s rule composition and predicate logic is provided by [dry-logic](https://github.com/dry-rb/dry-logic). The DSL is a simple front-end for it. It allows you to define the rules by only using predicate identifiers.  There are no magical options, conditionals and custom validation blocks known from other libraries. The focus is on pure validation logic expressed in a concise way.

The DSL is very abstract, it builds a rule AST which is compiled into an array of rule objects. This means alternative interfaces could be easily built.

### When To Use?

Always and everywhere. This is a general-purpose validation library that can be used for many things and **it's multiple times faster** than `ActiveRecord`/`ActiveModel::Validations` *and* `strong-parameters`.

Possible use-cases include validation of:

* Form params
* "GET" params
* JSON documents
* YAML documents
* Application configuration (ie stored in ENV)
* Replacement for `ActiveRecord`/`ActiveModel::Validations`
* Replacement for `strong-parameters`
* etc.

### Synopsis

``` ruby
UserSchema = Dry::Validation.Schema do
  required(:name).filled

  required(:email).filled(format?: EMAIL_REGEX)

  required(:age).maybe(:int?)

  required(:address).schema do
    required(:street).filled
    required(:city).filled
    required(:zipcode).filled
  end
end

UserSchema.(
  name: 'Jane',
  email: 'jane@doe.org',
  address: { street: 'Street 1', city: 'NYC', zipcode: '1234' }
).inspect

# #<Dry::Validation::Result output={:name=>"Jane", :email=>"jane@doe.org", :address=>{:street=>"Street 1", :city=>"NYC", :zipcode=>"1234"}} messages={:age=>["age is missing"]}>
```
