﻿Param(
	[Alias('p')]
	[int]$portNumber = 44283,

        [Alias('h')]
        [string]$hostName = 'localhost',

        [Alias('r')]
        [string]$allowRemote = $false
)

Write-Host

$baseAddress = "http://" + $hostName + ":" + $portNumber

Write-Host portNumber is $portNumber
Write-Host hostName is $hostName
Write-Host allowRemote is $allowRemote


Write-Host Bridge base address is $baseAddress

Write-Host

function checkBridge {
	try { 
		$response = Invoke-WebRequest $baseAddress
		Write-Host Status code from the bridge :  $response.StatusCode
		return $true
	} catch {
		Write-Debug $_.Exception
	}
	Write-Warning "Could not find bridge at $baseAddress"
	return $false;
}

$result= checkBridge;

if(!$result)
{
        if ($hostName -ne 'localhost')
        {
            Write-Host The Bridge cannot be started remotely on $hostName.
            Read-Host -Prompt "Press Enter to continue"
            exit -1;
        }

	$bridgePath = Join-Path $PSScriptRoot bridge.exe
        $bridgeArgs = '-port:' + $portNumber;
        if ($allowRemote -eq $true)
        {
            $bridgeArgs = $bridgeArgs + ' -allowRemote'
        }

	Write-Host Launching Bridge at $bridgePath $bridgeArgs

        #Read-Host -Prompt "Press Enter to continue"

	Start-Process $bridgePath $bridgeArgs -WorkingDirectory $PSScriptRoot
	$result = checkBridge;
}

if($result){
	#Write-Host Invoking test command Bridge.Commands.WhoAmI on the bridge.
	#$whoAmIUrl = $baseAddress + "/resource/WhoAmI"
	#Invoke-RestMethod $whoAmIUrl -Method PUT -Body "{name:'Bridge.Commands.WhoAmI'}" -ContentType application/json
	exit 0
}

exit -1;