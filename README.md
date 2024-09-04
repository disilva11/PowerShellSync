This repository contains a PowerShell script that synchronizes two folders: a source folder and a replica folder. The script ensures that the replica folder is an exact copy of the source folder by copying new files, updating existing files, and removing files that no longer exist in the source.

How to use it:
.\SyncFolders.ps1 -SourcePath "C:\Path\To\SourceFolder" -ReplicaPath "C:\Path\To\ReplicaFolder" -LogFilePath "C:\Path\To\LogFile.txt"
