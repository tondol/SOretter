<?php

require_once dirname(__FILE__) . '/config.php';

session_start();

// redirected from twitter
if ($_GET['verifying'] != '')
{
	if ($_GET['oauth_verifier'] != '') {
		$connection = new TwitterOAuth(
			$config['twitter']['consumer_key'], $config['twitter']['consumer_secret'],
			$_SESSION['oauth_token'], $_SESSION['oauth_token_secret']);

		$token_credentials = $connection->getAccessToken($_GET['oauth_verifier']);

		if ($token_credentials['oauth_token'] != '') {
			session_regenerate_id();
			$_SESSION['token_credentials'] = $token_credentials;

			header('Location: ./');
			exit(1);
		}
	}

	unset($_SESSION['oauth_token']);
	unset($_SESSION['oauth_token_secret']);
	echo "An error has occurred! Please report this issue to the administrator.";
	exit(1);
}

// redirect to twitter
$connection = new TwitterOAuth($config['twitter']['consumer_key'], $config['twitter']['consumer_secret']);
$temporary_credentials = $connection->getRequestToken($config['twitter']['callback_uri']);

$_SESSION['oauth_token'] = $temporary_credentials['oauth_token'];
$_SESSION['oauth_token_secret'] = $temporary_credentials['oauth_token_secret'];
$oauth_uri = $connection->getAuthorizeURL($temporary_credentials);

header('Location: ' . $oauth_uri);
