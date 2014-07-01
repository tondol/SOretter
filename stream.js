function h(s) {
	var map = {
		'<': '&lt;',
		'>': '&gt;',
		'&': '&amp;',
		'\'' :'&#39;',
		'"' :'&quot;'
	};
	function f(s) { return map[s]; }
	return s.replace(/<|>|&|'|"/g, f);
}
(function ($) {
	$.prototype.appendArray = function (array) {
		for (var i in array) {
			if (array[i] instanceof String) {
				this.append(h(array[i]));
			} else {
				this.append(array[i]);
			}
		}
		return this;
	};
})(jQuery);
function formatCreatedAt(s) {
	function pad(n, useSign) {
		var sign = useSign ? (n < 0 ? '-' : '+') : '';
		return sign + ('0' + Math.abs(n)).slice(-2);
	}
	var d = new Date(Date.parse(s));
	var offset = d.getTimezoneOffset();
	return d.getFullYear() + "-" +
		pad(d.getMonth() + 1) + "-" +
		pad(d.getDate()) + "T" +
		pad(d.getHours()) + ":" +
		pad(d.getMinutes()) + ":" +
		pad(d.getSeconds()) +
		pad(-offset / 60, true) + ":" +
		pad(-offset % 60);
}
function getUserUri(o) {
	return "https://twitter.com/" + h(o['user']['screen_name']);
}
function getPermalinkUri(o) {
	return "https://twitter.com/" + h(o['user']['screen_name']) + "/status/" + h(o['id_str']);
}
// https://gist.github.com/xendoc/4129696
function strlen(str) {
  var ret = 0;
  for (var i = 0; i < str.length; i++,ret++) {
    var upper = str.charCodeAt(i);
    var lower = str.length > (i + 1) ? str.charCodeAt(i + 1) : 0;
    if (isSurrogatePair(upper, lower)) {
      i++;
    }
  }
  return ret;
}
function substring(str, begin, end) {
  var ret = '';
  for (var i = 0, len = 0; i < str.length; i++, len++) {
    var upper = str.charCodeAt(i);
    var lower = str.length > (i + 1) ? str.charCodeAt(i + 1) : 0;
    var s = "";
    if(isSurrogatePair(upper, lower)) {
      i++;
      s = String.fromCharCode(upper, lower);
    } else {
      s = String.fromCharCode(upper);
    }
    if (begin <= len && len < end) {
      ret += s;
    }
  }
  return ret;
}
function isSurrogatePair(upper, lower) {
  return 0xD800 <= upper && upper <= 0xDBFF && 0xDC00 <= lower && lower <= 0xDFFF;
}
// https://gist.github.com/wadey/442463
function linkify(o) {
	var s = o['text'];
	var map = {};
	$.each(o['entities']['urls'], function (i, entry) {
		map[entry.indices[0]] = [entry.indices[1], function (s) {
			return "<a href=\""+ h(entry.expanded_url) + "\">" + h(entry.display_url) + "</a>";
		}];
	});
	$.each(o['entities']['user_mentions'], function (i, entry) {
		map[entry.indices[0]] = [entry.indices[1], function (s) {
			return "<a href=\"https://twitter.com/" + h(entry.screen_name) + "\">@" + h(entry.screen_name) + "</a>";
		}];
	});
	$.each(o['entities']['hashtags'], function (i, entry) {
		map[entry.indices[0]] = [entry.indices[1], function (s) {
			return "<a href=\"https://twitter.com/search?q=#" + h(entry.text) + "\">#" + h(entry.text) + "</a>";
		}];
	});
	if ('media' in o['entities']) {
		$.each(o['entities']['media'], function (i, entry) {
			map[entry.indices[0]] = [entry.indices[1], function (s) {
				return "<a href=\""+ h(entry.expanded_url) + "\">" + h(entry.display_url) + "</a>";
			}];
		});
	}
	var i = 0, last = 0;
	var result = '';
	for (var i=0;i<strlen(s);i++) {
		var index = map[i];
		if (index != undefined) {
			var end = index[0];
			var f = index[1];
			if (i != last) {
				result += h(substring(s, last, i));	
			}
			result += f(substring(s, i, end));
			i = end - 1;
			last = end;
		}
	}
	if (i != last) {
		result += h(substring(s, last, i));
	}
	return result;
}

function getStatusHeaderNode(o) {
	var dt = $("<dt></dt>");
	var img = $("<img />").attr('width', 24).attr('height', 24).attr('src', h(o['user']['profile_image_url']));
	var link = $("<a></a>").attr('href', getUserUri(o)).text(o['user']['screen_name']);
	dt.appendArray([img, " ", link]);
	return dt;
}
function getRetweetedStatusHeaderNode(o) {
	var r = o['retweeted_status'];
	var dt = $("<dt></dt>");
	var img1 = $("<img />").attr('width', 24).attr('height', 24).attr('src', h(r['user']['profile_image_url']));
	var img2 = $("<img />").attr('width', 24).attr('height', 24).attr('src', h(o['user']['profile_image_url']));
	var link1 = $("<a></a>").attr('href', getUserUri(r)).text(r['user']['screen_name']);
	var link2 = $("<a></a>").attr('href', getUserUri(o)).text(o['user']['screen_name']);
	dt.appendArray([img1, " ", link1, " (RT by ", img2, " ", link2, ")"]);
	return dt;
}
function getStatusBodyNode(o) {
	return $("<dd></dd>").html(linkify(o));
}
function getStatusFooterNode(o) {
	var dd = $("<dd></dd>");
	var link = $("<a></a>").attr('href', getPermalinkUri(o)).text(formatCreatedAt(o['created_at']));
	var favorite = $("<a></a>").attr('href', "#").text("Fav").click(function() {
		$.post('action.php', {
			'action': 'favorite',
			'id': o['id_str']
		});
		return false;
	});
	var retweet = $("<a></a>").attr('href', "#").text("RT").click(function() {
		$.post('action.php', {
			'action': 'retweet',
			'id': o['id_str']
		});
		return false;
	});
	dd.appendArray([link, " via ", o['source'], " ", favorite, " ", retweet]);
	return dd;
}
function getStatusNode(o) {
	if ('retweeted_status' in o) {
		var r = o['retweeted_status'];
		var header = getRetweetedStatusHeaderNode(o);
		var body = getStatusBodyNode(r);
		var footer = getStatusFooterNode(r);
	} else {
		var header = getStatusHeaderNode(o);
		var body = getStatusBodyNode(o);
		var footer = getStatusFooterNode(o);
	}
	var dl = $("<dl></dl>");
	dl.appendArray([header, body, footer]);
	return dl;
}
