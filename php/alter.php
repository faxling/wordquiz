<?php
include 'dbconn.php';
// Create connection
$conn = new mysqli($servername, $username, $password, "mysql");

$result = $conn->query("USE glosquiz");
// $sql = "ALTER TABLE quizindex MODIFY qname VARCHAR(100)";
// $sql = "update quizindex set desc1=CONVERT(CAST(CONVERT(desc1 USING latin1) AS BINARY) USING utf8)";
// $result = $conn->query($sql);
$sql = "select desc1 from quizindex where id=92";
$result = $conn->query($sql);
$row = $result->fetch_row();
// echo "<h1> quizindex alter 2". $conn->error  ."</h1>"
echo "<h1> update quizindex set desc1 ". $row[0] ."</h1>"
?>
