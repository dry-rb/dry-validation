# frozen_string_literal: true

require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.define do
  create_table :users do |table|
    table.column :email, :string
    table.column :age, :integer
  end
end

module AR
  class User < ActiveRecord::Base
    self.table_name = :users

    validates :email, :age, presence: true
    validates :age, numericality: { greater_than: 18 }
  end
end
