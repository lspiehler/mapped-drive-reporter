Option Explicit
On Error Resume Next

Dim jsonreq, restReq, url, drivemappings, userdn, computerdn, site

Function getDriveMappings(json)
	Dim strComputer, oWMI, colmld, omld, dm, mapping, access, availability, server, letter, volumename, providername, freespace, size, status, statusinfo
	
	dm = Array()
	Const ATTR_DEFAULT = 4
	strComputer = "."

	Set oWMI = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
	Set colmld = oWMI.ExecQuery("SELECT * FROM Win32_MappedLogicalDisk")

	For Each omld In colmld
		If isNull(omld.Access) Then
			access = " null"
		Else
			access = " """ + omld.Access + """"
		End If
		
		If isNull(omld.Availability) Then
			availability = " null"
		Else
			availability = " """ + omld.Availability + """"
		End If
		
		If isNull(omld.Name) Then
			letter = " null"
		Else
			letter = " """ + omld.Name + """"
		End If
		
		If isNull(omld.VolumeName) Then
			volumename = " null"
		Else
			volumename = " """ + omld.VolumeName + """"
		End If
		
		If isNull(omld.ProviderName) Then
			providername = " null"
		Else
			providername = " """ + omld.ProviderName + """"
		End If
		
		If isNull(omld.FreeSpace) Then
			freespace = " null"
		Else
			freespace = " """ + omld.FreeSpace + """"
		End If
		
		If isNull(omld.Size) Then
			size = " null"
		Else
			size = " """ + omld.Size + """"
		End If
		
		If isNull(omld.Status) Then
			status = " null"
		Else
			status = " """ + omld.Status + """"
		End If
		
		If isNull(omld.StatusInfo) Then
			statusinfo = " null"
		Else
			statusinfo = " """ + omld.StatusInfo + """"
		End If
		
		server = """" + Split(providername, "\")(2) + """"
		If json = True Then
			ReDim Preserve dm(UBound(dm) + 1)
			'dm(UBound(dm)) = """" + omld.Name + """: """ + omld.ProviderName + """"
			mapping = "{" + vbCrlf + _
			vbTab + vbTab + """Letter"":" +  letter + "," + vbCrlf + _
			vbTab + vbTab + """VolumeName"":" + volumename + "," + vbCrlf + _
			vbTab + vbTab + """Server"":" + server + "," + vbCrlf + _
			vbTab + vbTab + """Path"":" + Join(Split(providername, "\"), "\\") + "," + vbCrlf + _
			vbTab + vbTab + """Access"":" + access + "," + vbCrlf + _
			vbTab + vbTab + """Availability"":" + availability + "," + vbCrlf + _
			vbTab + vbTab + """FreeSpace"":" + freespace + "," + vbCrlf + _
			vbTab + vbTab + """Size"":" + size + "," + vbCrlf + _
			vbTab + vbTab + """Status"":" + status + "," + vbCrlf + _
			vbTab + vbTab + """StatusInfo"":" + statusinfo + vbCrlf + _
			vbTab + "}"
			'WScript.echo mapping
			dm(UBound(dm)) = mapping
			'getDefaultPrinter = vbTab & """default"":""" + Replace(omld.Name,"\","\\") + """"
		Else
			getDefaultPrinter = omld.Name
		End If
	Next
	
	'WScript.Echo Join(dm, ",")
	If colmld.count = 0 Then
		getDriveMappings = "false"
	Else
		getDriveMappings = Join(dm, ",")
	End If
	
End Function

'WScript.Echo getDriveMappings(True)
'WScript.Quit

