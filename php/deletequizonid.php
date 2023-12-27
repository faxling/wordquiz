<?php

include 'dbconn.php';

// Create connection
$conn = new mysqli($servername, $username, $password, "glosquiz");

$dbid = $_GET['dbid'];

// error_log($qname . "   " . $qpwd);

$sql = "SELECT qname FROM quizindex WHERE ID=" . $dbid  ;
$result = $conn->query($sql);
$row = $result->fetch_row();
$qname = $row[0];
$sql = "DELETE FROM quizindex WHERE ID=?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $dbid);
$ret = $stmt->execute();

$result = $conn->query("SELECT ROW_COUNT()");

$row = $result->fetch_row();

if ($row[0]> 0)
{
  unlink ($qname.".txt");
  echo("deleted ". $dbid);
}
else {
  echo("-1" . $qname);
}


$stmt->close();
$conn->close();
?>
