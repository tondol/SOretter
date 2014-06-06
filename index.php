<?php

require_once dirname(__FILE__) . '/config.php';

session_start();

$logged_in = !empty($_SESSION['token_credentials']);

include 'index.tpl';
