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
    def validates_strength_of(*attr_names)
      options = attr_names.extract_options!
      options.reverse_merge!(:level => :good, :with => :username)

      raise ArgumentError, "The :with option must be supplied" unless options.include?(:with)
      raise ArgumentError, "The :exclude options must be an array of string or regular expression" if options[:exclude] && !options[:exclude].kind_of?(Array) && !options[:exclude].kind_of?(Regexp)
      raise ArgumentError, "The :level option must be one of [:weak, :good, :strong]" unless [:weak, :good, :strong].include?(options[:level])

      validates_each(attr_names, options) do |record, attr_name, value|
        strength = PasswordStrength.test(record.send(options[:with]), value, :exclude => options[:exclude])
        record.errors.add(attr_name, :too_weak, options) unless strength.valid?(options[:level])
      end
    end
  end
end

class ActiveRecord::Base # :nodoc:
  extend PasswordStrength::ActiveRecord
end
