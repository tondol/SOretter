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
	var length = 0;
	setInterval(function() {
		//sleep randomly and reconnect
		if (xhr.readyState == 2 || xhr.readyState == 4) {
			if (Math.random() < 0.1) {
				xhr = connect();
			}
			return;
		}
		//not modified
		if (xhr.responseText.length == 0 || length == xhr.responseText.length) {
			return;
		}
		length = xhr.responseText.length;
		var lines = xhr.responseText.split("\n");
		var line = lines[lines.length - 2];
		var o = JSON.parse(line);
		if ('text' in o) {
			$("#statuses").prepend(getStatusNode(o).hide().fadeIn());
		} else {
			$("#statuses").prepend($("<dl></dl>").append($("<dt>JSON</dt>")));
		}
	}, 500);
});
</script>
<?php endif; ?>

</body>
</html>
