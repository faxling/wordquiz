<?php

include 'dbconn.php';
// Create connection
$conn = new mysqli($servername, $username, $password, "glosquiz");

// {"qname":oDD[i], "code":oDD[i+1],  "state1"
$post = file_get_contents('php://input');
$qname = $_GET['qname'];
$qcount = (int) $_GET['qcount'];
$desc1 = $_GET['desc1'];

$desc1 = $desc1 . "###" . date("Y-m-d:H-i");
$pwd = $_GET['pwd'];
$sql = "SELECT ID FROM QuizIndex WHERE qname=? and pwd=?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $qname, $pwd);
$stmt->execute();
$result = $stmt->get_result();
$row = $result ->fetch_row();

if ($row[0] <= 0) {
  http_response_code(207);
  return;
}

$id = $row[0];

$sql = "UPDATE quizindex SET  qcount=?, desc1=?  WHERE id=?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("isi", $qcount,$desc1, $id);
$stmt->execute();

// unlink ($qname.".txt");

$myfile = fopen($qname . ".txt", "w");
fwrite($myfile, $post);
fclose($myfile);
error_log("name " . $qname);
$conn->close();

?>
