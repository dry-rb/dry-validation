---
title: Macros
layout: gem-single
name: dry-validation
---

> This is **an experimental feature** and its API may change before 2.0.0

Macros are a simple way of streamlining rule definitions. Whenever you find yourself repeating the exact same type of validation rules, consider defining a macro to reduce duplication. You can either define globally available macros for all contracts, or a per-class macros where the class and its descandants will be able to access them.

### Defining a global macro

To define a global macro you can use `Dry::Validation.register_macro` API. Here's a simple example where we define a macro that checks format of a string:

``` ruby
Dry::Validation.register_macro(:email_format) do
  unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
    key.failure('not a valid email format')
  end
end
```

### Defining a macro for a contract class

Unlike global macros, contract macros are only available to the class and its descendants. To define a contract class macro you can use `Dry::Validation::Contract.register_macro`. Here's the same example like above but we'll define a class macro:

``` ruby
class ApplicationContract < Dry::Validation::Contract
  register_macro(:email_format) do
    unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
      key.failure('not a valid email format')
    end
  end
end
```

### Using a macro with rules

To define a rule that will apply a macro, simply use `Rule#validate` method:

```ruby
class NewUserContract < ApplicationContract
  params do
    required(:email).filled(:string)
  end

  rule(:email).validate(:email_format)
end
```

### Macro with options

If you want a macro to be parameterized, you can achieve that by passing a hash with options where the keys are macro identifiers. This way you will have access to macro arguments in the rule block. Here's an example how we could define a macro that checks a minimum size of an array, where we pass the minimum size as an option.

First, let's define a `:min_size` macro. Notice that we use a `macro` parameter in the block, which is the instance of our macro that gives us access to its `args`:

```ruby
class ApplicationContract < Dry::Validation::Contract
  register_macro(:min_size) do |macro:|
    min = macro.args[0]
    key.failure("must have at least #{min} elements") unless value.size >= min
  end
end
```

With the macro defined, you can simply use this with `Rule#validate`:

```ruby
class NewUserContract < ApplicationContract
  params do
    required(:phone_numbers).value(:array)
  end

  rule(:email).validate(min_size: 1)
end
```