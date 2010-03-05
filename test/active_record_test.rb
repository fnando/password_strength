require "test_helper"

class TestActiveRecord < Test::Unit::TestCase
  def setup
    Object.class_eval { remove_const("User") } if defined?(User)
    load "user.rb"
    @user = User.new
  end

  def test_respond_to_validates_strength_of
    assert User.respond_to?(:validates_strength_of)
  end

  def test_defaults
    User.validates_strength_of :password

    @user.update_attributes :username => "johndoe", :password => "johndoe"
    assert @user.errors.full_messages.include?("Password is too weak")
  end

  def test_strong_level
    User.validates_strength_of :password, :level => :strong

    @user.update_attributes :username => "johndoe", :password => "12345asdfg"
    assert @user.errors.full_messages.include?("Password is too weak")
  end

  def test_weak_level
    User.validates_strength_of :password, :level => :weak

    @user.update_attributes :username => "johndoe", :password => "johndoe"
    assert @user.errors.full_messages.empty?
  end

  def test_custom_username
    User.validates_strength_of :password, :with => :login

    @user.update_attributes :login => "johndoe", :password => "johndoe"
    assert @user.errors.full_messages.include?("Password is too weak")
  end

  def test_blank_username
    User.validates_strength_of :password

    @user.update_attributes :password => "johndoe"
    assert @user.errors.full_messages.include?("Password is too weak")
  end
end
