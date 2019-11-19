<?php

$qname = $_GET['qname'];


error_log(" qname " . $qname);
readfile($qname);


?>
