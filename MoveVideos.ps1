param(
    [Parameter(Mandatory=$true)]
    [string]$sourceDir,
    
    [Parameter(Mandatory=$true)]
    [string]$destDir
)

# Define common video file extensions
$videoExtensions = @('.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm', '.m4v', '.mpg', '.mpeg', '.3gp', '.ts', '.mts', '.m2ts')

# Convert source to absolute path
$sourceDir = (Get-Item $sourceDir).FullName

# Validate source directory exists
if (-not (Test-Path $sourceDir)) {
    Write-Error "Source directory '$sourceDir' does not exist."
    exit 1
}

# Convert destination to absolute path (create if needed)
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    Write-Host "Created destination directory: $destDir"
}
$destDir = (Get-Item $destDir).FullName

# Get all video files recursively from source directory
$videoFiles = Get-ChildItem -Path $sourceDir -Recurse -File | Where-Object {
    $videoExtensions -contains $_.Extension.ToLower()
}

if ($videoFiles.Count -eq 0) {
    Write-Host "No video files found in '$sourceDir'"
    exit 0
}

Write-Host "Found $($videoFiles.Count) video file(s) to move:"

foreach ($file in $videoFiles) {
    # Calculate relative path from source directory
    $relativePath = $file.FullName.Substring($sourceDir.Length).TrimStart('\')
    
    # Build destination path
    $destPath = Join-Path $destDir $relativePath
    $destFolder = Split-Path $destPath -Parent
    
    # Create destination folder if it doesn't exist
    if (-not (Test-Path $destFolder)) {
        New-Item -ItemType Directory -Path $destFolder -Force | Out-Null
        Write-Host "Created directory: $destFolder"
    }
    
    try {
        # Move the file
        Move-Item -Path $file.FullName -Destination $destPath -Force
        Write-Host "Moved: $($file.FullName) -> $destPath"
    }
    catch {
        Write-Error "Failed to move '$($file.FullName)': $($_.Exception.Message)"
        exit 1
    }
}

Write-Host "Video file move operation completed."