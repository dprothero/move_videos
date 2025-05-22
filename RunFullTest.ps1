# Start fresh
Remove-Item .\TestSource -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item .\TestDestination -Recurse -Force -ErrorAction SilentlyContinue

# Generate new test files
.\GenerateTestFiles.ps1 .\TestSource

# Move the videos  
.\MoveVideos.ps1 -sourceDir .\TestSource -destDir .\TestDestination

# Validate the results
.\ValidateMoveResults.ps1 -sourceDir .\TestSource -destDir .\TestDestination