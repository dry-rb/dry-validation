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

## The DSL

The core of `dry-validation` is rules composition and predicate logic. The DSL
is a simple front-end for that. It only allows you to define the rules by using
predicate identifiers. There are no magical options, conditionals and custom
validation blocks known from other libraries. The focus is on pure validation
logic.

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

errors = schema.messages(email: 'jane@doe.org', age: 19)

puts errors.inspect
# []

errors = schema.messages(email: nil, age: 19)

puts errors.inspect
# [[:email, ["email must be filled"]]]
```

A couple of remarks:

* `key` assumes that we want to use the `:key?` predicate to check the existance of that key
* `age.gt?(18)` translates to calling a predicate like this: `schema[:gt?].(18, age)`
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
    address.hash? do
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
end

schema = Schema.new

errors = schema.messages({})

puts errors.inspect
# [[:address, ["address is missing"]]]

errors = schema.messages(address: { city: 'NYC' })

puts errors.inspect
# [[:address, [[:street, ["street is missing"]], [:country, ["country is missing"]]]]]
```

### Array Elements

You can use `each` rule for validating each element in an array:

``` ruby
class Schema < Dry::Validation::Schema
  key(:phone_numbers) do |phone_numbers|
    phone_numbers.array? do
      phone_numbers.each(&:str?)
    end
  end
end

schema = Schema.new

errors = schema.messages(phone_numbers: '')

puts errors.inspect
# [[:phone_numbers, ["phone_numbers must be an array"]]]

errors = schema.messages(phone_numbers: ['123456789', 123456789])

puts errors.inspect
# [[:phone_numbers, [[:phone_numbers, ["phone_numbers must be a string"]]]]]
```

### Form Validation With Coercions

Probably the most common use case is to validate form params. This is a special
kind of a validation for a couple of reasons:

* The input is a hash with stringified keys
* The input include values that are strings, hashes or arrays
* Prior validation, we need to coerce values and symbolize keys based on the
  information from rules

For that reason, `dry-validation` ships with `Schema::Form` class:

``` ruby
require 'dry-validation'
require 'dry/validation/schema/form'

class UserFormSchema < Dry::Validation::Schema::Form
  key(:email) { |value| value.str? & value.filled? }

  key(:age) { |value| value.int? & value.gt?(18) }
end

schema = UserFormSchema.new

errors = schema.messages('email' => '', 'age' => '18')

puts errors.inspect

# [[:email, ["email must be filled"]], [:age, ["age must be greater than 18 (18 was given)"]]]
```

There are few major differences between how it works here and in `ActiveModel`:

* We have type checking as predicates, ie `gt?(18)` will not be applied if the value
  is not an integer
* Thus, error messages are provided *only for the rules that failed*
* There's a planned feature for generating "validation hints" which lists information
  about all possible rules
* Coercion is handled by `dry-data` coercible hash using its `form.*` types that
  are dedicated for this type of coercions
* It's very easy to add your own types and coercions (more info/docs coming soon)

### Defining Custom Predicates

You can simply define predicate methods on your schema object:

``` ruby
class Schema < Dry::Validation::Schema
  key(:email) { |value| value.str? & value.email? }

  def email?(value)
    ! /magical-regex-that-matches-emails/.match(value).nil?
  end
end
```

You can also re-use a predicate container across multiple schemas:

``` ruby
module MyPredicates
  include Dry::Validation::Predicates

  predicate(:email?) do |input|
    ! /magical-regex-that-matches-emails/.match(value).nil?
  end
end

class Schema < Dry::Validation::Schema
  configure do |config|
    config.predicates = MyPredicates
  end

  key(:email) { |value| value.str? & value.email? }
end
```

You need to provide error messages for your custom predicates if you want them
to work with `Schem#messages` interface.

