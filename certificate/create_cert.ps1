#Script to create a certificate on AD
#Autor: Guilherme Rauvers
# License: GNU_General_Public_License
## ------------------------------------------------------------------------------------------------------------------##

# Create certificate
New-SelfSignedCertificate -CertStoreLocation cert:\currentuser\my  -Subject "CN=Local Code Signing"  -KeyAlgorithm RSA  -KeyLength 2048 -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -KeyExportPolicy Exportable -KeyUsage DigitalSignature  -Type CodeSigningCert

#Export certificate "name" to a file with password
#Exporta o certificado "valor"  para arquivo com a senha password
$CertPassword = ConvertTo-SecureString -String “password” -Force –AsPlainText
Export-PfxCertificate -Cert cert:\currentuser\My\name -FilePath C:\certificate\cert.pfx -Password $CertPassword

#Sign the Scripts

$cert = @(Get-ChildItem cert:\CurrentUser\My -CodeSigning)[0] 
Set-AuthenticodeSignature C:\scripts\xxx.ps1 $cert

#--------------------------------------------------------------------------------------------------------------------##