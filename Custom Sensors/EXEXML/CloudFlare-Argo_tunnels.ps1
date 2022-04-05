#Cloudflared ARGO tunnel monitor plugin for PRTG
# Nikolai Pulman @ 2021

param(
	[string]$account = '',
	[string]$auth_key = '',
	[string]$auth_email = ''
)


#
#
#No edit after this line!
#
#


#API uri
$uri='https://api.cloudflare.com/client/v4/accounts/'

# Start debug timer
$queryMeasurement = [System.Diagnostics.Stopwatch]::StartNew()

#Main Cloudflare API URL
$api_uri = $uri + $account + '/tunnels?is_deleted=false'

#Headers
$headers = @{
'X-Auth-Email'= $auth_email
'X-Auth-Key'= $auth_key
'Content-Type'='application/json'
}

#What the hell???
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null

#Query API point
try {
$responce = Invoke-WebRequest -Uri $api_uri -Method Get -Headers $headers -UseBasicParsing | ConvertFrom-Json 
}catch{
	Write-Output "<prtg>"
	Write-Output "<error>1</error>"
	Write-Output "<text>API Query Failed: $($_.Exception.Message)</text>"
	Write-Output "</prtg>"
	Exit
}

#Stop timer
$queryMeasurement.Stop()


#PRTG XML OPEN
Write-host "<prtg>"

#Loop found tunnels
Foreach ($entry in ($responce.result )){
	#Tunnel as response
Write-Host "<result>"
$name = $entry.name
Write-Host "<channel>$name</channel>"
if($entry.status -eq "active"){$status= 0} else {$status= 2}
Write-Host "<value>$status</value>"
Write-Host "<ValueLookup>oid.CloudFlare.ArgoTunnel.Status</ValueLookup>"
Write-Host "</result>"
}

#Write Responce Time
Write-Host "<result>"
Write-Host "<channel>Response Time</channel>"
Write-Host "<value>$($queryMeasurement.ElapsedMilliseconds)</value>"
Write-Host "<CustomUnit>msecs</CustomUnit>"
Write-Host "</result>"
#PRTG XML CLOSE
write-host "</prtg>"
