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

<div id="tweets"></div>

<script type="text/javascript">
$(function () {
	xhr = new XMLHttpRequest();
	xhr.multipart = true;
	xhr.open('get', 'https://tmp.tondol.com/soretter/stream.php', true);
	xhr.onreadystatechange = function() {
		if (xhr.readyState == 3) {
			var lines = (xhr.responseText).split("\n");
			var status = JSON.parse(lines[lines.length - 2]);
			var node = getStatusNode(status);
			if (node != undefined) {
				$("#tweets").prepend(node.hide().fadeIn());
			}
		}
	}
<?php if ($logged_in): ?>
	xhr.send(null);
<?php endif; ?>
});
</script>

</body>
</html>
