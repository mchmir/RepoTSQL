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
Public objScriptExec
Public strPingResults

Public dd
Public qq
Public vmon
Public vday

'=======================================================================
'������� ����������� �����
'�������� ���� � ���� � ����� �����������
'=======================================================================
Sub CopyFileToArchive(objFile, objArchiveFolder)
    
    On Error Resume Next

    Dim strFolderTocopy

    strFolderTocopy= objArchiveFolder  '.Path '& "\" & Left(objFile.Name, 8)
    objFile.Copy strFolderTocopy+"\"+objFile.Name

    If Err.Number <> 0 Then
        LogStream.WriteLine "������ ����������� ����� "+strWorkFolder+"\"+objFile.Name+" - "+Err.Description
        Err.Clear
    Else
        LogStream.WriteLine "���� "+objFile.Name+" ���������� � "+strFolderTocopy& "\"+objFile.Name
    End If
    
End Sub
'=======================================================================
'������� ����������� �����
'�������� ���� �������� ����� � ���� � ����� �����������
'=======================================================================
Sub CopyFolderToArchive(strFolderPath, strFolderTocopy, objArchiveFolder)
    
    On Error Resume Next
    If NOT objFSO.FolderExists(objArchiveFolder.Path+"\"+strFolderTocopy) Then
	       Set objFolder = objFSO.CreateFolder(objArchiveFolder.Path+"\"+strFolderTocopy)
	end if

    LogStream.WriteLine "����������� "+strFolderTocopy+" � "+objArchiveFolder.Path+"..."
    CopyDir strFolderPath, "", objArchiveFolder+"\"+strFolderTocopy

    If Err.Number <> 0 Then
        LogStream.WriteLine "������ ����������� ����� "+strFolderTocopy+" - "+Err.Description
        Err.Clear
    Else
        LogStream.WriteLine "����������� "+strFolderTocopy+" � "+objArchiveFolder.Path+" ���������."
    End If
       
End Sub
'=======================================================================
'=======================================================================
Sub CopyDir ( ByVal Src, byval Name, ByVal Dst )
	if len(Name)<0 Then
		If NOT objFSO.FolderExists(Dst+"\"+Name) Then
	       Set objFolder = objFSO.CreateFolder(Dst+"\"+Name)
	    end if
	    for each objFile in objFSO.GetFolder(Src+"\"+Name).Files
	        objFSO.CopyFile objFile, Dst+"\"+Name+"\"+objFile.Name
            LogStream.WriteLine "---���� " & objFile.Name & " ���������� � " + Dst+"\"+Name + "\" & objFile.Name
	    next
	    for each objFolder in objFSO.GetFolder(Src+"\"+Name).Subfolders
	        CopyDir Src+"\"+Name + "\" + objFolder.Name ,objFolder.Name, Dst+"\"+Name +"\"+objFolder.Name
	    next
	else
		If NOT objFSO.FolderExists(Dst) Then
	       Set objFolder = objFSO.CreateFolder(Dst)
	    end if
	    for each objFile in objFSO.GetFolder(Src).Files
	        objFSO.CopyFile objFile, Dst+"\"+objFile.Name
            LogStream.WriteLine "---���� "+objFile.Name+" ���������� � "+Dst+"\"+objFile.Name
	    next
	    for each objFolder in objFSO.GetFolder(Src).Subfolders
            LogStream.WriteLine "--����� " & objFolder.Name & " �����������."
	        CopyDir Src+"\"+objFolder.Name ,objFolder.Name, Dst+"\"+objFolder.Name
	    next
	    
    end if
End Sub
'=======================================================================
'���������� ����
'=======================================================================
Sub ArchiveFile (strArchiveFolderName, strArchiveFileName, strFileName)
	'ArchiveFileName="backup_techservice.zip"
	'FileName="backup_techservice.bak"
	if objFSO.FileExists (strArchiveFolderName+"\"+strFileName) then
		Comand = str7ZFolder+" a -tzip "+strArchiveFolderName+"\"+strArchiveFileName+" "+strArchiveFolderName+"\"+strFileName
		LogStream.WriteLine "---������������ "+strFileName+"---"
		'LogStream.WriteLine comand
		WshShell.Run Comand , 0, True
		LogStream.WriteLine "---�������� ������������ "+strFileName+"---"
		objFSO.DeleteFile strArchiveFolderName+"\"+strFileName, True
		LogStream.WriteLine "---������� "+strFileName+"---"
	else
		LogStream.WriteLine "!!!---��� ����� ��� ��������� "+strFileName+"---"
	end if
end sub
'=======================================================================
'���������� �����
'=======================================================================
Sub ArchiveFolder(strArchiveFolderName, strArchiveName, strFolderName)
	'ArchiveFileName="backup_techservice.zip"
	'FileName="backup_techservice.bak"
	Comand = str7ZFolder+" a -tzip "+strArchiveFolderName+"\"+strArchiveName+" "+strArchiveFolderName+"\"+strFolderName
	LogStream.WriteLine "---������������ "+strFolderName+"---"
	'LogStream.WriteLine comand
	WshShell.Run Comand , 0, True
	LogStream.WriteLine "---�������� ������������ "+strFolderName+"---"
	objFSO.DeleteFolder strArchiveFolderName+"\"+strFolderName, True
	LogStream.WriteLine "---������� "+strFolderName+"---"
end sub

'=======================================================================
'������� �������� ���������� ����� �� �����
'Drive - ����� ����� � ������� �
'=======================================================================
function  CheckFreeSpace(Drive)
	on error resume next
	CheckFreeSpace=FormatNumber(objFSO.GetDrive(Drive).FreeSpace/1048576/1024, 1)
	If Err.Number <> 0 Then
        Err.Clear
        CheckFreeSpace=100
    Else
    End If
End function 

'=======================================================================
'���� ����� "������" ����� ������ �� �� ��������
'������ ����� ����� 2012-05-01
'=======================================================================
Sub GetOlderFolder(Src)
	on error resume next
	dim FolderDate
	dim OlderFolderDate
	dim OlderFolder
	OlderFolderDate=Now()
	'LogStream.WriteLine "������ ���� "+cstr(OlderFolderDate)
	for each objFolder in objFSO.GetFolder(Src).Subfolders
        'LogStream.WriteLine "����� "+objFolder.Name
	    FolderDate=cdate(objFolder.Name)
	    if OlderFolderDate>FolderDate then
	    	OlderFolderDate=FolderDate
	    	set OlderFolder=objFolder
	    end if
	    'LogStream.WriteLine "���� "+cstr(FolderDate)
	next 
	
	'LogStream.WriteLine "������ ����� "+OlderFolder.Path
	'LogStream.WriteLine	CheckFreeSpace("E")
	'if CheckFreeSpace("E")<50 then
		objFSO.DeleteFolder OlderFolder.Path, True
	'end if
	'LogStream.WriteLine "������ ���� "+cstr(OlderFolderDate)
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

qq=cdbl(now())
dd=cdate(qq)

vmon=cstr(Month(dd))
if len(vmon)=1 then vmon="0"+vmon

vday=cstr(day(dd))
if len(vday)=1 then vday="0"+vday

'dd="2006-02-13"
dd=cstr(year(dd))+"-"+vmon+"-"+vday
'���� � ����������
str7ZFolder="F:\BackUps\7-Zip\7z.exe"
'������ ��������
strWorkFolder = "F:\BackUps"
'���� ��������
strArchiveFolder = strWorkFolder+"\"+dd
'���� ���-�����
LogPath = strArchiveFolder
'���� ��� �������� �����, �� ������� ��
If Not objFSO.FolderExists(strArchiveFolder) Then
    objFSO.CreateFolder strArchiveFolder
End If
'���� ��� ���-�����, �� ������� ���
 If (objFSO.FileExists(LogPath+"\BackUpLog.log")) Then
    Set LogStream = objFSO.OpenTextFile(LogPath+"\BackUpLog.log", 8, True)
 Else
    Set LogStream = objFSO.CreateTextFile(LogPath+"\BackUpLog.log")
 end if
'����� � ���
LogStream.WriteLine "--- ������ ������ " & Now() & " ---"
LogStream.WriteLine
'���������, ���� ����� �� ����� ������ 50��
'���� ����� ������� ������ �����
do while CheckFreeSpace("F")<50
	GetOlderFolder(strWorkFolder)
loop
'�������� �������� ����� ��� ������
Set objArchiveFolder = objFSO.GetFolder(strArchiveFolder)
ArchiveFileName=""
'�������� �����
FilePath="\\Gtm-1\D$\GTM\"
''techservice (sql)
FileName="GTM.accdb"
Set WshShell = CreateObject("WScript.Shell")
''--
Set objScriptExec = WshShell.Exec("%comspec% /c ping.exe -n 2 GTM-1")
	strPingResults = LCase(objScriptExec.StdOut.ReadAll)
	if InStr(strPingResults, "ttl=") Then
		if objFSO.FileExists (FilePath+"\"+FileName) then
			set objFile=objFSO.GetFile(FilePath+"\"+FileName)'backup_techservice.bak")
			CopyFileToArchive objFile, objArchiveFolder
		end if
	else
		LogStream.WriteLine "!!!�� ��������� GTM-1. �� ���� ����������."
	end if
''--
Set objScriptExec = WshShell.Exec("%comspec% /c ping.exe -n 2 buh-1")
	strPingResults = LCase(objScriptExec.StdOut.ReadAll)
	if InStr(strPingResults, "ttl=") Then
		'�������� �����
		''
		strWorkFolder="\\Buh-0\D$\1Cv8\"
		''������
		''CopyFolderToArchive strWorkFolder+"������", "������", objArchiveFolder
		''������
		CopyFolderToArchive strWorkFolder+"������", "������", objArchiveFolder
		''��������
		CopyFolderToArchive strWorkFolder+"��������", "��������", objArchiveFolder
		''������_11112013
		CopyFolderToArchive strWorkFolder+"������_11112013", "������_11112013", objArchiveFolder
		
	else
		LogStream.WriteLine "!!!�� ��������� Buh-1. �� ���� ����������."
	end if
''--

'����������
''[���� � 7z][���� � ��� ������][���� ������������� ����� (�����)]
Set WshShell = CreateObject("WScript.Shell")
LogStream.WriteLine
LogStream.WriteLine "---������� ������������ " & Now() & " ---"
ArchiveFile objArchiveFolder.Path, "GTM_DB.zip", "GTM.accdb"
''ArchiveFolder objArchiveFolder.Path, "������.zip", "������"
ArchiveFolder objArchiveFolder.Path, "������.zip", "������"
ArchiveFolder objArchiveFolder.Path, "��������.zip", "��������"
ArchiveFolder objArchiveFolder.Path, "������_11112013.zip", "������_11112013"
LogStream.WriteLine
LogStream.WriteLine "---�������� ������������ " & Now() & " ---"
LogStream.WriteLine
LogStream.WriteLine "--- ��������� ������ " & Now() & " ---"
LogStream.WriteLine

'msgbox "Complete"
WScript.Quit(0)