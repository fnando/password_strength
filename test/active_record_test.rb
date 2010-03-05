require "test_helper"

class TestActiveRecord < Test::Unit::TestCase
  def setup
    Object.class_eval { remove_const("User") } if defined?(User)
    load "user.rb"
    @user = User.new
    I18n.locale = :en
  end

  def test_respond_to_validates_strength_of
    assert User.respond_to?(:validates_strength_of)
  end

  def test_error_messages_in_pt
    I18n.locale = :pt
    User.validates_strength_of :password
    @user.update_attributes :password => "123"
    assert @user.errors.full_messages.include?("Password não é segura; utilize letras (maiúsculas e mínusculas), números e caracteres especiais")
  end

  def test_error_messages_in_en
    I18n.locale = :en
    User.validates_strength_of :password
    @user.update_attributes :password => "123"
    assert @user.errors.full_messages.include?("Password is not secure; use letters (uppercase and downcase), numbers and special characters")
  end

  def test_custom_error_message
    User.validates_strength_of :password, :message => "is too weak"
    @user.update_attributes :password => "123"
    assert @user.errors.full_messages.include?("Password is too weak")
  end

  def test_defaults
    User.validates_strength_of :password

    @user.update_attributes :username => "johndoe", :password => "johndoe"
    assert @user.errors.full_messages.any?
  end

  def test_strong_level
    User.validates_strength_of :password, :level => :strong

    @user.update_attributes :username => "johndoe", :password => "12345asdfg"
    assert @user.errors.full_messages.any?
  end

  def test_weak_level
    User.validates_strength_of :password, :level => :weak

    @user.update_attributes :username => "johndoe", :password => "johndoe"
    assert @user.errors.full_messages.empty?
  end

  def test_custom_username
    User.validates_strength_of :password, :with => :login

    @user.update_attributes :login => "johndoe", :password => "johndoe"
    assert @user.errors.full_messages.any?
  end

  def test_blank_username
    User.validates_strength_of :password

    @user.update_attributes :password => "johndoe"
    assert @user.errors.full_messages.any?
  end
end
