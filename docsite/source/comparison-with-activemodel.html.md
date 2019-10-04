---
title: Comparison With ActiveModel
layout: gem-single
name: dry-validation
order: 10
---

As explained in the [introduction](/gems/dry-validation), dry-validation focuses on explicitness, clarity and precision of validation logic. For those of us used to ActiveModel validations with their numerous options, ifs, ons and unlesses, dry-validation is a way to make even the most complex validation cases easy to read and understand.

But, how would we go about converting our ActiveModel validation code into dry-validation?

After reading this guide, you will know:

- How to use dry-validation to replace built-in ActiveModel validation helpers.
- How to use dry-validation to create your own custom validation methods.

> Note that there isn't a one-to-one relationship between ActiveModel validators and Dry predicates. This guide shows you the closest matches, and highlights the differences where applicable.

> For the main documentation on dry-validation predicates, see [Built-in Predicates](/gems/dry-validation/0.13/basics/built-in-predicates).

## 1. Validation Overview

When using ActiveModel validation, validations are declared in the model in the following format:

`validates :name, :email, presence: true`

You then update the model's state and call `valid?` on the model to see if the state is correct.  (In the opinion of the dry-rb team, this is a design flaw of ActiveModel. See [this blog post](http://solnic.eu/2015/12/28/invalid-object-is-an-anti-pattern.html) for more information).

When using dry-validation, you declare your validation in a separate schema class using predicates to build up rules.

A predicate is a simple stateless method which receives some input and returns either `true` or `false`.

A simple schema can look like this:

```ruby
schema = Dry::Validation.Schema do
  required(:email).filled
  required(:name).filled
end
```

## 2. Validation Helpers

### 2.1 acceptance

In ActiveModel validations this helper is used to validate that a checkbox on the user interface was checked when a form was submitted. This is typically used when the user needs to agree to your application's terms of service, confirm reading some text, or any similar concept.

In its simplest form:

**ActiveModel Validation**

```ruby
validates :attr, acceptance: true
```

**dry-validation**

```ruby
required(:attr).filled(:bool?, :true?)
```

When using the `:accepts` option:

**ActiveModel Validation**

```ruby
validates :attr, acceptance: { accept: 'yes' }
```

**dry-validation**

```ruby
required(:attr).filled(eql?: 'yes')
```

> Note: ActiveModel automatically creates a virtual acceptance attribute for you. If you are using Protected Parameters you will need to add this attribute yourself.

### 2.2 validates_associated

This validates whether the associated object or objects are all valid and works with any kind of association.

As your dry-validation schema validates the keys and values you provide, it has no idea the structure of model to which this data relates or it's associations.

You could acheive something to ActiveModel's `validates_associated`  by using a nested schema and passing in the attributes for your associated objects:

**For single (`has_one` / `belongs_to`) associations**

**dry-validation**

```ruby
schema = Dry::Validation.Schema do
  required(:name).filled
  required(:email).filled

  required(:spouse).schema do
    required(:name).filled
    required(:email).filled
  end
end

schema.({
  name: 'Fred',
  email: 'fred@somewhere.com',
  spouse: {
    name: 'Alex',
    email: 'alex@somewhere.com'
  }
})
```

**For `has_many` associations**

**dry-validation**

```ruby
schema = Dry::Validation.Schema do
  required(:name).filled
  required(:email).filled

  required(:cars).each do
    schema do
      required(:registration_numer).filled
      required(:make).filled
      required(:model).filled
    end
  end
end

schema.({
  name: 'Fred',
  email: 'fred@somewhere.com',
  cars: [
    {
      registration_number: 'ZX651MU',
      make: 'Ford',
      model: 'Mustang'
    },
    {
      registration_number: 'MU65LTX',
      make: 'Audi',
      model: 'R8'
    }
  ]
})

```

### 2.3 confirmation

This helper is used when you have two text fields that should receive exactly the same content. Common use cases include email addresses and passwords.

**ActiveModel Validation**

```ruby
validates :attr, confirmation: true
```

**dry-validation**

```ruby
required(:attr).confirmation
```

> Note: ActiveModel automatically creates a virtual confirmation attribute for you whose name is the name of the field that has to be confirmed with "_confirmation" appended. If you are using Protected Parameters you will need to add this attribute yourself.

### 2.4 exclusion

This helper validates that the attributes' values are not included in a given enumerable object.

**ActiveModel Validation**

```ruby
validates :attr, exclusion: { in: enumerable_object }
```

**dry-validation**

```ruby
required(:attr).filled(excluded_from?: enumerable_object)
```

> Note: As per ActiveModel docs, `:within` option is an alias of `:in`

### 2.5 format

This helper validates the attributes' values by testing whether they match or doesn't match a given regular expression.

**ActiveModel Validation**

```ruby
validates :attr, format: { with: regex }
```

