<?php

require_once dirname(__FILE__) . '/config.php';
require_once dirname(__FILE__) . '/utilities.php';

session_start();

if (empty($_SESSION['token_credentials'])) {
	echo "{\"error\":\"not logged in\"}\r\n";
	ob_flush(); flush();
	exit(1);
}

$connection = new TwitterOAuth(
	$config['twitter']['consumer_key'], $config['twitter']['consumer_secret'],
	$_SESSION['token_credentials']['oauth_token'],
	$_SESSION['token_credentials']['oauth_token_secret']);

session_write_close();

header('Transfer-Encoding', 'chunked');
ob_flush(); flush();

$user = $connection->get('account/verify_credentials');

$connection->stream('https://userstream.twitter.com/1.1/user.json', array(), function ($response) use ($user) {
	if (connection_aborted()) {
		exit(1);
	}
	if (isset($response->in_reply_to_user_id) && $response->in_reply_to_user_id == $user->id) {
		$response = (object)array_merge((array)$response, array('is_mention' => true));
	}
	$chunk = json_encode($response);
	echo sprintf("%x", strlen($chunk)) . "\r\n";
	echo $chunk . "\r\n";
	ob_flush(); flush();
	return true;
});
