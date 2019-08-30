## Written by Heiko 2019-01-28

# Windows specific variables
$strRegistry = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Synology'
$hashRegistry = Get-ItemProperty -Path $strRegistry
$strUsername = $hashRegistry.apiUsername
$strPassword = $hashRegistry.apiPassword
$strFileServer = $hashRegistry.apiUrl

# Enable SSL connection using TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

################################################################################
### Calculate current school year
function currentSchoolYear {
	$intYear=(Get-Date).Year
	$intMonth=(Get-Date).Month
	if ($intMonth -gt 7) {
		$schoolYear = "$intYear-$($intYear + 1)"
	} else {
		$schoolYear = "$([int]$intYear - 1)-$intYear"
	}
	return $schoolYear
}

################################################################################
### Get current date
function currentDate {
	Get-date -Format 'yyyy-MM-dd'
}

################################################################################
### get info of auth module using Invoke-RestMethod with url string
function synologyInfoUrl {
	$strApiUrl = "$strFileServer/webapi/query.cgi?api=SYNO.API.Info&version=1&method=query&query=SYNO.API.Auth,SYNO.FileStation"
	$jsonData = Invoke-RestMethod -Uri $strApiUrl
	$jsonData.data
}

### get info of auth module using Invoke-RestMethod with Body
function synologyInfoBody {
	$hashBody = @{
		'api' = 'SYNO.API.Info'
		'version' = '1'
		'method' = 'query'
		'query' = 'SYNO.API.Auth,SYNO.FileStation'
	}
	$strApiUrl = "$strFileServer/webapi/query.cgi"
	$jsonData = Invoke-RestMethod -Uri $strApiUrl -Body $hashBody
	$jsonData.data
}

################################################################################
### log in to synology filestaitiom and get session sid using Invoke-RestMethod with url string
function synologyLoginUrl  {
	$strApiUrl = "$strFileServer/webapi/auth.cgi?api=SYNO.API.Auth&version=3&method=login&account=$strUsername&passwd=$strPassword&session=FileStation"
	$jsonData = Invoke-RestMethod -Uri $strApiUrl
	$strSID = $jsonData.data.sid
	Write-Host "Your session id is: $strSID"
	return $strSID
}

### log in to synology filestaitiom and get session sid using Invoke-RestMethod with Body
function synologyLoginBody {
	$hashBody = @{
		'api' = 'SYNO.API.Auth'
		'version' = '3'
		'method' = 'login'
		'account' = "$strUsername"
		'passwd' = "$strPassword"
		'session' = 'FileStation'
	}
	$strApiUrl = $strFileServer + '/webapi/auth.cgi'
	$jsonData = Invoke-RestMethod -Uri $strApiUrl -Body $hashBody
	$strSID = $jsonData.data.sid
	Write-Host "Your session id is: $strSID"
	return $strSID
}
	
################################################################################
### log out of synology filestaitiom using using Invoke-RestMethod with url string
function  synologyLogoutUrl ($strSID) {
	$strApiUrl = "$strFileServer/webapi/auth.cgi?api=SYNO.API.Auth&version=1&method=logout&session=FileStation&_sid=$strSID"
	$jsonData = Invoke-RestMethod -Uri $strApiUrl
	$strLogout = $jsonData.success
	Write-Host "Logged out of Filestation successful: $strLogout"
}

### log out of synology filestaitiom using Invoke-RestMethod with Body
function  synologyLogoutBody ($strSID) {
	$hashBody = @{
		'api' = 'SYNO.API.Auth'
		'version' = '1'
		'method' = 'logout'
		'session' = 'FileStation'
		'_sid' = $strSID
	}
	$strApiUrl = $strFileServer + '/webapi/auth.cgi'
	$jsonData = $hashBody | Invoke-RestMethod -Uri $strApiUrl
	$strLogout = $jsonData.success
	Write-Host "Logged out of Filestation successful: $strLogout"
}

################################################################################
### list FilseStation share using using Invoke-RestMethod with url string
function synologyListSharesUrl ($strSID) {
	$strApiUrl = $strFileServer + '/webapi/entry.cgi?api=SYNO.FileStation.List&version=2&method=list_share&_sid=' + $strSID
	$jsonData = Invoke-RestMethod -Uri $strApiUrl
	foreach ($objShare in $jsonData.data.shares) {
		Write-Host $objShare.name
	}		
}