You can learn how to do that in the [Error Messages](https://github.com/dryrb/dry-validation#error-messages) section.

## List of Built-In Predicates

* `array?`
* `empty?`
* `eql?`
* `exclusion?`
* `filled?`
* `format?`
* `gt?`
* `gteq?`
* `hash?`
* `inclusion?`
* `int?`
* `key?`
* `lt?`
* `lteq?`
* `max_size?`
* `min_size?`
* `nil?`
* `size?`
* `str?`

## Error Messages

By default `dry-validation` comes with a set of pre-defined error messages for
every built-in predicate. They are defined in [a yaml file](https://github.com/dryrb/dry-validation/blob/master/config/errors.yml)
which is shipped with the gem.

You can provide your own messages and configure your schemas to use it like that:

``` ruby
class Schema < Dry::Validation::Schema
  configure { |config| config.messages_file = '/path/to/my/errors.yml' }
end
```

You can also provide a namespace per-schema that will be used by default:

``` ruby
class Schema < Dry::Validation::Schema
  configure { |config| config.namespace = :user }
end
```

Lookup rules:

``` yaml
filled?: "%{name} must be filled"

attributes:
  email:
    filled?: "the email is missing"

user:
  filled?: "%{name} name cannot be blank"

  attributes:
    address:
      filled?: "You gotta tell us where you live"
```

Given the yaml file above, messages lookup works as follows:

``` ruby
messages = Dry::Validation::Messages.load('/path/to/our/errors.yml')

messages.lookup(:filled?, :age) # => "age must be filled"
messages.lookup(:filled?, :address) # => "address must be filled"
messages.lookup(:filled?, :email) # => "the email is missing"

# with namespaced messages
user_messages = messages.namespaced(:user)

user_messages.lookup(:filled?, :age) # "age cannot be blank"
user_messages.lookup(:filled?, :address) # "You gotta tell us where you live"
```

By configuring `messages_file` and/or `namespace` in a schema, default messages
are going to be automatically merged with your overrides and/or namespaced.

## I18n Integration

Coming (very) soon...

## Rule AST

Internally, `dry-validation` uses a simple AST representation of rules and errors
to produce rule objects and error messages. If you would like to programatically
generate rules, it is a very simple process:

``` ruby
ast = [
  [
    :and,
    [
      [:key, [:age, [:predicate, [:key?, []]]]],
      [
        :and,
        [
          [:val, [:age, [:predicate, [:filled?, []]]]],
          [:val, [:age, [:predicate, [:gt?, [18]]]]]
        ]
      ]
    ]
  ]
]

compiler = Dry::Validation::RuleCompiler.new(Dry::Validation::Predicates)

# compile an array of rule objects
rules = compiler.call(ast)

puts rules.inspect
# [
#   #<Dry::Validation::Rule::Conjunction
#     left=#<Dry::Validation::Rule::Key name=:age predicate=#<Dry::Validation::Predicate id=:key?>>
#     right=#<Dry::Validation::Rule::Conjunction
#       left=#<Dry::Validation::Rule::Value name=:age predicate=#<Dry::Validation::Predicate id=:filled?>>
#       right=#<Dry::Validation::Rule::Value name=:age predicate=#<Dry::Validation::Predicate id=:gt?>>>>
# ]

# dump it back to ast
puts rules.map(&:to_ary).inspect
# [[:and, [:key, [:age, [:predicate, [:key?, [:age]]]]], [[:and, [:val, [:age, [:predicate, [:filled?, []]]]], [[:val, [:age, [:predicate, [:gt?, [18]]]]]]]]]]
```

Complete docs for the AST format are coming soon, for now please refer to
[this spec](https://github.com/dryrb/dry-validation/blob/master/spec/unit/rule_compiler_spec.rb).

## Status and Roadmap

This library is in a very early stage of development but you are encauraged to
try it out and provide feedback.

For planned features check out [the issues](https://github.com/dryrb/dry-validation/labels/feature).

## License

See `LICENSE` file.
