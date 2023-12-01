<?php


include 'dbconn.php';
// Create connection


$conn = new mysqli($servername, $username, $password, "glosquiz");
$qlang = $_GET['qlang'];
$sql = "SELECT id, desc1, slang, qcount,qname  FROM quizindex WHERE slang LIKE '%" . $qlang.  "%' ORDER BY slang";
$result = $conn->query($sql);
$rows = array();
while ($row = $result->fetch_row()) {
  $rows[] = $row;
}

print json_encode($rows);
?>
