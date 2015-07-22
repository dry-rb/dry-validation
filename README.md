# dry-validator <a href="https://gitter.im/dryrb/chat" target="_blank">![Join the chat at https://gitter.im/dryrb/chat](https://badges.gitter.im/Join%20Chat.svg)</a>

<a href="https://travis-ci.org/dryrb/dry-validator" target="_blank">![Build Status](https://travis-ci.org/dryrb/dry-validator.svg?branch=master)</a>
<a href="http://inch-ci.org/github/dryrb/dry-validator" target="_blank">![Inline docs](http://inch-ci.org/github/dryrb/dry-validator.svg?branch=master&style=flat)</a>

A simple validator implemented in Ruby

## Synopsis

```ruby
User = Struct.new(:name)

user_validator = Dry::Validator.new(
  name: {
    presence: true,
    length: 2..5
  }
)

user = User.new('')
user_validator.call(user)
# => {
#      :name => [
#        {
#          :code => "presence",
#          :options=>true
#        },
#        {
#          :code => "length",
#          :options => {
#            :min=>2,
#            :max=>5
#           }
#         }
#       ]
#     }
```

## License

See `LICENSE` file.
