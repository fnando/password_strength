var strength;

QUnit.module("PasswordStrength", {
  beforeEach: function() {
    strength = new PasswordStrength();
    strength.username = "johndoe";
    strength.password = "mypass";
  }
});

QUnit.test("shortcut", function(assert) {
  strength = PasswordStrength.test("johndoe", "mypass");

  assert.equal("johndoe", strength.username);
  assert.equal("mypass", strength.password);
  assert.ok(strength.status);
});

QUnit.test("deal with empty password", function(assert) {
  strength = PasswordStrength.test("johndoe", "");

  assert.equal(strength.status, "weak");
  assert.ok(strength.isWeak());
});

QUnit.test("detect good strength", function(assert) {
  strength.status = "good";

  assert.ok(strength.isGood());
  assert.ok(strength.isValid("good"));
  assert.equal(strength.isWeak(), false);
  assert.equal(strength.isStrong(), false);
  assert.equal(strength.isInvalid(), false);
});

QUnit.test("detect weak strength", function(assert) {
  strength.status = "weak";

  assert.ok(strength.isWeak());
  assert.ok(strength.isValid("weak"));
  assert.equal(strength.isStrong(), false);
  assert.equal(strength.isGood(), false);
  assert.equal(strength.isInvalid(), false);
});

QUnit.test("detect strong strength", function(assert) {
  strength.status = "strong";

  assert.ok(strength.isStrong());
  assert.ok(strength.isValid("strong"));
  assert.ok(strength.isValid("good"));
  assert.equal(strength.isWeak(), false);
  assert.equal(strength.isGood(), false);
  assert.equal(strength.isInvalid(), false);
});

QUnit.test("test short password", function(assert) {
  strength.password = "abc";
  strength.test();

  assert.equal(strength.score, 0);
  assert.equal(strength.status, "weak");
});

QUnit.test("test password equal to username", function(assert) {
  strength.username = "johndoe";
  strength.password = "johndoe";
  strength.test();

  assert.equal(strength.score, 0);
  assert.equal(strength.status, "weak");
});

QUnit.test("test strong password", function(assert) {
  strength.password = "^P4ssw0rd$";
  strength.test();

  assert.equal(strength.score, 100);
  assert.equal(strength.status, "strong");
});

QUnit.test("test weak password", function(assert) {
  strength.password = "ytrewq";
  strength.test()
  assert.equal(strength.status, "weak");

  strength.password = "asdfghjklm";
  strength.test();
  assert.equal(strength.status, "weak");
});

QUnit.test("test good password", function(assert) {
  strength.password = "12345asdfg";
  strength.test();
  assert.equal(strength.status, "good");

  strength.password = "12345ASDFG";
  strength.test();
  assert.equal(strength.status, "good");

  strength.password = "12345Aa";
  strength.test();
  assert.equal(strength.status, "good");
});

QUnit.test("penalize password with chars-only", function(assert) {
  strength.password = "abcdef";
  assert.equal(strength.scoreFor("only_chars"), -15);
});

QUnit.test("penalize password numbers-only", function(assert) {
  strength.password = "12345";
  assert.equal(strength.scoreFor("only_numbers"), -15);
});

QUnit.test("penalize password equal to username", function(assert) {
  strength.username = "johndoe";
  strength.password = "johndoe";
  assert.equal(strength.scoreFor("username"), -100);
});

QUnit.test("penalize password that contains username", function(assert) {
  strength.username = "johndoe";
  strength.password = "$1234johndoe^";
  assert.equal(strength.scoreFor("username"), -15);
});

QUnit.test("penalize number sequence", function(assert) {
  strength.password = "123";
  assert.equal(strength.scoreFor("sequences"), -15);

  strength.password = "123123";
  assert.equal(strength.scoreFor("sequences"), -30);
});

QUnit.test("penalize letter sequence", function(assert) {
  strength.password = "abc";
  assert.equal(strength.scoreFor("sequences"), -15);

  strength.password = "abcabc";
  assert.equal(strength.scoreFor("sequences"), -30);
});

QUnit.test("penalize number and letter sequence", function(assert) {
  strength.password = "123abc";
  assert.equal(strength.scoreFor("sequences"), -30);

  strength.password = "123abc123abc";
  assert.equal(strength.scoreFor("sequences"), -60);
});

QUnit.test("penalize same letter sequence", function(assert) {
  strength.password = "aaa";
  assert.equal(strength.scoreFor("sequences"), -30);
});

QUnit.test("penalize same number sequence", function(assert) {
  strength.password = "111";
  assert.equal(strength.scoreFor("sequences"), -30);
});

QUnit.test("penalize reversed sequence", function(assert) {
  strength.password = "cba321";
  assert.equal(strength.scoreFor("sequences"), -30);

  strength.password = "cba321cba321";
  assert.equal(strength.scoreFor("sequences"), -60);
});

QUnit.test("penalize short password", function(assert) {
  strength.password = "123";
  assert.equal(strength.scoreFor("password_size"), -100);
});

QUnit.test("penalize repetitions", function(assert) {
  strength.password = "abcdabcdabcd";
  assert.equal(strength.scoreFor("repetitions"), -36);
});

