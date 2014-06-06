<html>
<head>
<title>SOretter</title>
<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js "></script>
<link rel="stylesheet" type="text/css" href="./fonts-min.css" />
<style type="text/css">
* {
	margin: 0;
	padding: 0;
}
body {
	background: #aaaaaa;
}
header {
	margin: 5px;
}
dt img {
	vertical-align: middle;
}
dl {
	margin: 5px;
	border: solid 2px #222222;
	border-radius: 6px;
	background: #ffffff;
}
dt {
	margin: 5px;
}
dd {
	margin: 5px;
}
a:link {
	color: #ff8050;
}
a:visited {
	color: #995080;
}
a:hover {
	color: #ff0090;
	text-decoration: none;
}
</style>
</head>
<body>

<header>
<?php if ($logged_in): ?>
	<h1>SOretter: Logged in</h1>
	<p>SOretterのSはStreamingのS。<a href="./logout.php">ログアウトする？</a></p>
<?php else: ?>
	<h1>SOretter: Not logged in</h1>
	<p><a href="./login.php">ログインする？</a></p>
<?php endif; ?>
</header>

<div id="tweets"></div>

<script type="text/javascript">
(function ($) {
	$.h = function(val) {
		return $("<div/>").text(val).html();
	};
})(jQuery);
$(function () {
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
	function getPermalinkUri(o) {
		return "https://twitter.com/" + o['user']['screen_name'] + "/status/" + o['id_str'];
	}
	function prepend(o) {
		if (!('text' in o)) {
			return;
		}
		var dl = undefined;
		if ('retweeted_status' in o) {
			var r = o['retweeted_status'];
			dl = $("<dl></dl>");
			var dt = $("<dt></dt>");
			var img1 = $("<img />").attr('width', 24).attr('height', 24).attr('src', $.h(r['user']['profile_image_url']));
			var img2 = $("<img />").attr('width', 24).attr('height', 24).attr('src', $.h(o['user']['profile_image_url']));
			dt.append(img1).append($.h(" " + r['user']['screen_name'] + " "));
			dt.append($.h("(RT: ")).append(img2).append($.h(" " + o['user']['screen_name'] + ")"));
			var dd1 = $("<dd></dd>").text(r['text']);
			var dd2 = $("<dd></dd>").append($("<a></a>").attr('href', getPermalinkUri(o)).text(formatCreatedAt(r['created_at'])));
			dl.append(dt).append(dd1).append(dd2);
		} else {
			dl = $("<dl></dl>");
			var dt = $("<dt></dt>");
			var img = $("<img />").attr('width', 24).attr('height', 24).attr('src', $.h(o['user']['profile_image_url']));
			dt.append(img).append($.h(" " + o['user']['screen_name']));
			var dd1 = $("<dd></dd>").text(o['text']);
			var dd2 = $("<dd></dd>").append($("<a></a>").attr('href', getPermalinkUri(o)).text(formatCreatedAt(o['created_at'])));
			dl.append(dt).append(dd1).append(dd2);
		}
		$("#tweets").prepend(dl.hide().fadeIn());
	}

	xhr = new XMLHttpRequest();
	xhr.multipart = true;
	xhr.open('get', 'https://tmp.tondol.com/soretter/stream.php', true);
	xhr.onreadystatechange = function() {
		if (xhr.readyState == 3) {
			var array = (xhr.responseText).split("\n");
			var o = JSON.parse(array[array.length - 2]);
			prepend(o);
		}
	}
<?php if ($logged_in): ?>
	xhr.send(null);
<?php endif; ?>
});
</script>

</body>
</html>
