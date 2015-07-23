# dry-validator <a href="https://gitter.im/dryrb/chat" target="_blank">![Join the chat at https://gitter.im/dryrb/chat](https://badges.gitter.im/Join%20Chat.svg)</a>

<a href="https://travis-ci.org/dryrb/dry-validator" target="_blank">![Build Status](https://travis-ci.org/dryrb/dry-validator.svg?branch=master)</a>
<a href="http://inch-ci.org/github/dryrb/dry-validator" target="_blank">![Inline docs](http://inch-ci.org/github/dryrb/dry-validator.svg?branch=master&style=flat)</a>

A simple validator implemented in Ruby

## Synopsis

```ruby
# Define a user model and some users
User = Struct.new(:name)
user = User.new('')
valid_user = User.new('Jack')

# A simple validator
user_validator = Dry::Validator.new(name: { presence: true })
user_validator.call(user)
# => {:name=>[{:code=>"presence", :options=>true}]}

# Validate an embedded object using a nested rules hash
embedded_user_validator = Dry::Validator.new(
  user: {
    embedded: {
      name: { presence: true }
    }
  }
)
embedded_user_validator.call(user: user)
# => {:user=>[{:name=>[{:code=>"presence", :value=>"", :options=>true}]}]}

# Validate an embedded object using a nested validator
embedded_user_validator = Dry::Validator.new(
  user: {
    embedded: user_validator
  }
)
embedded_user_validator.call(user: user)
# => {:user=>[{:name=>[{:code=>"presence", :value=>"", :options=>true}]}]}

# Validate an array of objects using a nested rules hash
users_validator = Dry::Validator.new(
  users: {
    each: {
      name: { presence: true }
    }
  }
)
users_validator.call(users: [valid_user, user])
# => {:users=>[{}, {:name=>[{:code=>"presence", :value=>"", :options=>true}]}]}

# Validate an array of objects using a nested validator
users_validator = Dry::Validator.new(
  users: {
    each: user_validator
  }
)
users_validator.call(users: [valid_user, user])
# => {:users=>[{}, {:name=>[{:code=>"presence", :value=>"", :options=>true}]}]}
```

## Configuration

#### Adding custom rules

```ruby
Dry::Validator::Rules.register(:blank) do |value, switch = true, *|
  {
    code: 'blank',
    value: value,
    options: switch
  } if (!switch && value.to_s.length == 0) || (switch && value.to_s.length > 0)
end
```

#### Using a custom rule set

```ruby
Dry::Validator::Processor.configure do |config|
  config.rules = {
    presence: ->(value, switch = true, *) do
      {
        code: 'presence',
        value: value,
        options: switch
      } if (switch && value.to_s.length == 0) || (!switch && value.to_s.length > 0)
    end
  }
end
```

#### Changing the attribute extractor

```ruby
Dry::Validator::Processor.configure do |config|
  config.attribute_extractor = ->(subject, attribute) { subject[attribute] }
end
```

#### Changing the default processor (invalidates all other configuration)

```ruby
Dry::Validator.configure do |config|
  config.default_processor = ->(validator, subject) do
    validator.rules.each_with_object({}) do |(attribute, rule_set), result|
      errors = rule_set.flat_map do |rule_name, options|
        Dry::Validator::Rules[rule_name].call(
          subject[attribute],
          options,
          validator
        )
      end.compact

      result[attribute] = errors unless errors.all?(&:empty?)
    end
  end
end
```

## License

See `LICENSE` file.
