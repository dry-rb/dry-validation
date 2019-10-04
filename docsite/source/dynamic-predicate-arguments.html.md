---
title: Dynamic Predicate Arguments
layout: gem-single
name: dry-validation
---

It's often the case that arguments that are passed to predicates are not known in the moment of defining a schema rules. If you need to calculate some arguments dynamically at run-time, you can simply define methods in your schema and refer to them in the DSL:

``` ruby
DataSchema = Dry::Validation.Schema do
  configure do
    def data
      %w(a b c)
    end
  end

  required(:letter).filled(included_in?: data)
end

DataSchema.(letter: 'f').messages
# {:letter=>["must be one of: a, b, c"]}
```