QUnit.test("penalize password length", function(assert) {
  strength.password = "12345";
  assert.equal(strength.scoreFor("password_size"), -100);
});

QUnit.test("reward password with numbers", function(assert) {
  strength.password = "123";
  assert.equal(strength.scoreFor("numbers"), 5);
});

QUnit.test("reward password with symbols", function(assert) {
  strength.password = "$!";
  assert.equal(strength.scoreFor("symbols"), 5);
});

QUnit.test("reward mixed-case passwords", function(assert) {
  strength.password = "aA";
  assert.equal(strength.scoreFor("uppercase_lowercase"), 10);
});

QUnit.test("reward password that contains both numbers and letters", function(assert) {
  strength.password = "a1";
  assert.equal(strength.scoreFor("numbers_chars"), 15);
});

QUnit.test("reward password that contains both numbers and symbols", function(assert) {
  strength.password = "1$";
  assert.equal(strength.scoreFor("numbers_symbols"), 15);
});

QUnit.test("reward password that contains symbols and chars", function(assert) {
  strength.password = "a$";
  assert.equal(strength.scoreFor("symbols_chars"), 15);
});

QUnit.test("detect two-chars repetitions", function(assert) {
  assert.equal(strength.repetitions("11221122", 2), 3);
});

QUnit.test("detect three-chars repetitions", function(assert) {
  assert.equal(strength.repetitions("123123123", 3), 3);
});

QUnit.test("detect four-chars repetitions", function(assert) {
  assert.equal(strength.repetitions("abcdabcdabcd", 4), 4);
});

QUnit.test("use exclude option as regular expression", function(assert) {
  strength.password = "password with whitespaces";
  strength.exclude = /\s/;
  strength.test();

  assert.equal(strength.status, "invalid");
  assert.ok(strength.isInvalid());
  assert.equal(strength.isValid(), false);
});

QUnit.test("set common words", function(assert) {
  assert.ok(PasswordStrength.commonWords.length > 500);
});

QUnit.test("reject common passwords", function(assert) {
  strength.password = PasswordStrength.commonWords[0];
  strength.test();

  assert.equal(strength.status, "invalid");
  assert.ok(strength.isInvalid());
  assert.equal(strength.isValid(), false);
});

QUnit.test("reject long passwords using same character", function(assert) {
    strength.password = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
    strength.test();
    assert.equal(strength.status, "invalid");
    // assert @strength.invalid?
    // refute @strength.valid?
});

QUnit.module("PasswordStrength: jQuery integration", {
  beforeEach: function() {
    $("#sample").html('<input type="text" id="username"><input type="text" id="password">');
    $("#username").val("johndoe");
    $("#password").val("mypass");
  },

  afterEach: function() {
    $("#sample").empty();
  }
});

QUnit.test("test defaults", function(assert) {
  $.strength("#username", "#password");
  $("#password").trigger("keydown");

  assert.equal($("img.strength").length, 1);
});

QUnit.test("custom callback", function(assert) {
  assert.expect(5);

  $.strength("#username", "#password", function(username, password, strength){
    assert.ok($(username).is("#username"));
    assert.ok($(password).is("#password"));
    assert.equal(strength.username, "johndoe");
    assert.equal(strength.password, "mypass");
    assert.equal(strength.status, "weak");
  });

  $("#password").trigger("keydown");
});

QUnit.test("apply callback when username is triggered", function(assert) {
  $.strength("#username", "#password");
  $("#username").trigger("keydown");

  assert.equal($("img.strength").length, 1);
});

QUnit.test("apply weak status to image", function(assert) {
  $.strength("#username", "#password");
  $("#password").trigger("keydown");

  assert.equal($("img.weak").length, 1);
  assert.equal($("img.strength").attr("src"), "/images/weak.png");
});

QUnit.test("apply good status to image", function(assert) {
  $("#password").val("12345asdfg");
  $.strength("#username", "#password");
  $("#password").trigger("keydown");

  assert.equal($("img.good").length, 1);
  assert.equal($("img.strength").attr("src"), "/images/good.png");
});

QUnit.test("apply strong status to image", function(assert) {
  $("#password").val("^P4ssw0rd$");
  $.strength("#username", "#password");
  $("#password").trigger("keydown");

  assert.equal($("img.strong").length, 1);
  assert.equal($("img.strength").attr("src"), "/images/strong.png");
});

QUnit.test("missing username element: use selector as text", function(assert) {
  $("#password").val("^P4ssw0rd$");
  $.strength("root", "#password", function(username, password, strength){
    assert.equal(strength.username, "root");
    assert.equal(strength.password, "^P4ssw0rd$");
  });

  $("#password").trigger("keydown");
});

QUnit.test("missing password element: use selector as text", function(assert) {
  $.strength("#username", "mypass", function(username, password, strength){
    assert.equal(strength.username, "johndoe");
    assert.equal(strength.password, "mypass");
  });

  $("#username").trigger("keydown");
});

QUnit.test("test exclude option as regular expression", function(assert) {
  $.strength("#username", "password with whitespaces", {exclude: /\s/}, function(username, password, strength){
    assert.equal(strength.status, "invalid");
    assert.ok(strength.isInvalid());
  });

  $("#username").trigger("keydown");
});
