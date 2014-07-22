var PasswordStrength = (function(){
  var MULTIPLE_NUMBERS_RE = /\d.*?\d.*?\d/;
  var MULTIPLE_SYMBOLS_RE = /[!@#$%^&*?_~].*?[!@#$%^&*?_~]/;
  var UPPERCASE_LOWERCASE_RE = /([a-z].*[A-Z])|([A-Z].*[a-z])/;
  var SYMBOL_RE = /[!@#\$%^&*?_~]/;

  function PasswordStrength() {
    this.username = null;
    this.password = null;
    this.score = 0;
    this.status = null;
  }

  PasswordStrength.fn = PasswordStrength.prototype;

  PasswordStrength.fn.test = function() {
    var score;
    this.score = score = 0;

    if (this.containInvalidMatches()) {
      this.status = "invalid";
    } else if (this.usesCommonWord()) {
      this.status = "invalid";
    } else {
      score += this.scoreFor("password_size");
      score += this.scoreFor("numbers");
      score += this.scoreFor("symbols");
      score += this.scoreFor("uppercase_lowercase");
      score += this.scoreFor("numbers_chars");
      score += this.scoreFor("numbers_symbols");
      score += this.scoreFor("symbols_chars");
      score += this.scoreFor("only_chars");
      score += this.scoreFor("only_numbers");
      score += this.scoreFor("username");
      score += this.scoreFor("sequences");
      score += this.scoreFor("repetitions");

      if (score < 0) {
        score = 0;
      }

      if (score > 100) {
        score = 100;
      }

      if (score < 35) {
        this.status = "weak";
      }

      if (score >= 35 && score < 70) {
        this.status = "good";
      }

      if (score >= 70) {
        this.status = "strong";
      }
    }

    this.score = score;
    return this.score;
  };

  PasswordStrength.fn.scoreFor = function(name) {
    score = 0;

    switch (name) {
      case "password_size":
        if (this.password.length < 6) {
          score = -100;
        } else {
          score = this.password.length * 4;
        }
        break;

      case "numbers":
        if (this.password.match(MULTIPLE_NUMBERS_RE)) {
          score = 5;
        }
        break;

      case "symbols":
        if (this.password.match(MULTIPLE_SYMBOLS_RE)) {
          score = 5;
        }
        break;

      case "uppercase_lowercase":
        if (this.password.match(UPPERCASE_LOWERCASE_RE)) {
          score = 10;
        }
        break;

      case "numbers_chars":
        if (this.password.match(/[a-z]/i) && this.password.match(/[0-9]/)) {
          score = 15;
        }
        break;

      case "numbers_symbols":
        if (this.password.match(/[0-9]/) && this.password.match(SYMBOL_RE)) {
          score = 15;
        }
        break;

      case "symbols_chars":
        if (this.password.match(/[a-z]/i) && this.password.match(SYMBOL_RE)) {
          score = 15;
        }
        break;

      case "only_chars":
        if (this.password.match(/^[a-z]+$/i)) {
          score = -15;
        }
        break;

      case "only_numbers":
        if (this.password.match(/^\d+$/i)) {
          score = -15;
        }
        break;

      case "username":
        if (this.password == this.username) {
          score = -100;
        } else if (this.password.indexOf(this.username) != -1) {
          score = -15;
        }
        break;

      case "sequences":
        score += -15 * this.sequences(this.password);
        score += -15 * this.sequences(this.reversed(this.password));
        break;

      case "repetitions":
        score += -(this.repetitions(this.password, 2) * 4);
        score += -(this.repetitions(this.password, 3) * 3);
        score += -(this.repetitions(this.password, 4) * 2);
        break;
    };

    return score;
  };

  PasswordStrength.fn.isGood = function() {
    return this.status == "good";
  };

  PasswordStrength.fn.isWeak = function() {
    return this.status == "weak";
  };

  PasswordStrength.fn.isStrong = function() {
    return this.status == "strong";
  };

  PasswordStrength.fn.isInvalid = function() {
    return this.status == "invalid";
  };

  PasswordStrength.fn.isValid = function(level) {
    if(level == "strong") {
      return this.isStrong();
    } else if (level == "good") {
      return this.isStrong() || this.isGood();
    } else {
      return !this.containInvalidMatches();
    }
  };

  PasswordStrength.fn.containInvalidMatches = function() {
    if (!this.exclude) {
      return false;
    }

    if (!this.exclude.test) {
      return false;
    }

    return this.exclude.test(this.password.toString());
  };

  PasswordStrength.fn.usesCommonWord = function() {
    return PasswordStrength.commonWords.indexOf(this.password.toLowerCase()) >= 0;
  };

  PasswordStrength.fn.sequences = function(text) {
    var matches = 0;
    var sequenceSize = 0;
    var codes = [];
    var len = text.length;
    var previousCode, currentCode;

    for (var i = 0; i < len; i++) {
      currentCode = text.charCodeAt(i);
      previousCode = codes[codes.length - 1];
      codes.push(currentCode);

      if (previousCode) {
        if (currentCode == previousCode + 1 || previousCode == currentCode) {
          sequenceSize += 1;
        } else {
          sequenceSize = 0;
        }
      }

      if (sequenceSize == 2) {
        matches += 1;
      }
    }

    return matches;
  };

  PasswordStrength.fn.repetitions = function(text, size) {
    var count = 0;
    var matches = {};
    var len = text.length;
    var substring;
    var occurrences;
    var tmpText;

    for (var i = 0; i < len; i++) {
      substring = text.substr(i, size);
      occurrences = 0;
      tmpText = text;

      if (matches[substring] || substring.length < size) {
        continue;
      }

      matches[substring] = true;

      while ((i = tmpText.indexOf(substring)) != -1) {
        occurrences += 1;
        tmpText = tmpText.substr(i + 1);
      };

      if (occurrences > 1) {
        count += 1;
      }
    }

    return count;
  };

  PasswordStrength.fn.reversed = function(text) {
    var newText = "";
    var len = text.length;

    for (var i = len -1; i >= 0; i--) {
      newText += text.charAt(i);
    }

    return newText;
  };

  PasswordStrength.test = function(username, password) {
    strength = new PasswordStrength();
    strength.username = username;
    strength.password = password;
    strength.test();
    return strength;
  };

  PasswordStrength.commonWords = ["000000", "010203", "1111", "11111", "111111", "11111111", "112233", "1212", "121212", "123123", "1234", "12345", "123456", "1234567", "12345678", "123456789", "1234567890", "1313", "131313", "2000", "2112", "2222", "232323", "3333", "4128", "4321", "4444", "5150", "5555", "555555", "654321", "6666", "666666", "6969", "696969", "7777", "777777", "7777777", "8675309", "987654", "aaaa", "aaaaaa", "abc123", "abcdef", "abgrtyu", "access", "access14", "action", "admin", "adobe123", "albert", "alex", "alexis", "amanda", "amateur", "andrea", "andrew", "angel", "angela", "angels", "animal", "anthony", "apollo", "apple", "apples", "arsenal", "arthur", "asdf", "asdfgh", "ashley", "asshole", "august", "austin", "azerty", "baby", "badboy", "bailey", "banana", "barney", "baseball", "batman", "beach", "bear", "beaver", "beavis", "beer", "bigcock", "bigdaddy", "bigdick", "bigdog", "bigtits", "bill", "billy", "birdie", "bitch", "bitches", "biteme", "black", "blazer", "blonde", "blondes", "blowjob", "blowme", "blue", "bond007", "bonnie", "booboo", "boobs", "booger", "boomer", "booty", "boston", "brandon", "brandy", "braves", "brazil", "brian", "bronco", "broncos", "bubba", "buddy", "bulldog", "buster", "butter", "butthead", "calvin", "camaro", "cameron", "canada", "captain", "carlos", "carter", "casper", "charles", "charlie", "cheese", "chelsea", "chester", "chevy", "chicago", "chicken", "chris", "cocacola", "cock", "coffee", "college", "compaq", "computer", "cookie", "cool", "cooper", "corvette", "cowboy", "cowboys", "cream", "crystal", "cumming", "cumshot", "cunt", "dakota", "dallas", "daniel", "danielle", "dave", "david", "debbie", "dennis", "deuseamor", "diablo", "diamond", "dick", "dirty", "doctor", "doggie", "dolphin", "dolphins", "donald", "dragon", "dreams", "driver", "eagle", "eagle1", "eagles", "edward", "einstein", "enjoy", "enter", "eric", "erotic", "extreme", "falcon", "FaMiLia", "fender", "ferrari", "fire", "firebird", "fish", "fishing", "florida", "flower", "flyers", "football", "ford", "forever", "frank", "fred", "freddy", "freedom", "fuck", "fucked", "fucker", "fucking", "fuckme", "fuckyou", "gandalf", "gateway", "gators", "gemini", "george", "giants", "ginger", "girl", "girls", "golden", "golf", "golfer", "gordon", "great", "green", "gregory", "guitar", "gunner", "hammer", "hannah", "happy", "hardcore", "harley", "heather", "hello", "helpme", "hentai", "hockey", "hooters", "horney", "horny", "hotdog", "house", "hunter", "hunting", "iceman", "iloveyou", "internet", "iwantu", "jack", "jackie", "jackson", "jaguar", "jake", "james", "japan", "jasmine", "jason", "jasper", "jennifer", "jeremy", "jessica", "jesus", "jesuscristo", "john", "johnny", "johnson", "jordan", "joseph", "joshua", "juice", "junior", "justin", "kelly", "kevin", "killer", "king", "kitty", "knight", "ladies", "lakers", "lauren", "leather", "legend", "letmein", "little", "london", "love", "lover", "lovers", "lucky", "maddog", "madison", "maggie", "magic", "magnum", "MARCELO", "marine", "mark", "marlboro", "martin", "marvin", "master", "matrix", "matt", "matthew", "maverick", "maxwell", "melissa", "member", "mercedes", "merlin", "michael", "michelle", "mickey", "midnight", "mike", "miller", "mine", "mistress", "money", "monica", "monkey", "monster", "morgan", "mother", "mountain", "movie", "muffin", "murphy", "music", "mustang", "naked", "nascar", "nathan", "naughty", "ncc1701", "newyork", "nicholas", "nicole", "ninja", "nipple", "nipples", "oliver", "orange", "ou812", "packers", "panther", "panties", "paris", "parker", "pass", "passw0rd", "password", "password1", "password12", "password123", "patrick", "paul", "peaches", "peanut", "penis", "pepper", "peter", "phantom", "phoenix", "photoshop", "player", "please", "pookie", "porn", "porno", "porsche", "power", "prince", "princess", "private", "purple", "pussies", "pussy", "qazwsx", "qwert", "qwerty", "qwertyui", "rabbit", "rachel", "racing", "raiders", "rainbow", "ranger", "rangers", "rebecca", "redskins", "redsox", "redwings", "richard", "robert", "rock", "rocket", "rosebud", "runner", "rush2112", "russia", "samantha", "sammy", "samson", "sandra", "saturn", "scooby", "scooter", "scorpio", "scorpion", "scott", "secret", "sexsex", "sexy", "shadow", "shannon", "shaved", "shit", "sierra", "silver", "skippy", "slayer", "slut", "smith", "smokey", "snoopy", "soccer", "sophie", "spanky", "sparky", "spider", "squirt", "srinivas", "star", "stars", "startrek", "starwars", "steelers", "steve", "steven", "sticky", "stupid", "success", "suckit", "summer", "sunshine", "super", "superman", "surfer", "swimming", "sydney", "taylor", "teens", "tennis", "teresa", "test", "tester", "testing", "theman", "thomas", "thunder", "thx1138", "tiffany", "tiger", "tigers", "tigger", "time", "tits", "tomcat", "topgun", "toyota", "travis", "trouble", "trustno1", "tucker", "turtle", "twitter", "united", "vagina", "victor", "victoria", "video", "viking", "viper", "voodoo", "voyager", "walter", "warrior", "welcome", "whatever", "white", "william", "willie", "wilson", "winner", "winston", "winter", "wizard", "wolf", "women", "xavier", "xxxx", "xxxxx", "xxxxxx", "xxxxxxxx", "yamaha", "yankee", "yankees", "yellow", "young", "zxcvbn", "zxcvbnm", "zzzzzz"];

  return PasswordStrength;
})();
