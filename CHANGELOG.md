# v0.2.1 2015-12-01

### Added

* `rule` interface in DSL for defining rules that depend on other rules (solnic)
* `confirmation` interface as a shortcut for defining "confirmation of" rule (solnic)

### Fixed

* `optional` rule with coercions work correctly with `|` + multiple `&`s (solnic)
* `Schema#[]` checks registered predicates first before defaulting to its own predicates (solnic)

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
