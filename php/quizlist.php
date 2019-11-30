<?php


include 'dbconn.php';
// Create connection


$conn = new mysqli($servername, $username, $password, "glosquiz");

$sql = "SELECT id, desc1, slang, qcount,qname  FROM QuizIndex ORDER BY slang";
$result = $conn->query($sql);
$rows = array();
while ($row = $result->fetch_row()) {
  $rows[] = $row;
}

print json_encode($rows);

?>
