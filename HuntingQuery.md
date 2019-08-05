# Reference

@HeirhabarovT
https://speakerdeck.com/heirhabarov/phdays-2018-threat-hunting-hands-on-lab

## Using MSI exec to execute msi by url
` process_command_line:"*msiexec*" AND process_command_line:"*http*" `

## Suspicious Processes Spawned From ms office
` event_id:("1" OR "4688") AND process_parent_path:("*\\\\excel.exe" or "*\\\\winword.exe" or "*\\\\powepnt.exe" or "*\\\\msaccess.exe" or "*\\\\mspub.exe" or "*\\\\outook.exe") AND process_path:("*\\\\cmd.exe" or "*\\\\powershell.exe" or "*\\\\wscript.exe" or "*\\\\cscript.exe" or "*\\\\bitsadmin.exe" or "*\\\\certutil.exe" or "*\\\\schtasks.exe" or "*\\\\rundll32.exe" or "*\\\\regsvr32.exe" or "*\\\\wmic.exe" or "*\\\\mshta.exe" or "*\\\\msiexec.exe" or "*\\\\schtasks.exe" or "*\\\\msbuild.exe") `

## WMI Squid By Two Attack
` process_command_line:"*wmic*" AND process_command_line:"*format*" AND process_command_line:("*ftp*" or "*http*") `

## Wmi squiblydoo attack
` process_command_line:*regsvr32* AND process_command_line:*scrobj* `

## Suspicious Code Injection
` event_id:8 AND log_name:"Microsoft-Windows-Sysmon/Operational" AND not process_path:"*\\\\VBoxTray.exe" AND process_target_path:"*\\\\csrss.exe" AND not thread_start_function:EtwpNotificationThread AND process_path:"*\\\\rundll32.exe" `

## Suspicious Powershell cmdline downloading
` process_command_line:("*powershell*" or "*pwsh*" or "*SyncAppvPublishingServer*") AND process_command_line:("*BitsTransfer*" or "*webclient*" or "*DownloadFile*" or "*downloadstring*" or "*wget*" or "*curl*" or "*WebRequest*" or "*WinHttpRequest*" or "*iwr*" or "*irm*" or "*internetExplorer.Application*" or "*Msxml2.XMLHTTP*" or "*MsXml2.ServerXmlHttp*") ` 

## Possible privilege escalation via weak service permissions
` process_path:"*\\\\sc.exe" AND process_command_line:"*config*" AND process_command_line:"*binPath*" AND process_integrity_level: "Medium" `

## Using Certutil For Downloading
` process_command_line:"*certutil*" AND process_command_line:("*urlcach*" or "*url*" or "*ping*") AND process_command_line:("*http*" or "*ftp*") `

## Using certutil for file decoding
` process_command_line:"*certutil*" AND process_command_line:"*decode*" ` 

## Files named like system processes but in the wrong place
` (process_path:("*\\\\rundll32.exe" or "*\\\\svchost.exe" or "*\\\\wmiprvse.exe" or "*\\\\wmiadap.exe" or "*\\\\smss.exe" or "*\\\\wininit.exe" or "*\\\\taskhost.exe" or "*\\\\lsass.exe" or "*\\\\winlogon.exe" or "*\\\\csrss.exe" or "*\\\\services.exe" or "*\\\\svchost.exe" or "*\\\\lsm.exe" or "*\\\\conhost.exe" or "*\\\\dllhost.exe" or "*\\\\dwm.exe" or "*\\\\spoolsv.exe" or "*\\\\wuauclt.exe" or "*\\\\taskhost.exe" or "*\\\\taskhostw.exe" or "*\\\\fontdrvhost.exe" or "*\\\\searchindexer.exe" or "*\\\\searchprotocolhost.exe" or "*\\\\searchfilterhost.exe" or "*\\\\sihost.exe") AND not process_path:("*\\\\system32\\\\*" or "*\\\\syswow64\\\\*" or "*\\\\winsxs\\\\*")) OR (file_name:("*\\\\rundll32.exe" or "*\\\\svchost.exe" or "*\\\\wmiprvse.exe" or "*\\\\wmiadap.exe" or "*\\\\smss.exe" or "*\\\\wininit.exe" or "*\\\\taskhost.exe" or "*\\\\lsass.exe" or "*\\\\winlogon.exe" or "*\\\\csrss.exe" or "*\\\\services.exe" or "*\\\\svchost.exe" or "*\\\\lsm.exe" or "*\\\\conhost.exe" or "*\\\\dllhost.exe" or "*\\\\dwm.exe" or "*\\\\spoolsv.exe" or "*\\\\wuauclt.exe" or "*\\\\taskhost.exe" or "*\\\\taskhostw.exe" or "*\\\\fontdrvhost.exe" or "*\\\\searchindexer.exe" or "*\\\\searchprotocolhost.exe" or "*\\\\searchfilterhost.exe" or "*\\\\sihost.exe")) `

## Mimikatz Commands Patterns
` process_command_line:("*mimikatz*" or "*mimidrv*" or "*mimilib*" or "*DumpCerts*" or "*DumpCreds*") OR (process_command_line:("*kerberos*" or "*sekurlsa*" or "*lsadump*" or "*dpapi*" or "*logonpasswords*" or "*privilege*" or "*rpc\\:\\:server*" or "*service\\:\\:me*" or "*token*" or "*vault*") AND process_command_line:"*\\:\\:*") `

