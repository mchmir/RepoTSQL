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
        'LogStream.WriteLine "���� "+objFile.Name+" ���������� � "+strFolderTocopy& "\"+objFile.Name
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
str7ZFolder="D:\BackUp\BackUps\7-Zip\7z.exe"
'������ ��������
strWorkFolder = "D:\BackUp\BackUps"
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
FilePath="\\Gtm-2\D$\GTM\"
''techservice (sql)
FileName="GTM.accdb"
Set WshShell = CreateObject("WScript.Shell")
''--
Set objScriptExec = WshShell.Exec("%comspec% /c ping.exe -n 2 GTM-2")
	strPingResults = LCase(objScriptExec.StdOut.ReadAll)
	if InStr(strPingResults, "ttl=") Then
		if objFSO.FileExists (FilePath+"\"+FileName) then
			set objFile=objFSO.GetFile(FilePath+"\"+FileName)'backup_techservice.bak")
			CopyFileToArchive objFile, objArchiveFolder
		end if
	else
		LogStream.WriteLine "!!!�� ��������� GTM-2. �� ���� ����������."
	end if
''--
Set objScriptExec = WshShell.Exec("%comspec% /c ping.exe -n 2 buh-main")
	strPingResults = LCase(objScriptExec.StdOut.ReadAll)
	if InStr(strPingResults, "ttl=") Then
		'�������� �����
		''
		strWorkFolder="\\Buh-main\D$\1Cv8\����\"
		''������
		''CopyFolderToArchive strWorkFolder+"������", "������", objArchiveFolder
		''������
		CopyFolderToArchive strWorkFolder+"Bostan", "Bostan", objArchiveFolder
		''��������
		CopyFolderToArchive strWorkFolder+"Ivanov", "Ivanov", objArchiveFolder
		''Profit Do svertki
		CopyFolderToArchive strWorkFolder+"Profit Do svertki", "Profit_Do_svertki", objArchiveFolder
		''�� ������� ��
		CopyFolderToArchive strWorkFolder+"Ivanova", "Ivanova", objArchiveFolder
		CopyFolderToArchive strWorkFolder+"Ivanova2", "Ivanova2", objArchiveFolder
		CopyFolderToArchive strWorkFolder+"Ivanova3", "Ivanova3", objArchiveFolder
		''������2013
		CopyFolderToArchive strWorkFolder+"Profit", "Profit", objArchiveFolder
		''������ 2013
		CopyFolderToArchive strWorkFolder+"Gorgaz 2013", "Gorgaz_2013", objArchiveFolder
		''Gorgaz_2013_2014
		CopyFolderToArchive strWorkFolder+"Gorgaz 2013-2014", "Gorgaz_2013_2014", objArchiveFolder
		''���������
		CopyFolderToArchive strWorkFolder+"Federation", "Federation", objArchiveFolder
	else
		LogStream.WriteLine "!!!�� ��������� Buh-main. �� ���� ����������."
	end if
''--
Set objScriptExec = WshShell.Exec("%comspec% /c ping.exe -n 2 buh-11")
	strPingResults = LCase(objScriptExec.StdOut.ReadAll)
	if InStr(strPingResults, "ttl=") Then
		'�������� �����
		''
		strWorkFolder="\\Buh-11\D$\1C_BASE\"
		''���������
		CopyFolderToArchive strWorkFolder+"TabisMarketing 2017", "TabisMarketing_2017", objArchiveFolder
	else
		LogStream.WriteLine "!!!�� ��������� Buh-11. �� ���� ����������."
	end if

'����������
''[���� � 7z][���� � ��� ������][���� ������������� ����� (�����)]
Set WshShell = CreateObject("WScript.Shell")
LogStream.WriteLine
LogStream.WriteLine "---������� ������������ " & Now() & " ---"
ArchiveFile objArchiveFolder.Path, "GTM_DB.zip", "GTM.accdb"
''ArchiveFolder objArchiveFolder.Path, "������.zip", "������"
ArchiveFolder objArchiveFolder.Path, "Bostan.zip", "Bostan"
ArchiveFolder objArchiveFolder.Path, "Ivanov.zip", "Ivanov"
ArchiveFolder objArchiveFolder.Path, "Ivanova.zip", "Ivanova"
ArchiveFolder objArchiveFolder.Path, "Ivanova2.zip", "Ivanova2"
ArchiveFolder objArchiveFolder.Path, "Ivanova3.zip", "Ivanova3"
ArchiveFolder objArchiveFolder.Path, "Profit.zip", "Profit"
ArchiveFolder objArchiveFolder.Path, "Gorgaz_2013.zip", "Gorgaz_2013"
ArchiveFolder objArchiveFolder.Path, "Gorgaz_2013_2014.zip", "Gorgaz_2013_2014"
ArchiveFolder objArchiveFolder.Path, "Federation.zip", "Federation"
ArchiveFolder objArchiveFolder.Path, "Profit_Do_svertki.zip", "Profit_Do_svertki"
ArchiveFolder objArchiveFolder.Path, "TabisMarketing_2017.zip", "TabisMarketing_2017"
LogStream.WriteLine
LogStream.WriteLine "---�������� ������������ " & Now() & " ---"
LogStream.WriteLine
LogStream.WriteLine "--- ��������� ������ " & Now() & " ---"
LogStream.WriteLine

'msgbox "Complete"
WScript.Quit(0)