[gem]: https://rubygems.org/gems/dry-validation
[travis]: https://travis-ci.org/dryrb/dry-validation
[gemnasium]: https://gemnasium.com/dryrb/dry-validation
[codeclimate]: https://codeclimate.com/github/dryrb/dry-validation
[coveralls]: https://coveralls.io/r/dryrb/dry-validation
[inchpages]: http://inch-ci.org/github/dryrb/dry-validation

# dry-validation [![Join the chat at https://gitter.im/dryrb/chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dryrb/chat)

[![Gem Version](https://badge.fury.io/rb/dry-validation.svg)][gem]
[![Build Status](https://travis-ci.org/dryrb/dry-validation.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/dryrb/dry-validation.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/dryrb/dry-validation/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/dryrb/dry-validation/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/dryrb/dry-validation.svg?branch=master)][inchpages]

Data validation library based on predicate logic and rule composition.

## Overview

Unlike other, well known, validation solutions in Ruby, `dry-validation` takes
a different approach and focuses a lot on explicitness, clarity and preciseness
of validation logic. It is designed to work with any data input, whether it's a
simple hash, an array or a complex object with deeply nested data.

It is based on an idea that each validation is encapsulated by a simple,
stateless predicate, that receives some input and returns either `true` or `false`.

Those predicates are encapsulated by `rules` which can be composed together using
`predicate logic`. This means you can use the common logic operators to build up
a validation `schema`.

Validations can be described with great precision, `dry-validation` eliminates
ambigious concepts like `presence` validation where we can't really say whether
some attribute or key is *missing* or it's just that the value is `nil`.

In `dry-validation` type-safety is a first-class feature, something that's completely
missing in other validation libraries, and it's an important and useful feature. It
means you can compose a validation that does rely on the type of a given value. In
example it makes no sense to validate each element of an array when it turns out to
be an empty string.

## The DSL

The core of `dry-validation` is rule composition and predicate logic provided by
[dry-logic](https://github.com/dryrb/dry-logic). The DSL is a simple front-end
for it. It only allows you to define the rules by using predicate identifiers.
There are no magical options, conditionals and custom validation blocks known from
other libraries. The focus is on pure validation logic expressed in a concise way.

The DSL is very abstract, it builds [a rule AST](https://github.com/dryrb/dry-validation/wiki/Rule-AST)
which is compiled into an array of rule objects. This means alternative interfaces could
be easily build.

## When To Use?

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

## Synopsis

Please refer to [the wiki](https://github.com/dryrb/dry-validation/wiki) for full usage documentation.

``` ruby
class UserSchema < Dry::Validation::Schema
  key(:name) { |name| name.filled? }

  key(:email) { |email| email.filled? & email.format?(EMAIL_REGEX) }

  key(:age) { |age| age.none? | age.int? }

  key(:address) do |address|
   address.key(:street, &:filled?)
   address.key(:city, &:filled?)
   address.key(:zipcode, &:filled?)
  end
end
```

## Status and Roadmap

This library is in an early stage of development but you are encouraged to
try it out and provide feedback.

For planned features check out [the issues](https://github.com/dryrb/dry-validation/labels/feature).

## License

See `LICENSE` file.
