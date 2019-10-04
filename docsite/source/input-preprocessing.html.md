---
title: Input Preprocessing
layout: gem-single
name: dry-validation
---

Sometimes, the data coming from outside needs to be preprocessed before being validated. Think of extraneous spaces before or after a string, for example.

### Preprocessing names to remove spaces

In the context of a web application form, it is common to ask for people's names. The name should not contain spaces before or after the other characters. It would be possible to reject such strings as invalid, but that would make the application harder to use. Instead, we can let dry-validation preprocess the input to remove such spaces. To that end, we will create a new type of validator:

```ruby
require "dry-validation"

module Types
  include Dry::Types.module

  Name = Types::String.constructor do |str|
    str ? str.strip.chomp : str
  end
end

SignUpForm = Dry::Validation.Params do
  configure do
    config.type_specs = true
  end

  required(:email, :string).filled(format?: /.@.+[.][a-z]{2,}/i)
  required(:name, Types::Name).filled(min_size?: 1)
  required(:password, :string).filled(min_size?: 6)
end

result = SignUpForm.call(
  "name" => "\t François \n",
  "email" => "francois@teksol.info",
  "password" => "some password")

result.success?
# true

result[:name]
# "François"
```

The magic happens by using a new type, namely `Name`, and making the form use explicit type specs. The `Name` type constructor does the actual preprocessing.

When you use explicit type specs, you must specify the types you expect your values to be. That is why the email and password fields specify a string type. Luckily, dry-validation comes with the usual suspects pre-built, so you don't have to type `Types::String` long-hand.

**WARNING**: You have to remember that the input to type constructors may be hostile, which means being extra careful with the operations you do at this point.

### Preprocessing array elements

If you have a list of fields on your form and you wanted to exclude empty elements, you could also preprocess the array elements to exclude empty items:

```ruby
require "dry-validation"

module Types
  include Dry::Types.module

  Names = Types::Array.constructor do |elements|
    elements ? elements.map(&:to_s).map(&:chomp).map(&:strip).reject(&:empty?) : elements
  end
end

InvitationForm = Dry::Validation.Params do
  configure do
    config.type_specs = true
  end

  required(:friend_names, Types::Names).filled(:array?, min_size?: 1)
end

result = InvitationForm.call("friend_names" => ["François", ""])

result.success?
# true

result[:friend_names]
# ["François"]
```
