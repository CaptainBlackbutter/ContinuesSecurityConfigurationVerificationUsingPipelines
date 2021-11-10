# setting colors
# Error: Write-Host "$([char]27)[91mError$([char]27)[0m"
# Good: Write-Host "$([char]27)[92mGood$([char]27)[0m"
# defining parameters
param ($JWT, $customer)
# import required modules
Import-Module WindowsCompatibility
Import-Module AzureAD -UseWindowsPowerShell 
Import-Module ExchangeOnlineManagement
# Set exitcode 
$exitcode = 0
# -------------------------------------------------------------------------------------------------------------
# Get credentials using Vault API and CI_JOB_JWT
# -------------------------------------------------------------------------------------------------------------
# Query Vault API for token
$postdata = '{\"role\": \"'+$customer+'_aad\", \"jwt\": \"' + $JWT + '\"}'
$vaultlogin = curl --request POST --data $postdata http://<vault-url>:8200/v1/auth/jwt/login -s
$jsonlogin = ConvertFrom-Json $vaultlogin
$vaulttoken = $jsonlogin.auth.client_token
# Query vault API for secret
$secret = curl --header "X-Vault-Token: $vaulttoken" http://<vault-url>:8200/v1/$customer/data/aad -s
$secretjson = ConvertFrom-Json $secret
# Set credential object
$secpassword = ConvertTo-SecureString $secretjson.data.data.aad_pw -AsPlainText -Force
$credObject = New-Object System.Management.Automation.PSCredential ($secretjson.data.data.aad_upn, $secpassword)
# Connect to AzureAD
Connect-AzureAD -Credential $credObject
# -------------------------------------------------------------------------------------------------------------
# check if conditional access policies exist
# -------------------------------------------------------------------------------------------------------------
$CA_policies = Get-AzureADMSConditionalAccessPolicy
if ($CA_policies.Count -lt 1) {
    Write-Host "$([char]27)[91mNo Conditional access policies found.$([char]27)[0m"
    $exitcode = 1
}
else {
    Write-Host "$([char]27)[92mConditional access policies found, no detailled processing.$([char]27)[0m"
    Write-Host $CA_policies
}
# -------------------------------------------------------------------------------------------------------------
# check number of global administrators
# -------------------------------------------------------------------------------------------------------------
$globaladminroleid = (Get-AzureADDirectoryRole | Where-Object {$_.DisplayName -eq "Global Administrator"}).ObjectId
$globaladminmembers = Get-AzureADDirectoryRoleMember -ObjectId $globaladminroleid
if ($globaladminmembers.Count -ge 4) {
    Write-Host "$([char]27)[91mMore then three global administrators found.$([char]27)[0m"
   foreach ($member in $globaladminmembers){
        Write-Host $member.UserPrincipalName
    }
    $exitcode = 1
}
else {
    Write-Host "$([char]27)[32mLess or equal than 4 global administrators found.$([char]27)[0m"
    foreach ($member in $globaladminmembers){
        Write-Host $member.UserPrincipalName
    }
}
# -------------------------------------------------------------------------------------------------------------
# Connect to Exchange Online
# -------------------------------------------------------------------------------------------------------------
Connect-ExchangeOnline -Credential $credObject  -ShowBanner:$false
# -------------------------------------------------------------------------------------------------------------
# Find mailboxes enable for basic authentication
# -------------------------------------------------------------------------------------------------------------
$basicAuthEnabled = Get-CASMailbox -Filter {ImapEnabled -eq "true" -or PopEnabled -eq "true" }
if ($basicAuthEnabled.Count -ge 0){
     Write-Host "$([char]27)[91mMailboxes are still allowed to use basic authentication.$([char]27)[0m"
   foreach ($member in $basicAuthEnabled){
        Write-Host $member.Name
    }
    $exitcode = 1
}
Else {
    Write-Host "$([char]27)[32mNo mailboxes allow to use basic authentication.$([char]27)[0m"
}
# -------------------------------------------------------------------------------------------------------------
# Check if auditing is enabled (disabled by default)
# -------------------------------------------------------------------------------------------------------------
if (Get-AdminAuditLogConfig | FL UnifiedAuditLogIngestionEnabled){
     Write-Host "$([char]27)[91mOffice auditing is not enabled.$([char]27)[0m"
}
else {
    Write-Host "$([char]27)[32mOffice auditing is enabled.$([char]27)[0m"
}
# -------------------------------------------------------------------------------------------------------------
# exit the script with the required result
# -------------------------------------------------------------------------------------------------------------
exit $exitcode
