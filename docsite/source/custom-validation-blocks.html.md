---
title: Custom Validation Blocks
layout: gem-single
name: dry-validation
---

Just like [high-level rules](/gems/dry-validation/0.13/high-level-rules), custom validation blocks are executed only when the values they depend on are valid. You can define these blocks using `validate` DSL, they will be executed in the context of your schema objects, which means schema collaborators or external configurations are accessible within these blocks.

``` ruby
UserSchema = Dry::Validation.Params do
  configure do
    option :ids

    def self.messages
      super.merge(
        en: { errors: { valid_id: 'id is not valid' } }
      )
    end
  end

  required(:id).filled(:int?)

  validate(valid_id: :id) do |id|
    ids.include?(id)
  end
end

schema = UserSchema.with(ids: [1, 2, 3])

schema.(id: 4).errors
# => {:valid_id=>["id is not valid"]}
```

Also, `validate` method allow more than one attribute:

```ruby
schema = Dry::Validation.Schema do
  configure do
    def self.messages
      super.merge(en: { errors: { email_required: 'provide email' }})
    end
  end

  required(:email).maybe(:str?)
  required(:newsletter).value(:bool?)

  validate(email_required: %i[newsletter email]) do |newsletter, email|
    if newsletter == true
      !email.nil?
    else
      true
    end
  end
end

schema.(newsletter: false, email: nil)
# => success

schema.(newsletter: true, email: nil)
# => {:email_required=>["provide email"]}
```
