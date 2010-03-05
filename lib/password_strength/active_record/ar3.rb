module ActiveModel # :nodoc:
  module Validations # :nodoc:
    class StrengthValidator < EachValidator # :nodoc: all
      def initialize(options)
        super(options.reverse_merge(:level => :good, :with => :username))
      end

      def validate_each(record, attribute, value)
        strength = PasswordStrength.test(record.send(options[:with]), value)
        record.errors.add(attribute, :too_weak, :default => options[:message], :value => value) unless strength.valid?(options[:level])
      end

      def check_validity!
        raise ArgumentError, "The :with option must be supplied" unless options.include?(:with)
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
      def validates_strength_of(*attr_names)
        validates_with StrengthValidator, _merge_attributes(attr_names)
      end
    end
  end
end
