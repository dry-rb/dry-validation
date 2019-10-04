---
title: Predicate Logic
layout: gem-single
name: dry-validation
---

Schema DSL allows you to define validation rules using predicate logic. All common logic operators are supported and you can use them to **compose rules**. This simple technique is very powerful as it allows you to compose validations in such a way that invalid state will not crash one of your rules. Validation is a process that always depends on specific conditions, in that sense, `dry-validation` schemas have rules that are always conditional, they are executed only if defined conditions are met.

This document explains how rule composition works in terms of predicate logic.

### Conjunction (and)

``` ruby
Dry::Validation.Schema do
  required(:age) { int? & gt?(18) }
end
```

`:age` rule is successful when both predicates return `true`.

### Disjunction (or)

``` ruby
Dry::Validation.Schema do
  required(:age) { none? | int? }
end
```

`:age` rule is successful when either of the predicates, or both return `true`.

### Implication (then)

``` ruby
Dry::Validation.Schema do
  required(:age) { filled? > int? }
end
```

`:age` rule is successful when `filled?` returns `false`, or when both predicates return `true`.

> [Optional keys](/gems/dry-validation/0.13/optional-keys-and-values) are defined using `implication`, that's why a missing key will not cause its rules to be applied and the whole key rule will be successful

### Exclusive Disjunction (xor)

``` ruby
Dry::Validation.Schema do
  required(:eat_cookie).filled
  required(:have_cookie).filled

  rule(be_reasonable: [:eat_cookie, :have_cookie]) do |eat_cookie, have_cookie|
    eat_cookie.eql?('yes') ^ have_cookie.eql?('yes')
  end
end
```

`:be_reasonable` rule is only successful when one of the values equals to `yes`.

> Learn more about [high-level rules](/gems/dry-validation/0.13/high-level-rules)

## Operator Aliases

Logic operators are actually aliases, use full method names at your own convenience:

* `and` => `&`
* `or` => `|`
* `then` => `>`
* `xor` => `^`
