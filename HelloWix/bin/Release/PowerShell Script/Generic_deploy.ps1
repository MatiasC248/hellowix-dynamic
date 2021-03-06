Param(
    [Array]$Steps,
    [bool]$forceDeploy,
	[string]$Source,
	[string]$major,
	[string]$minor,
	[string]$build,
	[string]$revision,	 
	[string]$CompanyName,
	[string]$applicationLongName,		
	[string]$applicationShortName,		
	[string]$MSIName,
	[string]$MSPName,
	[string]$MSIToolName,
	[string]$MSIArguments,
	[string]$MSPArguments,
	[string]$MSIToolArguments,
	[string]$ConsoleToolArguments,
	[string]$LogFileName,    
    [string]$ServiceName,
    [string]$ServicePassword
)

$ErrorActionPreference = "Stop" #Stop powershell on first error	
$Version = "$major.$minor.0"
 $Application =  "$CompanyName" + " " + $applicationLongName + " - " + "$Version"
if ($applicationShortName -eq "FundValuationBEWebApiSetup" ) {
    $Application =  "$CompanyName" + " " + $applicationLongName
}

$SetupConfiguration = "$CompanyName" + " " + "Investran Setup Configuration" + " - " + "$Version"
$logversion="$major."+"$minor."+"$build."+"$revision"
$date=Get-Date -Format yyyy-MM-dd-HH.mm
$suffix = "$date-"+"$logversion"

# Create xDeployment folder if not exists. Used to copy the setups.	
$SetupDestination = "C:\xDeployment\"
if (!(Test-path $SetupDestination )) {
	New-Item $SetupDestination -type directory	
}	
$MSIPath = "$Source$MSIName"
$MSPPath = "c:\xDeployment\$MSPName"
$MSIToolPath = "c:\xDeployment\$MSIToolName"

#----------------- Get Product Version from MSI -----------------	
	try {        
        $FullPath = (Resolve-Path "$MSIPath").Path
        $windowsInstaller = New-Object -com WindowsInstaller.Installer

        $database = $windowsInstaller.GetType().InvokeMember(
                "OpenDatabase", "InvokeMethod", $Null, 
                $windowsInstaller, @($FullPath, 0)
            )
        $q = "SELECT Target FROM CustomAction WHERE Action = 'SetARPCOMMENTS'"
        $View = $database.GetType().InvokeMember(
                "OpenView", "InvokeMethod", $Null, $database, ($q)
            )
        $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null)
        $record = $View.GetType().InvokeMember(
                "Fetch", "InvokeMethod", $Null, $View, $Null
            )
        $MsiProductVersion = $record.GetType().InvokeMember(
                "StringData", "GetProperty", $Null, $record, 1
            )
        $View.GetType().InvokeMember("Close", "InvokeMethod", $Null, $View, $Null)

    } catch {
        $MsiProductVersion =  "Failed to get MSI file version the error was: {0}." -f $_
    }
#----------------- Get Product Version from Tool -----------------	
	try {        
        $FullPath = (Resolve-Path "$MSIToolPath").Path
        $windowsInstaller = New-Object -com WindowsInstaller.Installer

        $database = $windowsInstaller.GetType().InvokeMember(
                "OpenDatabase", "InvokeMethod", $Null, 
                $windowsInstaller, @($FullPath, 0)
            )
        $q = "SELECT Target FROM CustomAction WHERE Action = 'SetARPCOMMENTS'"
        $View = $database.GetType().InvokeMember(
                "OpenView", "InvokeMethod", $Null, $database, ($q)
            )
        $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null)
        $record = $View.GetType().InvokeMember(
                "Fetch", "InvokeMethod", $Null, $View, $Null
            )
        $ToolProductVersion = $record.GetType().InvokeMember(
                "StringData", "GetProperty", $Null, $record, 1
            )
        $View.GetType().InvokeMember("Close", "InvokeMethod", $Null, $View, $Null)

    } catch {
        $ToolProductVersion =  "Failed to get MSI file version the error was: {0}." -f $_
    }		
#--------------------------------------------------------------------	

