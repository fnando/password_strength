ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :username
    t.string :email
    t.string :login
    t.string :password
  end
end