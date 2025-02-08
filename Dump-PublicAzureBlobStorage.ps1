<#
.SYNOPSIS
    Dumps all data of a public Azure Blob storage.

.DESCRIPTION
    This script dumps all files of a public Azure Blob Storage and saves them
    in the current directory. For every container, a new directory with the
    same name is created.

    This is still beta and was only used once. Not considered as stable.

.PARAMETER Url
    The SAS url to the public Azure Blob storage.

.EXAMPLE
    .\Dump-PublicAzureBlobStorage.ps1 https://example.blob.core.windows.net/

    If you have a SAS URL, omit the path but keep the parameters like sig, sp, ...

.NOTES
    Author: Emanuel Duss <me@emanuelduss.ch>
#>

param (
    [string]$Url
)


$parameters = "restype=container&comp=list"

# Check if URL already contains parameters and add parameters to list containers and blobs
if ($Url -match "\?") {
    $fullUrl = "${Url}&$parameters"
} else {
    $Url = "${Url}/?"
    $fullUrl = "${Url}?$parameters"
}

$response = [xml](Invoke-RestMethod -Uri $fullUrl).Substring(3) # Remove strange prefix

$containers = $response.EnumerationResults.Containers.Container

foreach ($container in $containers) {
    $containerName = $container.Name
    Write-Host "Found Container $containerName"

    $containerDir = Join-Path -Path (Get-Location) -ChildPath $containerName
    if (-not (Test-Path -Path $containerDir)) {
        New-Item -ItemType Directory -Path $containerDir | Out-Null
    }

    $containerUrl = $fullUrl.Replace("?", "${containerName}?") # Add container name to path

    $blobResponse = [xml](Invoke-RestMethod -Uri $containerUrl).Substring(3)

    $blobs = $blobResponse.EnumerationResults.Blobs.Blob

    foreach ($blob in $blobs) {
        $blobName = $blob.Name
        $blobPath = Join-Path -Path $containerDir -ChildPath $blobName

        $blobDir = Split-Path -Path $blobPath -Parent
        if (-not (Test-Path -Path $blobDir)) {
            New-Item -ItemType Directory -Path $blobDir | Out-Null
        }

        $blobUrl = $Url.Replace("?", "$containerName/${blobName}?")
        Invoke-WebRequest -Uri $blobUrl -OutFile $blobPath
        Write-Host "Downloaded $blobName to $blobPath"
    }
}

Write-Host "All files downloaded successfully."