if($Steps -contains "remove")
	{
		Write-Host "--------------------------------------------------- STEP REMOVE ---------------------------------------------------"
		try {
			# Uninstall Setup Configuration Tool
			<#
			if($ConsoleToolArguments) {
				$RegistrySetupConfiguration = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match $SetupConfiguration }
				if($RegistrySetupConfiguration.DisplayName -eq $SetupConfiguration) {                        							
                        if(-not $forceDeploy -and $RegistrySetupConfiguration -match "$ToolProductVersion") {
                            Write-Host "--- Version $ToolProductVersion of Setup Configuration is installed - Skipping uninstall" -foregroundcolor "DarkRed"
                        } else {
                            Write-Host "--- Started Uninstalling Setup Configuration..."
						    $ProductId = $RegistrySetupConfiguration.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
						    $ProductId = $ProductId.Trim()
						    $UninstallCommand ="/X $ProductId REBOOT=ReallySuppress /q /L*V C:\xDeployment\uninstall-SetupConfiguration-$suffix.log" 
						    Write-Host "--- UninstallCommand: $UninstallCommand" 
						    start-process  -Wait -FilePath "msiexec.exe" -ArgumentList $UninstallCommand

                            #Check if uninstall Setup Configuration completed successfully
				            $RegistrySetupConfiguration = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match $SetupConfiguration }
				            if($RegistrySetupConfiguration.DisplayName -ne $SetupConfiguration) {
						            Write-Host "--- Uninstall Setup Configuration completed successfully!" -foregroundcolor "DarkGreen"
				            }
				            else {
						            Write-Host "--- Uninstall Setup Configuration FAILED!" -foregroundcolor "DarkRed"
				            }
                        }
				}
				else {
						Write-Host "--- Setup Configuration does not exist..." -foregroundcolor "DarkRed"
				}				
			}			
			

			# Uninstall Application
			$RegistryApplication = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "$Application" }
			if(!$RegistryApplication) {
                Write-Host "--- Getting registry from Wow6432Node..."  
                $RegistryApplication = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "$Application" }
            }
			#>
            if($True) {	#$RegistryApplication.DisplayName -eq "$Application"
				if(-not $forceDeploy -and $RegistryApplication -match "$MsiProductVersion") {
					Write-Host "--- Version $MsiProductVersion of $Application is installed - Skipping uninstall" -foregroundcolor "DarkRed"
				} 
				else {	
					<#				
					if ($ServiceName  -eq "SunGard Investran Business Events Service") {						
						$Services = Get-WmiObject -Class win32_service -Filter "name  = 'SunGard Investran Business Events Service'"
						if ($Services) {
							foreach ($service in $Services) {
								try {
									Stop-Process -Id $service.processid -Force -PassThru -ErrorAction Stop
									Write-Host "--- SunGard Investran Business Events Service was stopped."
								}
								catch {
									Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message"
								}
							}
						}
						else {
							Write-Host "--- SunGard Investran Business Events Service was not found."
						}
					}
					#>
					Write-Host "--- Started Uninstalling..."                    					
					$ProductId = $RegistryApplication.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
					$ProductId = $ProductId.Trim()
					$UninstallCommand = "/X $MSIPath" #$ProductId #/q /L*V C:\xDeployment\uninstall-$applicationShortName-$suffix.log"  
					Write-Host "--- UninstallCommand: $UninstallCommand" 
					start-process  -Wait -FilePath "msiexec.exe" -ArgumentList $UninstallCommand

                    #Check if uninstall Application completed successfully
			        $RegistryApplication = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "$Application" }
			        if($RegistryApplication.DisplayName -ne "$Application") {
					        Write-Host "--- Uninstall $Application completed successfully!" -foregroundcolor "DarkGreen"
			        }
			        else {
					        Write-Host "--- Uninstall $Application FAILED!" -foregroundcolor "DarkRed"
                            throw $LASTEXITCODE
			        }
				}
			}
			else{
					Write-Host "--- $Application does not exist..." -foregroundcolor "DarkRed"
			}
		}
		catch [Exception]{
			Write-Host "REMOVE step Failed!" -foregroundcolor "DarkRed"
            Write-Host $_.Exception.GetType().FullName, $_.Exception.Message 
            throw $LASTEXITCODE
		}		
	}
