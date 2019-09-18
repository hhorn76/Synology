#!/usr/bin/python

from datetime import datetime
import json 
import requests
import urllib2 
import urllib3, certifi

#Specify variables
strUsername=''
strPassword=''
strFileServer='https://xxx.xxx.xxx:5001'
strShare='IBCollection'

#Initialize the urllib3 module for requests without getting SSL warings
http = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())

################################################################################
### Calculate current school year
def currentSchoolYear ():
	intYear=datetime.now().year
	intMonth=datetime.now().month
	if intMonth < 7:
		schoolYear=str (intYear - 1) + '-' + str (intYear)
	else:
		schoolYear=str (intYear) + '-' + str (intYear + 1)
	return schoolYear

################################################################################
### Get current date
def currentDate ():
	return datetime.today().strftime('%Y-%m-%d')

################################################################################
### get info of auth module using urllib2 module
def synologyInfoUrllib2 ():
	strApiUrl = strFileServer + '/webapi/query.cgi?api=SYNO.API.Info&version=1&method=query&query=SYNO.API.Auth,SYNO.FileStation'
	data = urllib2.urlopen(strApiUrl).read()
	print data

### get info of auth module using requests module
def synologyInfoRequests ():
	payload = {
		'api': 'SYNO.API.Info',
		'version': '1',
		'method': 'query',
		'query': 'SYNO.API.Auth,SYNO.FileStation'
	}
	strApiUrl = strFileServer + '/webapi/query.cgi'
	data = requests.get(strApiUrl, payload).content
	print data

### get info of auth module using urllib3 module
def synologyInfoUrllib3 ():
	strApiUrl = strFileServer + '/webapi/query.cgi?api=SYNO.API.Info&version=1&method=query&query=SYNO.API.Auth,SYNO.FileStation'
	r = http.request('GET', strApiUrl)
	jsonData = json.loads(r.data)
	print jsonData

################################################################################
### log in to synology filestaitiom and get session sid using urllib2 module
def synologyLogin ():
	strApiUrl = strFileServer + '/webapi/auth.cgi?api=SYNO.API.Auth&version=3&method=login&account=' + strUsername + '&passwd=' + strPassword + '&session=FileStation'
	jsonData = json.loads(urllib2.urlopen(strApiUrl).read())
	strSID = jsonData["data"]["sid"]
	print "Your session id is: " + strSID
	return strSID

### log in to synology filestaitiom and get session sid using requests module
def synologyLoginRequests ():
	payload = {
		'api': 'SYNO.API.Auth',
		'version': '3',
		'method': 'login',
		'account': strUsername,
		'passwd': strPassword,
		'session': 'FileStation'
	}
	strApiUrl = strFileServer + '/webapi/auth.cgi'
	jsonData = json.loads(requests.get(strApiUrl, payload).content)
	strSID = jsonData["data"]["sid"]
	print "Your session id is: " + strSID
	return strSID
	
### log in to synology filestaitiom and get session sid using urllib3 module	
def synologyLoginUrllib3 ():
	strApiUrl = strFileServer + '/webapi/auth.cgi?api=SYNO.API.Auth&version=3&method=login&account=' + strUsername + '&passwd=' + strPassword + '&session=FileStation'	
	jsonData = json.loads(http.request('GET', strApiUrl).data)
	strSID = jsonData["data"]["sid"]
	print "Your session id is: " + strSID
	return strSID
	
################################################################################
### log out of synology filestaitiom using urllib2 module 
def  synologyLogoutUrllib2 (strSID):
	strApiUrl = strFileServer + '/webapi/auth.cgi?api=SYNO.API.Auth&version=1&method=logout&session=FileStation&_sid=' + strSID
	jsonData = json.loads(urllib2.urlopen(strApiUrl).read())
	strLogout = str (jsonData["success"])
	print "Logged out of Filestation successful: " + strLogout

### log out of synology filestaitiom using requests module 
def  synologyLogoutRequests (strSID):
	payload = {
		'api': 'SYNO.API.Auth',
		'version': '1',
		'method': 'logout',
		'session': 'FileStation',
		'_sid': strSID
	}
	strApiUrl = strFileServer + '/webapi/auth.cgi'
	jsonData = json.loads(requests.get(strApiUrl, payload).content)
	strLogout = str (jsonData["success"])
	print "Logged out of Filestation successful: " + strLogout

