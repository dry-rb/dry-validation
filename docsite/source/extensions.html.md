---
title: Extensions
layout: gem-single
name: dry-validation
---

### Monads

The monads extension makes `Dry::Validation::Result` objects compatible with `dry-monads`.

To enable the extension:

```ruby
require 'dry/validation'

Dry::Validation.load_extensions(:monads)
```

After loading the extension, you can leverage monad API:

``` ruby
class MyContract < Dry::Validation::Contract
  params do
    required(:name).filled(:string)
  end
end

my_contract = MyContract.new

my_contract.(name: "")
  .to_monad
  .fmap { |r| puts "passed: #{r.to_h.inspect}" }
  .or   { |r| puts "failed: #{r.errors.to_h.inspect}" }
```

### Predicates as macros

This extension makes [`dry-logic` predicates](https://dry-rb.org/gems/dry-logic/1.0/predicates/) which are concerned with data values (in opposition with types) available as macros for validation rules.

Besides enabling the extension, you have to call `import_predicates_as_macros` before being able to use them:

```ruby
require 'dry/validation'

Dry::Validation.load_extensions(:predicates_as_macros)

class ApplicationContract < Dry::Validation::Contract
  import_predicates_as_macros
end

class AgeContract < ApplicationContract
  schema do
    required(:age).filled(:integer)
  end

  rule(:age).validate(gteq?: 18)
end

AgeContract.new.(age: 17).errors.first.text
# => 'must be greater than or equal to 18'
```