if($Steps -contains "install") {
		Write-Host "--------------------------------------------------- STEP INSTALL ---------------------------------------------------"
		try {
			$RegistryApplication = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "$Application" }
			if(!$RegistryApplication) {                
                $RegistryApplication = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "$Application" }
            }					
				if(-not $forceDeploy -and $RegistryApplication -match "$MsiProductVersion") {
					Write-Host "--- Version $MsiProductVersion of $Application is installed - Skipping install" -foregroundcolor "DarkRed"
				}
				else {					
					if ((Test-Path $MSIPath)) {				
						if($ServicePassword) {
							$InstallCommand = "/i $MSIPath $MSIArguments********* REBOOT=ReallySuppress /qn /lv c:\HelloWix\install-$applicationShortName-$suffix.log"                
							Write-Host "--- InstallCommand: $InstallCommand" 
							$InstallCommand = "/i $MSIPath $MSIArguments$ServicePassword REBOOT=ReallySuppress /qn /lv c:\HelloWix\install-$applicationShortName-$suffix.log"                
						} else {
							$InstallCommand = "/i $MSIPath" #$MSIArguments REBOOT=ReallySuppress /qn /lv c:\HelloWix\install-$applicationShortName-$suffix.log"                
							Write-Host "--- InstallCommand: $InstallCommand" 
						}
						
						Start-Process -Wait -FilePath "msiexec.exe" -ArgumentList $InstallCommand

						#Check if install completed successfully
						<#
						$RegistryApplication = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match $Application }
						if(!$RegistryApplication) {
							Write-Host "--- Getting registry from Wow6432Node..."  
							$RegistryApplication = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "$Application" }
						}			    
						if($RegistryApplication.DisplayName -eq $Application) {
								Write-Host "--- Installation of $Application completed successfully!" -foregroundcolor "DarkGreen"
						}
						else {
								Write-Host "--- Installation of $Application FAILED!" -foregroundcolor "DarkRed"
								throw $LASTEXITCODE
						}

						if($ConsoleToolArguments) {
							$RegistrySetupConfiguration = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match $SetupConfiguration }

							if(!$RegistrySetupConfiguration) {								
								Write-Host "--- Started Application installation...$SetupConfiguration"	                   
								$InstallCommand	= "/i $MSIToolPath $MSIToolArguments REBOOT=ReallySuppress /qn /lv c:\HelloWix\install-SetupConfiguration-$suffix.log"                
								Write-Host "--- InstallCommand: $InstallCommand" 
								start-process  -Wait -FilePath "msiexec.exe" -ArgumentList $InstallCommand
							}

							Write-Host "--- Started configuration with Setup Configuration Tool..."                    
							$InvtSetupConfigConsole = "C:\Program Files\FIS Investran\Investran Setup Configuration - 7.5.0\InvestranSetupConfigurationConsole.exe"
							
							Write-Host "--- ConfigurationCommand: $InvtSetupConfigConsole $ConsoleToolArguments"
							start-process  -Wait -FilePath $InvtSetupConfigConsole -ArgumentList $ConsoleToolArguments
														
							$LogPath = "C:\Program Files\FIS Investran\Investran Setup Configuration - 7.5.0\$LogFileName"
							$result = Select-String -Path $LogPath -Pattern "CONFIGURATION_SUCCESS"
							if ($result -ne $null) {
								Write-Host "--- CONFIGURATION_SUCCESS"
							}
							else {
								Write-Host "--- CONFIGURATION_FAILURE"
								throw $LASTEXITCODE
							}
						}
						#>
						if ($ServiceName) {
							try{
							   $list = @($($ServiceName).split(","))
								foreach($service in $list){ 
								 Write-Host "--- Starting Windows service...Name: $service"
								 Start-Service -Name $service -PassThru }						
							}
							catch{
								Write-Host "--- # Starting Windows service FAILED..." -foregroundcolor "DarkRed"
								throw $LASTEXITCODE
							}
						}
					}	
					else {
						Write-Host "--- Installer does not exist at the specified location...$MSIPath" -foregroundcolor "DarkRed"
					}
			}
		}
		catch [Exception]{
			Write-Host "INSTALL step Failed!" -foregroundcolor "DarkRed"
            Write-Host $_.Exception.GetType().FullName, $_.Exception.Message
            throw $LASTEXITCODE
		}
	}
