---
title: Struct
layout: gem-single
name: dry-validation
---

This extension allows schema to use `dry-struct`

``` ruby
Dry::Validation.load_extensions(:struct)

class Name < Dry::Struct::Value
  attribute :given_name, Dry::Types['strict.string']
  attribute :family_name, Dry::Types['strict.string']
end

class Person < Dry::Struct::Value
  attribute :name, Name
end

Dry::Validation.Schema do
  required(:person).filled(Person)
end
```

As shown in the previous example, it also works with nested struct.
