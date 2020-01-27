#Script to move disabled users based inactive account
#Autor: Guilherme Rauvers
# License: GNU_General_Public_License
## ------------------------------------------------------------------------------------------------------------------##

Import-Module ActiveDirectory 

#----------------------------------------------------------------------------------------------------------------------#
#Include OUs 
$Site0DN = "OU=,DC=,DC=" 
$Site1DN = "OU=,DC=,DC=" 
$Site2DN = "OU=,DC=,DC=" 
$Site3DN = "OU=,DC=,DC=" 

#----------------------------------------------------------------------------------------------------------------------#
#Mail Warnings

$Alerta_Site1DN = "Fail due to more than xxx users inactive!"
$Alerta_Site2DN = "Fail due to more than xxx users inactive!"
$Alerta_Site3DN = "Fail due to more than xxx users inactive!"
$Subject = "Too many inactives users!" 

#----------------------------------------------------------------------------------------------------------------------# 

#----------------------------------------------------------------------------------------------------------------------#

#Searching disabled users on Aspect
$disabled = Get-ADUser -Filter {(Enabled -eq $False)}  -SearchBase $Site1DN  -ResultPageSize 2000 -resultSetSize $null -Properties Name, SamAccountName, DistinguishedName, Enabled   
 
if($disabled.Count -gt 40){
    Send-MailMessage -SmtpServer mail-relay@xxx.com -To IT@xxx.com -From cleaningScript@xxx.com -Subject $Subject -Body $Alerta_Site1DN
}else{

    #Current date
    $data = (Get-Date -Format "MM/dd/yyyy_HH:mm")

    #movind each object to disabled users OU
    $disabled | ForEach-Object {
        $origem=$_.DistinguishedName
        $origem + " - " + $data | Out-File -FilePath ".\Log\S1.txt" -NoClobber -Append
        Move-ADObject -Identity $origem -TargetPath $Site0DN 
    }
}
#Searching disabled users on Schulze OU 
$disabled2 = Get-ADUser -Filter {(Enabled -eq $False)}  -SearchBase $Site2DN  -ResultPageSize 2000 -resultSetSize $null -Properties Name, SamAccountName, DistinguishedName, Enabled 

if($disabled2.Count -gt 20){
    Send-MailMessage -SmtpServer mail-relay@xxx.com -To IT@xxx.com -From cleaningScript@xxx.com -Subject $Subject -Body $Alerta_Site2DN
}else{
    
    #Current date
    $data = (Get-Date -Format "MM/dd/yyyy_HH:mm")
    
    #movind each object to correct OU
    $disabled2 | ForEach-Object {
        $origem=$_.DistinguishedName
        $origem + " - " + $data | Out-File -FilePath ".\Log\S2.txt" -NoClobber -Append
        Move-ADObject -Identity $origem -TargetPath $Site0DN 
    }
}
#Searching disabled users on SRVAD02 - Perfis gerenciados OU 
$disabled3 = Get-ADUser -Filter {(Enabled -eq $False)}  -SearchBase $Site3DN  -ResultPageSize 2000 -resultSetSize $null -Properties Name, SamAccountName, DistinguishedName, Enabled 

if($disabled3.Count -gt 20){
    Send-MailMessage -SmtpServer mail-relay@xxx.com -To IT@xxx.com -From cleaningScript@xxx.com -Subject $Subject -Body $Alerta_Site3DN
}else{
    
    #Current date
    $data = (Get-Date -Format "MM/dd/yyyy_HH:mm")
    
    #movind each object to correct OU
    $disabled3 | ForEach-Object {
        $origem=$_.DistinguishedName
        $origem + " - " + $data | Out-File -FilePath ".\Log\S3.txt" -NoClobber -Append
        Move-ADObject -Identity $origem -TargetPath $Site0DN  
    }
        #Finished first organization 
}
Start-Sleep -Seconds 10

