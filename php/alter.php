<?php
include 'dbconn.php';
// Create connection
$conn = new mysqli($servername, $username, $password, "mysql");

$result = $conn->query("USE glosquiz");
$sql = "ALTER TABLE quizindex MODIFY qname VARCHAR(100)";
$result = $conn->query($sql);

echo "<h1> quizindex alter ". $conn->error  ."</h1>"

?>
