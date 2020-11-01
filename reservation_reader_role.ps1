# Download Az.Reservations package if you don't already have it -> https://www.powershellgallery.com/packages/Az.Reservations/0.9.0

$app = Get-AzADApplication -DisplayName <CLOUDHEALTH-APP-DISPLAY-NAME>
$appId = $app.ApplicationId
$reservationOrders = Get-AzReservationOrder

if (!reservationOrders) {
    Write-Host("No Reservation Orders Found")
    Return
    }
else {
    foreach ($reservation in $reservationOrders) {
      $order_scope = $reservation.Id
      $assignedRoles = Get-AzRoleAssignment -Scope $order_scope -SPN $appId
      if (!$assignedRoles) {
        New-AzRoleAssignment -Scope $order_scope -RoleDefinitionName "Reader" -ApplicationId $appId
        Write-Host($order_scope + " successfully added Reader role")
        }
      elseif ($assignedRoles.RoleDefinitionName.Contains('Reader')) {
        Write-Host($order_scope + " has Reader role enabled already")
        }
      else {
        New-AzRoleAssignment -Scope $order_scope -RoleDefinitionName "Reader" -ApplicationId $appId
        Write-Host($order_scope + " successfully added Reader role")
        }
     }
}
