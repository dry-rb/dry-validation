require 'rspec/expectations'

RSpec::Matchers.define :be_successful do
  match do |actual|
    actual.success? &&
      actual.messages.empty?
  end

  failure_message do |actual|
    "expected that #{actual.inspect} would be successful"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual.inspect} would NOT be successful"
  end
end

RSpec::Matchers.define :be_failing do |messages|
  match do |actual|
    messages = case messages
               when Hash
                 messages
               else
                 Array(messages)
               end

    !actual.success? &&
      actual.messages.fetch(:foo) == messages
  end

  failure_message do |actual|
    "expected that #{actual.inspect} would be failing (#{messages.inspect})"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual.inspect} would NOT be failing"
  end
end
