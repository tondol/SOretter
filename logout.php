<?php

require_once dirname(__FILE__) . '/config.php';

session_start();
$_SESSION = array();
session_destroy();

header('Location: ./');
