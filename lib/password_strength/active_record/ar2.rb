module PasswordStrength
  module ActiveRecord
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
      options = attr_names.extract_options!
      options.reverse_merge!(:level => :good, :with => :username, :using => PasswordStrength::Base)

      raise ArgumentError, "The :with option must be supplied" unless options.include?(:with)
      raise ArgumentError, "The :exclude options must be an array of string or regular expression" if options[:exclude] && !options[:exclude].kind_of?(Array) && !options[:exclude].kind_of?(Regexp)
      raise ArgumentError, "The :level option must be one of [:weak, :good, :strong]" unless [:weak, :good, :strong].include?(options[:level])

      validates_each(attr_names, options) do |record, attr_name, value|
        strength = options[:using].new(record.send(options[:with]), value, :exclude => options[:exclude])
        strength.test
        record.errors.add(attr_name, :too_weak, options) unless PasswordStrength.enabled && strength.valid?(options[:level])
      end
    end
  end
end

class ActiveRecord::Base # :nodoc:
  extend PasswordStrength::ActiveRecord
end
