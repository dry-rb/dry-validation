require 'warning'

Warning.ignore(%r{rspec/core})
Warning[:experimental] = false if Warning.respond_to?(:[])
