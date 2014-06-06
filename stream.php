<?php

require_once dirname(__FILE__) . '/config.php';

session_start();

if (empty($_SESSION['token_credentials'])) {
	exit(1);
}

// header
header('Content-Encoding', 'chunked');
header('Transfer-Encoding', 'chunked');
header('Content-Type', 'text/html');
header('Connection', 'keep-alive');

ob_flush(); flush();

// body
$connection = new TwitterOAuth(
	$config['twitter']['consumer_key'], $config['twitter']['consumer_secret'],
	$_SESSION['token_credentials']['oauth_token'],
	$_SESSION['token_credentials']['oauth_token_secret']);
$connection->stream('https://userstream.twitter.com/1.1/user.json', array(), function ($response) {
	echo json_encode($response) . "\n";
	ob_flush(); flush();
	return true;
});