### log out of synology filestaitiom using urllib3 module 
def synologyLogoutUrllib3 (strSID):
	payload = {
		'api': 'SYNO.API.Auth',
		'version': '1',
		'method': 'logout',
		'session': 'FileStation',
		'_sid': strSID
	}
	strApiUrl = strFileServer + '/webapi/auth.cgi'
	jsonData = json.loads(http.request('GET', strApiUrl, payload).data)
	strLogout = str (jsonData["success"])
	print "Logged out of Filestation successful: " + strLogout

################################################################################
### list FilseStation share using urllib2 module 
def synologyListSharesUrllib2 (strSID):
	strApiUrl = strFileServer + '/webapi/entry.cgi?api=SYNO.FileStation.List&version=2&method=list_share&_sid=' + strSID
	jsonData = json.loads(urllib2.urlopen(strApiUrl).read())
	for share in jsonData["data"]["shares"]:
		print share["name"]

### list FilseStation share	using requests module 
def synologyListSharesRequests (strSID):
	payload = {
		'api': 'SYNO.FileStation.List',
		'version': '2',
		'method': 'list_share',
		'_sid': strSID
	}
	strApiUrl = strFileServer + '/webapi/entry.cgi'
	jsonData = json.loads(requests.get(strApiUrl, payload).content)
	for share in jsonData["data"]["shares"]:
		print share["name"]

### list FilseStation share using urllib3 module 
def synologyListSharesUrllib3 (strSID):
	payload = {
		'api': 'SYNO.FileStation.List',
		'version': '2',
		'method': 'list_share',
		'_sid': strSID
	}
	strApiUrl = strFileServer + '/webapi/entry.cgi'
	jsonData = json.loads(http.request('GET', strApiUrl, payload).data)
	for share in jsonData["data"]["shares"]:
		print share["name"]

################################################################################
## list FilseStation folder in folder path using urllib2 module 
def synologyListFoldersUrllib2 (strSID, strPath):
	strApiUrl = strFileServer + '/webapi/entry.cgi?api=SYNO.FileStation.List&version=2&method=list&_sid=' + strSID + '&folder_path=/' + strPath
	jsonData = json.loads(urllib2.urlopen(strApiUrl).read())
	for folders in jsonData["data"]["files"]:
		if folders["isdir"] == True:
			print folders["path"]

## list FilseStation folder in folder path using requests module 
def synologyListFoldersRequests (strSID, strPath):
	payload = {
		'api': 'SYNO.FileStation.List',
		'version': '2',
		'method': 'list',
		'_sid': strSID,
		'folder_path': '/'+ strPath
	}
	strApiUrl = strFileServer + '/webapi/entry.cgi'
	jsonData = json.loads(requests.get(strApiUrl, payload).content)
	for folders in jsonData["data"]["files"]:
		if folders["isdir"] == True:
			print folders["path"]

## list FilseStation folder in folder path using urllib3 module 
def synologyListFoldersUrllib3 (strSID, strPath):
	payload = {
			'api': 'SYNO.FileStation.List',
			'version': '2',
			'method': 'list',
			'_sid': strSID,
			'folder_path': '/'+ strPath
		}
	strApiUrl = strFileServer + '/webapi/entry.cgi'
	jsonData = json.loads(http.request('GET', strApiUrl, payload).data)
	for folders in jsonData["data"]["files"]:
		if folders["isdir"] == True:
			print folders["path"]

################################################################################
## list FilseStation files in folder path using urllib2 module 
def synologyListFilesUrllib2 (strSID, strPath):
	strApiUrl = strFileServer + '/webapi/entry.cgi?api=SYNO.FileStation.List&version=2&method=list&_sid=' + strSID + '&folder_path=/' + strPath
	jsonData = json.loads(urllib2.urlopen(strApiUrl).read())
	intCount = 0
	for files in jsonData["data"]["files"]:
		if files["isdir"] == False:
			intCount+=1
			print files["name"]
	print 'Files in Folder: ' + str (intCount)

