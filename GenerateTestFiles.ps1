param(
    [Parameter(Mandatory=$true)]
    [string]$testDir
)

# Create the main test directory
if (-not (Test-Path $testDir)) {
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Write-Host "Created test directory: $testDir"
} else {
    Write-Host "Using existing directory: $testDir"
}

# Define test file structure with mixed file types
$testFiles = @(
    # Root level files
    "\vacation.mp4",
    "\family_photo.jpg",
    "\document.pdf",
    "\presentation.pptx",
    "\birthday_party.mov",
    "\notes.txt",
    "\concert.avi",
    
    # 2021 folder
    "\2021\summer_trip.mp4",
    "\2021\beach_photos.jpg",
    "\2021\wedding.png",
    "\2021\graduation.mkv",
    "\2021\receipt.pdf",
    
    # 2021\something subfolder
    "\2021\something\blah.mp4",
    "\2021\something\foobar.png",
    "\2021\something\random.txt",
    "\2021\something\clip.webm",
    
    # 2001 folder
    "\2001\haha.avi",
    "\2001\old_photos.jpg",
    "\2001\memories.wmv",
    "\2001\scan.tiff",
    
    # 2020 folder
    "\2020\quarantine_videos.mp4",
    "\2020\zoom_call.m4v",
    "\2020\screenshot.png",
    "\2020\report.docx",
    
    # holidays subfolder
    "\holidays\christmas.mov",
    "\holidays\christmas_photos.jpg",
    "\holidays\newyear.flv",
    "\holidays\card.pdf",
    
    # work folder
    "\work\meeting_recording.ts",
    "\work\project_files.zip",
    "\work\presentation.pptx",
    "\work\demo.mpg",
    
    # Additional mixed files
    "\gack.mov",
    "\gack.jpg",
    "\random_video.3gp",
    "\photo_album.png",
    "\music.mp3",
    "\trailer.mts"
)

Write-Host "Creating test files..."

foreach ($file in $testFiles) {
    $fullPath = Join-Path $testDir $file.TrimStart('\')
    $directory = Split-Path $fullPath -Parent
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
        Write-Host "Created directory: $directory"
    }
    
    # Create the file with some dummy content
    $extension = [System.IO.Path]::GetExtension($file).ToLower()
    
    # Add appropriate dummy content based on file type
    switch ($extension) {
        {$_ -in '.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm', '.m4v', '.mpg', '.mpeg', '.3gp', '.ts', '.mts'} {
            "This is a dummy video file: $file`nCreated for testing purposes." | Out-File -FilePath $fullPath -Encoding UTF8
        }
        {$_ -in '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff'} {
            "This is a dummy image file: $file`nNot a real image." | Out-File -FilePath $fullPath -Encoding UTF8
        }
        '.pdf' {
            "This is a dummy PDF document: $file`nContains fake content for testing." | Out-File -FilePath $fullPath -Encoding UTF8
        }
        '.txt' {
            "This is a text file: $file`nSome sample text content for testing the video move script." | Out-File -FilePath $fullPath -Encoding UTF8
        }
        default {
            "This is a dummy file: $file`nFile type: $extension`nCreated for testing." | Out-File -FilePath $fullPath -Encoding UTF8
        }
    }
    
    Write-Host "Created: $fullPath"
}

# Count video files for summary
$videoExtensions = @('.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm', '.m4v', '.mpg', '.mpeg', '.3gp', '.ts', '.mts')
$videoCount = $testFiles | Where-Object { $videoExtensions -contains [System.IO.Path]::GetExtension($_).ToLower() } | Measure-Object | Select-Object -ExpandProperty Count
$totalCount = $testFiles.Count

Write-Host ""
Write-Host "Test file generation completed!"
Write-Host "Created $totalCount total files ($videoCount video files, $($totalCount - $videoCount) other files)"
Write-Host "Directory structure created in: $testDir"
Write-Host ""
Write-Host "You can now test the video move script with:"
Write-Host ".\MoveVideos.ps1 -sourceDir `"$testDir`" -destDir `"C:\TestDestination`""