<?php


include 'dbconn.php';
// Create connection


$conn = new mysqli($servername, $username, $password, "glosquiz");

// update quizindex set qname=binary convert(qname using utf8);
//$conn->query("update quizindex set desc1=binary convert(desc1 using utf8)");
$sql = "SELECT id, desc1, slang, qcount,qname FROM quizindex ORDER BY slang";
$result = $conn->query($sql);
$rows = array();
while ($row = $result->fetch_row()) {
  $rows[] = $row;
}

print json_encode($rows);
?>
