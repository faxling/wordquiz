<?php

$servername = "localhost";
$username = "root";
$password = "admin";

// Create connection
$conn = new mysqli($servername, $username, $password, "glosquiz");

$qname = $_GET['qname'];
$qpwd = $_GET['qpwd'];
$dbid = $_GET['dbid'];
error_log($qname . "   " . $qpwd);
$sql = "DELETE FROM QuizIndex WHERE qname=? AND pwd=?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $qname, $qpwd);
$ret = $stmt->execute();

$result = $conn->query("SELECT ROW_COUNT()");

$row = $result->fetch_row();

if ($row[0]> 0)
{
  echo($dbid);
}
else {
  echo(-1);
}


unlink ($qname.".txt");
$stmt->close();
$conn->close();
?>
