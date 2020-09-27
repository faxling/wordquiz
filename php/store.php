<?php

include 'dbconn.php';
// Create connection
$conn = new mysqli($servername, $username, $password, "glosquiz");

// {"qname":oDD[i], "code":oDD[i+1],  "state1"
$post = file_get_contents('php://input');
$qname = $_GET['qname'];
$slang = $_GET['slang'];
$qcount = (int) $_GET['qcount'];
$desc1 = $_GET['desc1'];
$desc1 = $desc1 . "###" . date("Y-m-d  H:i");
$pwd = $_GET['pwd'];
$sql = "SELECT count(*) FROM QuizIndex WHERE qname=?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $qname);
$stmt->execute();
$result = $stmt->get_result();
$row = $result ->fetch_row();

if ($row[0] > 0) {
  http_response_code(206);
  return;
}

$myfile = fopen($qname . ".txt", "w");

$sql = "INSERT INTO quizindex (qname, slang, qcount,pwd,desc1) VALUES (?,?,?,?,?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ssiss", $qname, $slang, $qcount, $pwd, $desc1);
$retBool = $stmt->execute();
if (!$retBool) {
  http_response_code(208);
}

error_log($conn->error);
fwrite($myfile, $post);
fclose($myfile);
error_log("name " . $qname);
$conn->close();
?>
