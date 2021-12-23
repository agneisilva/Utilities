param (
    [Parameter(Mandatory=$true)]
    [string]$buildName = "Projur-rc",
    [Parameter(Mandatory=$true)]
    [string]$type = "minor"
    )

$PSScriptRoot
$username = ""
$password = ""

Function QueryWorkItem {

    Write-Output "##[command] BUILDS BUILD VERSION UPDATER V1.0.0"

    Write-Host "SYSTEM_TEAMPROJECT: $ENV:SYSTEM_TEAMPROJECT"
    Write-Host "SYSTEM_TEAMFOUNDATIONSERVERURI: $ENV:SYSTEM_TEAMFOUNDATIONSERVERURI"
    Write-Host "SYSTEM_TEAMFOUNDATIONCOLLECTIONURI: $ENV:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI"
    Write-Host "SYSTEM_COLLECTIONID: $ENV:SYSTEM_COLLECTIONID"
    Write-Host "SYSTEM_DEFAULTWORKINGDIRECTORY: $ENV:SYSTEM_DEFAULTWORKINGDIRECTORY"
    Write-Host "BUILD_DEFINITIONNAME: $ENV:BUILD_DEFINITIONNAME"
    Write-Host "BUILD_DEFINITIONVERSION: $ENV:BUILD_DEFINITIONVERSION"
    Write-Host "BUILD_BUILDNUMBER: $ENV:BUILD_BUILDNUMBER"
    Write-Host "BUILD_BUILDURI: $ENV:BUILD_BUILDURI"
    Write-Host "BUILD_BUILDID: $ENV:BUILD_BUILDID"
    Write-Host "BUILD_QUEUEDBY: $ENV:BUILD_QUEUEDBY"
    Write-Host "BUILD_QUEUEDBYID: $ENV:BUILD_QUEUEDBYID"
    Write-Host "BUILD_REQUESTEDFOR: $ENV:BUILD_REQUESTEDFOR"
    Write-Host "BUILD_REQUESTEDFORID: $ENV:BUILD_REQUESTEDFORID"
    Write-Host "BUILD_SOURCEVERSION: $ENV:BUILD_SOURCEVERSION"
    Write-Host "BUILD_SOURCEBRANCH: $ENV:BUILD_SOURCEBRANCH"
    Write-Host "BUILD_SOURCEBRANCHNAME: $ENV:BUILD_SOURCEBRANCHNAME"
    Write-Host "BUILD_REPOSITORY_NAME: $ENV:BUILD_REPOSITORY_NAME"
    Write-Host "BUILD_REPOSITORY_PROVIDER: $ENV:BUILD_REPOSITORY_PROVIDER"
    Write-Host "BUILD_REPOSITORY_CLEAN: $ENV:BUILD_REPOSITORY_CLEAN"
    Write-Host "BUILD_REPOSITORY_URI: $ENV:BUILD_REPOSITORY_URI"
    Write-Host "BUILD_REPOSITORY_TFVC_WORKSPACE: $ENV:BUILD_REPOSITORY_TFVC_WORKSPACE"
    Write-Host "BUILD_REPOSITORY_TFVC_SHELVESET: $ENV:BUILD_REPOSITORY_TFVC_SHELVESET"
    Write-Host "BUILD_REPOSITORY_GIT_SUBMODULECHECKOUT: $ENV:BUILD_REPOSITORY_GIT_SUBMODULECHECKOUT"
    Write-Host "AGENT_NAME: $ENV:AGENT_NAME"
    Write-Host "AGENT_ID: $ENV:AGENT_ID"
    Write-Host "AGENT_HOMEDIRECTORY: $ENV:AGENT_HOMEDIRECTORY"
    Write-Host "AGENT_ROOTDIRECTORY: $ENV:AGENT_ROOTDIRECTORY"
    Write-Host "AGENT_WorkFolder: $ENV:AGENT_WorkFolder"
    Write-Host "BUILD_REPOSITORY_LOCALPATH: $ENV:BUILD_REPOSITORY_LOCALPATH"
    Write-Host "BUILD_SOURCESDIRECTORY: $ENV:BUILD_SOURCESDIRECTORY"
    Write-Host "BUILD_ARTIFACTSTAGINGDIRECTORY: $ENV:BUILD_ARTIFACTSTAGINGDIRECTORY"
    Write-Host "BUILD_STAGINGDIRECTORY: $ENV:BUILD_STAGINGDIRECTORY"
    Write-Host "AGENT_BUILDDIRECTORY: $ENV:AGENT_BUILDDIRECTORY"

    Add-Type -AssemblyName System.Web

    $baseUrl = [System.Web.HttpUtility]::HtmlDecode($ENV:SYSTEM_TEAMFOUNDATIONSERVERURI)


    $targetProject = $ENV:SYSTEM_TEAMPROJECT
     
    $strPass = ConvertTo-SecureString -String $password -AsPlainText -Force
    $cred= New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($username, $strPass)

    $header = @{
        Accept        = ("api-version=3.0") 
    }
    $url1 = "$baseUrl$targetProject/_apis/build/Definitions"
     
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $result1 = Invoke-RestMethod -Uri $url1 -Method Get -ContentType "application/json" -Headers $header -Credential $Cred

    Write-Output "##[command] BUILDS LOADED"

    $url2 = ($result1.Value | Where-Object { $_.name -eq $buildName } | Select-Object -First 1).url
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $result2 = Invoke-RestMethod -Uri $url2 -Method Get -ContentType "application/json" -Headers $header -Credential $Cred

    Write-Output "##[command] BUILD LOADED"
    
    $vars = $result2.variables

    $versionMajor = $vars."version.major".Value
    $versionMinor = $vars."version.minor".Value
    $versionPatch = $vars."version.patch".Value
    $versionType = $vars."version.type".Value
    $typeUpdate = $vars."version.$type".Value

    Write-Output "##[warning] Current Version: $versionMajor.$versionMinor.$versionPatch$versionType"

    Write-Output "##[command] UPDATING"

    $result2.variables."version.$type".Value = [int]$typeUpdate + 1

    $post = $result2 | ConvertTo-Json -Depth 10

    #[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    #$response = Invoke-RestMethod -Uri $url2 -Headers $header -Method Put -Body ([System.Text.Encoding]::UTF8.GetBytes($post)) -ContentType "application/json" -Credential $Cred
    #$response.StatusDescription

    Write-Output "##[command] UPDATED"
        
    #$vars = $result2.variables

    #$versionMajor = $vars."version.major".Value
    #$versionMinor = $vars."version.minor".Value
    #$versionPatch = $vars."version.patch".Value
    #$versionType = $vars."version.type".Value
    #$typeUpdate = $vars."version.$type".Value

    Write-Output "##[section] SUCCESS"

    Write-Output "##[warning] Updated type.$type to $typeUpdate"

    Write-Output "##[warning] New Version: $versionMajor.$versionMinor.$versionPatch$versionType"

}

QueryWorkItem


