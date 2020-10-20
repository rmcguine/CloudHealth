$app = Get-AzADApplication -DisplayName rmcguinetestaccount
$appId = $app.ApplicationId
$subs = Get-AzSubscriptiom
foreach ($sub in $subs) {
  $sub_scope = "/subscriptions/" + $sub.Id
  $assignedRoles = Get-AzRoleAssignment -Scope $sub_scope -SPN $appId
    if ($assignedRoles.RoleDefinitionNamee.Contains('Reader')) {
      write-host($sub_scope + " has Reader role enabled already")
      }
    else {
      New-AzRoleAssignment -RoleDefinitionName "Reader" -ApplicationId $appId
      write-host($sub_scope + " successfully added Reader role")
      }
 }
      
