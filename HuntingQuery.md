# Reference

@HeirhabarovT
https://speakerdeck.com/heirhabarov/phdays-2018-threat-hunting-hands-on-lab

## Suspicious processes spawned from MS Office applications 

```
event_id:(1 OR 4688) AND (process_parent_name:("*\\excel.exe" "*\\winword.exe" "*\\powepnt.exe" "*\\msaccess.exe" "*\\mspub.exe" "*\\outook.exe")) AND process_name:("*\\cmd.exe" "*\\powershell.exe" "*\\wscript.exe" "*\\cscript.exe" "*\\bitsadmin.exe" "*\\certutil.exe" "*\\schtasks.exe" "*\\rundll32.exe" "*\\regsvr32.exe" "*\\wmic.exe" "*\\mshta.exe" "*\\msiexec.exe" "*\\schtasks.exe" "*\\msbuild.exe")

```

## PowerShell Download cradles

```
process_command_line:(*powershell* *pwsh* *SyncAppvPublishingServer*) AND process_command_line:(*BitsTransfer*  *webclient* *DownloadFile* *downloadstring* *wget* *curl* *WebRequest* *WinHttpRequest* *internetExplorer.Application* *Msxml2.XMLHTTP* *MsXml2.ServerXmlHttp*)

```

## Privilege escalation - Run whoami as System
```
process_name:"*\\whoami.exe" AND (reporter_logon_id: 0x3e7 OR SubjectLogonId: 0x3e7 OR user_account:"NT AUTHORITY\\SYSTEM")

```

## Using certutil for downloading 

```
process_command_line:(*certutil*) AND process_command_line:(*urlcach* *url* *ping*) AND process_command_line:(*http* *ftp*)
```

## Possible logon session hijacking

```
process_name:"*\\tscon.exe" AND (reporter_logon_id:0x3e7 OR SubjectLogonId:0x3e7 OR user_account:"NT AUTHORITY\\SYSTEM")

```

### .... Coming Soon

