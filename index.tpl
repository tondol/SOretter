<!DOCTYPE html>
<html>
<head>
<title>SOretter</title>
<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
<script type="text/javascript" src="./stream.js"></script>
<link rel="stylesheet" type="text/css" href="./fonts-min.css" />
<link rel="stylesheet" type="text/css" href="./stream.css" />
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

<div id="statuses"></div>

<?php if ($logged_in): ?>
<script type="text/javascript">
$(function () {
	var connect = function () {
		var xhr = new XMLHttpRequest();
		xhr.open('GET', 'https://tmp.tondol.com/soretter/stream.php', true);
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
		//2*i+0: n-th content length
		//2*i+1: n-th content body
		if (latest == undefined) {
			var from = 1;
		} else {
			for (var from = lines.length - 2; ; from -= 2) {
				if (lines[from] == latest || from < 1) {
					from += 2;
					break;
				}
			}
		}
		console.log("from=#" + from + ", to=#" + (lines.length - 2));
		for (var to = lines.length - 2; from <= to; from += 2) {
			var o = JSON.parse(lines[from]);
			if ('text' in o) {
				$("#statuses").prepend(getStatusNode(o).hide().fadeIn());
			} else if ('event' in o) {
				if (o['event'] == 'favorite') {
					$("#statuses").prepend(getFavoritedStatusNode(o).hide().fadeIn());
				} else if (o['event'] == 'unfavorite') {
					$("#statuses").prepend(getUnfavoritedStatusNode(o).hide().fadeIn());
				} else {
					var dt = $("<dt>" + o['event'] + "</dt>");
					$("#statuses").prepend($("<dl></dl>").append(dt));
				}
			} else if ('delete' in o) {
				var dt = $("<dt>delete</dt>");
				$("#statuses").prepend($("<dl></dl>").append(dt));
			} else {
				var dt = $("<dt>unsupported</dt>");
				$("#statuses").prepend($("<dl></dl>").append(dt));
			}
		}
		latest = lines[to];
	}, 500);
});
</script>
<?php endif; ?>

</body>
</html>
