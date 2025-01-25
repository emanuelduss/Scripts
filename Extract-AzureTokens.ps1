<#
.SYNOPSIS
    Extracts Azure access and refresh tokens from a file (e.g. a memory dump)
    and shows some details.

.DESCRIPTION
    This script searches the provided file for Azure access tokens / refresh
    tokens, shows some claims and if the token is already expired.

    You can e.g. create a dump of the winword.exe or outlook.exe process using
    procdump.exe from Sysinternals and then analyze this file.

.PARAMETER File
    The path to the file from which the tokens will be extracted.

.EXAMPLE
    .\Extract-AzureTokens.ps1 C:\path\to\file.bin
    This command will extract and decode tokens from the specified file.

.NOTES
    Author: Emanuel Duss <me@emanuelduss.ch>
#>

param (
    [string]$File
)

if (-not $File) {
    Write-Output "Usage: .\Extract-AzureTokens.ps1 <path-to-file>"
    exit 1
}

if (-not (Test-Path $File)) {
    Write-Output "Error: File not found at path '$File'"
    exit 1
}

$jwtRegex = 'eyJ[A-Za-z0-9-_]+\.eyJ[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+'
$refreshTokenRegex = '0\.AY[A-Za-z0-9-_.+/=]*'

function Decode-Base64Url {
    param ($base64Url)
    $base64 = $base64Url.Replace('-', '+').Replace('_', '/')
    switch ($base64.Length % 4) {
        2 { $base64 += '==' }
        3 { $base64 += '=' }
    }
    return [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64))
}

function Convert-UnixTimestampToUTC {
    param ($timestamp)
    $dateTime = [System.DateTimeOffset]::FromUnixTimeSeconds($timestamp).UtcDateTime
    $formattedTime = $dateTime.ToString("yyyy-MM-dd HH:mm:ss")

    if ($dateTime -lt [System.DateTime]::UtcNow) {
        return "$formattedTime UTC ($timestamp) EXPIRED!!!"
    } else {
        return "$formattedTime ($timestamp)"
    }
}

$stream = [System.IO.File]::OpenRead($File)
$reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)

try {
    while (-not $reader.EndOfStream) {
        $line = $reader.ReadLine()

        $matches = [regex]::Matches($line, $jwtRegex)

        foreach ($match in $matches) {
            $jwt = $match.Value

            $parts = $jwt -split '\.'
            if ($parts.Length -ge 2) {
                try {
                    $decodedPayload = Decode-Base64Url $parts[1]

                    $payloadObject = $decodedPayload | ConvertFrom-Json

                    $aud = $payloadObject.aud
                    $name = $payloadObject.name
                    $upn = $payloadObject.upn
                    $scp = $payloadObject.scp
                    $iss = $payloadObject.iss
                    $appDisplayName = $payloadObject.app_displayname
                    $exp = $payloadObject.exp

                    $expUTC = Convert-UnixTimestampToUTC $exp

                    Write-Output "[*] JWT found"
                    Write-Output "  name: $name"
                    Write-Output "  upn: $upn"
                    Write-Output "  exp: $expUTC"
                    Write-Output "  iss: $iss"
                    Write-Output "  aud: $aud"
                    Write-Output "  app_displayname: $appDisplayName"
                    Write-Output "  scp: $scp"
                    Write-Output "  JWT: $jwt"
                    Write-Output ""
                } catch {
                    Write-Output "Error decoding JWT: $jwt"
                }
            }
        }

        $matches = [regex]::Matches($line, $refreshTokenRegex)

        foreach ($match in $matches) {
            $refreshToken = $match.Value
            Write-Output "[*] Refresh Token found"
            Write-Output "  Token: $refreshToken"
            Write-Output ""
        }
    }
} finally {
    $reader.Close()
    $stream.Close()
}
