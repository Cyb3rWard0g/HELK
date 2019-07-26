# Suspicious processes spawned from MS Office applications 

```
event_id:(1 OR 4688) AND (process_parent_name:("*\\excel.exe" "*\\winword.exe" "*\\powepnt.exe" "*\\msaccess.exe" "*\\mspub.exe" "*\\outook.exe")) AND process_name:("*\\cmd.exe" "*\\powershell.exe" "*\\wscript.exe" "*\\cscript.exe" "*\\bitsadmin.exe" "*\\certutil.exe" "*\\schtasks.exe" "*\\rundll32.exe" "*\\regsvr32.exe" "*\\wmic.exe" "*\\mshta.exe" "*\\msiexec.exe" "*\\schtasks.exe" "*\\msbuild.exe")

```

