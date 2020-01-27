#Script to move computers based on IP (DNS) 
#Script execute a disable and enable verification before trying to move the computers to the final OU
#Autor: Guilherme Rauvers

#TO DO LIST
#Automate iteration between origim paths  - Need testing, do not move servers or incorrect Objetcs
# Expand Ou Locations and validate ip Ranges


## ------------------------------------------------------------------------------------------------------------------##

Import-Module ActiveDirectory 

#----------------------------------------------------------------------------------------------------------------------#

#----------------------------------------------------------------------------------------------------------------------#
#Define Locations and OUs update

#Base Locations 
$Base_DIR1 = "OU=,CN=,DC=,DC="
$Base_DIR2 = "OU=,CN=,DC=,DC="

#OU Locations 
$Site00DN = "CN=,DC=,DC="
$Site0DN = "OU=Disable=,DC=,DC="
$Site1DN = "CN=,DC=,DC=" 
$Site2DN = "CN=,DC=,DC="
$Site3DN = "CN=,DC=,DC="
$Site4DN = "CN=,DC=,DC="

# sites update
$Site5DN = "OU,CN=,DC=,DC="
$Site6DN = "OU=,CN=,DC=,DC="
$Site7DN = "OU=,CN=,DC=,DC="
$Site8DN = "OU=,CN=,DC=,DC="
$Site9DN = "OU=,CN=,DC=,DC="

#######################################################
# Must select the correct path for moving the computers
# Automation not configured 
#######################################################
#Path
$path0 = "CN=,DC=,DC="
$path="OU,CN=,DC=,DC="
$path3="OU,CN=,DC=,DC="
$path4="OU,CN=,DC=,DC="

# Warnings
$Warning_DIR2 = "Ao executar a desativacao de computadores com mais de 60 dias sem logon da OU: XXX, foram localizados mais de 20 computadores inativos. O Script nao sera executado!"
$Warning_DIR1 = "Ao executar a desativacao de computadores com mais de 60 dias sem logon da OU: XXX1, foram localizados mais de 20 computadores inativos. O Script nao sera executado!"
# Subjects for Warning
$Subject = "!Muitos Computadores sem logar por 90 dias!"

#---------------------------------------------------------------------------------------------------------------------------#

# Disabled Stale computer by OU with more then 90 days 

# Inactive days for search
$DaysInactive = 60
$time = (Get-Date).Adddays(-($DaysInactive)) 

# Get computers win 7 or 10 with more then 60 days stale 

# Get computers from Gerenciados
$InactiveComputer = Get-ADComputer -Filter {( OperatingSystem -like "Windows 7*" -or OperatingSystem -like "Windows 10*") -and ( Enabled -eq "True") -and (LastLogonTimeStamp -lt $time)} -SearchBase $Base_DIR2 -resultSetSize $null  

#If more than 20 computer stale, send warning.
if($InactiveComputer.Count -gt 20){
        Send-MailMessage -SmtpServer mail-relay@xxx.com -To IT@xxx.com -From CleaningScripts@xxx.com -Subject $Subject -Body $Warning_DIR2
}else{
        #Get current data for log purpose
        $data = (Get-Date -Format "MM/dd/yyyy_HH:mm")

        #Inactive computers 
        $InactiveComputer | ForEach-Object {
               $_.DistinguishedName + " - " + $data | Out-File -FilePath ".\Log\C1.txt" -NoClobber -Append
               Set-ADComputer -Identity $_.Name -Enabled $False
        }
}

#_----------_ Second iteration _---------------_#


# Get computers from Schulze
$InactiveComputer2 = Get-ADComputer -Filter {( OperatingSystem -like "Windows 7*" -or OperatingSystem -like "Windows 10*") -and ( Enabled -eq "True") -and (LastLogonTimeStamp -lt $time)} -SearchBase $Base_DIR1 -resultSetSize $null 

#If more than 20 computer stale, send warning.
if($InactiveComputer2.Count -gt 20){
        Send-MailMessage -SmtpServer mail-relay@xxx.com -To IT@xxx.com -From CleaningScripts@xxx.com -Subject $Subject -Body $Warning_DIR1
}else{
        #Get current data for log purpose
        $data = (Get-Date -Format "MM/dd/yyyy_HH:mm")

        #Inactive computers 
        $InactiveComputer2 | ForEach-Object {
               $_.DistinguishedName + " - " + $data | Out-File -FilePath ".\Log\C2.txt" -NoClobber -Append
               Set-ADComputer -Identity $_.Name -Enabled $False
        }
}


#----------------------------------------------------------------------------------------------------------------------------#

#Search if computers are active, if not move to disabled OU
#Search Disable OU for active conputers and move to Computers OU

#Searching Gerenciados for disabled computers
$disabled = Get-ADComputer -Filter {(Enabled -eq $False)}  -SearchBase $Base_DIR2 -ResultPageSize 2000 -resultSetSize $null -Properties Name, OperatingSystem, SamAccountName, DistinguishedName, Enabled   
 
    #movind each object to correct OU
    $disabled | ForEach-Object {
        $origem=$_.DistinguishedName
        $_.Name #debug purpose
        $origem #debug purpose
        $DestinationDN #debug purpose
        Move-ADObject -Identity $origem -TargetPath $Site0DN 
        }

