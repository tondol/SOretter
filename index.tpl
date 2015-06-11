<!DOCTYPE html>
<html>
<head>
<title>SSOretter</title>
<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
<script type="text/javascript" src="./stream.js"></script>
<link rel="stylesheet" type="text/css" href="./fonts-min.css" />
<link rel="stylesheet" type="text/css" href="./stream.css" />
</head>
<body>

<header>
<?php if ($logged_in): ?>
	<h1>SSOretter: Logged in</h1>
	<p>SSOretterのSはStreamingとSimpleのS。<a href="./logout.php">ログアウトする？</a></p>
<?php else: ?>
	<h1>SSOretter: Not logged in</h1>
	<p><a href="./login.php">ログインする？</a></p>
<?php endif; ?>
</header>

<div id="statuses"></div>

<?php if ($logged_in): ?>
<script type="text/javascript">
$(function () {
	var connect = function () {
		var xhr = new XMLHttpRequest();
		xhr.open('GET', 'https://tmp.tondol.com/ssoretter/stream.php', true);
		xhr.send(null);
		return xhr;
	};
	var xhr = connect();
	var latest = undefined;
	setInterval(function() {
		//closed; retry after random sleep
		if (xhr.readyState == 2 || xhr.readyState == 4) {
			if (Math.random() < 0.1) {
				xhr = connect();
			}
			return;
		}
		//response is empty
		if (xhr.responseText.length == 0) {
			return;
		}
		//output new entries
		var lines = xhr.responseText.split("\n");
		//3*n+0: n-th content length
		//3*n+1: n-th content body
		if (latest == undefined) {
			var from = 1;
		} else {
			for (var from = lines.length - 3; ; from -= 3) {
				if (lines[from] == latest) {
					from += 3;
					break;
				}
			}
		}
		for (var to = lines.length - 3; from <= to; from += 3) {
			var o = JSON.parse(lines[from]);
			if ('text' in o) {
				$("#statuses").prepend(getStatusNode(o).hide().fadeIn());
			} else if ('event' in o && o['event'] == 'favorite') {
				$("#statuses").prepend(getFavoritedStatusNode(o).hide().fadeIn());
			} else if ('event' in o && o['event'] == 'unfavorite') {
				$("#statuses").prepend(getUnfavoritedStatusNode(o).hide().fadeIn());
			} else {
				$("#statuses").prepend($("<dl></dl>").append($("<dt>JSON</dt>")));
			}
		}
		latest = lines[to];
	}, 500);
});
</script>
<?php endif; ?>

</body>
</html>
