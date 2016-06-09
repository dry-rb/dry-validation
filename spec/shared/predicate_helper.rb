shared_context 'predicate helper' do
  def p(name, *args)
    predicates[name].curry(*args).to_ast
  end

  let!(:predicates) do
    Module.new {
      include Dry::Logic::Predicates

      predicate(:email?) { |_| true }
      predicate(:type?) { |_| true }
    }
  end
end
