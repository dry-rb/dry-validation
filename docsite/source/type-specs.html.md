---
title: Explicit type specs
layout: gem-single
name: dry-validation
---

Default behavior for coercions is to automatically infer it from rule definitions. It’s smart and reduces code duplication; however, it turned out to be extremely slow. Furthermore, it is an implicit behavior that we don’t really like. That’s why it’s been decided that we’ll be separating coercions from validation rules for 1.0.0. This release is the first step in that direction. Final API is not yet discovered, ideas and feedback are much appreciated!

To enable explicit type specifications, which will be used to configure coercion, you need to configure your schema:

``` ruby
UserSchema = Dry::Validation.Params do
  # enable type specs
  configure { config.type_specs = true }

  # now you can explicitly define types
  required(:login, :string).filled(:str?, min_size?: 3)

  # you can define more than one type
  required(:age, [:nil, :integer]).maybe(:int?, gt?: 18)

  # array with member type is supported too
  required(:nums, [:integer]).value(size?: 3)

  # dry-types can be used too
  required(:login_time, Types::Params::DateTime).filled(:date_time?)
end
```

As you can see, with this style there’s more verbosity, however there are 2 big advantages:

* Defining a schema like that is roughly ~85 x faster - if you’ve got a big, REALLY BIG schema, you will benefit from this
* We make it clear that coercion is a separate process from applying validation rules

At the first glance, it’s tempting to say that we can easily infer validations *from type specs*; unfortunately it’s not as simple as it seems. Validation rules can branch differently depending on the actual type that coercion returned, and this makes things tricky.

We’ll be experimenting with various ways of making the API as concise as possible, but for now please try to use this feature. If code duplication is a problem, we added a new feature for defining custom macros so that you can encapsulate common definitions easily!
