<?php

require_once dirname(__FILE__) . '/config.php';
require_once dirname(__FILE__) . '/utilities.php';

session_start();

$is_valid = false;

if (!empty($_POST['action']) && !empty($_SESSION['token_credentials'])) {
	$connection = new TwitterOAuth(
		$config['twitter']['consumer_key'], $config['twitter']['consumer_secret'],
		$_SESSION['token_credentials']['oauth_token'],
		$_SESSION['token_credentials']['oauth_token_secret']);

	if ($_POST['action'] == "favorite" && !empty($_POST['id'])) {
		$status = $connection->post('favorites/create', array(
			'id' => $_POST['id'],
		));
		$is_valid = true;
	} else if ($_POST['action'] == "retweet" && !empty($_POST['id'])) {
		$status = $connection->post('statuses/retweet/' . $_POST['id']);
		$is_valid = true;
	}
}

if (is_null($status)) {
	if ($is_valid) {
		echo json_encode(array(
			'success' => false,
			'error' => $status,
		));
	} else {
		echo json_encode(array(
			'success' => false,
			'error' => "invalid parameters",
		));
	}
} else {
	echo json_encode(array(
		'success' => true,
		'status' => $status,
	));
}
