param(
    [Parameter(Mandatory=$true)]
    [string]$sourceDir,
    
    [Parameter(Mandatory=$true)]
    [string]$destDir
)

# Convert to absolute paths to avoid relative path issues
$sourceDir = (Get-Item $sourceDir).FullName
$destDir = (Get-Item $destDir).FullName

# Define video extensions (same as in MoveVideos.ps1)
$videoExtensions = @('.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm', '.m4v', '.mpg', '.mpeg', '.3gp', '.ts', '.mts')

# Expected video files based on GenerateTestFiles.ps1
$expectedVideoFiles = @(
    "\vacation.mp4",
    "\birthday_party.mov",
    "\concert.avi",
    "\2021\summer_trip.mp4",
    "\2021\graduation.mkv",
    "\2021\something\blah.mp4",
    "\2021\something\clip.webm",
    "\2001\haha.avi",
    "\2001\memories.wmv",
    "\2020\quarantine_videos.mp4",
    "\2020\zoom_call.m4v",
    "\holidays\christmas.mov",
    "\holidays\newyear.flv",
    "\work\meeting_recording.ts",
    "\work\demo.mpg",
    "\gack.mov",
    "\random_video.3gp",
    "\trailer.mts"
)

Write-Host "=== Video Move Validation Report ===" -ForegroundColor Cyan
Write-Host ""

# Check if directories exist
if (-not (Test-Path $sourceDir)) {
    Write-Host "[ERROR] Source directory '$sourceDir' does not exist!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $destDir)) {
    Write-Host "[ERROR] Destination directory '$destDir' does not exist!" -ForegroundColor Red
    exit 1
}

# Initialize counters
$validationResults = @{
    ExpectedFound = 0
    ExpectedMissing = 0
    UnexpectedFound = 0
    SourceCleanedProperly = $true
    TotalExpected = $expectedVideoFiles.Count
}

Write-Host "Checking destination directory for expected video files..." -ForegroundColor Yellow
Write-Host ""

# Check each expected video file in destination
foreach ($expectedFile in $expectedVideoFiles) {
    $destPath = Join-Path $destDir $expectedFile.TrimStart('\')
    
    if (Test-Path $destPath) {
        Write-Host "[FOUND] $expectedFile" -ForegroundColor Green
        $validationResults.ExpectedFound++
    } else {
        Write-Host "[MISSING] $expectedFile" -ForegroundColor Red
        $validationResults.ExpectedMissing++
    }
}

Write-Host ""
Write-Host "Checking for unexpected video files in destination..." -ForegroundColor Yellow
Write-Host ""

# Get all video files actually in destination
$actualVideoFiles = Get-ChildItem -Path $destDir -Recurse -File | Where-Object {
    $videoExtensions -contains $_.Extension.ToLower()
}

foreach ($actualFile in $actualVideoFiles) {
    # Calculate relative path correctly by ensuring we handle the path separator
    $relativePath = $actualFile.FullName.Substring($destDir.Length)
    if ($relativePath.StartsWith('\') -or $relativePath.StartsWith('/')) {
        $relativePath = $relativePath.Substring(1)
    }
    $normalizedPath = "\" + $relativePath
    
    if ($expectedVideoFiles -notcontains $normalizedPath) {
        Write-Host "[UNEXPECTED] $normalizedPath" -ForegroundColor Magenta
        $validationResults.UnexpectedFound++
    }
}

if ($validationResults.UnexpectedFound -eq 0) {
    Write-Host "[OK] No unexpected video files found" -ForegroundColor Green
}

Write-Host ""
Write-Host "Checking source directory cleanup..." -ForegroundColor Yellow
Write-Host ""

# Check if video files were properly removed from source
$remainingVideoFiles = Get-ChildItem -Path $sourceDir -Recurse -File | Where-Object {
    $videoExtensions -contains $_.Extension.ToLower()
}

if ($remainingVideoFiles.Count -eq 0) {
    Write-Host "[OK] Source directory properly cleaned - no video files remain" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Source directory not properly cleaned - $($remainingVideoFiles.Count) video files remain:" -ForegroundColor Red
    $validationResults.SourceCleanedProperly = $false
    foreach ($remainingFile in $remainingVideoFiles) {
        $relativePath = $remainingFile.FullName.Substring($sourceDir.Length)
        if ($relativePath.StartsWith('\') -or $relativePath.StartsWith('/')) {
            $relativePath = $relativePath.Substring(1)
        }
        Write-Host "   Remaining: \$relativePath" -ForegroundColor Red
    }
}

# Check that non-video files are still in source
Write-Host ""
Write-Host "Checking that non-video files remain in source..." -ForegroundColor Yellow

$remainingNonVideoFiles = Get-ChildItem -Path $sourceDir -Recurse -File | Where-Object {
    $videoExtensions -notcontains $_.Extension.ToLower()
}

if ($remainingNonVideoFiles.Count -gt 0) {
    Write-Host "[OK] Non-video files properly preserved in source ($($remainingNonVideoFiles.Count) files)" -ForegroundColor Green
} else {
    Write-Host "[WARNING] No non-video files found in source (this might be expected if only videos existed)" -ForegroundColor Yellow
}

# Final summary
Write-Host ""
Write-Host "=== VALIDATION SUMMARY ===" -ForegroundColor Cyan
Write-Host "Expected video files found: $($validationResults.ExpectedFound)/$($validationResults.TotalExpected)" -ForegroundColor $(if ($validationResults.ExpectedFound -eq $validationResults.TotalExpected) { "Green" } else { "Red" })
Write-Host "Missing video files: $($validationResults.ExpectedMissing)" -ForegroundColor $(if ($validationResults.ExpectedMissing -eq 0) { "Green" } else { "Red" })
Write-Host "Unexpected video files: $($validationResults.UnexpectedFound)" -ForegroundColor $(if ($validationResults.UnexpectedFound -eq 0) { "Green" } else { "Yellow" })
Write-Host "Source properly cleaned: $($validationResults.SourceCleanedProperly)" -ForegroundColor $(if ($validationResults.SourceCleanedProperly) { "Green" } else { "Red" })

Write-Host ""
if ($validationResults.ExpectedFound -eq $validationResults.TotalExpected -and 
    $validationResults.ExpectedMissing -eq 0 -and 
    $validationResults.UnexpectedFound -eq 0 -and 
    $validationResults.SourceCleanedProperly) {
    Write-Host "[SUCCESS] VALIDATION PASSED - MoveVideos.ps1 worked perfectly!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[FAILED] VALIDATION FAILED - There were issues with the move operation" -ForegroundColor Red
    exit 1
}