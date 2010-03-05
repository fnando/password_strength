new Test.Unit.Runner({
	setup: function() {
		$("#sample").html('<input type="text" id="username"><input type="text" id="password">');
		$("#username").val("johndoe");
		$("#password").val("mypass");
	},

	teardown: function() {
		$("#sample").empty();
	},

	// Respond to strength
	testRespondToStrength: function() { with(this) {
		assertRespondsTo("strength", jQuery);
	}},

	// Defaults
	testDefaults: function() { with(this) {
		$.strength("#username", "#password");
		$("#password").trigger("keydown");

		assertEqual(1, $("img.strength").length);
	}},

	// Custom callback
	testCustomCallback: function() { with(this) {
		$.strength("#username", "#password", function(username, password, strength){
			assert($(username).is("#username"));
			assert($(password).is("#password"));
			assert("johndoe", strength.username);
			assert("password", strength.password);
			assert("weak", strength.status);
		});

		$("#password").trigger("keydown");
	}},

	// Apply callback when username is triggered
	testApplyCallbackWhenUsernameIsTriggered: function() { with(this) {
		$.strength("#username", "#password");
		$("#username").trigger("keydown");

		assertEqual(1, $("img.strength").length);
	}},

	// Apply weak status to image
	testApplyWeakStatusToImage: function() { with(this) {
		$.strength("#username", "#password");
		$("#password").trigger("keydown");

		assertEqual(1, $("img.weak").length);
		assertEqual("/images/weak.png", $("img.strength").attr("src"));
	}},

	// Apply good status to image
	testApplyGoodStatusToImage: function() { with(this) {
		$("#password").val("12345asdfg");
		$.strength("#username", "#password");
		$("#password").trigger("keydown");

		assertEqual(1, $("img.good").length);
		assertEqual("/images/good.png", $("img.strength").attr("src"));
	}},

	// Apply strong status to image
	testApplyStrongStatusToImage: function() { with(this) {
		$("#password").val("^P4ssw0rd$");
		$.strength("#username", "#password");
		$("#password").trigger("keydown");

		assertEqual(1, $("img.strong").length);
		assertEqual("/images/strong.png", $("img.strength").attr("src"));
	}},
});
