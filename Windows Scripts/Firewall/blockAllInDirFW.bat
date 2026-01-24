:: This script recursively scans the current directory for all .exe files
:: and creates Windows Firewall rules to block each executable from making
:: any inbound or outbound network connections. It does this by:
::   - Changing to the script's directory
::   - Looping through all .exe files in all subfolders
::   - Adding an outbound block rule for each .exe
::   - Adding an inbound block rule for each .exe
:: Finally, it pauses so you can review the output before the window closes.

@ setlocal enableextensions

@ cd /d "%~dp0"

for /R %%f in (*.exe) do (

netsh advfirewall firewall add rule name="Blocked: %%f" dir=out program="%%f" action=block

netsh advfirewall firewall add rule name="Blocked : %%f" dir=in program="%%f" action=block

)

pause