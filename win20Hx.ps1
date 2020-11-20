# ��������� ��������� ������� ������ � ������� ������ PowerShell;
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# ������� ������ �� ������ ������� �� ����� ��������������;
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# ������������� ����;
function Show-Menu
{
	param (
		[string]$Title = '������ ��������� Windows 10 Build 2004 � 2009 ( 20H1 | 20H2 )'
	)
	cls
	Write-Host "================ $Title ================"
	Write-Host "---"
	Write-Host "1: ��������� ������;"
	Write-Host "2: ��������� ������ ���������������� ������������;"
	Write-Host "3: ��������� ���������� Windows;"
	Write-Host "4: ��������� ���������� Windows;"
	Write-Host "5: ������� ���������� ���������� �� �������� Windows Store;"
	Write-Host "6: �������� Tweak's;"
	Write-Host "7: ��������� ������� ��� ������ � SSD;"
	Write-Host "8: ������� OneDrive;"
	Write-Host "9: ��������� ������� ����� WinSxS;"
	Write-Host "10: ���������� ���������� � ������� WinGet (App Installer);"
	Write-Host "---"
	Write-Host "Q: ������� 'Q' ����� �����."
}

# ������ ������� �������;
#
# ���������� �����;
Function f_disable_services {
	$services = @(
		# �������������� ����������� ��� ������������ ������������� � ����������
		"DiagTrack"
		# ������ ������������� push-��������� �� ������ ��������� WAP
		"dmwappushservice"
		# ����������� ������ �������� ������ ����������� Microsoft
		"diagnosticshub.standardcollector.service"
		# ������ ������������ ��������� Microsoft Defender
		"WinDefend"
		# ������ ������������ ����������
		"UsoSvc"
		# ������ ��������� ���������� � ������ ����������� �����
		"TabletInputService"
		# ������ ���������� �����
		"RmSvc"
	)
	ForEach ($service in $services) {
		echo "��������� ������: $service"
		Get-Service -Name $service | Stop-Service -Force
		echo "���������� ������: $service"
		Get-Service -Name $service | Set-Service -StartupType Disabled
	}
}

# ��������� ������ ���������������� ������������;
function f_disable_scheduledtasks {
	$ScheduledTaskList = @(
		# �������� ��������������� ������ ��������� ��� ������� � ��������� ��������� �������� ������������ ����������� ����������
		"Microsoft Compatibility Appraiser",
		# ���� ��������������� ������ ��������� ��� ������� � ��������� ��������� �������� ��
		"ProgramDataUpdater",
		# ��� ������ �������� � ��������� ������ SQM ��� ������� � ��������� ��������� �������� ������������ �����������
		"Proxy",
		# ���� ������������ ������� ������� ����������� � ��������� �� ��������� �������� ������������ ����������� Windows, ��� ������ ����� �������� � ���������� �������� � ������ ������������ ����������� � ����������
		"Consolidator",
		# ��� ���������� ������ ��������� ��������� �������� �� ���� USB (USB CEIP) �������������� ���� �������������� ������ �� ������������� ������������� ���������������� ���� USB � � ������� � ����������, ������� ������������ ���������� ������ ���������� �� �������� ����������� ��������� � Windows
		"UsbCeip",
		# ��� �������������, ����������� � ��������� �������� �������� ������������ �����������, ������ ����������� ������ Windows ������������� ����� �������� � ������ � ������� � ���������� ����������
		"Microsoft-Windows-DiskDiagnosticDataCollector",
		# �������� ����� ������������ �� ��������� ������ �� ���� �� ����������� � ��������� ������������, ����� ������� ��������� � �������������� ������
		"File History (maintenance mode)",
		# �������� �������������� � ����������� �������
		"WinSAT",
		# ��� ������ ���������� ��������� ����� (����������� �����������) ���������� "�����"
		"MapsToastTask",
		# ��� ������ ��������� ������� ���������� ��� ����, ����������� ��� ����������� �������������
		"MapsUpdateTask",
		# ������������� �������� � ���������� ������ �������� ������������
		"FamilySafetyMonitor",
		# �������������� ��������� ��������� �� ������� ������� ����� ������� ������� ����������
		"FamilySafetyRefreshTask",
		# XblGameSave Standby Task
		"XblGameSaveTask"
	)
	# ���� ���������� �� �������� ���������, ��������� ����� � FODCleanupTask
	if ((Get-CimInstance -ClassName Win32_ComputerSystem).PCSystemType -ne 2) {
		# Windows Hello
		$ScheduledTaskList += "FODCleanupTask"
	}
	Get-ScheduledTask -TaskName $ScheduledTaskList | Disable-ScheduledTask
}

