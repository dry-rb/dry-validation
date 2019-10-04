---
title: Macros
layout: gem-single
name: dry-validation
---

Rule composition using blocks is very flexible and powerful; however, in many common cases repeatedly defining the same rules leads to boilerplate code. That's why `dry-validation`'s DSL provides convenient macros to reduce that boilerplate. Every macro can be expanded to its block-based equivalent.

This document describes available built-in macros.

### filled

Use it when a value is expected to be filled. "filled" means that the value is non-nil and, in the case of a `String`, `Hash`, or `Array` value, that the value is not `.empty?`.

``` ruby
Dry::Validation.Schema do
  # expands to `required(:age) { filled? }`
  required(:age).filled
end
```

``` ruby
Dry::Validation.Schema do
  # expands to `required(:age) { filled? & int? }`
  required(:age).filled(:int?)
end
```

### maybe

Use it when a value can be nil.

``` ruby
Dry::Validation.Schema do
  # expands to `required(:age) { none?.not > int? }`
  required(:age).maybe(:int?)
end
```

### each

Use it to apply predicates to every element in a value that is expected to be an array.

``` ruby
Dry::Validation.Schema do
  # expands to: `required(:tags) { array? { each { str? } } }`
  required(:tags).each(:str?)
end
```

### when

Use it when another rule depends on the state of a value:

``` ruby
Dry::Validation.Schema do
  # expands to:
  #
  # rule(email: [:login]) { |login| login.true?.then(value(:email).filled?) }
  #
  required(:email).maybe

  required(:login).filled(:bool?).when(:true?) do
    value(:email).filled?
  end
end
```

> Learn more about [high-level rules](/gems/dry-validation/0.13/high-level-rules)

### confirmation

Use confirmation to assert that an identical value in the sample is mapped to the same key suffixed with `_confirmation`.

``` ruby
Dry::Validation.Schema do
  # expands to:
  #
  # rule(password_confirmation: [:password]) do |password|
  #   value(:password_confirmation).eql?(password)
  # end
  #
  required(:password).filled(min_size?: 12).confirmation
end
```
