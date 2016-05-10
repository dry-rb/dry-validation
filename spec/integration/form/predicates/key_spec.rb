# See: https://github.com/dry-rb/dry-validation/issues/127
# RSpec.describe 'Predicates: Key' do
#   context 'with required' do
#     subject(:schema) do
#       Dry::Validation.Form do
#         required(:foo) { key? }
#       end
#     end

#     context 'with valid input' do
#       let(:input) { { 'foo' => 'bar' } }

#       it 'is successful' do
#         expect(result).to be_successful
#       end
#     end

#     context 'with missing input' do
#       let(:input) { {} }

#       it 'is not successful' do
#         expect(result).to be_failing ['is missing']
#       end
#     end

#     context 'with nil input' do
#       let(:input) { { 'foo' => nil } }

#       it 'is successful' do
#         expect(result).to be_successful
#       end
#     end

#     context 'with blank input' do
#       let(:input) { { 'foo' => '' } }

#       it 'is successful' do
#         expect(result).to be_successful
#       end
#     end
#   end

#   context 'with optional' do
#     subject(:schema) do
#       Dry::Validation.Form do
#         optional(:foo) { key? }
#       end
#     end

#     context 'with valid input' do
#       let(:input) { { 'foo' => 'bar' } }

#       it 'is successful' do
#         expect(result).to be_successful
#       end
#     end

#     context 'with missing input' do
#       let(:input) { {} }

#       it 'is successful' do
#         expect(result).to be_successful
#       end
#     end

#     context 'with nil input' do
#       let(:input) { { 'foo' => nil } }

#       it 'is successful' do
#         expect(result).to be_successful
#       end
#     end

#     context 'with blank input' do
#       let(:input) { { 'foo' => '' } }

#       it 'is successful' do
#         expect(result).to be_successful
#       end
#     end
#   end

#   context 'as macro' do
#     context 'with required' do
#       context 'with value' do
#         subject(:schema) do
#           Dry::Validation.Form do
#             required(:foo).value(:key?)
#           end
#         end

#         context 'with valid input' do
#           let(:input) { { 'foo' => 'bar' } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end

#         context 'with missing input' do
#           let(:input) { {} }

#           it 'is not successful' do
#             expect(result).to be_failing ['is missing']
#           end
#         end

#         context 'with nil input' do
#           let(:input) { { 'foo' => nil } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end

#         context 'with blank input' do
#           let(:input) { { 'foo' => '' } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end
#       end

#       context 'with filled' do
#         subject(:schema) do
#           Dry::Validation.Form do
#             required(:foo).filled(:key?)
#           end
#         end

#         context 'with valid input' do
#           let(:input) { { 'foo' => 'bar' } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end

#         context 'with missing input' do
#           let(:input) { {} }

#           it 'is not successful' do
#             expect(result).to be_failing ['is missing']
#           end
#         end

#         context 'with nil input' do
#           let(:input) { { 'foo' => nil } }

#           it 'is not successful' do
#             expect(result).to be_failing ['must be filled']
#           end
#         end

#         context 'with blank input' do
#           let(:input) { { 'foo' => '' } }

#           it 'is not successful' do
#             expect(result).to be_failing ['must be filled']
#           end
#         end
#       end

#       context 'with maybe' do
#         subject(:schema) do
#           Dry::Validation.Form do
#             required(:foo).maybe(:key?)
#           end
#         end

#         context 'with valid input' do
#           let(:input) { { 'foo' => 'bar' } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end

#         context 'with missing input' do
#           let(:input) { {} }

#           it 'is not successful' do
#             expect(result).to be_failing ['is missing']
#           end
#         end

#         context 'with nil input' do
#           let(:input) { { 'foo' => nil } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end

#         context 'with blank input' do
#           let(:input) { { 'foo' => '' } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end
#       end
#     end

#     context 'with optional' do
#       context 'with value' do
#         subject(:schema) do
#           Dry::Validation.Form do
#             optional(:foo).value(:key?)
#           end
#         end

#         context 'with valid input' do
#           let(:input) { { 'foo' => 'bar' } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end

#         context 'with missing input' do
#           let(:input) { {} }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end

#         context 'with nil input' do
#           let(:input) { { 'foo' => nil } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end

#         context 'with blank input' do
#           let(:input) { { 'foo' => '' } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end
#       end

#       context 'with filled' do
#         subject(:schema) do
#           Dry::Validation.Form do
#             optional(:foo).filled(:key?)
#           end
#         end

#         context 'with valid input' do
#           let(:input) { { 'foo' => 'bar' } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end

#         context 'with missing input' do
#           let(:input) { {} }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end

#         context 'with nil input' do
#           let(:input) { { 'foo' => nil } }

#           it 'is not successful' do
#             expect(result).to be_failing ['must be filled']
#           end
#         end

#         context 'with blank input' do
#           let(:input) { { 'foo' => '' } }

#           it 'is not successful' do
#             expect(result).to be_failing ['must be filled']
#           end
#         end
#       end

#       context 'with maybe' do
#         subject(:schema) do
#           Dry::Validation.Form do
#             optional(:foo).maybe(:key?)
#           end
#         end

#         context 'with valid input' do
#           let(:input) { { 'foo' => 'bar' } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end

#         context 'with missing input' do
#           let(:input) { {} }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end

#         context 'with nil input' do
#           let(:input) { { 'foo' => nil } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end

#         context 'with blank input' do
#           let(:input) { { 'foo' => '' } }

#           it 'is successful' do
#             expect(result).to be_successful
#           end
#         end
#       end
#     end
#   end
# end
