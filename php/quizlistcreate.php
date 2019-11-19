<?php

$servername = "localhost";
$username = "root";
$password = "admin";

// Create connection
$conn = new mysqli($servername, $username, $password, "mysql");

$sql = "CREATE DATABASE glosquiz";
$result = $conn->query($sql);
$result = $conn->query("USE glosquiz");
$conn->query("DROP TABLE quizindex");
$sql = "CREATE TABLE quizindex  (ID INT KEY AUTO_INCREMENT, desc1 text,slang varchar(10), qcount int, pwd varchar(20), qname varchar(20))";
$result = $conn->query($sql);

echo "<h1> quizindex created ".$result."</h1>"

?>
