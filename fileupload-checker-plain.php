<?php
//
// fileupload-checker-plain.php
//
// Simple file upload form that returns file size, hash and first 20 bytes
//
// Author: Emanuel Duss <me@emanuelduss.ch>
//
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>File Upload Tester</title>
</head>
<body>
    <h1>File Upload Tester</h1>
    <p>Upload a file to calculate its SHA256 sum, display its size, and show the first 20 bytes in hex:</p>
    <form enctype="multipart/form-data" action="upload.php" method="POST">
        <input type="file" name="file" required>
        <br><br>
        <input type="submit" value="Upload">
    </form>
</body>
</html>

<?php
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_FILES['file'])) {
    $fileSize = $_FILES['file']['size'];
    $tmpFile = $_FILES['file']['tmp_name'];

    if (is_uploaded_file($tmpFile)) {
        $hashContext = hash_init('sha256');
        $fileHandle = fopen($tmpFile, 'rb');

        // Read the first 20 bytes to display in hex
        $first20Bytes = fread($fileHandle, 20);
        $hexFirst20Bytes = bin2hex($first20Bytes);

        rewind($fileHandle);

        // Read the file in chunks and update the hash context
        while (!feof($fileHandle)) {
            $chunk = fread($fileHandle, 8192); // Read in 8KB chunks
            hash_update($hashContext, $chunk);
        }

        fclose($fileHandle);

        $fileHash = hash_final($hashContext);

        echo "<h3>File uploaded successfully!</h3>\n\n";
        echo "<p>File Size: " . htmlspecialchars(number_format($fileSize)) . " bytes</p>\n";
        echo "<p>SHA256 Hash: " . htmlspecialchars($fileHash, ENT_QUOTES, 'UTF-8') . "</p>\n";
        echo "<p>First 20 Bytes (Hex): " . htmlspecialchars($hexFirst20Bytes, ENT_QUOTES, 'UTF-8') . "</p>\n";
    } else {
        echo "<h3>File upload failed.</h3>";
    }
}
?>