## Mimikatz Commands Metadata
` file_description:("*mimidrv*" or "*mimikatz*" or "*mimilib*") OR file_product:("*mimidrv*" or "*mimikatz*" or "*mimilib*") OR file_company:("*gentilkiwi*" or "*Benjamin DELPY*") OR signature:"Benjamin Delpy" `

## Using bits for downloading or uploading
` (process_command_line:"*bitsadmin*" AND process_command_line:("*transfer*" or "*addfile*" or "*Add-BitsFile*" or "*Start-BitsTransfer*")) OR (process_command_line:"*powershell*" AND process_command_line:("*Add-BitsFile*" or "*Start-BitsTransfer*")) `

## Run whoami as system
` process_path:"*\\whoami.exe" AND (reporter_logon_id: 0x3e7 OR SubjectLogonId: 0x3e7 OR user_account:"NT AUTHORITY\\SYSTEM") ` 

## Remotely created scheduled task
` event_id:("4698" or "4702") AND logon_type:3 `

## Process Creation in network logon session
` event_id:1 AND log_name:*Sysmon AND logon_type:3 `

## Using Net tool for connection to admin share
` process_command_line:"*net*" AND process_command_line:"*use*" AND process_command_line.keyword:"*$*" `

## Using Net tool for connection to  share
` process_command_line:"*net*" AND process_command_line:"*use*" ` 

## privileged_network_logon_from_non_admin_host
` event_id:4672 AND logon_type:3 AND (src_ip_addr:* OR user_domain:*) `

## Suspicious dll load by lsass
` event_id:7 AND process_path:"*\\\\lsass.exe" AND not signature:"*Microsoft*" `

## replaced_accessability_features_binary_execution
` event_id:1 AND process_name:("*sethc*" or "*utilman*" or "*osk*" or "*narrator*" or "*magnify*" or "*displayswitch*") AND not file_description:("Display Switch" or "Accessibility shortcut keys" or "Screen Reader" or "*Magnifier*" or "*Keyboard*" or "Utility Manager")	`

## Accessibility features binary replacement
` log_name:"*Sysmon" AND event_id:"11" AND file_name:("*\\\\displayswitch.exe" or "*\\\\sethc.exe" or "*\\\\magnify.exe" or "*\\\\narrator.exe" or "*\\\\osk.exe" or "*utilman.exe") `

## suspicious_lsass_password_filter_was_loaded
` event_id:4614 AND not NotificationPackageName:("scecli" or "rassfm" or "WDIGEST" or "KDCPw") `

## suspicious_lsass_ssp_was_loaded
` event_id:4622 AND not SecurityPackageName:("*pku2u" or "*TSSSP" or "*NTLM" or "*Negotiate" or "*NegoExtender" or "*Schannel" or "*Kerberos" or "*Wdigest" or "*Microsoft Unified Security Protocol Provider" or "cloudap") `

## Suspicious service that start interesting system binary
` event_id:("4697" or "7045") AND process_command_line:("*rundll32*" or "*regsvr32*" or "*msbuild*" or "*installutil*" or "*odbcconf*" or "*wmic*" or "*msiexec*" or "*cscript*" or "*wscript*" or "*cmd*" or "*powershell*" or "*comspec*") `

## Suspicious services credential dumping tools
` event_id:("4697" or "7045") AND (process_command_line:("*rpc::server*" or "*service::me*" or "*fgexec*" or "*servpw*" or "*cachedump*" or "*dumpsvc*" or "*mimidrv*" or "*mimikatz*" or "*wceservice*" or "*wce service*" or "*pwdump*" or "*gsecdump*" or "*cachedump*") OR service_name:("*fgexec*" or "*servpw*" or "*cachedump*" or "*dumpsvc*" or "*mimidrv*" or "*mimikatz*" or "*wceservice*" or "*wce" or "service*" or "*pwdump*" or "*gsecdump*" or "*cachedump*")) `

## suspicious_services_remote_execution_tools
` (event_id:("4697" or "7045") OR (log_name:Autoruns AND Category:Services))  AND (process_command_line:("*psexe*" or "*winexe*" or "*paexe*" or "*remcom*") OR service_name:("*BTOBTO*" or "*psexe*" or "*winexe*" or "*paexe*" or "*remcom*")) `


## suspicious powershell execution of encoded script
` process_command_line:*powershell* AND (process_command_line:("* -e *" or "* -en *" or "* -ec *" or "* -enc *" or "* -enco" or "* -encod" or "* -encode" or "* -encoded" or "* -encodedc" or "* -encodedco" or "* -encodedcom" or "* -encodedcomm" or "* -encodedcomma" or "* -encodedcomman" or "* -encodedcommand") OR process_command_line:("*StreamReader*" or "*GzipStream*" or "*Decompress*" or "*MemoryStream*" or "*FromBase64String*")) `

## uac_bypass_via_event_viewer
` (event_id:("1" or "4688") AND process_parent_path:"*\\\\eventvwr.exe" AND not process_name:"*\\\\mmc.exe" ) OR (event_id:"13" AND registry_key_path:"*mscfile" AND registry_key_path:"*shell*" AND registry_key_path:"*open*" AND registry_key_path:"*command*") `



