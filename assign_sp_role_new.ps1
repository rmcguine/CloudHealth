#Current CH script uses depecating AzureRm commands; this script is updated to use Az
#https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-4.8.0&viewFallbackFrom=azps-4.6.1#upgrade-to-az

#Custom Role Script

$role = Get-AzRoleDefinition -Name Contributor
$role.Id = $null
$role.Name = "CHTActions"
$role.Description = "Grants access to Actions"
$role.AssignableScopes.Clear()
$role.Actions.Clear()
$role.NotActions.Clear()
$role.Actions.Add("Microsoft.Compute/*/write")
$role.Actions.Add("Microsoft.Compute/*/action")
$role.Actions.Add("Microsoft.ClassicCompute/*/write")
$role.Actions.Add("Microsoft.ClassicCompute/*/action")
$role.Actions.Add("Microsoft.Sql/*/write")
$role.Actions.Add("Microsoft.Sql/*/action")
$role.Actions.Add("Microsoft.Storage/*/write")
$role.Actions.Add("Microsoft.Storage/*/action")
$role.Actions.Add("Microsoft.ClassicStorage/*/write")
$role.Actions.Add("Microsoft.ClassicStorage/*/action")
$role.NotActions.Add("*/Delete")
$role.NotActions.Add("Microsoft.Authorization/*")
$subs = Get-AzSubscription
foreach ($sub in $subs) {
	$sub_scope = '/subscriptions/' + $sub.Id
	$role.AssignableScopes.Add("$sub_scope")
}
New-AzRoleDefinition -Role $role

#Assignment Script

$subs = Get-AzSubscription
$client_id = '<MANUALLY_ENTER_APPLICATION_CLIENT_ID>'
$sp = Get-AzADServicePrincipal -SPN $client_id
foreach ($sub in $subs) {
	$sub_scope = '/subscriptions/' + $sub.Id
	New-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName CHTActions -Scope 	$sub_scope
}
