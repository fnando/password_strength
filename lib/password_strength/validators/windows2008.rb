module PasswordStrength
  module Validators
    # Validates a Windows 2008 password against the following rules:
    #
    # * Passwords cannot contain the user's account name or parts of the user's full name that exceed two consecutive characters.
    # * Passwords must be at least six characters in length.
    # * Passwords must contain characters from three of the following four categories: English uppercase characters (A through Z); English lowercase characters (a through z); Base 10 digits (0 through 9); Non-alphabetic characters (for example, !, $, #, %).
    #
    # Reference: http://technet.microsoft.com/en-us/library/cc264456.aspx
    #
    class Windows2008 < PasswordStrength::Base
      def test
        return invalid! if password.size < 6

        variety = 0
        variety += 1 if password =~ /[A-Z]/
        variety += 1 if password =~ /[a-z]/
        variety += 1 if password =~ /[0-9]/
        variety += 1 if password =~ PasswordStrength::Base::SYMBOL_RE

        return invalid! if variety < 3
        return invalid! if password_contains_username?

        strong!
      end

      def password_contains_username?
        0.upto(password.size - 1) do |i|
          substring = password[i, 3]
          return true if username.include?(substring)
        end

        false
      end
    end
  end
end
