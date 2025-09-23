# frozen_string_literal: true

# This file is synced from hanakai-rb/repo-sync

require "warning"

Warning.ignore(%r{rspec/core})
Warning.ignore(%r{rspec/mocks})
Warning.ignore(/codacy/)
Warning[:experimental] = false if Warning.respond_to?(:[])