**dry-validation**

```ruby
required(:attr).filled(format?: regex)
```

#### Doesn't Match

**ActiveModel Validation**

```ruby
validates :attr, format: { without: regex }
```

**dry-validation**

```ruby
required(:attr) { filled? & format?(regex).not }
```

### 2.6 inclusion

This helper validates that the attributes' values are included in a given enumerable object.

**ActiveModel Validation**

```ruby
validates :attr, inclusion: { in: enumerable_object }
```

**dry-validation**

```ruby
required(:attr).filled(included_in?: enumerable_object)
```

> Note: As per ActiveModel docs, `:within` option is an alias of `:in`

### 2.7 length

This helper validates the length of the attribute's value. ActiveModel relies on a variety of options to specify length constraints in different ways. dry-validation uses different predicates for each constraint.

#### Minimum

**ActiveModel Validation**

```ruby
validates :attr, length: { minimum: int }
```

**dry-validation**

```ruby
required(:attr).filled(min_size?: int)
```

#### Maximum

**ActiveModel Validation**

```ruby
validates :attr, length: { maximum: int }
```

**dry-validation**

```ruby
required(:attr).filled(max_size?: int)
```

#### In

**ActiveModel Validation**

```ruby
validates :attr, length: { in: range }
```

**dry-validation**

```ruby
required(:attr).filled(size?: range)
```

#### Is

**ActiveModel Validation**

```ruby
validates :attr, length: { is: int }
```

**dry-validation**

```ruby
required(:attr).filled(size?: int)
```

#### Tokeniser Option

As with ActiveModel Validations, dry-validation counts characters by default. ActiveModel provides a `:tokeniser` option to allow you to customise how the value is split. You can achieve the same thing in dry-validation by creating your own predicate e.g.:

```ruby
Dry::Validation.Schema do
  configure do
    def word_count?(options, value)
      words = value.split(/\s+/).size # split into seperate words
      words >= options[:min_size] && words <= options[:max_size] # compare no. words with parameters
    end
  end

  required(:attr).filled(word_count?: { min_size: 300, max_size: 400 } }
end
```

### 2.8 numericality

ActiveModel determines numericality either by trying to convert the value to a Float, or by using a Regex if you specify `only_integer: true`.

In dry-validation, you can either validate that the value is of type Integer, Float, or Decimal using the `.int?`, `.float?` and `.decimal?` predicates respectively, or you can use `number?` to test if the value is numerical regardless of its specific data type.

**ActiveModel Validation**

```ruby
validates :attr, numericality: true
```

**dry-validation**

```ruby
Dry::Validation.Schema do
  # if you know what type of number you require then simply use one of the options below:
  required(:attr).filled(:int?)
  required(:attr).filled(:float?)
  required(:attr).filled(:decimal?)

  # For anything which represents a number (e.g. '1', 15, '12.345' etc.)
  # you can simply use:
  required(:attr).filled(:number?)
end
```

#### Options - only_integer

**ActiveModel Validation**

```ruby
validates :attr, numericality: { only_integer: true }
```

**dry-validation**

```ruby
required(:attr).filled(format?: /\A[+-]?\d+\Z/) # option 1 - most similar to ActiveModel
required(:attr).filled(:int?) # option 2 - best practise
```

#### Options - greater_than

**ActiveModel Validation**

```ruby
validates :attr, numericality: { greater_than: int }
```

**dry-validation**

```ruby
required(:attr).filled(:int?, gt?: int)
```

#### Options - greater_than_or_equal_to

**ActiveModel Validation**

```ruby
validates :attr, numericality: { greater_than_or_equal_to: int }
```

**dry-validation**

```ruby
required(:attr).filled(:int?, gteq?: int)
```

#### Options - less_than

**ActiveModel Validation**

```ruby
validates :attr, numericality: { less_than: int }
```

**dry-validation**

```ruby
required(:attr).filled(:int?, lt?: int)
```

#### Options - less_than_or_equal_to

**ActiveModel Validation**

```ruby
validates :attr, numericality: { less_than_or_equal_to: int }
```

**dry-validation**

```ruby
required(:attr).filled(:int?, lteq?: int)
```

#### Options - equal_to

**ActiveModel Validation**

```ruby
validates :attr, numericality: { equal_to: int }
```

**dry-validation**

```ruby
required(:attr).filled(:int?, eql?: int)
```

#### Options - odd

**ActiveModel Validation**

```ruby
validates :attr, numericality: { odd: true }
```

**dry-validation**

```ruby
Dry::Validation.Schema do
  required(:attr).filled(:int?, :odd?)
end
```

#### Options - even

**ActiveModel Validation**

```ruby
validates :attr, numericality: { even: true }
```

**dry-validation**

```ruby
Dry::Validation.Schema do
  required(:attr).filled(:int?, :even?)
end
```

