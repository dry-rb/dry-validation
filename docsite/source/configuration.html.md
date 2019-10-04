---
title: Configuration
layout: gem-single
name: dry-validation
---

Contract classes can be configured using their `config` object. You'll usually want to define an abstract contract class that all your other classes will inherit from. This way you can share common configuration between many contracts with no duplication.

### Accessing configuration

Use `Contract.config` to access configuration and set its values:

``` ruby
class ApplicationContract < Dry::Validation::Contract
  config.messages.default_locale = :pl
end
```

Now any class that inherits from `ApplicationContract` will have the same configuration:

``` ruby
class UserContract < ApplicationContract
end

UserContract.config.messages.default_locale
# :pl
```

### Configuration settings

You can configure following settings:

- `config.messages.top_namespace` - the key in the locale files under which messages are defined, by default it's `dry_validation`
- `config.messages.backend` - the localization backend to use. Supported values are: `:yaml` and `:i18n`
- `config.messages.load_paths` - an array of files paths that are used to load messages
- `config.messages.namespace` - custom messages namespace for a contract class. Use this to differentiate common messages
- `config.messages.default_locale` - default `I18n`-compatible locale identifier

### Example

Let's say you want to configure a contract class to load messages from a custom file and use our own `top_namespace`. Our messages file will look like this:

```yaml
# config/errors.yml
en:
  my_app:
    errors:
      taken: 'is already taken'
```

If you want your contract classes to use `my_app` as your own top-level namespace and pull in custom messages, use the following configuration:

``` ruby
class ApplicationContract < Dry::Validation::Contract
  config.messages.top_namespace = :my_app
  config.messages.load_paths << 'config/errors.yml'
end
```
