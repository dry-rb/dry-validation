RSpec.describe Dry::Validation::Result do
  describe '#inspect' do
    let(:params) do
      double(:params, errors: {}, to_h: { email: 'jane@doe.org' })
    end

    it 'returns a string representation' do
      result = Dry::Validation::Result.new(params) do |r|
        r.add_error(:email, 'not valid')
      end

      expect(result.inspect).to eql('#<Dry::Validation::Result{:email=>"jane@doe.org"} errors={:email=>["not valid"]}>')
    end
  end
end
