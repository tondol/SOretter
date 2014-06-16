<?php

require_once dirname(__FILE__) . '/config.php';
require_once dirname(__FILE__) . '/utilities.php';

session_start();

$logged_in = !empty($_SESSION['token_credentials']);

include dirname(__FILE__) . '/index.tpl';
