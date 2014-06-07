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
	for (var i=0;i<s.length;i++) {
		var index = map[i];
		if (index != undefined) {
			var end = index[0];
			var f = index[1];
			if (i != last) {
				result += h(s.substring(last, i));	
			}
			result += f(s.substring(i, end));
			i = end - 1;
			last = end;
		}
	}
	if (i != last) {
		result += h(s.substring(last, i));
	}
	return result;
}
function getStatusNode(o) {
	if (!('text' in o)) {
		return;
	}
	var dl = undefined;
	if ('retweeted_status' in o) {
		var r = o['retweeted_status'];
		dl = $("<dl></dl>");
		var img1 = $("<img />").attr('width', 24).attr('height', 24).attr('src', h(r['user']['profile_image_url']));
		var img2 = $("<img />").attr('width', 24).attr('height', 24).attr('src', h(o['user']['profile_image_url']));
		var link1 = $("<a></a>").attr('href', getUserUri(r)).text(r['user']['screen_name']);
		var link2 = $("<a></a>").attr('href', getUserUri(o)).text(o['user']['screen_name']);
		var link3 = $("<a></a>").attr('href', getPermalinkUri(o)).text(formatCreatedAt(r['created_at']));
		var dt = $("<dt></dt>");
		var dd1 = $("<dd></dd>").html(linkify(r));
		var dd2 = $("<dd></dd>");
		dt.appendArray([img1, " ", link1, " (RT: ", img2, " ", link2, ")"]);
		dd2.appendArray([link3, " via ", o['source']]);
		dl.appendArray([dt, dd1, dd2]);
	} else {
		dl = $("<dl></dl>");
		var dt = $("<dt></dt>");
		var dd1 = $("<dd></dd>").html(linkify(o));
		var dd2 = $("<dd></dd>");
		var img = $("<img />").attr('width', 24).attr('height', 24).attr('src', h(o['user']['profile_image_url']));
		var link1 = $("<a></a>").attr('href', getUserUri(o)).text(o['user']['screen_name']);
		var link2 = $("<a></a>").attr('href', getPermalinkUri(o)).text(formatCreatedAt(o['created_at']));
		dt.appendArray([img, " ", link1]);
		dd2.appendArray([link2, " via ", o['source']]);
		dl.appendArray([dt, dd1, dd2]);
	}
	return dl;
}
