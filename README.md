# Video File Organizer Scripts

A collection of PowerShell scripts for moving video files while preserving directory structure, with comprehensive testing capabilities.

## Scripts Overview

This toolkit includes three PowerShell scripts:

1. **`MoveVideos.ps1`** - The main script that moves video files from source to destination
2. **`GenerateTestFiles.ps1`** - Creates test data for safely testing the move script
3. **`ValidateMoveResults.ps1`** - Validates that the move operation worked correctly

## Prerequisites

### PowerShell Execution Policy

Before running these scripts, you'll need to allow PowerShell to execute local scripts. Choose one of these options:

**Option 1: Temporary (Recommended for testing)**
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```
This allows scripts to run only in your current PowerShell session.

**Option 2: Unblock specific files**
```powershell
Unblock-File .\MoveVideos.ps1
Unblock-File .\GenerateTestFiles.ps1
Unblock-File .\ValidateMoveResults.ps1
```

**Option 3: Allow local scripts permanently**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Script Details

### MoveVideos.ps1

**Purpose:** Moves video files from a source directory to a destination directory while preserving the original folder structure.

**Supported Video Formats:** 
`.mp4`, `.avi`, `.mov`, `.mkv`, `.wmv`, `.flv`, `.webm`, `.m4v`, `.mpg`, `.mpeg`, `.3gp`, `.ts`, `.mts`

**Usage:**
```powershell
.\MoveVideos.ps1 -sourceDir "C:\MyPictures" -destDir "C:\MyVideos"
```

**Parameters:**
- `sourceDir` - Source directory to scan for video files
- `destDir` - Destination directory where videos will be moved

**Features:**
- Recursively scans all subdirectories
- Preserves original folder structure
- Creates destination directories as needed
- Stops immediately on any error
- Provides detailed progress output

**Example:**
If your source has:
- `C:\MyPictures\2021\vacation.mp4`
- `C:\MyPictures\2021\photos.jpg`
- `C:\MyPictures\2022\birthday.avi`

The script will move only the video files to:
- `C:\MyVideos\2021\vacation.mp4`
- `C:\MyVideos\2022\birthday.avi`

The `photos.jpg` file remains in the original location.

### GenerateTestFiles.ps1

**Purpose:** Creates a test directory structure with mixed file types for safely testing the move script.

**Usage:**
```powershell
.\GenerateTestFiles.ps1 -testDir "C:\TestSource"
```

**Parameters:**
- `testDir` - Directory where test files will be created

**What it creates:**
- 18 video files in various formats
- 20+ non-video files (images, documents, etc.)
- Realistic folder structure with subfolders
- Small dummy files (not real videos/images)

### ValidateMoveResults.ps1

**Purpose:** Thoroughly validates that the move operation completed successfully.

**Usage:**
```powershell
.\ValidateMoveResults.ps1 -sourceDir "C:\TestSource" -destDir "C:\TestDestination"
```

**Parameters:**
- `sourceDir` - Original source directory
- `destDir` - Destination directory where files were moved

**Validation checks:**
- All expected video files are in destination
- No video files missing
- No unexpected files in destination
- Source directory properly cleaned of video files
- Non-video files preserved in source

## Complete Testing Workflow

Here's how to safely test the scripts before using them on real data:

### Step 1: Set Execution Policy
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

### Step 2: Generate Test Data
```powershell
.\GenerateTestFiles.ps1 -testDir ".\TestSource"
```

### Step 3: Run the Move Script
```powershell
.\MoveVideos.ps1 -sourceDir ".\TestSource" -destDir ".\TestDestination"
```

### Step 4: Validate Results
```powershell
.\ValidateMoveResults.ps1 -sourceDir ".\TestSource" -destDir ".\TestDestination"
```

### Step 5: Clean Up Test Data
```powershell
Remove-Item .\TestSource -Recurse -Force
Remove-Item .\TestDestination -Recurse -Force
```

## Real-World Usage

Once you've tested and are confident the scripts work correctly:

```powershell
# Set execution policy (if needed)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Move your actual video files
.\MoveVideos.ps1 -sourceDir "C:\MyPhotosAndVideos" -destDir "D:\OrganizedVideos"
```

## Important Notes

**Safety Features:**
- The move script stops immediately if any error occurs
- No files are deleted - videos are moved, other files remain untouched
- Original directory structure is preserved
- Destination directories are created automatically

**Before Running on Real Data:**
- Always test with the provided test scripts first
- Consider backing up important files
- Make sure you have enough space in the destination directory
- Verify the destination path is correct

**Path Handling:**
- Scripts work with both relative paths (like `.\TestSource`) and absolute paths (like `C:\Videos`)
- Paths with spaces are supported when quoted

## Error Handling

The scripts provide clear error messages and will stop execution if:
- Source directory doesn't exist
- Cannot create destination directory
- File move operation fails
- Path access is denied

## Troubleshooting

**"Cannot be loaded" Error:**
- Set the PowerShell execution policy (see Prerequisites section)

**"Access Denied" Error:**
- Run PowerShell as Administrator
- Check file/folder permissions

**Validation Shows Unexpected Files:**
- Usually indicates the move script was run multiple times
- Clean up test directories and start fresh

## License

These scripts are provided as-is for personal use. Test thoroughly before using on important data.