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
	xhr = new XMLHttpRequest();
	xhr.open('GET', 'https://tmp.tondol.com/soretter/stream.php', true);
	xhr.send(null);

	var length = 0;
	setInterval(function() {
		if (length != xhr.responseText.length) {
			length = xhr.responseText.length;
			var lines = xhr.responseText.split("\n"),
				line = lines[lines.length - 2],
				o = JSON.parse(line);
			if ('text' in o) {
				$("#statuses").prepend(getStatusNode(o).hide().fadeIn());
			} else {
				$("#statuses").prepend($("<dl></dl>").append($("<dt>JSON</dt>")));
			}
		}
	}, 500);
});
</script>
<?php endif; ?>

</body>
</html>