if($Steps -contains "update") {
		Write-Host "--------------------------------------------------- STEP UPDATE ---------------------------------------------------"
		try {
			# Update Application
            $RegistryApplication = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match $Application }
            if(!$RegistryApplication) {
                 Write-Host "--- Getting registry from Wow6432Node..."  
                 $RegistryApplication = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "$Application" }
            }
			if($RegistryApplication.DisplayName -eq $Application) {               
				if (Test-Path $MSPPath) {
					if ($ServiceName  -eq "SunGard Investran Business Events Service") {						
						$Services = Get-WmiObject -Class win32_service -Filter "name  = 'SunGard Investran Business Events Service'"
						if ($Services) {
							foreach ($service in $Services) {
								try {
									Stop-Process -Id $service.processid -Force -PassThru -ErrorAction Stop
									Write-Host "--- SunGard Investran Business Events Service was stopped."
								}
								catch {
									Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message"
								}
							}
						}
						else {
							Write-Host "--- SunGard Investran Business Events Service was not found."
						}
					}
					
					Write-Host "--- Started Application installation of Patch Update...$Application"
                    $UpdateCommand = "/update $MSPPath REBOOT=ReallySuppress /qn /lv c:\xDeployment\update-$applicationShortName-$suffix.log"
                    Write-Host "--- UpdateCommand: $UpdateCommand"
					Start-Process -Wait -FilePath "msiexec.exe" -ArgumentList $UpdateCommand
                    #Check if install completed successfully
			        $RegistryApplication = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match $Application }
                    if(!$RegistryApplication) {
                         Write-Host "--- Getting registry from Wow6432Node..."  
                         $RegistryApplication = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "$Application" }
                    }
			        if($RegistryApplication.DisplayName -eq $Application) {
					        Write-Host "-- Installation of $Application completed successfully!" -foregroundcolor "DarkGreen"
			        }
			        else {
					        Write-Host "-- Installation of $Application FAILED!" -foregroundcolor "DarkRed"
                            throw $LASTEXITCODE
			        }
				}	
				else {
					Write-Host "--- Installer does not exist at the specified location....$MSPPath" -foregroundcolor "DarkRed"
				}
		   }
		   else	   {
	   			Write-Host "--- Please install the base version of $Application and then try with the update...." -foregroundcolor "DarkRed"
		   }			
		}
		catch [Exception]{
			Write-Host "UPDATE step Failed!" -foregroundcolor "DarkRed"
            Write-Host $_.Exception.GetType().FullName, $_.Exception.Message
            throw $LASTEXITCODE
		}
	}	

if($Steps -contains "config") {
		Write-Host "--------------------------------------------------- STEP CONFIGURATION ONLY ---------------------------------------------------"
		try {
			if($ConsoleToolArguments) {
				Write-Host "--- Started configuration with Setup Configuration Tool..."                    
				$InvtSetupConfigConsole = "C:\Program Files\FIS Investran\Investran Setup Configuration - 7.5.0\InvestranSetupConfigurationConsole.exe"
				
				Write-Host "--- ConfigurationCommand: $InvtSetupConfigConsole $ConsoleToolArguments"
				start-process  -Wait -FilePath $InvtSetupConfigConsole -ArgumentList $ConsoleToolArguments
											
				$LogPath = "C:\Program Files\FIS Investran\Investran Setup Configuration - 7.5.0\$LogFileName"
				$result = Select-String -Path $LogPath -Pattern "CONFIGURATION_SUCCESS"
				if ($result -ne $null) {
					Write-Host "--- CONFIGURATION_SUCCESS"
				}
				else {
				Write-Host "--- CONFIGURATION_FAILURE"
				throw $LASTEXITCODE
				}
			} else {
				Write-Host "--- There is not configuration for this application." 
			}
		}
		catch [Exception]{
			Write-Host "UPDATE step Failed!" -foregroundcolor "DarkRed"
            Write-Host $_.Exception.GetType().FullName, $_.Exception.Message
            throw $LASTEXITCODE
		}
	}