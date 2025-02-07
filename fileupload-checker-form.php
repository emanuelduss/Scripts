<?php
//
// fileupload-checker-plain.php
//
// Simple file upload script that returns file size, hash and first 20 bytes
//
// Author: Emanuel Duss <me@emanuelduss.ch>
//

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $rawData = file_get_contents('php://input');
    $dataSize = strlen($rawData);

    if ($dataSize > 0) {
        $hashContext = hash_init('sha256');
        hash_update($hashContext, $rawData);
        $fileHash = hash_final($hashContext);

        $first20Bytes = substr($rawData, 0, 20);
        $hexFirst20Bytes = bin2hex($first20Bytes);

        echo "<h3>Data processed successfully!</h3>\n";
        echo "<p>Data Size: " . htmlspecialchars(number_format($dataSize)) . " bytes</p>\n";
        echo "<p>SHA256 Hash: " . htmlspecialchars($fileHash, ENT_QUOTES, 'UTF-8') . "</p>\n";
        echo "<p>First 20 Bytes (Hex): " . htmlspecialchars($hexFirst20Bytes, ENT_QUOTES, 'UTF-8') . "</p>\n";
    } else {
        echo "<h3>No data received.</h3>";
    }
}
?>
