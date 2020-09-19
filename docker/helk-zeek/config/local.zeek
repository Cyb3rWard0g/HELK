# HELK Zeek Conf
# Author: Nate (@neu5ron)
# License: GPL-3.0

#TODO: enable ntp analyzer 
## Applicable to framework
@load misc/loaded-scripts
@load tuning/defaults
@load misc/capture-loss
@load misc/stats
@load misc/scan
redef LogAscii::use_json = T;
redef ignore_checksums = T;
@load packages

## Applicable to various / many protocols
@load policy/frameworks/software/windows-version-detection
@load frameworks/software/vulnerable
@load frameworks/software/version-changes
@load-sigs frameworks/signatures/detect-windows-shells

## DNS
@load protocols/dns/detect-external-names

#### Conn
@load policy/protocols/conn/mac-logging
#@load policy/protocols/conn/vlan-logging #disabled because using https://github.com/corelight/log-add-vlan-everywhere
@load protocols/conn/known-hosts
@load protocols/conn/known-services

#### DHCP
@load policy/protocols/dhcp/software
@load policy/protocols/dhcp/sub-opts
@load policy/protocols/dhcp/msg-orig

#### DNS
@load policy/protocols/dns/auth-addl

#### Files
@load base/files/x509/main
@load base/files/hash/main
@load frameworks/files/hash-all-files
@load policy/frameworks/files/entropy-test-all-files
# Detect SHA1 sums in Team Cymru's Malware Hash Registry.
#@load frameworks/files/detect-MHR

#### FTP
@load protocols/ftp/software
@load protocols/ftp/detect

#### HTTP
redef HTTP::default_capture_password = T;
@load policy/protocols/http/header-names
@load policy/protocols/http/software
@load policy/protocols/http/software-browser-plugins
@load policy/protocols/http/var-extraction-cookies
#@load policy/protocols/http/var-extraction-uri
@load policy/protocols/http/header-names
@load protocols/http/detect-webapps
@load protocols/http/detect-sqli

#### FTP
redef FTP::default_capture_password = T;

#### Modbus
@load policy/protocols/modbus/track-memmap
@load policy/protocols/modbus/known-masters-slaves

#### MySQL
@load protocols/mysql/software

#### Kerberos
@load base/protocols/krb/files

#### MQTT
@load policy/protocols/mqtt

#### RDP
@load policy/protocols/rdp/indicate_ssl

#### SMB
#@load base/protocols/smb/smb1-main
#@load base/protocols/smb/smb2-main
@load protocols/smb/log-cmds

#### SMTP
@load base/protocols/smtp/entities
@load base/protocols/smtp/files
@load policy/protocols/smtp/software
@load policy/frameworks/notice/extend-email/hostnames

#### SOCKS
redef SOCKS::default_capture_password = T;

#### SSH
@load protocols/ssh/software
#@load protocols/ssh/geo-data
@load protocols/ssh/detect-bruteforcing
@load protocols/ssh/interesting-hostnames

#### SSL/TLS/X509
@load protocols/ssl/weak-keys
@load policy/protocols/ssl/heartbleed
@load protocols/ssl/validate-certs
@load protocols/ssl/log-hostcerts-only
# @load protocols/ssl/notary
@load protocols/ssl/known-certs

#### Traceroute
@load misc/detect-traceroute

# Additional Custom
#@load redef_dce_rpc_ports.zeek