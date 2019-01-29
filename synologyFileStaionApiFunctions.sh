#!/bin/bash
## Written by Heiko 2019-01-28

#Specify variables
strUsername='apiuser'
strPassword='myPassw0rd'
strFileServer='https://xxx.xxx.xxx:5001'
strShare=''

########################################
### Calculate current school year
function currentSchoolYear {	
	intYear=$(date +%Y)
	intMonth=$(date +%m) 
	if [ $intMonth -lt 7 ]; then
		schoolYear="$((intYear - 1))-$intYear"
	else
		schoolYear="$intYear-$((intYear + 1))"
	fi
	strDate=$(date +%Y-%m-%d)
}
########################################
### get FileStation auth module information
function synologyInfo {
	strFileServerApi=${strFileServer}'/webapi/query.cgi?api=SYNO.API.Info&version=1&method=query&query=SYNO.API.Auth,SYNO.FileStation'
	curl $strFileServerApi --silent
}
########################################
### log in to synology filestaitiom and get session sid
function synologyLogin {
	strFileServerApi=${strFileServer}'/webapi/auth.cgi?api=SYNO.API.Auth&version=3&method=login&account='$strUsername'&passwd='$strPassword'&session=FileStation'
	strSID=$(curl $strFileServerApi --silent | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["sid"];')
	echo "Your session id is: "$strSID
}

########################################
### list FilseStation share

############ currently working on 
function synologyListShares {
	strFileServerApi=${strFileServer}'/webapi/entry.cgi?api=SYNO.FileStation.List&version=2&method=list_share&_sid='$strSID
arrShares=$(curl $strFileServerApi --silent | /usr/bin/python -c 'import json,sys; obj=json.load(sys.stdin);
for share in obj["data"]["shares"]: print share["name"]')
	
	for strShares in $arrShares; do
		echo $strShares
	done
}

########################################
## list FilseStation folder in folder path
function synologyListFolders {
	strFileServerApi=${strFileServer}'/webapi/entry.cgi?api=SYNO.FileStation.List&version=2&method=list&_sid='$strSID'&folder_path=/'$1
#json=$(curl $strFileServerApi --silent)
#echo $json
arrJson=$(curl $strFileServerApi --silent | /usr/bin/python -c 'import json,sys; obj=json.load(sys.stdin);
for share in obj["data"]["files"]: 
	if share["isdir"] == 'True': print share["path"]')
	
	for strShares in $arrJson; do
		echo $strShares
	done
}

########################################
## list FilseStation files in folder path
function synologyListFiles {
	strFileServerApi=${strFileServer}'/webapi/entry.cgi?api=SYNO.FileStation.List&version=2&method=list&_sid='$strSID'&folder_path=/'$1
	#curl $strFileServerApi --silent # | perl -pe 's/[^[:ascii:]]+//g'
	intCount=0
arrJson=$(curl $strFileServerApi --silent | perl -pe 's/[^[:ascii:]]+//g' | /usr/bin/python -c 'import json,sys; obj=json.load(sys.stdin);
for file in obj["data"]["files"]: 
	if file["isdir"] == 'False': print file["name"]')
		
	for strFiles in ${arrJson}; do
		echo $strFiles
		intCount=$(expr $intCount + 1)
	done	
	echo "Files in Folder: $intCount"
}

########################################
#create folder on Filestation share
function synologyCreateFolder {
	strFileServerApi=${strFileServer}'/webapi/entry.cgi?api=SYNO.FileStation.CreateFolder&version=2&method=create&_sid='$strSID'&folder_path=/'$1'&name='$2
	strSucess=$(curl $strFileServerApi --silent | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["success"];')
		echo "Creation of folder $1/$2 successful: "$strSucess
}

########################################
#delete Foler on Filestation share
function synologyDeleteFolder {
	strFileServerApi=${strFileServer}'/webapi/entry.cgi?api=SYNO.FileStation.Delete&version=2&method=start&_sid='$strSID'&path=/'$1
	strSucess=$(curl $strFileServerApi --silent | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["success"];')
			echo "Deletion of folder $1 successful: "$strSucess
}

########################################
### upload file to Filestation
function synologyUploadFile {
	strFileServerApi=${strFileServer}'/webapi/entry.cgi?api=SYNO.FileStation.Upload&version=2&method=upload&_sid='$strSID

echo "Copying file: $1
from: $2
to network location: $3
overwrite: $4
create parent: $5"

	strStatus=$(curl $strFileServerApi \
	-H "Content-Type: multipart/form-data" \
	-F "api=SYNO.FileStation.Upload" \
	-F "version=2" \
	-F "method=upload" \
	-F "overwrite=${4}" \
	-F "path=${3}" \
	-F "create_parents=${5}" \
	-F "_sid=${strSID}" \
	-F "file=@\"${2}${1}\";filename=\"${1}\"" \
	--silent | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["success"];')
	echo "File copy was successful: "$strStatus
}

########################################
### log out of synology filestaitiom ###
function synologyLogout {
	strFileServerApi=${strFileServer}'/webapi/auth.cgi?api=SYNO.API.Auth&version=1&method=logout&session=FileStation&_sid='$strSID
	strLogout=$(curl $strFileServerApi --silent | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["success"];')
	echo "Logged out of Filestation successful: "$strLogout
}


########################################
### execute functions
currentSchoolYear
echo "Current school year: $schoolYear"
echo "Crurrent Date: "$strDate
echo ''
#synologyLogin
#synologyListShares
#synologyListFolders "$strShare/$schoolYear"
#synologyListFolders "$strShare"
#synologyListFiles "$strShare"
#synologyListFiles "$strShare/$schoolYear/2019-01-25"
#synologyListFiles "$strShare/$schoolYear/$strDate"
#synologyCreateFolder $strShare "test3"
#synologyDeleteFolder "$strShare/test3"

# Function variables for upload: 1) file_name 2) local file_path 3) network file_path 4) overwrite 5) create_parent
#synologyUploadFile "$strFileName" "$strFilePath" "/$strShare/$schoolYear/$strDate" "true" "true"
#synologyLogout