# ��������� ���������� Windows;
Function f_disable_components {
	$WindowsOptionalFeatures = @(
		# ���������� ������� ������
		"LegacyComponents"
		# ���������� ������ � �����������
		"MediaPlayback"
		# �������� ������ XPS-���������� (Microsoft)
		"Printing-XPSServices-Features"
		# ������ ������� �����
		"WorkFolders-Client"
	)
	Disable-WindowsOptionalFeature -Online -FeatureName $WindowsOptionalFeatures -NoRestart
}

# ��������� ���������� Windows;
Function f_disable_winupdate {
	$services = @(
		# ������ ������������ ����������
		"UsoSvc"
		# ����� ���������� Windows
		"wuauserv"
	)
	ForEach ($service in $services) {
		echo "��������� ������: $service"
		Get-Service -Name $service | Stop-Service -Force
		echo "���������� ������: $service"
		Get-Service -Name $service | Set-Service -StartupType Disabled
	}
	$ScheduledTaskList = @(
		# WindowsUpdate
		"Scheduled Start"
		# UpdateOrchestrator
		#"Schedule Scan"
		#"Schedule Scan Static Task"
	)
	Get-ScheduledTask -TaskName $ScheduledTaskList | Disable-ScheduledTask
	
}

# ������� ���������� ���������� �� �������� Windows Store;
Function f_remove_builtinapps {
	# Get-AppxProvisionedPackage -Online | Select DisplayName, PackageName
	# Get-AppxPackage | Select Name, PackageFullName
	$apps = @(
		# Cortana
		"Microsoft.549981C3F5F10"
		# ����������� ���������
		"Microsoft.GetHelp"
		# ������ ����������
		"Microsoft.Getstarted"
		# �������� ��������� ��������� ����������
		"Microsoft.Microsoft3DViewer"
		# Office
		"Microsoft.MicrosoftOfficeHub"
		# ���� ������������� ����������
		"Microsoft.MicrosoftSolitaireCollection"
		# ������ ��������� ����������
		"Microsoft.MixedReality.Portal"
		# Paint 3D
		"Microsoft.MSPaint"
		# OneNote ��� Windows 10
		"Microsoft.Office.OneNote"
		# ���� (����������)
		"Microsoft.People"
		# Skype
		"Microsoft.SkypeApp"
		# ���������� (����������)
		"Microsoft.Windows.Photos"
		# ������ Windows
		"Microsoft.WindowsCamera"
		# ����� �������
		"Microsoft.WindowsFeedbackHub"
		# ����� Windows
		"Microsoft.WindowsMaps"
		# �������������� xbox Live
		"Microsoft.Xbox.TCUI"
		# ��������� ������� Xbox
		"Microsoft.XboxApp"
		# ������������ ������ Xbox
		"Microsoft.XboxGameOverlay"
		# ���� ���� Xbox
		"Microsoft.XboxGamingOverlay"
		# ��������� ������������� Xbox
		"Microsoft.XboxIdentityProvider"
		# XboxSpeechToTextOverlay
		"Microsoft.XboxSpeechToTextOverlay"
		# ������ Groove
		"Microsoft.ZuneMusic"
		# ���� � ��
		"Microsoft.ZuneVideo"
		# ������.������
		"A025C540.Yandex.Music"
	)
	ForEach ($app in $apps) {
		$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $app}
		if ($ProvisionedPackages -ne $null) {
			echo "�������� ����������������� ������: $app"
			ForEach  ($ProvisionedPackage in $ProvisionedPackages) {
				Remove-AppxProvisionedPackage -Online -PackageName $ProvisionedPackage.PackageName
			}
		}
		else {
			echo "�� ������� ����� ���������������� �����: $app"
		}
		$Packages = Get-AppxPackage | Where-Object {$_.Name -eq $app}
		if ($Packages -ne $null) {
			echo "�������� ������: $app"
			ForEach ($Package in $Packages) {
				Remove-AppxPackage -AllUsers -Package $Package.PackageFullName
			}
		}
		else {
			echo "�� ������� ����� �����: $app"
		}
	}
}

