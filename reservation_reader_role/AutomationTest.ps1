# Variables to be set
$cloudhealth_api_key = "CLOUDHEALTH_API_KEY"

# Call CloudHealth API for derived reservation orders
$url = "https://chapi.cloudhealthtech.com/api/search?api_version=2&name=AzureReservationOrder&query=is_derived=true&api_key=$cloudhealth_api_key"
$cloudhealthdata = Invoke-RestMethod $url

# Assign reservation order ID's to a variable
$reservationOrders = $cloudhealthdata.name

# Call CloudHealth API for Service Principals
$url2 = "https://chapi.cloudhealthtech.com/v1/azure_service_principals?api_key=$cloudhealth_api_key"
$cloudhealthServicePrincipals = Invoke-RestMethod $url2

# Assign SPs to a variable
$appId = $cloudhealthServicePrincipals.azure_service_principals.client_id

# Assign all Tenant IDs to which the user has access to to a variable
$tenants = (Get-AzTenant).Id

# If no Derived Reservation Orders found, cancel process
if (!$reservationOrders) {
    Write-Host("No Derived Reservation Orders Found")
    Return
}
else {
    foreach ($tenant in $tenants) {
        Set-AzContext -TenantId $tenant
        # Confirm if there are subscriptions within the tenant. No subscription = no Reservation Orders
        $subscriptionCheck = (Get-AzSubscription -TenantId $tenant)
        if (!$subscriptionCheck) {
            Write-Host "No Azure Subscriptions found in this tenant. Escaping process, as there will be no Reservation Orders to be found." -ForegroundColor Yellow
        }
        else {
            foreach ($app in $appId) {
                $existingSP = Get-AzADApplication -ApplicationId $app
                if (!$existingSP) {
                    Write-Host "SP:" $app "not found in this Tenant ID."
                }
                else {
                    # Assign Reader Role to Reservation Order for CloudHealth Application
                    foreach ($reservation in $reservationOrders) {
                        $in_Tenant = (Get-AzReservationOrder).Name 
                        if ($in_Tenant -contains $reservation) {
                            $order_scope = "/providers/microsoft.capacity/reservationOrders/"+$reservation
                            $assignedRoles = Get-AzRoleAssignment -Scope $order_scope -SPN $app
                            if (!$assignedRoles) {
                                try {
                                    New-AzRoleAssignment -Scope $order_scope -RoleDefinitionName "Reader" -ApplicationId $app -ErrorAction Stop
                                    Write-Host($order_scope + " successfully added Reader role")
                                }
                                catch { 
                                    Write-Host "Invalid Authorization" -ForegroundColor Yellow
                                }
                            }
                            elseif ($assignedRoles.RoleDefinitionName.Contains('Reader')) {
                                Write-Host($order_scope + " has Reader role enabled already")
                            }
                            else {
                                try {
                                    New-AzRoleAssignment -Scope $order_scope -RoleDefinitionName "Reader" -ApplicationId $app
                                    Write-Host($order_scope + " successfully added Reader role")
                                }
                                catch {
                                    Write-Host "Invalid Authorization" -ForegroundColor Yellow
                                }
                            }
                        } 
                    }
                }  
            }
        }   
    }
}

