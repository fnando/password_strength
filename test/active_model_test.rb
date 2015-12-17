require "test_helper"

class TestActiveModel < Minitest::Test
  def setup
    PasswordStrength.enabled = true
    Object.class_eval { remove_const("User") } if defined?(User)
    load "user.rb"
    @user = User.new
    I18n.locale = :en
  end

  def test_respond_to_validates_strength_of
    assert User.respond_to?(:validates_strength_of)
  end

  def test_error_messages_in_pt
    I18n.locale = 'pt-BR'
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

  def test_lambda_strong_level
    User.validates_strength_of :password, :level => lambda {|u| :strong }

    @user.update_attributes :username => "johndoe", :password => "12345asdfg"
    assert @user.errors.full_messages.any?
  end

  def test_lambda_weak_level
    User.validates_strength_of :password, :level => lambda {|u| :weak }

    @user.update_attributes :username => "johndoe", :password => "johndoe"
    assert @user.errors.full_messages.empty?
  end

  def test_lambda_with_string_return
    User.validates_strength_of :password, :level => lambda {|u| 'weak' }

    @user.update_attributes :username => "johndoe", :password => "johndoe"
    assert @user.errors.full_messages.empty?
  end

  def test_lambda_incorrect_level
    User.validates_strength_of :password, :level => lambda {|u| 'incorrect_level' }

    assert_raises(ArgumentError, "The :level option must be one of [:weak, :good, :strong], a proc or a lambda") do
      @user.update_attributes :username => "johndoe", :password => "johndoe"
    end
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

  def test_exclude_option
    User.validates_strength_of :password, :exclude => /\s/

    @user.update_attributes :password => "^password with whitespaces 1234ASDF$"
    assert @user.errors.full_messages.any?
  end

  def test_ignore_validations_when_password_strength_is_disabled
    User.validates_strength_of :password
    PasswordStrength.enabled = false
    @user.update_attributes :password => ""
    assert @user.valid?
  end

  def test_record_access_from_validator
    tester = Class.new(PasswordStrength::Base) do
      def test
        record.username = 'bar'
        good!
      end
    end

    User.validates_strength_of :password, :using => tester
    @user.username = "foo"
    @user.password = "foo"

    assert @user.username, "foo"
    @user.valid?
    assert @user.username, "bar"
  end
end
