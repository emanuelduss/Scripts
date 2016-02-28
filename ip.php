<?php
    if(!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ip_address = $_SERVER['HTTP_X_FORWARDED_FOR'];
    }
    else {
        $ip_address = $_SERVER['REMOTE_ADDR'];
    }
    echo htmlspecialchars($ip_address,ENT_QUOTES | ENT_HTML401,'UTF-8');
?>
