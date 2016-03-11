# v0.7.0 to-be-released

### Added

* Support for macros:
  * `required` - when value must be filled
  * `maybe` - when value can be nil (or empty, in case of `Form`)
  * `when` - for composing high-level rule based on predicates applied to a
    validated value
  * `confirmation` - for confirmation validation
* Support for `value(:foo).eql?(value(:bar))` syntax in high-level rules (solnic)
* New DSL for defining schema objects `Dry::Validation.Schema do .. end` (solnic)
* Ability to define nested schemas via `key(:location).schema do .. end` (solnic)
* Ability to re-use schemas inside other schemas via `key(:location).schema(LocationSchema)` (solnic)
* Ability to inherit rules from another schema via `Dry::Validation.Schema(Other) do .. end` (solnic)
* Ability to inject arbitrary dependencies to schemas via `Schema.option` + `Schema#with` (solnic)
* Ability to provide translations for rule names under `%{locale}.rules.%{name}` pattern (solnic)
* Ability to configure input processor, either `:form` or `:sanitizer` (solnic)
* Ability to pass a constrained dry type when defining keys or attrs, ie `key(:age, Types::Age)` (solnic)
* `Result#messages` supports `:full` option to get messages with rule names, disabled by default (solnic)

### Changed

* `schema` was **removed** from the DSL, just use `key` instead (solnic)
* `confirmation` is now a macro that you can call on a key rule (solnic)
* rule names for nested structures are now fully qualified, which means you can
  provide customized messages for them. ie `user: :email` (solnic)
* `Schema::Result#params` was renamed to `#output` (solnic)
* `Schema::Result` is now `Validation::Result` and it no longer has success and
  failure results, only error results are provided (solnic)

### Fixed

* Qualified rule names properly use last node by default for error messages (solnic)
* Validation hints only include relevant messages (solnic)
* `:yaml` messages respect `:locale` option in `Result#messages` (solnic)

[Compare v0.6.0...v0.7.0](https://github.com/dryrb/dry-validation/compare/v0.6.0...v0.7.0)

# v0.6.0 2016-01-20

### Added

* Support for validating objects with attr readers via `attr` (SunnyMagadan)
* Support for `value` interface in the DSL for composing high-level rules based on values (solnic)
* Support for `rule(name: :something)` syntax for grouping high-level rules under
  the same name (solnic)
* Support for `confirmation(:foo, some_predicate: some_argument)` shortcut syntax (solnic)
* Support for error messages for grouped rules (like `confirmation`) (solnic)
* Schemas support injecting rules from the outside (solnic)

## Changed

* `rule` uses objects that inherit from `BasicObject` to avoid conflicts with
  predicate names and built-in `Object` methods (solnic)
* In `Schema::Form` both `key` and `optional` will apply `filled?` predicate by
  default when no block is passed (solnic)

[Compare v0.5.0...v0.6.0](https://github.com/dryrb/dry-validation/compare/v0.5.0...v0.6.0)

# v0.5.0 2016-01-11

### Changed

* Now depends on [dry-logic](https://github.com/dryrb/dry-logic) for predicates and rules (solnic)
* `dry/validation/schema/form` is now required by default (solnic)

### Fixed

* `Schema::Form` uses safe `form.array` and `form.hash` types which fixes #42 (solnic)

[Compare v0.4.1...v0.5.0](https://github.com/dryrb/dry-validation/compare/v0.4.1...v0.5.0)

# v0.4.1 2015-12-27

### Added

* Support for `each` and type coercion inference in `Schema::Form` (solnic)

[Compare v0.4.0...v0.4.1](https://github.com/dryrb/dry-validation/compare/v0.4.0...v0.4.1)

# v0.4.0 2015-12-21

### Added

* Support for high-level rule composition via `rule` interface (solnic)
* Support for exclusive disjunction (aka xor/^ operator) (solnic)
* Support for nested schemas within a schema class (solnic)
* Support for negating rules via `rule(name).not` (solnic)
* Support for `validation hints` that are included in the error messages (solnic)

### Fixed

* Error messages hash has now consistent structure `rule_name => [msgs_array, input_value]` (solnic)

[Compare v0.3.1...v0.4.0](https://github.com/dryrb/dry-validation/compare/v0.3.1...v0.4.0)

# v0.3.1 2015-12-08

### Added

* Support for `Range` and `Array` as an argument in `size?` predicate (solnic)

### Fixed

* Error compiler returns an empty hash rather than a nil when there are no errors (solnic)

[Compare v0.3.0...v0.3.1](https://github.com/dryrb/dry-validation/compare/v0.3.0...v0.3.1)

# v0.3.0 2015-12-07

### Added

* I18n messages support (solnic)
* Ability to configure `messages` via `configure { config.messages = :i18n }` (solnic)
* `rule` interface in DSL for defining rules that depend on other rules (solnic)
* `confirmation` interface as a shortcut for defining "confirmation of" rule (solnic)
* Error messages can be now matched by input value type too (solnic)

### Fixed

* `optional` rule with coercions work correctly with `|` + multiple `&`s (solnic)
* `Schema#[]` checks registered predicates first before defaulting to its own predicates (solnic)

### Changed

* `Schema#messages(input)` => `Schema#call(input).messages` (solnic)
* `Schema#call` returns `Schema::Result` which has access to all rule results,
  errors and messages
* `Schema::Result#messages` returns a hash with rule names, messages and input values (solnic)

[Compare v0.2.0...HEAD](https://github.com/dryrb/dry-validation/compare/v0.2.0...HEAD)

# v0.2.0 2015-11-30

### Added

* `Schema::Form` with a built-in coercer inferred from type-check predicates  (solnic)
* Ability to pass a block to predicate check in the DSL ie `value.hash? { ... }` (solnic)
* Optional keys using `optional(:key_name) { ... }` interface in the DSL (solnic)
* New predicates:
  - `bool?`
  - `date?`
  - `date_time?`
  - `time?`
  - `float?`
  - `decimal?`
  - `hash?`
  - `array?`

### Fixed

* Added missing `and` / `or` interfaces to composite rules (solnic)

[Compare v0.1.0...HEAD](https://github.com/dryrb/dry-validation/compare/v0.1.0...HEAD)

# v0.1.0 2015-11-25

First public release
