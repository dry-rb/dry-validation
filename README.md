# dry-validation <a href="https://gitter.im/dryrb/chat" target="_blank">![Join the chat at https://gitter.im/dryrb/chat](https://badges.gitter.im/Join%20Chat.svg)</a>

<a href="https://rubygems.org/gems/dry-validation" target="_blank">![Gem Version](https://badge.fury.io/rb/dry-validation.svg)</a>
<a href="https://travis-ci.org/dryrb/dry-validation" target="_blank">![Build Status](https://travis-ci.org/dryrb/dry-validation.svg?branch=master)</a>
<a href="https://gemnasium.com/dryrb/dry-validation" target="_blank">![Dependency Status](https://gemnasium.com/dryrb/dry-validation.svg)</a>
<a href="https://codeclimate.com/github/dryrb/dry-validation" target="_blank">![Code Climate](https://codeclimate.com/github/dryrb/dry-validation/badges/gpa.svg)</a>
<a href="http://inch-ci.org/github/dryrb/dry-validation" target="_blank">![Documentation Status](http://inch-ci.org/github/dryrb/dry-validation.svg?branch=master&style=flat)</a>

A simple validation library

## Synopsis

```ruby
# Define a user model and some users
User = Struct.new(:name)
user = User.new('')
valid_user = User.new('Jack')

# A simple validator
class UserValidator
  include Dry::Validation

  rules << {
    name: {
      presence: true
    }
  }
end
UserValidator.new(user).errors
# => {:name=>[{:code=>"presence", :options=>true}]}

# Validate an embedded object using a nested rules hash
class EmbeddedUserValidator
  include Dry::Validation

  rules << {
    user: {
      name: {
        presence: true
      }
    }
  }
end
EmbeddedUserValidator.new(user: user).errors
# => {
#      :user=>[
#        {
#          :code=>"embedded",
#          :errors=>{:name=>[{:code=>"presence", :value=>"", :options=>true}]},
#          :value=>#<struct User name="">,
#          :options=>{}
#        }
#      ]
#    }

# Validate an embedded object using a nested validator
class EmbeddedUserValidator
  include Dry::Validation

  rules << {
    user: UserValidator
  }
end
EmbeddedUserValidator.new(user: user).errors
# => {
#      :user=>[
#        {
#          :code=>"embedded",
#          :errors=>{:name=>[{:code=>"presence", :value=>"", :options=>true}]},
#          :value=>#<struct User name="">,
#          :options=>{}
#        }
#      ]
#    }

# Validate an array of objects using a nested rules hash
class UsersValidator
  include Dry::Validation

  rules << {
    users: {
      each: {
        name: { presence: true }
      }
    }
  }
end
UsersValidator.new(users: [valid_user, user]).errors
# => {
#      :users=>[
#         {
#           :code=>"each",
#           :errors=>[{}, {:name=>[{:code=>"presence", :value=>"", :options=>true}]}],
#           :value=>[#<struct User name="Jack">, #<struct User name="">],
#           :options=>{}
#         }
#      ]
#    }

# Validate an array of objects using a nested validator
class UsersValidator
  include Dry::Validation

  rules << {
    users: {
      each: UserValidator
    }
  }
end
UsersValidator.new(users: [valid_user, user]).errors
# => {
#      :users=>[
#         {
#           :code=>"each",
#           :errors=>[{}, {:name=>[{:code=>"presence", :value=>"", :options=>true}]}],
#           :value=>[#<struct User name="Jack">, #<struct User name="">],
#           :options=>{}
#         }
#      ]
#    }
```

## Configuration

#### Adding custom rules

```ruby
Dry::Validation::Rules.register(:blank) do |value, switch = true, *|
  {
    code: 'blank',
    value: value,
    options: switch
  }  if (switch == (value.respond_to?(:length) && value.length > 0))
end
```

#### Using a custom rule set

```ruby
Dry::Validation::Processor.configure do |config|
  config.rules = {
    presence: ->(value, switch = true, *) do
      {
        code: 'presence',
        value: value,
        options: switch
      } if (switch == (value.respond_to?(:length) && value.length == 0))
    end
  }
end
```

#### Changing the attribute extractor

```ruby
Dry::Validation::Processor.configure do |config|
  config.attribute_extractor = ->(subject, attribute) { subject[attribute] }
end
```

#### Changing the default processor (invalidates all other configuration)

```ruby
Dry::Validation.configure do |config|
  config.default_processor = ->(validator, subject) do
    validator.rules.each_with_object({}) do |(attribute, rule_set), result|
      errors = rule_set.flat_map do |rule_name, options|
        Dry::Validation::Rules[rule_name].call(
          subject[attribute],
          options,
          validator
        )
      end.compact

      result[attribute] = errors unless errors.empty?
    end
  end
end
```

## License

See `LICENSE` file.
