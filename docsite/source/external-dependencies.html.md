---
title: External dependencies
layout: gem-single
name: dry-validation
---

It's common to use external services that are needed for various validation rules. A good example is using objects that give you access to the database. Whenever you need to access such services, you can levarage `Dry::Validation::Contract.option`.

Let's say you use an API client object that can perform address validation - we can define it as an external dependency that will be injected to the contract's constructor:

```ruby
class NewUserContract < Dry::Validation::Contract
  option :address_validator

  params do
    required(:address).filled(:string)
  end

  rule(:address) do
    key.failure("invalid address") unless address_validator.valid?(values[:address])
  end
end
```

Now we can instantiate the contract and pass `address_validator` as a dependency:

``` ruby
new_user_contract = NewUserContract.new(address_validator: your_address_validator)

new_user_contract.call(address: "Some Street 15/412")
```

> If you're using dependency injection with dry-auto_inject, this will work out-of-the-box
