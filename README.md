# dry-validation <a href="https://gitter.im/dryrb/chat" target="_blank">![Join the chat at https://gitter.im/dryrb/chat](https://badges.gitter.im/Join%20Chat.svg)</a>

<a href="https://rubygems.org/gems/dry-validation" target="_blank">![Gem Version](https://badge.fury.io/rb/dry-validation.svg)</a>
<a href="https://travis-ci.org/dryrb/dry-validation" target="_blank">![Build Status](https://travis-ci.org/dryrb/dry-validation.svg?branch=master)</a>
<a href="https://gemnasium.com/dryrb/dry-validation" target="_blank">![Dependency Status](https://gemnasium.com/dryrb/dry-validation.svg)</a>
<a href="https://codeclimate.com/github/dryrb/dry-validation" target="_blank">![Code Climate](https://codeclimate.com/github/dryrb/dry-validation/badges/gpa.svg)</a>
<a href="http://inch-ci.org/github/dryrb/dry-validation" target="_blank">![Documentation Status](http://inch-ci.org/github/dryrb/dry-validation.svg?branch=master&style=flat)</a>

Data validation library based on predicate logic and rule composition.

## Overview

Unlike other, well known, validation solutions in Ruby, `dry-validation` takes
a different approach and focuses a lot on explicitness, clarity and preciseness
of validation logic. It is designed to work with any data input, whether it's a
simple hash, an array or a complex object with deeply nested data.

It is based on a simple idea that each validation is encapsulated by a simple,
stateless predicate, that receives some input and returns either `true` or `false`.

Those predicates are encapsulated by `rules` which can be composed together using
`predicate logic`. This means you can use the common logic operators to build up
a validation `schema`.

It's very explicit, powerful and extendible.

Validations can be described with great precision, `dry-validation` eliminates
ambigious concepts like `presence` validation where we can't really say whether
some attribute or key is *missing* or it's just that the value is `nil`.

There's also the concept of type-safety, completely missing in other validation
libraries, which is quite important and useful. It means you can compose a validation
that does rely on the type of a given value. In example it makes no sense to validate
each element of an array when it turns out to be an empty string.

### The DSL

The core of `dry-validation` is rules composition and predicate logic. The DSL
is a simple front-end for that. It only allows you to define the rules by using
predicate identifiers. There are no magical options, conditionals and custom
validation blocks known from other libraries. The focus is on pure validation
logic.

### Error Messages

A default error message compiler is shipped with the library. It can use a configuration
hash which maps predicates to error messages. `Error::Set` object does not generate
error messages, it's only a source of information about the validation results.

## Examples

### Basic

Here's a basic example where we validate following things:

* The input *must have a key* called `:email`
  * Provided the email key is present, its value *must be filled*
* The input *must have a key* called `:age`
  * Provided the age key is present, its value *must be an integer* and it *must be greater than 18*

This can be easily expressed through the DSL:

``` ruby
require 'dry-validation'

class Schema < Dry::Validation::Schema
  key(:email) { |email| email.filled? }

  key(:age) do |age|
    age.int? & age.gt?(18)
  end
end

schema = Schema.new

puts errors.inspect
# #<Dry::Validation::Error::Set:0x007ff3e29626d8 @errors=[]>

errors = schema.(email: nil, age: 19)

puts errors.inspect
#<Dry::Validation::Error::Set:0x007f80ac198a00 @errors=[#<Dry::Validation::Error:0x007f80ac193aa0 @result=#<Dry::Validation::Result::Value success?=false input=nil rule=#<Dry::Validation::Rule::Value name=:email predicate=#<Dry::Validation::Predicate id=:filled?>>>>]>
```

A couple of remarks:

* `key` assumes that we want to use the `:key?` predicate to check the existance of that key
* `age.gt?(18)` translates to `Dry::Validation::Predicates.gt?(18, age)`
* `age.int? & age.gt?(18)` is a conjunction, so we don't bother about `gt?` unless `int?` returns `true`
* You can also use `|` for disjunction
* Schema object does not carry the input as its state, nor does it know how to access the input values, we
  pass the input to `call` and get error set as the response

### Nested Hash

We are free to define validations for anything, including deeply nested structures:

``` ruby
require 'dry-validation'

class Schema < Dry::Validation::Schema
  key(:address) do |address|
    address.key(:city) do |city|
      city.min_size?(3)
    end

    address.key(:street) do |street|
      street.filled?
    end

    address.key(:country) do |country|
      country.key(:name, &:filled?)
      country.key(:code, &:filled?)
    end
  end
end

schema = Schema.new

errors = schema.({})

puts errors.inspect
#<Dry::Validation::Error::Set:0x007fc4f89c4360 @errors=[#<Dry::Validation::Error:0x007fc4f89c4108 @result=#<Dry::Validation::Result::Value success?=false input=nil rule=#<Dry::Validation::Rule::Key name=:address predicate=#<Dry::Validation::Predicate id=:key?>>>>]>

errors = schema.(address: { city: 'NYC' })

puts errors.inspect
#<Dry::Validation::Error::Set:0x007fd151189b18 @errors=[#<Dry::Validation::Error:0x007fd151188e20 @result=#<Dry::Validation::Result::Set success?=false input={:city=>"NYC"} rule=#<Dry::Validation::Rule::Set name=:address predicate=[#<Dry::Validation::Rule::Conjunction left=#<Dry::Validation::Rule::Key name=:city predicate=#<Dry::Validation::Predicate id=:key?>> right=#<Dry::Validation::Rule::Value name=:city predicate=#<Dry::Validation::Predicate id=:min_size?>>>, #<Dry::Validation::Rule::Conjunction left=#<Dry::Validation::Rule::Key name=:street predicate=#<Dry::Validation::Predicate id=:key?>> right=#<Dry::Validation::Rule::Value name=:street predicate=#<Dry::Validation::Predicate id=:filled?>>>, #<Dry::Validation::Rule::Conjunction left=#<Dry::Validation::Rule::Key name=:country predicate=#<Dry::Validation::Predicate id=:key?>> right=#<Dry::Validation::Rule::Set name=:country predicate=[#<Dry::Validation::Rule::Conjunction left=#<Dry::Validation::Rule::Key name=:name predicate=#<Dry::Validation::Predicate id=:key?>> right=#<Dry::Validation::Rule::Value name=:name predicate=#<Dry::Validation::Predicate id=:filled?>>>, #<Dry::Validation::Rule::Conjunction left=#<Dry::Validation::Rule::Key name=:code predicate=#<Dry::Validation::Predicate id=:key?>> right=#<Dry::Validation::Rule::Value name=:code predicate=#<Dry::Validation::Predicate id=:filled?>>>]>>]>>>]>
```

## Status and Roadmap

This library is in a very early stage of development but you are encauraged to
try it out and provide feedback.

For planned features check out [the issues](https://github.com/dryrb/dry-validation/labels/feature).

## License

See `LICENSE` file.
