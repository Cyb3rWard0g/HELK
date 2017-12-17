function start-winlogbeat
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [Alias('wc')]
        [string]$winconfig="https://raw.githubusercontent.com/Cyb3rWard0g/HELK/master/winlogbeat/winlogbeat.yml",

        [Parameter(Mandatory=$true, Position=1)]
        [Alias('lsip')]
        [String]$logstaship
    )

    function invoke-unzip
    {
        [CmdletBinding()]
        Param (
            [Parameter()]
            [string]$file
        )

        write-verbose "[+++] Unzipping file.."
        [string]$RemoteFolderPath = $env:ProgramFiles
        [int32]$copyOption = 20
        $shell = New-Object -ComObject shell.application
        $zip = $shell.Namespace($file)
        foreach($item in $zip.items()){
            $shell.Namespace($RemoteFolderPath).copyhere($item, $copyOption) | Out-Null
        }    
    }
    
    $winInstall_source = "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-6.0.0-windows-x86_64.zip"
    $winInstall_dest = ($env:ProgramFiles + "\winlogbeat-6.0.0-windows-x86_64.zip")
    $winconfig_dest = ($env:ProgramFiles + "\winlogbeat\winlogbeat.yml")
    $winInstall_old = $env:ProgramFiles + "\winlogbeat-6.0.0-windows-x86_64"
    $winInstall_new = $env:ProgramFiles + "\winlogbeat"

    if (Get-WmiObject -class win32_service | Where-Object {$_.Name -like "winlogbeat"})
    {
        Write-Verbose "[+++] Winlogbeat service already exists."

        if (Get-WmiObject -class win32_service | Where-Object {$_.Name -like "winlogbeat" -and $_.State -eq "Running"}){
            Write-Verbose "[!!!] Winlogbeat service already exists and it is running.."
        }
        else
        {
            Write-Verbose "[!!!] Winlogbeat service already exists but it is not running.."
        }
    }
    else
    {
        $wc=New-Object System.Net.WebClient;
        $wc.Proxy = [System.Net.WebRequest]::GetSystemWebProxy();
        $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials;

        write-verbose "[+++] Downloading Winlogbeat from $winInstall_source"
        $wc.DownloadFile($winInstall_source,$winInstall_dest)
    

        if (get-item $winInstall_dest)
        {
            invoke-unzip -file $winInstall_dest

            Rename-Item -Path $winInstall_old -NewName $winInstall_new
            Remove-Item -Path $winInstall_dest

            if (get-item $winInstall_new)
            {
                & ($winInstall_new +"\install-service-winlogbeat.ps1")
                if (get-wmiobject Win32_Service -Filter 'Name LIKE "%winlogbeat%"')
                {
                    Rename-Item ($winInstall_new + "\winlogbeat.yml") -NewName ($winInstall_new + "\BACKUP_winlogbeat_config.yml")
            
                    write-verbose "[+++] Downloading Winlogbeat config from $winconfig"
                    $wc.DownloadFile($winconfig,$winconfig_dest)

                    if (get-item $winconfig_dest)
                    {
                        write-verbose "[+++] Replacing default localhost string for logstash connection with $logstaship"
                        (get-content $winconfig_dest) -replace 'hosts: \[\"localhost\:5044\"\]', ('hosts: ["'+$logstaship+':5044"]') | Set-Content $winconfig_dest
                    }
                    else
                    {
                        Write-Verbose "[!!!] $winconfig_dest does not exist locally.."
                        Write-verbose $_.Exception.Message
                        break
                    }
                    write-verbose "[+++] Starting winlogbeat service.."
                    start-service winlogbeat
                    if (Get-WmiObject -class win32_service | Where-Object {$_.Name -like "winlogbeat" -and $_.State -eq "Running"})
                    {
                        Write-Verbose "[!!!] Winlogbeat was installed successfully and it is running.."
                    }
                    else
                    {
                        Write-verbose $_.Exception.Message
                        break
                    }
                }
            }
        }
        else
        {
            Write-Verbose "[!!!] $winInstall_dest does not exist locally.."
            Write-verbose $_.Exception.Message
        }
    }
}
