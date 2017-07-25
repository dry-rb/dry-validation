require 'dry/validation/messages/i18n'

RSpec.describe Messages::Namespaced do
  let(:namespace) { :user }

  context 'when namespaced build from Messages::YAML' do
    subject(:messages) { Messages::YAML.new(Messages::YAML.load_file(path)).namespaced(namespace) }

    let(:path) { SPEC_ROOT.join('fixtures/locales/en.yml') }

    describe '#rule' do
      subject { messages.rule('name') }

      it { expect(subject).to eq('Name') }
    end

    describe '#key?' do
      let(:key) { "%{locale}.rules.#{namespace}.name" }
      subject { messages.key?(key, {locale: :en}) }

      it { expect(subject).to be_truthy }
    end

    describe '#get' do
      let(:key) { "%{locale}.rules.#{namespace}.name" }
      subject { messages.get(key, {locale: :en}) }

      it { expect(subject).to eq('Name') }
    end
  end

  context 'when namespaced build from Messages::I18n' do
    subject(:messages) { Messages::I18n.new.namespaced(namespace) }

    before do
      I18n.config.available_locales_set << :pl
      I18n.load_path.concat(%w(en pl).map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") })
      I18n.backend.load_translations
      I18n.locale = :pl
    end

    describe '#rule' do
      subject { messages.rule('name') }

      it { expect(subject).to eq('Name') }
    end

    describe '#key?' do
      let(:key) { "rules.#{namespace}.name" }
      subject { messages.key?(key, {locale: :en}) }

      it { expect(subject).to be_truthy }
    end

    describe '#get' do
      let(:key) { "rules.#{namespace}.name" }
      subject { messages.get(key, {locale: :en}) }

      it { expect(subject).to eq('Name') }
    end

    after(:all) do
      I18n.locale = I18n.default_locale
    end
  end
end
