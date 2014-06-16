<?php

require_once dirname(__FILE__) . '/config.php';
require_once dirname(__FILE__) . '/utilities.php';

session_start();
$_SESSION = array();
session_destroy();

header('Location: ./');
