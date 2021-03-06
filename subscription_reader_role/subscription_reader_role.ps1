# Azure Management Groups would be considered the best practice for subscription reader role assignment. However, not all Azure customers use AMG's.
# Grabs all existing subscriptions in directory and assigns the reader role 

$app = Get-AzADApplication -DisplayName <CLOUDHEALTH-APP-DISPLAY-NAME>
$appId = $app.ApplicationId
$subs = Get-AzSubscription
foreach ($sub in $subs) {
  $sub_scope = "/subscriptions/" + $sub.Id
  $assignedRoles = Get-AzRoleAssignment -Scope $sub_scope -SPN $appId
  if (!$assignedRoles) {
    New-AzRoleAssignment -Scope $sub_scope -RoleDefinitionName "Reader" -ApplicationId $appId
    Write-Host($sub_scope + " successfully added Reader role")
    }
  elseif ($assignedRoles.RoleDefinitionName.Contains('Reader')) {
    Write-Host($sub_scope + " has Reader role enabled already")
    }
  else {
    New-AzRoleAssignment -Scope $sub_scope -RoleDefinitionName "Reader" -ApplicationId $appId
    Write-Host($sub_scope + " successfully added Reader role")
    }
 }