## list FilseStation files in folder path using requests module 
def synologyListFilesRequests (strSID, strPath):
	payload = {
		'api': 'SYNO.FileStation.List',
		'version': '2',
		'method': 'list',
		'_sid': strSID,
		'folder_path': '/'+ strPath
	}
	strApiUrl = strFileServer + '/webapi/entry.cgi'
	jsonData = json.loads(requests.get(strApiUrl, payload).content)
	intCount = 0
	for files in jsonData["data"]["files"]:
		if files["isdir"] == False:
			intCount+=1
			print files["name"]
	print 'Files in Folder: ' + str (intCount)
	
## list FilseStation files in folder path using urllib3 module 
def synologyListFilesUrllib3 (strSID, strPath):
	payload = {
		'api': 'SYNO.FileStation.List',
		'version': '2',
		'method': 'list',
		'_sid': strSID,
		'folder_path': '/'+ strPath
	}
	strApiUrl = strFileServer + '/webapi/entry.cgi'
	jsonData = json.loads(http.request('GET', strApiUrl, payload).data)
	intCount = 0
	for files in jsonData["data"]["files"]:
		if files["isdir"] == False:
			intCount+=1
			print files["name"]
	print 'Files in Folder: ' + str (intCount)

################################################################################
#create folder on Filestation share
def synologyCreateFolderUrllib2 (strSID, strPath, strName):
	strApiUrl = strFileServer + '/webapi/entry.cgi?api=SYNO.FileStation.CreateFolder&version=2&method=create&_sid=' + strSID + '&folder_path=/'+ strPath + '&name=' + strName
	jsonData = json.loads(urllib2.urlopen(strApiUrl).read())
	strSucess = str (jsonData["success"])
	print 'Creation of folder /' + strPath + '/' + strName + ' successful: ' + strSucess

#create folder on Filestation share using requests module 
def synologyCreateFolderRequests (strSID, strPath, strName):
	payload = {
		'api': 'SYNO.FileStation.CreateFolder',
		'version': '2',
		'method': 'create',
		'_sid': strSID,
		'folder_path': '/' + strPath,
		'name': strName
	}
	strApiUrl = strFileServer + '/webapi/entry.cgi'
	jsonData = json.loads(requests.get(strApiUrl, payload).content)
	strSucess = str (jsonData["success"])
	print 'Creation of folder /' + strPath + '/' + strName + ' successful: ' + strSucess

#create folder on Filestation share using urllib3 module 
def synologyCreateFolderUrllib3 (strSID, strPath, strName):
	payload = {
		'api': 'SYNO.FileStation.CreateFolder',
		'version': '2',
		'method': 'create',
		'_sid': strSID,
		'folder_path': '/' + strPath,
		'name': strName
	}
	strApiUrl = strFileServer + '/webapi/entry.cgi'
	jsonData = json.loads(http.request('GET', strApiUrl, payload).data)
	strSucess = str (jsonData["success"])
	print 'Creation of folder /' + strPath + '/' + strName + ' successful: ' + strSucess

################################################################################
#delete Foler on Filestation share
def synologyDeleteFolderUrllib2 (strSID, strPath):
	strApiUrl = strFileServer + '/webapi/entry.cgi?api=SYNO.FileStation.Delete&version=2&method=start&_sid=' + strSID + '&path=/' + strPath
	jsonData = json.loads(urllib2.urlopen(strApiUrl).read())
	strSucess = str (jsonData["success"])
	print 'Deletion of folder ' + strPath + ' successful: ' + strSucess
	
#delete Foler on Filestation share using requests module 
def synologyDeleteFolderRequests (strSID, strPath):
	payload = {
		'api': 'SYNO.FileStation.Delete',
		'version': '2',
		'method': 'start',
		'_sid': strSID,
		'path': '/' + strPath
	}
	strApiUrl = strFileServer + '/webapi/entry.cgi'
	jsonData = json.loads(requests.get(strApiUrl, payload).content)
	strSucess = str (jsonData["success"])
	print 'Deletion of folder ' + strPath + ' successful: ' + strSucess
	
