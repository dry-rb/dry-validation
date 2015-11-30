# v0.2.0 to-be-released

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
