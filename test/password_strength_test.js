new Test.Unit.Runner({
	setup: function() {
		strength = new PasswordStrength();
		strength.username = "johndoe";
		strength.password = "mypass";
	},

	teardown: function() {
	},

	// Shortcut
	testShortcut: function() { with(this) {
		strength = PasswordStrength.test("johndoe", "mypass");

		assertEqual("johndoe", strength.username);
		assertEqual("mypass", strength.password);
		assertNotNull(strength.status);
	}},

	// Good strength
	testGoodStrength: function() { with(this) {
		strength.status = "good";
		assert(strength.isGood());
		assert(strength.isValid("good"));
		assertEqual(false, strength.isWeak());
		assertEqual(false, strength.isStrong());
		assertEqual(false, strength.isInvalid());
	}},

	// Weak strength
	testWeakStrength: function() { with(this) {
		strength.status = "weak";
		assert(strength.isWeak());
    assert(strength.isValid("weak"));
    // assertEqual(false, strength.isStrong());
    // assertEqual(false, strength.isGood());
    // assertEqual(false, strength.isInvalid());
	}},

	// Strong strength
	testStrongStrength: function() { with(this) {
		strength.status = "strong";
		assert(strength.isStrong());
		assert(strength.isValid("strong"));
		assert(strength.isValid("good"));
		assertEqual(false, strength.isWeak());
		assertEqual(false, strength.isGood());
		assertEqual(false, strength.isInvalid());
	}},

	// Short password
	testShortPassword: function() { with(this) {
		strength.password = "123";
		strength.test();

		assertEqual(0, strength.score);
		assertEqual("weak", strength.status);
	}},

	// Password equals to username
	testPasswordEqualsToUsername: function() { with(this) {
		strength.username = "johndoe";
		strength.password = "johndoe";
		strength.test();

		assertEqual(0, strength.score);
		assertEqual("weak", strength.status);
	}},

	// Strong password
	testStrongPassword: function() { with(this) {
		strength.password = "^P4ssw0rd$";
		strength.test();

		assertEqual(100, strength.score);
		assertEqual("strong", strength.status);
	}},

	// Weak password
	testWeakPassword: function() { with(this) {
		strength.password = "1234567890";
		strength.test()
		assertEqual("weak", strength.status);

		strength.password = "asdfghjklm";
		strength.test();
		assertEqual("weak", strength.status);
	}},

	// Good password
	testGoodPassword: function() { with(this) {
		strength.password = "12345asdfg";
		strength.test();
		assertEqual("good", strength.status);

		strength.password = "12345ASDFG";
		strength.test();
		assertEqual("good", strength.status);

		strength.password = "12345Aa";
		strength.test();
		assertEqual("good", strength.status);
	}},

	// Penalize password with chars only
	testPenalizePasswordWithCharsOnly: function() { with(this) {
		strength.password = "abcdef";
    	assertEqual(-15, strength.scoreFor("only_chars"));
	}},

	// Penalize password with numbers only
	testPenalizePasswordWithNumbersOnly: function() { with(this) {
		strength.password = "12345";
    	assertEqual(-15, strength.scoreFor("only_numbers"));
	}},

	// Penalize password equals to username
	testPenalizePasswordEqualsToUsername: function() { with(this) {
	    strength.username = "johndoe";
	    strength.password = "johndoe";
	    assertEqual(-100, strength.scoreFor("username"));
	}},

	// Penalize password with username
	testPenalizePasswordWithUsername: function() { with(this) {
		strength.username = "johndoe";
    	strength.password = "$1234johndoe^";
    	assertEqual(-15, strength.scoreFor("username"));
	}},

	// Penalize number sequence
	testPenalizeNumberSequence: function() { with(this) {
		strength.password = "123";
		assertEqual(-15, strength.scoreFor("sequences"));

		strength.password = "123123";
		assertEqual(-30, strength.scoreFor("sequences"));
	}},

	// Penalize letter sequence
	testPenalizeLetterSequence: function() { with(this) {
		strength.password = "abc";
		assertEqual(-15, strength.scoreFor("sequences"));

		strength.password = "abcabc";
		assertEqual(-30, strength.scoreFor("sequences"));
	}},

	// Penalize number and letter sequence
	testPenalizeNumberAndLetterSequence: function() { with(this) {
		strength.password = "123abc";
		assertEqual(-30, strength.scoreFor("sequences"));

		strength.password = "123abc123abc";
		assertEqual(-60, strength.scoreFor("sequences"));
	}},

	// Penalize same letter sequence
	testPenalizeSameLetterSequence: function() { with(this) {
		strength.password = "aaa";
		assertEqual(-30, strength.scoreFor("sequences"));
	}},

	// Penalize same number sequence
	testPenalizeSameNumberSequence: function() { with(this) {
		strength.password = "111";
		assertEqual(-30, strength.scoreFor("sequences"));
	}},

	// Penalize reversed sequence
	testPenalizeReversedSequence: function() { with(this) {
		strength.password = "cba321";
		assertEqual(-30, strength.scoreFor("sequences"));

		strength.password = "cba321cba321";
		assertEqual(-60, strength.scoreFor("sequences"));
	}},

	// Penalize short password
	testPenalizeShortPassword: function() { with(this) {
		strength.password = "123";
    	assertEqual(-100, strength.scoreFor("password_size"));
	}},

	// Penalize repetitions
	testPenalizeRepetitions: function() { with(this) {
	    strength.password = "abcdabcdabcd";
	    assertEqual(-36, strength.scoreFor("repetitions"));
	}},

	// Password length
	testPasswordLength: function() { with(this) {
		strength.password = "12345";
    	assertEqual(20, strength.scoreFor("password_size"));
	}},

	// Password with numbers
	testPasswordWithNumbers: function() { with(this) {
		strength.password = "123";
    	assertEqual(5, strength.scoreFor("numbers"));
	}},

	// Password with symbols
	testPasswordWithSymbols: function() { with(this) {
		strength.password = "$!";
    	assertEqual(5, strength.scoreFor("symbols"));
	}},

	// Password with uppercase and lowercase
	testPasswordWithUppercaseAndLowercase: function() { with(this) {
		strength.password = "aA";
    	assertEqual(10, strength.scoreFor("uppercase_lowercase"));
	}},

	// numbers and chars
	testNumbersAndChars: function() { with(this) {
		strength.password = "a1";
    	assertEqual(15, strength.scoreFor("numbers_chars"));
	}},

	// Numbers and symbols
	testNumbersAndSymbols: function() { with(this) {
		strength.password = "1$";
    	assertEqual(15, strength.scoreFor("numbers_symbols"));
	}},

	// Symbols and chars
	testSymbolsAndChars: function() { with(this) {
		strength.password = "a$";
    	assertEqual(15, strength.scoreFor("symbols_chars"));
	}},

	// Two char repetition
	testTwoCharRepetition: function() { with(this) {
		assertEqual(3, strength.repetitions("11221122", 2));
	}},

	// Three char repetition
	testThreeCharRepetition: function() { with(this) {
		assertEqual(3, strength.repetitions("123123123", 3));
	}},

	// Four char repetition
	testFourCharRepetition: function() { with(this) {
		assertEqual(4, strength.repetitions("abcdabcdabcd", 4));
	}},

	// Exclude option as regular expression
	testExcludeOptionAsRegularExpression: function() { with(this) {
    strength.password = "password with whitespaces";
    strength.exclude = /\s/;
    strength.test();

    assertEqual("invalid", strength.status);
    assert(strength.isInvalid());
    assertEqual(false, strength.isValid());
	}}
});