Function getDefaultPrinter(json)
	Dim strComputer, oWMI, colPrinters, oPrinter
	Const ATTR_DEFAULT = 4
	strComputer = "."

	Set oWMI = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
	Set colPrinters = oWMI.ExecQuery("SELECT * FROM Win32_Printer")

	For Each oPrinter In colPrinters
		If oPrinter.Attributes And ATTR_DEFAULT Then
			getDefaultPrinter = oPrinter.Name
			If json = True Then
				getDefaultPrinter = vbTab & """default"":""" + Replace(oPrinter.Name,"\","\\") + """"
			Else
				getDefaultPrinter = oPrinter.Name
			End If
			Exit Function
		End If
	Next
	
	getDefaultPrinter = ""
End Function

Function getADSite(json)
	Dim objADSysInfo
	
	Set objADSysInfo = CreateObject("ADSystemInfo")

	'WScript.Echo "Current site name: " & objADSysInfo.SiteName
	If json = True Then
		getADSite = vbTab & """site"":""" + objADSysInfo.SiteName + """"
	Else
		getADSite = objADSysInfo.SiteName
	End If
End Function

Function getADUserDN(json)
	Dim objSysInfo, objUser, rawDN
	
	Set objSysInfo = CreateObject("ADSystemInfo")

	Set objUser = GetObject("LDAP://" & Replace(objSysInfo.UserName,"/","\/"))
	
	rawDN = Join(Split(objUser.distinguishedName, "\"), "\\")
	
	If json = True Then
		getADUserDN = vbTab & """userdn"":""" + rawDN + """"
	Else
		getADUserDN = rawDN
	End If
End Function

Function getADComputerDN(json)
	Dim objSysInfo, objComp, rawDN
	
	Set objSysInfo = CreateObject("ADSystemInfo")

	Set objComp = GetObject("LDAP://" & Replace(objSysInfo.ComputerName,"/","\/"))
	
	rawDN = Join(Split(objComp.distinguishedName, "\"), "\\")
	
	If json = True Then
		getADComputerDN = vbTab & """computerdn"":""" + rawDN + """"
	Else
		getADComputerDN = rawDN
	End If
End Function

Function getEnvVariable(envvar, json, wait)
	Dim objShell, wshSystemEnv, value, loopcount
	
	value=""
	loopcount=0

	Do while value = "" AND loopcount < 45
		Set objShell = WScript.CreateObject("WScript.Shell")
		Set wshSystemEnv = objShell.Environment( "PROCESS" ) 'PROCESS,SYSTEM,USER, OR VOLATILE
		value = wshSystemEnv( envvar )
		loopcount = loopcount+1
		If value = "" Then
			WScript.Sleep(1000)
		End If
		If Not wait Then
			exit do
		End If
	Loop

	If json = True Then
		getEnvVariable = vbTab & """" + envvar + """:""" + value + """"
	Else
		getEnvVariable = value
	End If
End Function

Function getNetworkPrinters(json)

	Dim WshNetwork, existprinters, i, list, printers
	
	printers = Array()
	
	Set WshNetwork = WScript.CreateObject("WScript.Network")

	Set existprinters = WshNetwork.EnumPrinterConnections

	For i = 0 to existprinters.Count - 1 Step 1
		'WScript.Echo existprinters.Item(i)
		If Left(ucase(existprinters.Item(i)),2) = "\\" Then
			If Right(ucase(existprinters.Item(i)),1) <> ":" Then
				'WScript.Echo UBound(printers)
				ReDim Preserve printers(UBound(printers) + 1)
				printers(UBound(printers)) = Replace(existprinters.Item(i),"\","\\")
				''WScript.Echo existprinters.Item(i)
				'WSHNetwork.RemovePrinterConnection existprinters.Item(i+1)
				'If Not printerArray(current,printers) Then
					'WScript.Echo("Deleting " + current)
				'	WSHNetwork.RemovePrinterConnection current
				'End If
			End If
		End If
	Next
	
	If json = True Then
		If UBound(printers) >= 0 Then
			getNetworkPrinters = vbTab & """printers"": [" & vbCrlf & vbTab & vbTab & """" & Join(printers, """," & vbCrlf & vbTab & vbTab & """") & """" & vbCrlf & vbTab & "]"
			Exit Function
		Else
			'getNetworkPrinters = vbTab & """printers"": []"
			getNetworkPrinters = "false"
			Exit Function
		End If
	Else
		getNetworkPrinters = Join(printers, ",")
		Exit Function
	End If
End Function

WScript.Sleep 60000

userdn = getADUserDN(True)
If userdn = "" Then
	userdn = vbTab & """userdn"":"""""
End If

computerdn = getADComputerDN(True)
If computerdn = "" Then
	computerdn = vbTab & """computerdn"":"""""
End If

site = getADSite(True)
If site = "" Then
	site = vbTab & """site"":"""""
End If

'defaultprinter = getDefaultPrinter(True)
'If defaultprinter = "" Then
	'defaultprinter = vbTab & """default"":"""""
'End If

drivemappings = getDriveMappings(True)

'WScript.Echo allprinters

If NOT drivemappings = "false" AND NOT drivemappings = "" Then
	jsonreq = "{" & vbCrlf & _
		getEnvVariable("COMPUTERNAME", True, True) & "," & vbCrlf & _
		getEnvVariable("USERNAME", True, True) & "," & vbCrlf & _
		getEnvVariable("USERDOMAIN", True, True) & "," & vbCrlf & _
		site & "," & vbCrlf & _
		computerdn & "," & vbCrlf & _
		userdn & "," & vbCrlf & _
		vbTab & """mappings"": [" & drivemappings & vbCrlf & vbTab & "]" & _
		vbCrlf & "}"
		
	'WScript.Echo jsonreq
	'WScript.Quit
		
		
	Set restReq = CreateObject("Microsoft.XMLHTTP")

	' Replace <node> with the address of your INSTEON device
	' Additionally, any REST command will work here
	url = "https://apigateway.lcmchealth.org/mappeddrives"

	' If auth is required, replace the userName and password values
	' with the ones you use on your ISY
	'userName = "admin"
	'password = "<yourpassword>"

	'restReq.open "GET", url, false, userName, password
	restReq.open "POST", url, false
	restReq.setRequestHeader "Content-Type", "application/json"
	restReq.send jsonreq
End If

'WScript.Echo restReq.responseText
WScript.Quit