#delete Foler on Filestation share using requests module 
def synologyDeleteFolderUrllib3 (strSID, strPath):
	payload = {
		'api': 'SYNO.FileStation.Delete',
		'version': '2',
		'method': 'start',
		'_sid': strSID,
		'path': '/' + strPath
	}
	strApiUrl = strFileServer + '/webapi/entry.cgi'
	jsonData = json.loads(http.request('GET', strApiUrl, payload).data)
	strSucess = str (jsonData["success"])
	print 'Deletion of folder ' + strPath + ' successful: ' + strSucess

################################################################################
### upload file to Filestation
#def synologyUploadFile (strFileName, strFilePath, strNetworkPath, boolOverwrite, boolCreatePrent):
#	strApiUrl = strFileServer + '/webapi/entry.cgi?api=SYNO.FileStation.Upload&version=2&method=upload&_sid=' + strSID
#	print strFileName, strFilePath, strNetworkPath, boolOverwrite, boolCreatPrent
	
	### Currently not working
def synologyUploadFile(strDestPath, strFilePath, sid, create_parents=True, overwrite=True):
	api_name = 'SYNO.FileStation.Upload'
	filename = os.path.basename(strFilePath)
	session = requests.session()
	with open(strFilePath, 'rb') as payload:
		url = strFileServer + '/webapi/entry.cgi' + '?api=' + api_name + '&version=2&method=upload&_sid=' + sid
		args = {
		'path': strDestPath,
		'create_parents': create_parents,
		'overwrite': overwrite,
		}
		files = {'file': (filename, payload, 'application/octet-stream')}
		print url
		print args
		r = session.post(url, data=args, files=files)
		print "Uploading file: " + strFilePath + ' to ' + strDestPath
		if r.status_code is 200 and r.json()['success']:
			return 'Upload Complete'
		else:
			print r.status_code, r.json()
			return r.status_code, r.json()

# 	POST /webapi/entry.cgi
# Content-Length:20326728
# Content-type: multipart/form-data, boundary=AaB03x
# --AaB03x
# content-disposition: form-data; name="api"
# SYNO.FileStation.Upload
# --AaB03x
# content-disposition: form-data; name="version"
# 2
# --AaB03x
# content-disposition: form-data; name="method"
# upload
# --AaB03x
# content-disposition: form-data; name="path"
# /upload/test
# --AaB03x
# content-disposition: form-data; name="create_parents"
# true
# --AaB03x
# content-disposition: form-data; name="file"; filename="file1.txt"
# Content-Type: application/octet-stream
# ... contents of file1.txt ...
# --AaB03x--

########################################	
schoolYear = currentSchoolYear ()
strDate = currentDate ()
#synologyInfoUrllib2 ()
#synologyInfoRequests()
#synologyInfoUrllib3 ()

#strSID = synologyLoginUrllib2 ()
#strSID = synologyLoginRequests()
strSID = synologyLoginUrllib3 ()

#synologyListSharesUrllib2 (strSID)
#synologyListSharesRequests(strSID)
#synologyListSharesUrllib3 (strSID)

#synologyListFoldersUrllib2 (strSID, strShare + '/' + schoolYear)
#synologyListFoldersRequests (strSID, strShare + '/' + schoolYear)
#synologyListFoldersUrllib3 (strSID, strShare + '/' + schoolYear)

#synologyListFilesUrllib2 (strSID, strShare + '/' + schoolYear + '/' + strDate)
#synologyListFilesUrllib2 (strSID, strShare + '/' + schoolYear + '/2019-01-27')
#synologyListFilesRequests (strSID, strShare + '/' + schoolYear + '/2019-01-27')
#synologyListFilesUrllib3 (strSID, strShare + '/' + schoolYear + '/2019-01-27')

#synologyCreateFolderUrllib2 (strSID, strShare, 'Test')
#synologyCreateFolderRequests (strSID, strShare, 'Test')
#synologyCreateFolderUrllib3 (strSID, strShare, 'Test')

#synologyDeleteFolderUrllib2 (strSID, strShare + '/Test')
#synologyDeleteFolderRequests (strSID, strShare + '/Test')
#synologyDeleteFolderUrllib3 (strSID, strShare + '/Test')

#synologyUploadFile (strShare + '/' + schoolYear + '/' + strDate, '~/Desktop/test_file.txt', strSID, True, True)

#synologyLogoutUrllib2 (strSID)
#synologyLogoutRequests(strSID)
synologyLogoutUrllib3 (strSID)