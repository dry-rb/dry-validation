---
title: Introduction
description: Powerful data validation
layout: gem-single
type: gem
name: dry-validation
sections:
  - configuration
  - schemas
  - rules
  - messages
  - macros
  - external-dependencies
  - extensions
---

dry-validation is a data validation library that provides a powerful DSL for defining schemas and validation rules.

Validations are expressed through contract objects. A contract specifies a schema with basic type checks and any additional rules that should be applied. Contract rules are applied only once the values they rely on have been succesfully verified by the schema.

### Unique features

There are a couple of unique features that make `dry-validation` stand out from the crowd:

- Strict, explicit data schemas are separated from the domain validation logic - this allows you define validation rules that are **type safe** and focus exclusively on validation logic. This in turn makes rule code much simpler and easier to understand
- Schemas are powered by [`dry-schema`](/gems/dry-schema) which **sanitizes, coerces and type-checks** the input for you
- Contracts support defining macros, which can **significantly reduce code duplication** in your rules
- Plays nice with dependency injection, using either `option` API or automated approach via `dry-auto_inject`

### Quick start

Here's an example contract:

``` ruby
class NewUserContract < Dry::Validation::Contract
  params do
    required(:email).filled(:string)
    required(:age).value(:integer)
  end

  rule(:email) do
    unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
      key.failure('has invalid format')
    end
  end

  rule(:age) do
    key.failure('must be greater than 18') if value < 18
  end
end

contract = NewUserContract.new

contract.call(email: 'jane@doe.org', age: '17')
# #<Dry::Validation::Result{:email=>"jane@doe.org", :age=>17} errors={:age=>["must be greater than 18"]}>
```
