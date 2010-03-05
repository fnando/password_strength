(function($){
	$.strength = function(username, password, callback) {
		username = $(username);
		password = $(password);
		var strength = new PasswordStrength();
		callback = callback || $.strength.callback;

		var handler = function(){
			strength.username = $(username).val();
			strength.password = $(this).val();
			strength.test();
			callback(username, password, strength);
		};

		$(username).keydown(handler);
		$(password).keydown(handler);
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

			console.debug($.strength[strength.status + "Image"])
		},
		weakImage: "/images/weak.png",
		goodImage: "/images/good.png",
		strongImage: "/images/strong.png"
	});
})(jQuery);
