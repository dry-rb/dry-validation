require 'dry/validation/messages/abstract'

RSpec.describe Messages::YAML do
  subject(:messages) { Messages::YAML.new(Messages::YAML.load_file(path)) }

  let(:path) { SPEC_ROOT.join('fixtures/locales/en.yml') }

  describe '#rule' do
    subject { messages.rule('email') }

    it { expect(subject).to eq('E-mail') }
  end

  describe '#key?' do
    let(:key) { '%{locale}.rules.email' }
    subject { messages.key?(key, {locale: :en}) }

    it { expect(subject).to be_truthy }
  end

  describe '#get' do
    let(:key) { '%{locale}.rules.email' }
    subject { messages.get(key, {locale: :en}) }

    it { expect(subject).to eq('E-mail') }
  end
end
