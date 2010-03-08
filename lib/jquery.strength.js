(function($){
	$.strength = function(username, password, callback) {
		var usernameField = $(username);
		var passwordField = $(password);
		var strength = new PasswordStrength();
		callback = callback || $.strength.callback;

		var handler = function(){
			strength.username = $(usernameField).val() || username;
			strength.password = $(passwordField).val() || password;
			strength.test();
			callback(usernameField, passwordField, strength);
		};

		$(usernameField).keydown(handler);
		$(passwordField).keydown(handler);
	};

	$.extend($.strength, {
		callback: function(username, password, strength){
			var img = $(password).next("img.strength");

			if (!img.length) {
				$(password).after("<img class='strength'>");
				img = $("img.strength");
			}

			$(img)
				.removeClass("weak")
				.removeClass("good")
				.removeClass("strong")
				.addClass(strength.status)
				.attr("src", $.strength[strength.status + "Image"]);
		},
		weakImage: "/images/weak.png",
		goodImage: "/images/good.png",
		strongImage: "/images/strong.png"
	});
})(jQuery);
