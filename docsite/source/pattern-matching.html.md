---
title: Pattern matching
layout: gem-single
name: dry-validation
---

Ruby 2.7 added experimental support for pattern matching. dry-validation supports pattern matching on result values starting with 1.4.1.

```ruby
class PersonContract < Dry::Validation::Contract
  params do
    required(:first_name).filled(:string)
    required(:last_name).filled(:string)
  end
end

contract = PersonContract.new

case contract.('first_name' => 'John', 'last_name' => 'Doe')
in { first_name:, last_name: } => result if result.success?
  puts "Hello #{first_name} #{last_name}"
in _ => result
  puts "Invalid input: #{result.errors.to_h}"
end
```

Alternatively, results can be matched as a 2-value tuple of two hashes. The hash is validation output as in the previous example. The second is the context value shared between rules.

```ruby
class AddressContract < Dry::Validation::Contract
  option :address_repo

  params do
    required(:address).filled(:string)
  end

  rule(:address) do |context:|
    address = address_repo.find(value)
    contex[:address] = address if address
  end
end

contract = AddressContract.new(address_repo: AddressRepo.new)

case contract.('name' => 'John Doe', 'address' => 'Pedro Moreno 10, Ciudad de México')
in [{ name: }, { address: }] => result if result.success?
  # adding person to existing address
in { name:, address: } => result if result.success?
  # adding person to new address
else
  # showing errors
end
```

### Pattern matching with monads

It may get tedious to write `if result.success?` every time. Another option is using the `:monads` extention that wraps `Result` objects with `Success`/`Failure` constructors.

```ruby
require 'dry/validation'
require 'dry/monads'

Dry::Validation.load_extensions(:monads)

class CreatePerson
  include Dry::Monads[:result]

  class Contract < Dry::Validation::Contract
    params do
      required(:first_name).filled(:string)
      required(:last_name).filled(:string)
    end
  end

  attr_reader :repo

  def initialize(repo)
    @repo = repo
  end

  def call(input)
    case contract.(input).to_monad
    in Success(first_name:, last_name:)
      Success(repo.create(first_name, last_name))
    in Failure(result)
      Failure(result.errors.to_h)
    end
  end

  def contract
    @contract ||= Contract.new
  end
end
```

In this example it is important to have monads included in the class with `include Dry::Monads[:result]` because of how pattern matching works in Ruby. Still, it's neat!