# �������� Tweak's
Function f_tweaks {
	# ���������� ����� ����� �� ��������� �� ���������� ����
	Set-WinDefaultInputMethodOverride "0409:00000409"
	# ���������� "���� ���������" �� ������� ����� (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -Type DWord 0
	# ���������� "��������� ������������" �� ������� ����� (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' -Type DWord 0
	# ��������� ��������� ���: "���� ���������" (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'LaunchTo' -Type DWord 1
	# �� ���������� ������ ������� �� ������ ����� (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowCortanaButton' -Type DWord 0
	# �� ���������� ������� ������������ ����� �� ������ �������� ������� (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'ShowFrequent' -Type DWord 0
	# �� ���������� ������� ���������������� ����� �� ������ �������� ������� (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'ShowRecent' -Type DWord 0
	# �� ������������ ���������� ��� ���� ��������� � ��������� (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers' -Name 'DisableAutoplay' -Type DWord 1
	# �� ��������� ����������� �� ������ ����������� ��������� ���������� � ���������� ��������� �� ���� ���������� � �������� (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP' -Name 'RomeSdkChannelUserAuthzPolicy' -Type DWord 0
	# �������� ������������ ������������ ���������� � ���������� ����������
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name 'HwSchMode' -Type DWord 2
	# ��������� �������������� ��������� ��������������� ���������� (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SilentInstalledAppsEnabled' -Type DWord 0
	# �� ��������� ���-������ ������������� ������� ���������� �� ���� ������� � ������ ������ (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\Control Panel\International\User Profile' -Name 'HttpAcceptLanguageOptOut' -Type DWord 1
	# �� ���������� ������������������� �����������, ���������� �� ��������� ��������� ��������������� ������ (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy' -Name 'TailoredExperiencesWithDiagnosticDataEnabled' -Type DWord 0
	# ������������ ������ PRINT SCREEN, ����� ��������� ������� �������� ��������� ������ (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\Control Panel\Keyboard' -Name 'PrintScreenKeyForSnippingEnabled' -Type DWord 1
	# �� �������� ������, ��������� � ������������ ��� ������������� Windows (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-338389Enabled' -Type DWord 0
	# �� ���������� ������������� ���������� � ���������� "���������" (������ ��� �������� ������������)
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-338393Enabled' -Type DWord 0
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-353694Enabled' -Type DWord 0
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-353696Enabled' -Type DWord 0
	# �������� ��������� ������ ��������� Windows PowerShell
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'DontUsePowerShellOnWinX' -Type DWord 1
	# ������ ����� "�������� �������" �� "���� ���������" � �� ������ �������� ������� (������ ��� �������� ������������)
	if (-not (Test-Path -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag')) {
		New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag' -Force
	} Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag' -Name 'ThisPCPolicy' -Type String 'Hide'
	# �e �o�a����� "- �p���" � ����� co��a�ae��� �p����� (������ ��� �������� ������������)
	if (-not (Test-Path -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates')) {
		New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates' -Force
	} Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates' -Name 'ShortcutNameTemplate' -Type String '%s.lnk'
	# �������� ������ ������ ���������� ���: ������ ������ (������ ��� �������� ������������)
	if (-not (Test-Path -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel)) {
		New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel -Force
	} Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel' -Name 'AllItemsIconView' -Type DWord 1
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel' -Name 'PropertyType' -Type DWord 1
	# �������� ������� ������������ ������� �� "�������" ��� �������� ������������
	if (-not (Test-Path -Path HKCU:\SOFTWARE\Microsoft\Siuf\Rules)) {
		New-Item -Path HKCU:\SOFTWARE\Microsoft\Siuf\Rules -Force
	} Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' -Name 'NumberOfSIUFInPeriod' -Type DWord 0
	# �� ��������� ����������� ������������ ������������� ������� (������ ��� �������� ������������)
	if (-not (Test-Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo)) {
		New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Force
	} Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Type DWord 0
	# �� ���������� ������� ���������� ��������� ���������� ��� ����������� ������������ ������������� Windows (������ ��� �������� ������������)
	if (-not (Test-Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement)) {
		New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement -Force
	} Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement' -Name 'ScoobeSystemSettingEnabled' -Type DWord 0
	# ���������� ������� ����� ��������������� �������� �� �� "�����������"
	if (Get-WindowsEdition -Online | Where-Object -FilterScript {$_.Edition -like "Enterprise*" -or $_.Edition -eq "Education"}) {
		# "������������"
		Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' -Name 'AllowTelemetry' -Type DWord 0
		
	} else {
		# "������� ���������"
		Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' -Name 'AllowTelemetry' -Type DWord 1
	}
	# ��������� ������ �� ������� Windows ��� �������� ������������
	if ((Get-WindowsEdition -Online).Edition -notmatch "Core*") {
		Get-ScheduledTask -TaskName QueueReporting | Disable-ScheduledTask
		Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\Windows Error Reporting' -Name 'Disabled' -Type DWord 1
	}
}

# ����������� ��� ������ ������������� �� SSD;
Function f_ssd_settings {
	# get-help Disable-ComputerRestore -examples
	# ��������� ������ ������� ��� ������ "C:\","D:\"
	Disable-ComputerRestore "C:\", "D:\"
	# ������� ��� ����� �������������� �� ���� ������
	vssadmin delete shadows /all /quiet
	# ���������� ����� ��������
	wmic computersystem set AutomaticManagedPagefile=False
	wmic pagefileset delete
	# ���������� ����������
	powercfg -h off
	# ���������� ����� Superfetch � ������ Windows
	#Get-Service -Name SysMain | Stop-Service -Force
	#Get-Service -Name SysMain | Set-Service -StartupType Disabled
	Get-Service -Name WSearch | Stop-Service -Force
	Get-Service -Name WSearch | Set-Service -StartupType Disabled
	# ���������� Prefetch � Superfetch
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters' -Name 'EnablePrefetcher' -Type DWord 0
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters' -Name 'EnableSuperfetch' -Type DWord 0
	# ���������� ClearPageFileAtShutdown � LargeSystemCache
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'ClearPageFileAtShutdown' -Type DWord 0
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'LargeSystemCache' -Type DWord 0
}

# ������� OneDrive;
function f_remove_onedrive
{
	[string]$UninstallString = Get-Package -Name "Microsoft OneDrive" -ProviderName Programs -ErrorAction Ignore | ForEach-Object -Process {$_.Meta.Attributes["UninstallString"]}
	if ($UninstallString)
	{
		Write-Verbose -Message $Localization.OneDriveUninstalling -Verbose
		Stop-Process -Name OneDrive -Force -ErrorAction Ignore
		Stop-Process -Name OneDriveSetup -Force -ErrorAction Ignore
		Stop-Process -Name FileCoAuth -Force -ErrorAction Ignore

		# �������� ������ �� OneDriveSetup.exe � ��� ��������(�)
		[string[]]$OneDriveSetup = ($UninstallString -Replace("\s*/",",/")).Split(",").Trim()
		if ($OneDriveSetup.Count -eq 2)
		{
			Start-Process -FilePath $OneDriveSetup[0] -ArgumentList $OneDriveSetup[1..1] -Wait
		}
		else
		{
			Start-Process -FilePath $OneDriveSetup[0] -ArgumentList $OneDriveSetup[1..2] -Wait
		}

		# �������� ���� �� ����� ������������ OneDrive
		$OneDriveUserFolder = Get-ItemPropertyValue -Path HKCU:\Environment -Name OneDrive
		if ((Get-ChildItem -Path $OneDriveUserFolder | Measure-Object).Count -eq 0)
		{
			Remove-Item -Path $OneDriveUserFolder -Recurse -Force
		}
		else
		{
			$Message = Invoke-Command -ScriptBlock ([ScriptBlock]::Create($Localization.OneDriveNotEmptyFolder))
			Write-Error -Message $Message -ErrorAction SilentlyContinue
			Invoke-Item -Path $OneDriveUserFolder
		}

		Remove-ItemProperty -Path HKCU:\Environment -Name OneDrive, OneDriveConsumer -Force -ErrorAction Ignore
		Remove-Item -Path HKCU:\SOFTWARE\Microsoft\OneDrive -Recurse -Force -ErrorAction Ignore
		Remove-Item -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\OneDrive -Recurse -Force -ErrorAction Ignore
		Remove-Item -Path "$env:ProgramData\Microsoft OneDrive" -Recurse -Force -ErrorAction Ignore
		Remove-Item -Path $env:SystemDrive\OneDriveTemp -Recurse -Force -ErrorAction Ignore
		Unregister-ScheduledTask -TaskName *OneDrive* -Confirm:$false

		# �������� ���� �� ����� OneDrive
		$OneDriveFolder = Split-Path -Path (Split-Path -Path $OneDriveSetup[0] -Parent)

		# ��������� ��� �������� �����, ����� ������������ �� ����� ����������� ����������
		Clear-Variable -Name OpenedFolders -Force -ErrorAction Ignore
		$OpenedFolders = {(New-Object -ComObject Shell.Application).Windows() | ForEach-Object -Process {$_.Document.Folder.Self.Path}}.Invoke()

		# ��������� ������� ����������
		TASKKILL /F /IM explorer.exe

		# ������� ����������������� FileSyncShell64.dll � �������
		$FileSyncShell64dlls = Get-ChildItem -Path "$OneDriveFolder\*\amd64\FileSyncShell64.dll" -Force
		foreach ($FileSyncShell64dll in $FileSyncShell64dlls.FullName)
		{
			Start-Process -FilePath regsvr32.exe -ArgumentList "/u /s $FileSyncShell64dll" -Wait
			Remove-Item -Path $FileSyncShell64dll -Force -ErrorAction Ignore

			if (Test-Path -Path $FileSyncShell64dll)
			{
				$Message = Invoke-Command -ScriptBlock ([ScriptBlock]::Create($Localization.OneDriveFileSyncShell64dllBlocked))
				Write-Error -Message $Message -ErrorAction SilentlyContinue
			}
		}

		# ������������� �������� �����
		Start-Process -FilePath explorer
		foreach ($OpenedFolder in $OpenedFolders)
		{
			if (Test-Path -Path $OpenedFolder)
			{
				Invoke-Item -Path $OpenedFolder
			}
		}

		Remove-Item -Path $OneDriveFolder -Recurse -Force -ErrorAction Ignore
		Remove-Item -Path $env:LOCALAPPDATA\OneDrive -Recurse -Force -ErrorAction Ignore
		Remove-Item -Path $env:LOCALAPPDATA\Microsoft\OneDrive -Recurse -Force -ErrorAction Ignore
		Remove-Item -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force -ErrorAction Ignore
	}
}

# ��������� ������� ����� WinSxS | ������� � ������ ������ ����������;
Function f_WinSxS {
	Dism.exe /Online /Cleanup-Image /StartComponentCleanup
}

# App Installer;
Function f_app_installer {
	$wingets = @(
		"7zip.7zip"
		"LibreOffice.LibreOffice"
		"Adobe.AdobeAcrobatReaderDC"
		"Google.Chrome"
		"VideoLAN.VLC"
		"Microsoft.VC++2005Redist-x64"
		"Microsoft.VC++2005Redist-x86"
		"Microsoft.VC++2008Redist-x64"
		"Microsoft.VC++2008Redist-x86"
		"Microsoft.VC++2010Redist-x64"
		"Microsoft.VC++2010Redist-x86"
		"Microsoft.VC++2012Redist-x64"
		"Microsoft.VC++2012Redist-x86"
		"Microsoft.VC++2013Redist-x64"
		"Microsoft.VC++2013Redist-x86"
		"Microsoft.VC++2015-2019Redist-x86"
		"Microsoft.VC++2015-2019Redist-x64"
	)
	ForEach ($winget in $wingets) {
		echo "��������� ����������: $winget"
		winget install $winget
	}
}

# ���� �������� ����;
do
{
	Show-Menu
	$input = Read-Host " - �����"
	switch ($input)
	{
		'1' {
			cls
			f_disable_services
		} '2' {
			cls
			f_disable_scheduledtasks
		} '3' {
			cls
			f_disable_components
		} '4' {
			cls
			f_disable_winupdate
		} '5' {
			cls
			f_remove_builtinapps
		} '6' {
			cls
			f_tweaks
		} '7' {
			cls
			f_ssd_settings
		}'8' {
			cls
			f_remove_onedrive
		}'9' {
			cls
			f_WinSxS
		}'10' {
			cls
			f_app_installer
		} 'q' {
			return
		}
	}
	pause
}
until ($input -eq 'q')