### list FilseStation share	using Invoke-RestMethod with Body
function synologyListSharesBody ($strSID) {
	$hashBody = @{
		'api' = 'SYNO.FileStation.List'
		'version' = '2'
		'method' = 'list_share'
		'_sid' = $strSID
	}
	$strApiUrl = $strFileServer + '/webapi/entry.cgi'
	$jsonData = $hashBody | Invoke-RestMethod -Uri $strApiUrl
	foreach ($objShare in $jsonData.data.shares) {
		Write-Host $objShare.name
	}
}

################################################################################
## list FilseStation folder in folder path using Invoke-RestMethod with url string
function synologyListFoldersUrl ($strSID, $strPath) {
	$strApiUrl = $strFileServer + '/webapi/entry.cgi?api=SYNO.FileStation.List&version=2&method=list&_sid=' + $strSID + '&folder_path=/' + $strPath
	$jsonData = Invoke-RestMethod -Uri $strApiUrl
	foreach ($objFolders in $jsonData.data.files) {
		if ($objFolders.isdir -eq $True) {
			Write-Host $objFolders.path
		}	
	}
}

## list FilseStation folder in folder path using Invoke-RestMethod with Body
function synologyListFoldersBody ($strSID, $strPath) {
	$hashBody = @{
		'api' = 'SYNO.FileStation.List'
		'version' = '2'
		'method' = 'list'
		'_sid' = $strSID
		'folder_path' = '/'+ $strPath
	}
	$strApiUrl = $strFileServer + '/webapi/entry.cgi'
	$jsonData = $hashBody | Invoke-RestMethod -Uri $strApiUrl
	foreach ($objFolders in $jsonData.data.files) {
		if ($objFolders.isdir -eq $true) {
			Write-Host $objFolders.path
		}	
	}
}

################################################################################
## list FilseStation files in folder path using using Invoke-RestMethod with url string
function synologyListFilesUrl ($strSID, $strPath) {
	$strApiUrl = $strFileServer + '/webapi/entry.cgi?api=SYNO.FileStation.List&version=2&method=list&_sid=' + $strSID + '&folder_path=/' + $strPath
	$jsonData = Invoke-RestMethod -Uri $strApiUrl
	$intCount = 0
	foreach ($objFiles in $jsonData.data.files) {
		if ($objFiles.isdir -eq $false) {
			$intCount+=1
			Write-Host $objFiles.name
		}
	}
	Write-Host "Files in Folder: $intCount"
}

## list FilseStation files in folder path using Invoke-RestMethod with Body
function synologyListFilesBody ($strSID, $strPath) {
	$hashBody = @{
		'api' = 'SYNO.FileStation.List'
		'version' = '2'
		'method' = 'list'
		'_sid' = $strSID
		'folder_path' = '/'+ $strPath
	}
	$strApiUrl = $strFileServer + '/webapi/entry.cgi'
	$jsonData = $hashBody | Invoke-RestMethod -Uri $strApiUrl
	$intCount = 0
	foreach ($objFiles in $jsonData.data.files) {
		if ($objFiles.isdir -eq $false) {
			$intCount+=1
			Write-Host $objFiles.name
		}
	}
	Write-Host "Files in Folder: $intCount"
}

################################################################################
#create folder on Filestation share using Invoke-RestMethod with url string
function synologyCreateFolderUrl ($strSID, $strPath, $strName) {
	$strApiUrl = $strFileServer + '/webapi/entry.cgi?api=SYNO.FileStation.CreateFolder&version=2&method=create&_sid=' + $strSID + '&folder_path=/'+ $strPath + '&name=' + $strName
	$jsonData = Invoke-RestMethod -Uri $strApiUrl
	$strSucess = $jsonData.success
	Write-Host "Creation of folder /$strPath/$strName successful: $strSucess"
}

#create folder on Filestation share using Invoke-RestMethod with Body
function synologyCreateFolderBody ($strSID, $strPath, $strName) {
	$hashBody = @{
		'api' = 'SYNO.FileStation.CreateFolder'
		'version' = '2'
		'method' = 'create'
		'_sid' = $strSID
		'folder_path' = '/' + $strPath
		'name' = $strName
	}
	$strApiUrl = $strFileServer + '/webapi/entry.cgi'
	$jsonData = $hashBody | Invoke-RestMethod -Uri $strApiUrl
	$strSucess = $jsonData.success
	Write-Host "Creation of folder /$strPath/$strName successful: $strSucess"
}

