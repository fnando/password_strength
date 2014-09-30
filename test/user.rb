class User
  include ActiveModel::Validations

  attr_accessor :username, :password, :login, :email

  def initialize(attributes = {})
    update_attributes(attributes)
  end

  def update_attributes(attributes = {})
    attributes.each {|name, value| public_send "#{name}=", value }
    valid?
  end
end