#Searching Schulze for disabled computers
$disabled2 = Get-ADComputer -Filter {(Enabled -eq $False)}  -SearchBase $Base_DIR2 -ResultPageSize 2000 -resultSetSize $null -Properties Name, OperatingSystem, SamAccountName, DistinguishedName, Enabled 

    #movind each object to correct OU
    $disabled2 | ForEach-Object {
        $origem=$_.DistinguishedName
        $_.Name #debug purpose
        $origem #debug purpose
        $DestinationDN #debug purpose
        Move-ADObject -Identity $origem -TargetPath $Site0DN 
        }

#Move Active computers on Disabled OU to default OU Computers
$active = Get-ADComputer -Filter {(Enabled -eq $true)}  -SearchBase $Site0DN  -ResultPageSize 2000 -resultSetSize $null -Properties Name, OperatingSystem, SamAccountName, DistinguishedName, Enabled 

    #movind each object to correct OU
    $active | ForEach-Object {
        $origem=$_.DistinguishedName
        $_.Name #debug purpose
        $origem #debug purpose
        $DestinationDN #debug purpose
        Move-ADObject -Identity $origem -TargetPath $Site00DN  
        }

#Finished first organization 

#SLEEP Waiting Moves

Start-Sleep -Seconds 10

#-----------------------------------------------------------------------------------------------------------------

# Organize computers on OU: Computers based on current IP
# 


#Computer get with only search base level 1
$Computers=Get-ADComputer -filter * -SearchBase $path0 -SearchScope 1 -Properties * |Select-Object Name, IPv4Address, Description, CanonicalName ,DistinguishedName 

#IP range
$Site0IPRange = “\b(?:(?:192)\.)” + “\b(?:(?:168)\.)” + “\b(?:(?:0)\.)” + “\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))” # 192.168.0.0/24
$Site1IPRange = “\b(?:(?:192)\.)” + “\b(?:(?:168)\.)” + “\b(?:(?:1)\.)” + “\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))” # 192.168.1.0/24
$Site2IPRange = “\b(?:(?:192)\.)” + “\b(?:(?:168)\.)” + “\b(?:(?:2)\.)” + “\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))” # 192.168.2.0/24
$Site3IPRange = “\b(?:(?:192)\.)” + “\b(?:(?:168)\.)” + “\b(?:(?:3)\.)” + “\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))” # 192.168.3.0/24
$Site4IPRange = “\b(?:(?:192)\.)” + “\b(?:(?:168)\.)” + “\b(?:(?:4)\.)” + “\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))” # 192.168.4.0/24
$Site5IPRange = “\b(?:(?:192)\.)” + “\b(?:(?:168)\.)” + “\b(?:(?:5)\.)” + “\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))” # 192.168.5.0/24
$Site6IPRange = “\b(?:(?:192)\.)” + “\b(?:(?:168)\.)” + “\b(?:(?:6)\.)” + “\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))” # 192.168.6.0/24
$Site7IPRange = “\b(?:(?:192)\.)” + “\b(?:(?:168)\.)” + “\b(?:(?:7)\.)” + “\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))” # 192.168.7.0/24
$Site8IPRange = “\b(?:(?:192)\.)” + “\b(?:(?:168)\.)” + “\b(?:(?:8)\.)” + “\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))” # 192.168.8.0/24
$Site9IPRange = “\b(?:(?:192)\.)” + “\b(?:(?:168)\.)” + “\b(?:(?:9)\.)” + “\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))” # 192.168.9.0/24



#validating ips
$Computers | ForEach-Object {
    $IP=$null
    $flag=0
    $IP=$_.IPv4Address
    $ComputerName=$_.Name
    if( $IP -match $Site1IPRange ){
            $DestinationDN = $Site1DN

    }ElseIf ($IP -match $Site2IPRange) {
            $DestinationDN = $Site2DN

    }ElseIf ($IP -match $Site3IPRange) {
            $DestinationDN = $Site3DN

    }ElseIf ($IP -match $Site4IPRange) {
            $DestinationDN = $Site4DN

    }ElseIf ($IP -match $Site5IPRange) {
            $DestinationDN = $Site4DN

    }ElseIf ($IP -match $Site6IPRange) {
            $DestinationDN = $Site4DN

    }ElseIf ($IP -match $Site7IPRange) {
            $DestinationDN = $Site5DN

    }ElseIf ($IP -match $Site8IPRange) {

            $DestinationDN = $Site6DN
    }Else {     
            # If the subnet does not match we should not move the computer so we pass the current distinguished name as destination, a posterior validation will occur
            $DestinationDN =$_.DistinguishedName.Replace( "CN=$ComputerName," , "") 
            $flag=1
    }
    #$ComputerContainer=$_.DistinguishedName
    $origem=$_.DistinguishedName
    $_.Name #debug purpose
    $_.IPv4Address #debug purpose
    $DestinationDN #debug purpose
    # Validate if locations is different then move
    if( $flag.Equals(0) ){
        Move-ADObject -Identity $origem -TargetPath $DestinationDN
    }
}