################################################################################
#delete Foler on Filestation share using Invoke-RestMethod with url string
function synologyDeleteFolderUrl ($strSID, $strPath) {
	$strApiUrl = "$strFileServer/webapi/entry.cgi?api=SYNO.FileStation.Delete&version=2&method=start&_sid=$strSID&path=/$strPath"
	$jsonData = Invoke-RestMethod -Uri $strApiUrl
	$strSucess = $jsonData.success
	Write-Host  "Deletion of folder $strPath successful: $strSucess"
}

#delete Foler on Filestation share using Invoke-RestMethod with Body
function synologyDeleteFolderBody ($strSID, $strPath) {
	$hashBody = @{
		'api' = 'SYNO.FileStation.Delete'
		'version' = '2'
		'method' = 'start'
		'_sid' = $strSID
		'path' = '/' + $strPath
	}
	$strApiUrl = $strFileServer + '/webapi/entry.cgi'
	$jsonData = $hashBody | Invoke-RestMethod -Uri $strApiUrl
	$strSucess = $jsonData.success
	Write-Host  "Deletion of folder $strPath successful: $strSucess"
}

################################################################################
### upload file to Filestation using Invoke-RestMethod with url string
function synologyUploadFileUrl ($strFileName, $strFilePath, $strNetworkPath, $boolOverwrite, $boolCreateParent) {
	### Currently not working
	Write-Host "Copying file: $strFileName `nfrom: $strFilePath`nto network location: $strNetworkPath`noverwrite: $boolOverwrite`ncreate parent: $boolCreateParent"
	$strApiUrl = "$strFileServer/webapi/entry.cgi?api=SYNO.FileStation.Upload&version=2&method=upload&_sid=$strSID&path=$strNetworkPath&overwrite=True&create_parents=True&file=""$(Get-Content $strFilePath\$strFileName)"";filename=""$strFileName"""	
	Invoke-RestMethod -Uri $strApiUrl -ContentType "multipart/form-data"
}

### upload file to Filestation using Invoke-RestMethod with Body
function synologyUploadFileBody ($strFileName, $strFilePath, $strNetworkPath, $boolOverwrite, $boolCreateParent) {
	### Currently not working
	$file = Get-Item "$strFilePath\$strFileName"
	$hashHeaders = @{
		'Content-Type' = 'multipart/form-data'
		#'Content-Length' = $file.Length
		#'Content-Encoding' = 'chunked'
	}
	$hashBody = @{
		'api' = 'SYNO.FileStation.Upload'
		'version' = '2'
		'method' = 'upload'
		'overwrite' = $boolOverwrite
		'path' = $strNetworkPath
		'create_parents' = $boolCreateParent
		'_sid' = $strSID
		'file' = """$(Get-Content $strFilePath\$strFileName)"";filename=""$strFileName"""
	}
	$strApiUrl = "$strFileServer/webapi/entry.cgi"
	$jsonData = $hashBody | Invoke-RestMethod -Uri $strApiUrl -Headers $hashHeaders
	$strStatus = $jsonData.success
	Write-Host "File copy was successful: "$strStatus
}

################################################################################
### This is where the magic happens, here you can call the individul functions
########################################	
synologyInfoUrl
synologyInfoBody

$strSID = synologyLoginUrl
$strSID = synologyLoginBody

synologyListSharesUrl $strSID
synologyListSharesBody $strSID

$strShare = 'IBCollection'
$schoolYear = currentSchoolYear
$strDate = currentDate
synologyListFoldersUrl $strSID "$strShare/$schoolYear"
synologyListFoldersBody $strSID "$strShare/$schoolYear"

synologyListFilesUrl $strSID "$strShare/$schoolYear/$strDate"
synologyListFilesUrl $strSID "$strShare/2018-2019/2019-06-21"
synologyListFilesBody $strSID "$strShare/2018-2019/2019-06-21"

synologyCreateFolderUrl $strSID $strShare 'Test'
synologyCreateFolderBody $strSID $strShare 'Test1'

synologyDeleteFolderUrl $strSID "$strShare/Test"
synologyDeleteFolderBody $strSID "$strShare/Test1"

### Currently not working
synologyUploadFileUrl 'test_file.txt' '~/Desktop/' "$strShare/$schoolYear/$strDate" 'True' 'True'

synologyLogoutUrl $strSID
synologyLogoutBody $strSID