> Note: `odd?` and `even?` predicates can only be used on integers.

**Additional Uses:**

dry-validation's predicates uses basic Ruby equality operators (`<`, `>`, `==` etc.) which means that they can be used to validate anything that's comparable.

For example you can use these predicates to validate dates straight out of the box:

```ruby
required(:attr).filled(:date?, lteq?: start_date, gteq?: end_date)
```

### 2.9 presence

dry-validation has no exact equivalent of ActiveModel's `presence` validation (`validates :attr, presence: true`. The closest translation would be `required(:attr).filled`; however there are a few differences.

Internally, ActiveModel's `presence` validation calls the method `present?` on the validated attribute, which is equivalent to `!blank?`. Neither `present?` nor `blank?` are a inbuilt Ruby methods, but a monkey-patch added to every object by ActiveSupport, with the following semantics:

- `nil` and `false` are blank
- strings composed only of whitespace are blank
- empty arrays and hashes are blank
- any object that responds to `empty?` and is empty is blank.
- everything else is present.

dry-validation's `filled?` predicate is simpler than this, and considers everything to be filled except `nil`, empty Strings, empty Arrays, and empty Hashes.

If you want to validate that a string key contains non-whitespace characters (like ActiveSupport's `String#present?`, you can use a custom predicate such as:

```ruby
WHITESPACE_PATTERN = /\A[[:space:]#{"\u200B\u200C\u200D\u2060\uFEFF"}]*\z/

def non_blank?(input)
  !(WHITESPACE_PATTERN =~ input)
end
```

**Associations**

If you want to be sure that an association is present, you'll need to create a custom predicate to test whether the associated object itself is present. Here is a simple example of what such a predicate might look like:

```ruby
schema = Dry::Validation.Schema do
  configure do
    def is_record?(class, value)
      class.where(id: value).any?
    end
  end

  required(:name).filled
  required(:email).filled
  required(:spouse_id).filled(is_record?: Person) # single association
  required(:car_ids).filled(:array?, is_record?: Car) # many association
end

schema.({
  name: 'Fred',
  email: 'fred@somewhere.com',
  spouse_id: 1,
  car_ids: [21, 23, 24, 25]
})

```

**Booleans**

If you want to validate the presence of a boolean field (e.g. true or false) you should use the built in predicate `.bool?`.
E.g. `required(:attr).filled(:bool?)`

### 2.10 absence

**ActiveModel Validation**

```ruby
validates :attr, absence: true
```

**dry-validation**

Dry validation includes two predicates (`empty?` and `none?`) for absence. You should use whichever is most applicable to your situation, remembering that an empty string can be turned into nil using `to_nil` coercion.

```ruby
required(:attr).value(:none?)  # only allows nil
required(:attr).value(:empty?) # only empty values:  "", [], {}, or nil
```

#### Associations

If you want to be sure that an association is absent, we can do the opposite to checking that the association if present but use none for a single object and empty for may objects.

Checking that an association is absent is in many ways is simpler than its `present?` equivilent as if the foreign_key / id is nil, then the association would also be nil.

We can therefore simply check that our ids are nil/ empty:

**dry-validation**

```ruby
schema = Dry::Validation.Schema do
  required(:name).filled
  required(:email).filled
  required(:spouse_id).value(:none?) # single association
  required(:cars).value(:empty?) # many association
end

schema.({
  name: 'Fred',
  email: 'fred@somewhere.com',
  spouse_id: '',
  car_ids: []
})

```

**Booleans**

To validate the absence of a boolean field (e.g. not true or false) you should use:

`required(:attr).value(:none?)`

This validates that the value of the `:attr` key is `nil`.

### 2.11 uniqueness

Rails' `uniqueness` validation is fundamentally different from the other validations because it requires a query against a database. (Accordingly, the uniqueness validation is contained within the `activerecord` gem, while other validations are part of `activemodel`.) You can test if an attribute is unique by creating a custom predicate to run this query to the database.

Let's take the example included in the offical Active Record Validation guide:

**ActiveModel Validations**
```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

**dry-validation**
```ruby
schema = Dry::Validation.Schema do
  configure do
    option :record

    def unique?(attr_name, value)
      record.class.where.not(id: record.id).where(attr_name => value).empty?
    end
  end
  required(:email).filled(unique?: :email)
end

schema.with(record: user_account).call(input)
```

Note that our query checks for any records in our class which have the same value for our attribute and where the id is not equal to the record we are updating. This works for both new and persisted records.

**Scope**

To limit the scope of your query you can simply update your query as needed or as in our example below add a scope paramenter to your custom predicate for example:

```ruby
schema = Dry::Validation.Schema do
  configure do
    option :record

    def scoped_unique?(attr_name, scope, value)
       record.class.where.not(id: record.id).where(scope).where(attr_name => value).empty?
    end
  end

  required(:email).filled(scoped_unique?: [:email, { active: true }])
end

schema.with(record: user_account).call(input)
```

**Case Sensitive**

There is also a :case_sensitive option that you can use to define whether the uniqueness constraint will be case sensitive or not. In Active Model Validations this option defaults to true.

Depending on your chosen database, you might find that searches are case insensitive anyway. If not then you could simply update your query to perform a case insensitive search. The exact implementation will depend on your database but here's an example that works with PostgreSQL.

```ruby
schema = Dry::Validation.Schema do
  configure do
    option :account

    def case_insensitive_unique?(attr_name, value)
       account.class.where.not(id: account.id).where("LOWER(#{attr_name}) = ?", value.downcase).empty?
    end
  end

  required(:email).filled(case_insensitive_unique?: :email)
end

schema.with(object: user_account).call(input)
```

### 2.12 validates_with

The validates_with helper takes a class, or a list of classes to use for validation.

In reality by using dry-validation you are effectively doing this as your schema is an independent class.

You can read more about how dry-validation work [here](/gems/dry-validation/0.13/basics/working-with-schemas) and more information on how to reuse your schemas [here](/gems/dry-validation/0.13/reusing-schemas)

### 2.13 validates_each

This helper validates attributes against a block.

Example as per the official Active Record Validation Guide

**Active Model Validation**

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'must start with upper case') if value =~ /\A[[:lower:]]/
  end
end
````

**dry-validation**

In dry-validation we don't provide such a helper. You can acheive the same thing by converting the contents of your validates_each block to a custom predicate and

Now for those of you who have been paying attention, for this simple example we could use our `format?` predicate to validate this. However, lets for arguments sake say that we want to do this via a custom predicate what might that look like?

```ruby
  schema = Dry::Validation.Schema do
    configure do
      def starts_with_uppercase?(value)
        value =~ /^[A-Z]*/ # check that the first character in our string is uppercase
      end
    end

    required(:name).filled(:str, :starts_with_uppercase?)
    required(:surname_name).filled(:str, :starts_with_uppercase?)
  end
```


### 3. Common Validation Options

These are the common options allowed by ActiveModel validations, and their equivalents in dry-validation

**3.1 `:allow_nil`**

Simply use `maybe` instead of `required` when defining your rules.

**ActiveModel Validation**

```ruby
validates :attr, length: { minimum: int, allow_nil: true }
```

**dry-validation**

```ruby
required(:attr).maybe(str?, min_size?: int)
```

**3.2  `:allow_blank`**

Bareing in mind the differences explained between Ruby's
In dry-validation you will need to use a block when defining your rule instead of `filled`, and include the `.empty?` predicate into your rule.

**ActiveModel Validation**

```ruby
validates :attr, length: { minimum: int, allow_blank: true }
```

**dry-validation**

```ruby
required(:attr) { empty? | str? & min_size?(int) )
```

**3.3 `:message`**

Custom messages are implemented through a separate YAMl file. See [Error Messages](/gems/dry-validation/0.13/error-messages) for full instructions.

**3.4 `:on`**

In dry-validation, validations are defined in schemas. You can create separate schemas for various states (e.g UserCreateSchema, UserUpdateSchema) and then choose the correct schema to run in the relevant action.

You can keep your schema code nice and DRY by [reusing schemas](/gems/dry-validation/0.13/reusing-schemas).

### 4. Conditional Validation

**ActiveModel Validation**

In ActiveModel you can use `:if` or `:unless` to only perform a validation based on the result of a proc or method.

A simple schema can look like this:

```ruby
validates :card_number, presence: true, if: :paid_with_card?

def paid_with_card?
  payment_type == "card"
end
```

**dry-validation**

To achieve this in dry-validation you can use [high-level rules](/gems/dry-validation/0.13/high-level-rules).

Declare a rule for each of the attributes you need to reference:

```ruby
required(:payment_type).filled(included_in?: ["card", "cash", "cheque"])
optional(:card_number).maybe
```

Declare a high level rule to require the card number if `payment_type == 'card'`:

```ruby
rule(require_card_number: [:card_number, :payment_type]) do |card_number, payment_type|
  payment_type.eql?('card') > card_number.filled?
end
```

Put it all together and you get:
```ruby
schema = Dry::Validation.Schema do
  required(:payment_type).filled(included_in?: ["card", "cash", "cheque"])
  optional(:card_number).maybe

  rule(require_card_number: [:card_number, :payment_type]) do |card_number, payment_type|
    payment_type.eql?('card') > card_number.filled?
  end
end

schema.({
  payment_type: 'cash',
}).success? # true

schema.({
  payment_type: 'card',
}).success? # false

schema.({
  payment_type: 'card',
  card_number: '4242424242424242',
}).success? # true
```
