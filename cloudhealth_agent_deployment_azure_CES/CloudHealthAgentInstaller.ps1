# Silent install CloudHealth Agent
# https://help.cloudhealthtech.com/integrations/integrate-with-cht-agent

# Path for the workdir
$workdir = "c:\installer\"

# Check if work directory exists; if not, create it

If (Test-Path -Path $workdir -PathType Container)
{
    Write-Host "$workdir already exists" -ForegroundColor Red
}
else {
    New-Item -Path $workdir -ItemType Directory
}

# Download the installer

$source = "https://s3.amazonaws.com/remote-collector/agent/windows/22/CloudHealthAgent.exe"
$destination = "$workdir\CloudHealthAgent.exe"

# Check if Invoke-Webreqest exists; otherwise, execute WebClient

If (Get-Command 'Invoke-WebRequest')
{   
    Invoke-WebRequest $source -OutFile $destination
}
else {
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile($source, $destination)
}

# Start the installation

Start-Process -FilePath "$workdir\CloudHealthAgent.exe" -ArgumentList /S /v"/l* install.log /qn CLOUDNAME=azure CHTAPIKEY=b43ff4a4-e67f-40cc-9f49-cdf6a2eb8dea"

# Wait XX seconds for the installation for finish

Start-Sleep -s 35

# Remove the installer

rm -Force $workdir\CloudHealth*
