# v0.11.1 2017-09-15

### Changed

* [internal] fix warnings from dry-types v0.12.0

[Compare v0.11.0...v0.11.1](https://github.com/dry-rb/dry-validation/compare/v0.11.0...v0.11.1)

# v0.11.0 2017-05-30

### Changed

* [internal] input processor compilers have been updated to work with new dry-types' AST (GustavoCaso)

[Compare v0.10.7...v0.11.0](https://github.com/dry-rb/dry-validation/compare/v0.10.7...v0.11.0)

# v0.10.7 2017-05-15

### Fixed

* `validate` can now be defined multiple times for the same key (kimquy)
* Re-using rules between schemas no longer mutates original rule set (pabloh)

[Compare v0.10.6...v0.10.7](https://github.com/dry-rb/dry-validation/compare/v0.10.6...v0.10.7)

# v0.10.6 2017-04-26

### Fixed

* Fixes issue with wrong localized error messages when namespaced messages are used (kbredemeier)

[Compare v0.10.5...v0.10.6](https://github.com/dry-rb/dry-validation/compare/v0.10.5...v0.10.6)

# v0.10.5 2017-01-12

### Fixed

* Warnings under MRI 2.4.0 are gone (koic)

[Compare v0.10.4...v0.10.5](https://github.com/dry-rb/dry-validation/compare/v0.10.4...v0.10.5)

# v0.10.4 2016-12-03

### Fixed

* Updated to dry-core >= 0.2.1 (ruby warnings are gone) (flash-gordon)
* `format?` predicate is excluded from hints (solnic)

### Changed

* `version` file is now required by default (georgemillo)

[Compare v0.10.3...v0.10.4](https://github.com/dry-rb/dry-validation/compare/v0.10.3...v0.10.4)

# v0.10.3 2016-09-27

### Fixed

* Custom predicates work correctly with `each` macro (solnic)

[Compare v0.10.2...v0.10.3](https://github.com/dry-rb/dry-validation/compare/v0.10.2...v0.10.3)

# v0.10.2 2016-09-23

### Fixed

* Constrained types + hints work again (solnic)

[Compare v0.10.1...v0.10.2](https://github.com/dry-rb/dry-validation/compare/v0.10.1...v0.10.2)

# v0.10.1 2016-09-22

### Fixed

* Remove obsolete require of `dry/struct` which is now an optional extension (flash-gordon)

[Compare v0.10.0...v0.10.1](https://github.com/dry-rb/dry-validation/compare/v0.10.0...v0.10.1)

# v0.10.0 2016-09-21

### Added

* Support for `validate` DSL which accepts an arbitratry validation block that gets executed in the context of a schema object and is treated as a custom predicate (solnic)
* Support for `or` error messages ie "must be a string or must be an integer" (solnic)
* Support for retrieving error messages exclusively via `schema.(input).errors` (solnic)
* Support for retrieving hint messages exclusively via `schema.(input).hints` (solnic)
* Support for opt-in extensions loaded via `Dry::Validation.load_extensions(:my_ext)` (flash-gordon)
* Add `:monads` extension which transforms a result instance to `Either` monad, `schema.(input).to_either` (flash-gordon)
* Add `dry-struct` integration via an extension activated by `Dry::Validation.load_extensions(:struct)` (flash-gordon)

### Fixed

* Input rules (defined via `input` macro) are now lazy-initialized which makes it work with predicates defined on the schema object (solnic)
* Hints are properly generated based on argument type in cases like `size?`, where the message should be different for strings (uses "length") or other types (uses "size") (solnic)
* Defining nested keys without `schema` blocks results in `ArgumentError` (solnic)

### Changed

* [BREAKING] `when` macro no longer supports multiple disconnected rules in its block, whatever the block returns will be used for the implication (solnic)
* [BREAKING] `rule(some_name: %i(some keys))` will *always* use `:some_name` as the key for failure messages (solnic)

### Internal

* ~2 x performance boost (solnic)
* Rule AST was updated to latest dry-logic (solnic)
* `MessageCompiler` was drastically simplified based on the new result AST from dry-logic (solnic)
* `HintCompiler` is gone as hints are now part of the result AST (solnic)
* `maybe` macro creates an implication instead of a disjunction (`not(none?).then(*your-predicates)`) (solnic)

[Compare v0.9.5...v0.10.0](https://github.com/dry-rb/dry-validation/compare/v0.9.5...v0.10.0)

# v0.9.5 2016-08-16

### Fixed

* Infering multiple predicates with options works as expected ie `value(:str?, min_size?: 3, max_size?: 6)` (solnic)
* Default `locale` configured in `I18n` is now respected by the messages compiler (agustin + cavi21)

[Compare v0.9.4...v0.9.5](https://github.com/dry-rb/dry-validation/compare/v0.9.4...v0.9.5)

# v0.9.4 2016-08-11

### Fixed

* Error messages for sibling deeply nested schemas are nested correctly (timriley)

[Compare v0.9.3...v0.9.4](https://github.com/dry-rb/dry-validation/compare/v0.9.3...v0.9.4)

# v0.9.3 2016-07-22

### Added

* Support for range arg in error messages for `excluded_from?` and `included_in?` (mrbongiolo)
* `Result#message_set` returns raw message set object (solnic)

### Fixed

* Error messages for high-level rules in nested schemas are nested correctly (solnic)
* Dumping error messages works with high-level rules relying on the same value (solnic)

### Changed

* `#messages` is no longer memoized (solnic)

[Compare v0.9.2...v0.9.3](https://github.com/dry-rb/dry-validation/compare/v0.9.2...v0.9.3)

# v0.9.2 2016-07-13

### Fixed

* Constrained types now work with `each` macro (solnic)
* Array coercion without member type works now ie `required(:arr).maybe(:array?)` (solnic)

[Compare v0.9.1...v0.9.2](https://github.com/dry-rb/dry-validation/compare/v0.9.1...v0.9.2)

# v0.9.1 2016-07-11

### Fixed

* `I18n` backend is no longer required and set by default (solnic)

[Compare v0.9.0...v0.9.1](https://github.com/dry-rb/dry-validation/compare/v0.9.0...v0.9.1)

# v0.9.0 2016-07-08

### Added

* Support for defining maybe-schemas via `maybe { schema { .. } }` (solnic)
* Support for interpolation of custom failure messages for custom rules (solnic)
* Support for defining a base schema **class** with config and rules (solnic)
* Support for more than 1 predicate in `input` macro (solnic)
* Class-level `define!` API for defining rules on a class (solnic)
* `:i18n` messages support merging from other paths via `messages_file` setting (solnic)
* Support for message token transformations in custom predicates (fran-worley)
* [EXPERIMENTAL] Ability to compose predicates that accept dynamic args provided by the schema (solnic)

### Changed

* Tokens for `size?` were renamed `left` => `size_left` and `right` => `size_right` (fran-worley)

### Fixed

* Duped key names in nested schemas no longer result in invalid error messages structure (solnic)
* Error message structure for deeply nested each/schema rules (solnic)
* Values from `option` are passed down to nested schemas when using `Schema#with` (solnic)
* Hints now work with array elements too (solnic)
* Hints for elements are no longer provided for an array when the value is not an array (solnic)
* `input` macro no longer messes up error messages for nested structures (solnic)

### Internal

* Compiling messages is now ~5% faster (solnic + splattael)
* Refactored Error and Hint compilers (solnic)
* Refactored Schema to use an internal executor objects with steps (solnic)
* Extracted root-rule into a separate validation step (solnic)
* Added `MessageSet` that result objects now use (in 1.0.0 it'll be exposed via public API) (solnic)
* We can now distinguish error messages from validation hints via `Message` and `Hint` objects (solnic)

[Compare v0.8.0...v0.9.0](https://github.com/dry-rb/dry-validation/compare/v0.8.0...v0.9.0)

# v0.8.0 2016-07-01

### Added

* Explicit interface for type specs used to set up coercions, ie `required(:age, :int)` (solnic)
* Support new dry-logic predicates: `:excluded_from?`, `:excludes?`, `:included_in?`, `:includes?`, `:not_eql?`, `:odd?`, `:even?` (jodosha, fran-worley)
* Support for blocks in `value`, `filled` and `maybe` macros (solnic)
* Support for passing a schema to `value|filled|maybe` macros ie `maybe(SomeSchema)` (solnic)
* Support for `each(SomeSchema)` (solnic)
* Support for `value|filled|maybe` macros + `each` inside a block ie: `maybe(:filled?) { each(:int?) }` (solnic)
* Support for dedicated hint messages via `en.errors.#{predicate}.(hint|failure)` look-up paths (solnic)
* Support for configuring custom DSL extensions via `dsl_extensions` setting on Schema class (solnic)
* Support for preconfiguring a predicate for the input value ie `value :hash?` used for prerequisite-checks (solnic)
* Infer coercion from constrained types  (solnic)
* Add value macro (coop)
* Enable .schema to accept objects that respond to #schema (ttdonovan)
* Support for schema predicates which don't need any arguments (fran-worley)
* Error and hint messages have access to all predicate arguments by default (fran-worley+solnic)
* Invalid predicate name in DSL will raise an error (solnic)
* Predicate with invalid arity in DSL will raise an error (solnic)

### Fixed

* Support for jRuby  9.1.1.0 (flash-gordon)
* Fix bug when using predicates with options in each and when (fran-worley)
* Fix bug when validating custom types (coop)
* Fix depending on deeply nested values in high-lvl rules (solnic)
* Fix duplicated error message for lt? when hint was used (solnic)
* Fix hints for nested schemas (solnic)
* Fix an issue where rules with same names inside nested schemas have incorrect hints (solnic)
* Fix a bug where hints were being generated 4 times (solnic)
* Fix duplicated error messages when message is different than a hint (solnic)

### Changed

* Uses new `:weak` hash constructor from dry-types 0.8.0 which can partially coerce invalid hash (solnic)
* `key` has been deprecated in favor of `required` (coop)
* `required` has been deprecated in favor of `filled` (coop)
* Now relies on dry-logic v0.3.0 and dry-types v0.8.0 (fran-worley)
* Tring to use illogical predicates with maybe and filled macros now raise InvalidSchemaError (fran-worley)
* Enable coercion on form.true and form.false (fran-worley)
* Remove attr (will be extracted to a separate gem) (coop)
* Deprecate required in favour of filled (coop)
* Deprecate key in favor of required (coop)
* Remove nested key syntax (solnic)

### Internal

* ~15% performance boost via various optimizations (solnic)
* When using explicit type specs building a schema is ~80-85x faster (solnic)
* No longer uses `Dry::Types::Predicates` as `:type?` predicate was moved to dry-logic (solnic)
* Integration specs covering predicates with Form and Schema (jodosha)
* Use latest ruby versions on travis (flash-gordon)
* Make pry console optional with IRB as a default (flash-gordon)
* Remove wrapping rules in :set nodes (solnic)

[Compare v0.7.4...v0.8.0](https://github.com/dry-rb/dry-validation/compare/v0.7.4...v0.8.0)

# v0.7.4 2016-04-06

### Added

* `Schema.JSON` with json-specific coercions (coop)
* Support for error messages for `odd? and `even?` predicates (fran-worley)

### Fixed

* Depending on deeply nested values in high-level rules works now (solnic)

[Compare v0.7.3...v0.7.4](https://github.com/dry-rb/dry-validation/compare/v0.7.3...v0.7.4)

# v0.7.3 2016-03-30

### Added

* Support for inferring rules from constrained type (coop + solnic)
* Support for inferring nested schemas from `Dry::Types::Struct` classes (coop)
* Support for `number?` predicate (solnic)

### Fixed

* Creating a nested schema properly sets full path to nested data structure (solnic)
* Error message for `empty?` predicate is now correct (jodosha)

### Internal

* Switch from `thread_safe` to `concurrent` (joevandyk)

[Compare v0.7.2...v0.7.3](https://github.com/dry-rb/dry-validation/compare/v0.7.2...v0.7.3)

# v0.7.2 2016-03-28

### Added

* Support for nested schemas inside high-level rules (solnic)
* `Schema#to_proc` so that you can do `data.each(&schema)` (solnic)

[Compare v0.7.1...v0.7.2](https://github.com/dry-rb/dry-validation/compare/v0.7.1...v0.7.2)

# v0.7.1 2016-03-21

### Added

* You can use `schema` inside `each` macro (solnic)

### Fixed

* `confirmation` macro defines an optional key with maybe value with `_confirmation` suffix (solnic)
* `each` macro works correctly when its inner rule specify just one key (solnic)
* error messages for `each` rules where input is equal are now correctly generated (solnic)

### Changed

* Now depends on `dry-logic` >= `0.2.1` (solnic)

[Compare v0.7.0...v0.7.1](https://github.com/dry-rb/dry-validation/compare/v0.7.0...v0.7.1)

# v0.7.0 2016-03-16

### Added

* Support for macros:
  * `required` - when value must be filled
  * `maybe` - when value can be nil (or empty, in case of `Form`)
  * `when` - for composing high-level rule based on predicates applied to a
    validated value
  * `confirmation` - for confirmation validation
* Support for `value(:foo).eql?(value(:bar))` syntax in high-level rules (solnic)
* New DSL for defining schema objects `Dry::Validation.Schema do .. end` (solnic)
* Ability to define a schema for an array via top-level `each` rule (solnic)
* Ability to define nested schemas via `key(:location).schema do .. end` (solnic)
* Ability to re-use schemas inside other schemas via `key(:location).schema(LocationSchema)` (solnic)
* Ability to inherit rules from another schema via `Dry::Validation.Schema(Other) do .. end` (solnic)
* Ability to inject arbitrary dependencies to schemas via `Schema.option` + `Schema#with` (solnic)
* Ability to provide translations for rule names under `%{locale}.rules.%{name}` pattern (solnic)
* Ability to configure input processor, either `:form` or `:sanitizer` (solnic)
* Ability to pass a constrained dry type when defining keys or attrs, ie `key(:age, Types::Age)` (solnic)
* `Result#messages` supports `:full` option to get messages with rule names, disabled by default (solnic)
* `Validation::Result` responds to `#[]` and `#each` (delegating to its output)
  and it's an enumerable (solnic)

### Changed

* `schema` was **removed** from the DSL, just use `key(:name).schema` instead (solnic)
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

[Compare v0.6.0...v0.7.0](https://github.com/dry-rb/dry-validation/compare/v0.6.0...v0.7.0)

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

[Compare v0.5.0...v0.6.0](https://github.com/dry-rb/dry-validation/compare/v0.5.0...v0.6.0)

# v0.5.0 2016-01-11

### Changed

* Now depends on [dry-logic](https://github.com/dry-rb/dry-logic) for predicates and rules (solnic)
* `dry/validation/schema/form` is now required by default (solnic)

### Fixed

* `Schema::Form` uses safe `form.array` and `form.hash` types which fixes #42 (solnic)

[Compare v0.4.1...v0.5.0](https://github.com/dry-rb/dry-validation/compare/v0.4.1...v0.5.0)

# v0.4.1 2015-12-27

### Added

* Support for `each` and type coercion inference in `Schema::Form` (solnic)

[Compare v0.4.0...v0.4.1](https://github.com/dry-rb/dry-validation/compare/v0.4.0...v0.4.1)

# v0.4.0 2015-12-21

### Added

* Support for high-level rule composition via `rule` interface (solnic)
* Support for exclusive disjunction (aka xor/^ operator) (solnic)
* Support for nested schemas within a schema class (solnic)
* Support for negating rules via `rule(name).not` (solnic)
* Support for `validation hints` that are included in the error messages (solnic)

### Fixed

* Error messages hash has now consistent structure `rule_name => [msgs_array, input_value]` (solnic)

[Compare v0.3.1...v0.4.0](https://github.com/dry-rb/dry-validation/compare/v0.3.1...v0.4.0)

# v0.3.1 2015-12-08

### Added

* Support for `Range` and `Array` as an argument in `size?` predicate (solnic)

### Fixed

* Error compiler returns an empty hash rather than a nil when there are no errors (solnic)

[Compare v0.3.0...v0.3.1](https://github.com/dry-rb/dry-validation/compare/v0.3.0...v0.3.1)

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

[Compare v0.2.0...HEAD](https://github.com/dry-rb/dry-validation/compare/v0.2.0...HEAD)

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

[Compare v0.1.0...HEAD](https://github.com/dry-rb/dry-validation/compare/v0.1.0...HEAD)

# v0.1.0 2015-11-25

First public release
