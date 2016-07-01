RSpec.describe 'Extending DSL' do
  it 'allows configuring custom DSL methods' do
    dsl_ext = Module.new do
      def maybe_int(name, *predicates, &block)
        required(name, [:nil, :int]).maybe(:int?, *predicates, &block)
      end
    end

    Dry::Validation::Schema.configure do |config|
      config.dsl_extensions = dsl_ext
    end

    schema = Dry::Validation.Schema do
      configure do
        config.input_processor = :form
        config.type_specs = true
      end

      maybe_int(:age)
    end

    expect(schema.(age: nil)).to be_success
    expect(schema.(age: 1)).to be_success
    expect(schema.(age: '1')).to be_success
    expect(schema.(age: 'foo').messages).to eql(age: ['must be an integer'])
  end
end
