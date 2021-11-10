# setting colors
# Error: Write-Host "$([char]27)[91mError$([char]27)[0m"
# Good: Write-Host "$([char]27)[92mGood$([char]27)[0m"
# defining parameters
param ($JWT, $customer, $referencehostIP)
# Set exitcode 
$exitcode = 0
# -------------------------------------------------------------------------------------------------------------
# Get credentials using Vault API and CI_JOB_JWT
# -------------------------------------------------------------------------------------------------------------
# Query Vault API for token
$postdata = '{\"role\": \"'+$customer+'_ad\", \"jwt\": \"' + $JWT + '\"}'
$vaultlogin = curl --request POST --data $postdata http://<vault-url>:8200/v1/auth/jwt/login -s
$jsonlogin = ConvertFrom-Json $vaultlogin
$vaulttoken = $jsonlogin.auth.client_token
# Query vault API for secret
$secret = curl --header "X-Vault-Token: $vaulttoken" http://<vault-url>:8200/v1/$customer/data/ad -s
$secretjson = ConvertFrom-Json $secret
# Set credential object
$secpassword = ConvertTo-SecureString $secretjson.data.data.ad_pw -AsPlainText -Force
$credObject = New-Object System.Management.Automation.PSCredential ($secretjson.data.data.ad_upn, $secpassword)
# -------------------------------------------------------------------------------------------------------------
# Create remote PowerShell session
# -------------------------------------------------------------------------------------------------------------
 $remote = New-PSSession -ComputerName $referencehostIP -Credential $credObject
# -------------------------------------------------------------------------------------------------------------
# Verify CIS 2.3.17.1 (L1) Ensure 'User Account Control: Admin Approval Mode for the Built-in Administrator account' is set to 'Enabled' (Automated)
# -------------------------------------------------------------------------------------------------------------
 $result = Invoke-Command -Session $remote -ScriptBlock {
     $exitcode_inBlock = 0
     $value = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name "FilterAdministratorToken"
     if ($value -eq 1)
     { 
         Write-Host "$([char]27)[92mAdmin approval mode for the built-in administrator account is enabled.$([char]27)[0m"
     }
     else
     {
        Write-Host "$([char]27)[91mAdmin approval mode for the built-in administrator account is NOT enabled.$([char]27)[0m"
        $exitcode_inBlock = 1
     }
    return $exitcode_inBlock
}
if ($result -eq 1) {$exitcode = 1}
# -------------------------------------------------------------------------------------------------------------
# Verify CIS 18.3.2 (L1) Ensure 'Configure SMB v1 client driver' is set to 'Enabled: Disable driver (recommended)' (Automated)
# -------------------------------------------------------------------------------------------------------------
 $result = Invoke-Command -Session $remote -ScriptBlock {
     $exitcode_inBlock = 0
     $value = 0
     $ErrorActionPreference = "stop"
     try {
         
         $value = Get-ItemPropertyValue -Path HKLM:\SYSTEM\CurrentControlSet\Services\MrxSmb10 -Name "Start"
     }
     catch{
         $value = 0
     }    
     if ($value -eq 4)
     { 
         Write-Host "$([char]27)[92SMBv1 client is disabled.$([char]27)[0m"
     }
     else
     {
        Write-Host "$([char]27)[91mSMBv1 client is enabled or not explicitly disabled.$([char]27)[0m"
        $exitcode_inBlock = 1
     }
     return $exitcode_inBlock
}
if ($result -eq 1) {$exitcode = 1}
exit $exitcode
