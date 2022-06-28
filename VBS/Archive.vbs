Option Explicit

Public objFSO
Public objArchiveFolder
Public objFile
Public objFolder

Public strWorkFolder
Public strCopyFolder
Public strArchiveFolder
Public str7ZFolder
Public LogStream
Public LogPath 
Public objShellApp
Public WshShell

Public dd
Public qq
Public vmon
Public vday

'=======================================================================
'���������� ����
'=======================================================================
Sub ArchiveFile (strArchiveFolderName, strArchiveFileName, strFileName)
	if objFSO.FileExists (strArchiveFolderName+"\"+strFileName) then
		Comand = str7ZFolder+" a -tzip "+strArchiveFolderName+"\"+strArchiveFileName+" "+strArchiveFolderName+"\"+strFileName
		LogStream.WriteLine "---������������ "+strFileName+"---"
	
		WshShell.Run Comand , 0, True
		LogStream.WriteLine "---�������� ������������ "+strFileName+"---"
	
	else
		LogStream.WriteLine "!!!---��� ����� ��� ��������� "+strFileName+"---"
	end if
end sub
'=======================================================================
'���������� �����
'=======================================================================
Sub ArchiveFolder(strArchiveFolderName, strArchiveName, strFolderName)

	Comand = str7ZFolder+" a -tzip "+strArchiveFolderName+"\"+strArchiveName+" "+strArchiveFolderName+"\"+strFolderName
	LogStream.WriteLine "---������������ "+strFolderName+"---"

	WshShell.Run Comand , 0, True
	LogStream.WriteLine "---�������� ������������ "+strFolderName+"---"
	objFSO.DeleteFolder strArchiveFolderName+"\"+strFolderName, True
	LogStream.WriteLine "---������� "+strFolderName+"---"
end sub


'=======================================================================
'���������� ������
'=======================================================================
'on error resume next
set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShellApp = CreateObject("Shell.Application")
dim FilePath
dim FileName
dim ArchiveFileName
dim Comand

'���� � ����������
str7ZFolder="D:\BackUp\7-Zip\7z.exe"
'������ ��������
strWorkFolder = "D:\BackUp"
'���� ��������
strArchiveFolder = strWorkFolder
'���� ���-�����
LogPath = strArchiveFolder
'���� ��� ���-�����, �� ������� ���
 If (objFSO.FileExists(LogPath+"\BackUpLog.log")) Then
    Set LogStream = objFSO.OpenTextFile(LogPath+"\BackUpLog.log", 8, True)
 Else
    Set LogStream = objFSO.CreateTextFile(LogPath+"\BackUpLog.log")
 end if
'����� � ���
LogStream.WriteLine "--- ������ ������ " & Now() & " ---"
LogStream.WriteLine
'�������� �������� ����� ��� ������
Set objArchiveFolder = objFSO.GetFolder(strArchiveFolder)
ArchiveFileName=""

'����������
''[���� � 7z][���� � ��� ������][���� ������������� ����� (�����)]
Set WshShell = CreateObject("WScript.Shell")
LogStream.WriteLine
LogStream.WriteLine "---������� ������������ " & Now() & " ---"
'msgbox objArchiveFolder.Path
ArchiveFile objArchiveFolder.Path, "backup_gefest_"& Date() &".zip", "backup_gefest.bak"
ArchiveFile objArchiveFolder.Path, "backup_sale_"& Date() &".zip", "sale.bak"
ArchiveFile objArchiveFolder.Path, "backup_DemandTemplates_"& Date() &".zip", "DemandTemplates.bak"


LogStream.WriteLine
LogStream.WriteLine "---�������� ������������ " & Now() & " ---"
LogStream.WriteLine
LogStream.WriteLine "--- ��������� ������ " & Now() & " ---"
LogStream.WriteLine

'msgbox "Complete"
WScript.Quit(0)