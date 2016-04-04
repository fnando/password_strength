# Introduction

Check password strength against several rules. Includes ActiveRecord/ActiveModel support.

<a href="https://travis-ci.org/fnando/password_strength"><img src="https://travis-ci.org/fnando/password_strength.svg" alt="Build Status" /></a>

Validates the strength of a password according to several rules:

* size
* 3+ numbers
* 2+ special characters
* uppercased and downcased letters
* combination of numbers, letters and symbols
* password contains username
* sequences (123, abc, aaa)
* repetitions
* can't be a common password (view list at support/common.txt)

Some results:

* `123`: weak
* `123abc`: weak
* `aaaaaa`: weak
* `myPass145`: good
* `myPass145$`: strong

## Install

```
gem install password_strength
```

or put this in your Gemfile:

```ruby
gem "password_strength"
```

The JavaScript code is also available as a NPM package.

```
npm install @fnando/password_strength --save
```

If you want the source go to http://github.com/fnando/password_strength

## Usage

```ruby
strength = PasswordStrength.test("johndoe", "mypass")
#=> return a object

strength.good?
#=> status == :good

strength.weak?
#=> status == :weak

strength.strong?
#=> status == :strong

strength.status
#=> can be :weak, :good, :strong

strength.valid?(:strong)
#=> strength == :strong

strength.valid?(:good)
#=> strength == :good or strength == :strong
```

## ActiveRecord/ActiveModel

The PasswordStrength library comes with ActiveRecord/ActiveModel support.

```ruby
class Person < ActiveRecord::Base
  validates_strength_of :password
end
```

To be honest, you can use it with plain ActiveModel objects.

```ruby
class Person
  include ActiveModel::Model
  validates_strength_of :password
end

# or simply

class Person
  include ActiveModel::Validations
  validates_strength_of :password
end
```

The default options are `:level => :good, :with => :username`.

If you want to compare your password against other field, you have to set the `:with` option.

```ruby
validates_strength_of :password, :with => :email
```

The available levels are: `:weak`, `:good` and `:strong`.

```ruby
validates_strength_of :password, :with => :email, :level => :good
```

Also you can set level with a lambda.

```ruby
validates_strength_of :password, :with => :email, :level => lambda {|u| :good }
```

You can also provide a custom class/module that will test that password.

```ruby
validates_strength_of :password, :using => CustomPasswordTester
```

Your `CustomPasswordTester` class should override the default implementation. In practice, you're going to override only the `test` method that must call one of the following methods: `invalid!`, `weak!`, `good!` or `strong!`.

```ruby
class CustomPasswordTester < PasswordStrength::Base
  def test
    if password != "mypass"
      invalid!
    else
      strong!
    end
  end
end
```

The tester above will accept only +mypass+ as password.

PasswordStrength implements two validators: `PasswordStrength::Base` and `PasswordStrength::Validators::Windows2008`.

**ATTENTION:** Custom validators are not supported by JavaScript yet!

## JavaScript

The PasswordStrength also implements the algorithm in the JavaScript.

```javascript
var strength = PasswordStrength.test("johndoe", "mypass");
strength.isGood();
strength.isStrong();
strength.isWeak();
strength.isValid("good");
```

The API is basically the same!

You can use the `:exclude` option. Only regular expressions are supported for now.

```javascript
var strength = PasswordStrength.test("johndoe", "password with whitespaces", {exclude: /\s/});
strength.isInvalid();
```

Additionaly, a jQuery plugin is available.

```javascript
$.strength("#username", "#password");
```

The line above will validate the `#password` field against `#username`.
The result will be an image to the respective strength status. By default the image path will be
`/images/weak.png`, `/images/good.png` and `/images/strong.png`.

You can overwrite the image path and the default callback.

```javascript
$.strength.weakImage = "/weak.png";
$.strength.goodImage = "/good.png";
$.strength.strongImage = "/strong.png";
$.strength.callback = function(username, password, strength) {
    // do whatever you want
};
```

If you just want to overwrite the callback, you can simple do

```javascript
$.strength("#username", "#password", function(username, password, strength){
    // do whatever you want
});
```

Get the files:

* https://github.com/fnando/password_strength/blob/master/app/assets/javascripts/jquery_strength.js
* https://github.com/fnando/password_strength/blob/master/app/assets/javascripts/password_strength.js

If you're using asset pipeline, just add the following lines to your `application.js`.

```javascript
//= require jquery
//= require password_strength
//= require jquery_strength
```

## Running tests

### Ruby

1. Install all dependencies with `bundle install`.
2. Run `rake test`.

### JavaScript

1. Install Node.js, then run `npm install`.
2. Open `test/password_strength_test.html` in your target browser.

## License

(The MIT License)

Copyright © 2010-2016 Nando Vieira (http://nandovieira.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
