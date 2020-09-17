<?php

$qname = $_GET['qname'];
header('Content-Description: File Transfer');
header('Content-Type: application/octet-stream');
header('Content-Length: ' . filesize($qname));
error_log(" qname " . $qname);
readfile($qname);


?>
