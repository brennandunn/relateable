ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database  => ":memory:"

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string      :name
    t.integer     :age
    t.text        :bio
  end
  
  create_table :model_relations do |t|
    t.integer     :model_id
    t.integer     :associated_id
    t.string      :model_type
    t.float       :score
  end
end

class User < ActiveRecord::Base ; end