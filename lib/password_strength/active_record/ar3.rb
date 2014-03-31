module ActiveModel # :nodoc:
  module Validations # :nodoc:
    class StrengthValidator < EachValidator # :nodoc: all
      def initialize(options)
        super(options.reverse_merge(:level => :good, :with => :username, :using => PasswordStrength::Base))
      end

      def validate_each(record, attribute, value)
        return unless PasswordStrength.enabled
        strength = options[:using].new(record.send(options[:with]), value, :exclude => options[:exclude], :record => record)
        strength.test
        record.errors.add(attribute, :too_weak, options) unless PasswordStrength.enabled && strength.valid?(options[:level])
      end

      def check_validity!
        raise ArgumentError, "The :with option must be supplied" unless options.include?(:with)
        raise ArgumentError, "The :exclude options must be an array of strings or regular expression" if options[:exclude] && !options[:exclude].kind_of?(Array) && !options[:exclude].kind_of?(Regexp)
        raise ArgumentError, "The :level option must be one of [:weak, :good, :strong]" unless [:weak, :good, :strong].include?(options[:level])
        super
      end
    end

    module ClassMethods
      # Validates that the specified attributes are not weak (according to several rules).
      #
      #   class Person < ActiveRecord::Base
      #     validates_strength_of :password
      #   end
      #
      # The default options are <tt>:level => :good, :with => :username</tt>.
      #
      # If you want to compare your password against other field, you have to set the <tt>:with</tt> option.
      #
      #   validates_strength_of :password, :with => :email
      #
      # The available levels are: <tt>:weak</tt>, <tt>:good</tt> and <tt>:strong</tt>
      #
      # You can also provide a custom class/module that will test that password.
      #
      #   validates_strength_of :password, :using => CustomPasswordTester
      #
      # Your +CustomPasswordTester+ class should override the default implementation. In practice, you're
      # going to override only the +test+ method that must call one of the following methods:
      # <tt>invalid!</tt>, <tt>weak!</tt>, <tt>good!</tt> or <tt>strong!</tt>.
      #
      #   class CustomPasswordTester < PasswordStrength::Base
      #     def test
      #       if password != "mypass"
      #         invalid!
      #       else
      #         strong!
      #       end
      #     end
      #   end
      #
      # The tester above will accept only +mypass+ as password.
      #
      # PasswordStrength implements two validators: <tt>PasswordStrength::Base</tt> and <tt>PasswordStrength::Validators::Windows2008</tt>.
      #
      def validates_strength_of(*attr_names)
        validates_with StrengthValidator, _merge_attributes(attr_names)
      end
    end
  end
end
