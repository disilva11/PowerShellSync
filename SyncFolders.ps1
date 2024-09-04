param (
    [string]$SourcePath,
    [string]$ReplicaPath,
    [string]$LogFilePath
)

function Log-Message {
    param (
        [string]$Message
    )
    Write-Output $Message
    Add-Content -Path $LogFilePath -Value $Message
}

# Check sourcepath 
if (-Not (Test-Path -Path $SourcePath)) {
    Log-Message "ERROR: Source path does not exist: $SourcePath"
    exit 1
}

# Making sure replica exists
if (-Not (Test-Path -Path $ReplicaPath)) {
    New-Item -ItemType Directory -Path $ReplicaPath | Out-Null
    Log-Message "INFO: Created replica folder: $ReplicaPath"
}

# Synchronize files from source to replica
function Sync-Folders {
    param (
        [string]$Source,
        [string]$Replica
    )

    # Copy and update files from source to replica
    Get-ChildItem -Path $Source -Recurse | ForEach-Object {
        $SourceFilePath = $_.FullName
        $ReplicaFilePath = $SourceFilePath -replace [regex]::Escape($Source), [regex]::Escape($Replica)

        if (-Not (Test-Path -Path $ReplicaFilePath)) {
            # Copy new files
            Copy-Item -Path $SourceFilePath -Destination $ReplicaFilePath
            Log-Message "INFO: Copied new file: $SourceFilePath to $ReplicaFilePath"
        } elseif ((Get-Item -Path $SourceFilePath).LastWriteTime -ne (Get-Item -Path $ReplicaFilePath).LastWriteTime) {
            # Update modified files
            Copy-Item -Path $SourceFilePath -Destination $ReplicaFilePath -Force
            Log-Message "INFO: Updated file: $SourceFilePath to $ReplicaFilePath"
        }
    }

    # Remove the extra files and directories from replica
    Get-ChildItem -Path $Replica -Recurse | ForEach-Object {
        $ReplicaFilePath = $_.FullName
        $SourceFilePath = $ReplicaFilePath -replace [regex]::Escape($Replica), [regex]::Escape($Source)

        if (-Not (Test-Path -Path $SourceFilePath)) {
            # Remove the extra files and directories
            Remove-Item -Path $ReplicaFilePath -Force -Recurse
            Log-Message "INFO: Removed extra item: $ReplicaFilePath"
        }
    }
}

# Start the synchronization
Log-Message "INFO: Starting synchronization from $SourcePath to $ReplicaPath"
Sync-Folders -Source $SourcePath -Replica $ReplicaPath
Log-Message "INFO: Synchronization completed"
