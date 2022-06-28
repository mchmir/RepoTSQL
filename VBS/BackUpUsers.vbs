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

Public MyExt
public MyFolders
MyExt=Array("lnk","jpg","jpeg","bmp","png","gif","avi","mkv","wmv","wma","mp3","mp4","exe","wav","cda","apk","msi","znitcve","mov")
MyFolders=Array("��� �������","My Scans","Downloads","��������","��� ������")
Public CompUsers
Public CompUsers2
Public CompUsers3
Public CompUsers3_Name
''strWorkFolder="\d$\��� ���������"
CompUsers=Array("Buh-main","Buh-1","Buh-22","Buh-33","Jurist","Jurist-2","Jurist-3","Ab-3","Ab-1","Ab-15","Pto-1","Pto-2","Pto-6","Pto-7","Pto-10","Ab-2","Peo-1","Peo-2","Tb-1","Ok-1","Secretary")
''strWorkFolder="\e$\��� ���������"
''CompUsers2=Array("Ok-1")
''strWorkFolder="\c$\Documents and Settings\"
CompUsers3=Array("Pto-8")
CompUsers3_Name=Array("ntkach")
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
	On Error Resume Next
	dim fExt
	dim Need
	dim i
	if len(Name)<0 Then
		If NOT objFSO.FolderExists(Dst+"\"+Name) Then
	       Set objFolder = objFSO.CreateFolder(Dst+"\"+Name)
	    end if
	    for each objFile in objFSO.GetFolder(Src+"\"+Name).Files
	        objFSO.CopyFile objFile, Dst+"\"+Name+"\"+objFile.Name
            'LogStream.WriteLine "---���� " & objFile.Name & " ���������� � " + Dst+"\"+Name + "\" & objFile.Name
	    next
	    for each objFolder in objFSO.GetFolder(Src+"\"+Name).Subfolders
	        CopyDir Src+"\"+Name + "\" + objFolder.Name ,objFolder.Name, Dst+"\"+Name +"\"+objFolder.Name
	    next
	else
		If NOT objFSO.FolderExists(Dst) Then
	       Set objFolder = objFSO.CreateFolder(Dst)
	    end if
	    for each objFile in objFSO.GetFolder(Src).Files
	    '���� ���� ������� ����� 8 ���� ����� �� ������������ ���
	    	'If DateDiff("d", objFile.DateLastModified, Now) < 8 Then 
	    	'������ ������ �����
		    	Need=1
	        	fExt = objFSO.GetExtensionName(objFile.Path)
	        	'msgbox fExt
		        for i=0 to Ubound(MyExt)
		        	if LCase(fExt)=LCase(MyExt(i)) then
		        		Need=0
		        		exit for	
		        	end if
		        next
		        if Need = 1 then
		        	objFSO.CopyFile objFile, Dst+"\"+objFile.Name
		        end if
	            'LogStream.WriteLine "---���� "+objFile.Name+" ���������� � "+Dst+"\"+objFile.Name
	        'end if 
	    next
	    for each objFolder in objFSO.GetFolder(Src).Subfolders
	    	Need=1
	    	for i=0 to Ubound(MyFolders)
		       	if LCase(objFolder.Name)=LCase(MyFolders(i)) then
		       		Need=0
		       		exit for	
		       	end if
		    next
	    	if Need = 1 then
	    		CopyDir Src+"\"+objFolder.Name ,objFolder.Name, Dst+"\"+objFolder.Name
	        	LogStream.WriteLine "--����� " & objFolder.Name & " �����������."
	        else
	        	LogStream.WriteLine "--����� " & objFolder.Name & " �� �������� �����������"
	    	end if
'	        if not objFolder.Name="��� �������" then
'	        	CopyDir Src+"\"+objFolder.Name ,objFolder.Name, Dst+"\"+objFolder.Name
'	        	LogStream.WriteLine "--����� " & objFolder.Name & " �����������."
'	        end if
'	        if not objFolder.Name="My Scans" then
'	        	CopyDir Src+"\"+objFolder.Name ,objFolder.Name, Dst+"\"+objFolder.Name
'	        	LogStream.WriteLine "--����� " & objFolder.Name & " �����������."
'	        end if
'	        if not objFolder.Name="Downloads" then
'	        	CopyDir Src+"\"+objFolder.Name ,objFolder.Name, Dst+"\"+objFolder.Name
'	        	LogStream.WriteLine "--����� " & objFolder.Name & " �����������."
'	        end if
'	        if not objFolder.Name="��������" then
'	        	CopyDir Src+"\"+objFolder.Name ,objFolder.Name, Dst+"\"+objFolder.Name
'	        	LogStream.WriteLine "--����� " & objFolder.Name & " �����������."
'	        end if
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
		Comand = str7ZFolder+" a -tzip -mx9 "+strArchiveFolderName+"\"+strArchiveFileName+" "+strArchiveFolderName+"\"+strFileName
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
	Comand = str7ZFolder+" a -tzip -mx9 "+strArchiveFolderName+"\"+strArchiveName+" "+strArchiveFolderName+"\"+strFolderName
	LogStream.WriteLine "---������������ "+strFolderName+"---"
	'LogStream.WriteLine comand
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
dim strComputer
dim i

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
strWorkFolder = "D:\BackUp\UserBackUps"
If Not objFSO.FolderExists(strWorkFolder) Then
    objFSO.CreateFolder strWorkFolder
End If
'���� ��������
strArchiveFolder = strWorkFolder+"\"+dd
'���� ���-�����
LogPath = strArchiveFolder
'���� ��� �������� �����, �� ������� ��
If Not objFSO.FolderExists(strArchiveFolder) Then
    objFSO.CreateFolder strArchiveFolder
End If
'���� ��� ���-�����, �� ������� ���
 If (objFSO.FileExists(LogPath+"\BackUpUserLog.log")) Then
    Set LogStream = objFSO.OpenTextFile(LogPath+"\BackUpUserLog.log", 8, True)
 Else
    Set LogStream = objFSO.CreateTextFile(LogPath+"\BackUpUserLog.log")
 end if

'����� � ���
LogStream.WriteLine "--- ������ ������ " & Now() & " ---"
LogStream.WriteLine
'�������� �������� ����� ��� ������
Set objArchiveFolder = objFSO.GetFolder(strArchiveFolder)
ArchiveFileName=""
'�������� �����
'FilePath="\\app-server\G$"
Set WshShell = CreateObject("WScript.Shell")
'�������� �����
strWorkFolder="\d$\��� ���������"
for i=0 to Ubound(CompUsers)
	strComputer=cstr(CompUsers(i))
	Set objScriptExec = WshShell.Exec("%comspec% /c ping.exe -n 2 "+strComputer)
	strPingResults = LCase(objScriptExec.StdOut.ReadAll)
	if InStr(strPingResults, "ttl=") Then
		CopyFolderToArchive "\\"+strComputer+strWorkFolder, strComputer, objArchiveFolder
	else
		LogStream.WriteLine "!!!�� ��������� "+strComputer+". �� ���� ����������."
	end if
next

'strWorkFolder="\f$\��� ���������"
'for i=0 to Ubound(CompUsers2)
'	strComputer=cstr(CompUsers2(i))
'	Set objScriptExec = WshShell.Exec("%comspec% /c ping.exe -n 2 "+strComputer)
'	strPingResults = LCase(objScriptExec.StdOut.ReadAll)
'	if InStr(strPingResults, "ttl=") Then
'		CopyFolderToArchive "\\"+strComputer+strWorkFolder, strComputer, objArchiveFolder
'	else
'		LogStream.WriteLine "!!!�� ��������� "+strComputer+". �� ���� ����������."
'	end if
'next

strWorkFolder="\c$\Documents and Settings\"
dim strCompUserName
for i=0 to Ubound(CompUsers3)
	strComputer=cstr(CompUsers3(i))
	strCompUserName=cstr(CompUsers3_Name(i))
	Set objScriptExec = WshShell.Exec("%comspec% /c ping.exe -n 2 "+strComputer)
	strPingResults = LCase(objScriptExec.StdOut.ReadAll)
	if InStr(strPingResults, "ttl=") Then
		CopyFolderToArchive "\\"+strComputer+strWorkFolder+strCompUserName+"\��� ���������", strComputer, objArchiveFolder
	else
		LogStream.WriteLine "!!!�� ��������� "+strComputer+". �� ���� ����������."
	end if
next

''�������� ���� 
'CopyFolderToArchive "\\Buh-9"+strWorkFolder, "Buh-9", objArchiveFolder
''��������� �.�. 
'CopyFolderToArchive "\\"+strComputer+strWorkFolder, strComputer, objArchiveFolder
''�������� ��������� 
'CopyFolderToArchive "\\Buh-10"+strWorkFolder, "Buh-10", objArchiveFolder
''������� �.�.
'CopyFolderToArchive "\\Buh-1"+strWorkFolder, "Buh-1", objArchiveFolder
''������ ����� 
'CopyFolderToArchive "\\Jurist-1"+strWorkFolder, "Jurist-1", objArchiveFolder
''������ �����
'CopyFolderToArchive "\\Jurist-2"+strWorkFolder, "Jurist-2", objArchiveFolder
''���������� �������
'CopyFolderToArchive "\\Jurist-3"+strWorkFolder, "Jurist-3", objArchiveFolder
''���������� ����
'CopyFolderToArchive "\\Ab-8"+strWorkFolder, "Ab-8", objArchiveFolder
''���������� �����
'CopyFolderToArchive "\\Ab-15"+strWorkFolder, "Ab-15", objArchiveFolder
''����������� �.�.
'CopyFolderToArchive "\\Ab-11"+strWorkFolder, "Ab-11", objArchiveFolder

'����������
''[���� � 7z][���� � ��� ������][���� ������������� ����� (�����)]
'LogStream.WriteLine
'LogStream.WriteLine "---������� ������������---"
'objFSO.MoveFolder objArchiveFolder.Path+"\Bostan Group" , objArchiveFolder.Path+"\Bostan_Group"
'ArchiveFolder objArchiveFolder.Path, "Bostan_Group.zip", "Bostan_Group"

'LogStream.WriteLine
'LogStream.WriteLine "---�������� ������������---"
LogStream.WriteLine
LogStream.WriteLine "--- ��������� ������ " & Now() & " ---"
LogStream.WriteLine

'msgbox "Complete"
WScript.Quit(0)