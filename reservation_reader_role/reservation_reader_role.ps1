# Grabs all existing Reservation Orders in directory and assigns the reader role 
# Download Az.Reservations package if you don't already have it -> https://www.powershellgallery.com/packages/Az.Reservations/0.9.0
# "Get-AzADApplication -DisplayName" will only grab Applications within the directory the user is logged in to in Azure

# Get current working directory and inform user
$currentDirectory = Get-AzContext
Write-Host "Starting with current Azure Directory ('Tenant ID'):" $currentDirectory.Tenant -ForegroundColor Yellow

# Prompt User for the CloudHealth App Display Name
$cloudHealthAppID = Read-Host "Please enter your CloudHealth Application ID for Azure Tenant ID" $currentDirectory.Tenant
Write-Host ""

# Get Application ID based on user input, as well as Reservation Orders in directory
$reservationOrders = Get-AzReservationOrder

# Check to see if Reservation Order list is empty, and end sequence if true
if (!$reservationOrders) {
    Write-Host("No Reservation Orders Found")
    }

# For each Reservation Order found, determine if it has the Reader Role for CH app already. If not, assign it.
foreach ($reservation in $reservationOrders) {
  $order_scope = $reservation.Id
  $assignedRoles = Get-AzRoleAssignment -Scope $order_scope -SPN $cloudHealthAppID
  if (!$assignedRoles) {
    New-AzRoleAssignment -Scope $order_scope -RoleDefinitionName "Reader" -ApplicationId $cloudHealthAppID
    Write-Host($order_scope + " successfully added Reader role")
    }
  elseif ($assignedRoles.RoleDefinitionName.Contains('Reader')) {
    Write-Host($order_scope + " has Reader role enabled already")
    }
  else {
    New-AzRoleAssignment -Scope $order_scope -RoleDefinitionName "Reader" -ApplicationId $cloudHealthAppID
    Write-Host($order_scope + " successfully added Reader role")
    }
  }

# Give user the option to update additional directories
$directoryPrompt = "Would you like to enter another Azure Tenant ID? (Y/N)"
do {
  Write-Host ""
  $response = Read-Host -Prompt $directoryPrompt
  if ($response -eq 'Y' -or $response -eq 'y') {
  $newDirectory = Read-Host "Please enter your next Azure Tenant ID"
  Write-Host "Setting new Az-Context..." -ForegroundColor Yellow
  Write-Host ""
  Set-AzContext -TenantId $newDirectory
  Write-Host ""

  # Prompt User for the CloudHealth App Display Name
  $cloudHealthAppID = Read-Host "Please enter your CloudHealth Application ID for Azure Tenant ID" $newDirectory
  Write-Host ""

  # Get Application ID based on user input, as well as Reservation Orders in directory
  $reservationOrders = Get-AzReservationOrder

  # Check to see if Reservation Order list is empty, and end sequence if true
  if (!$reservationOrders) {
      Write-Host("No Reservation Orders Found")
      Return
      }

  # For each Reservation Order found, determine if it has the Reader Role for CH app already. If not, assign it.
  foreach ($reservation in $reservationOrders) {
      $order_scope = $reservation.Id
      $assignedRoles = Get-AzRoleAssignment -Scope $order_scope -SPN $cloudHealthAppID
      if (!$assignedRoles) {
        New-AzRoleAssignment -Scope $order_scope -RoleDefinitionName "Reader" -ApplicationId $cloudHealthAppID
        Write-Host($order_scope + " successfully added Reader role")
        }
      elseif ($assignedRoles.RoleDefinitionName.Contains('Reader')) {
        Write-Host($order_scope + " has Reader role enabled already")
        }
      else {
        New-AzRoleAssignment -Scope $order_scope -RoleDefinitionName "Reader" -ApplicationId $cloudHealthAppID
        Write-Host($order_scope + " successfully added Reader role")
        }
    }

  }
}
until ($response -eq 'N' -or $response -eq 'n')
Write-Host "Exiting..."
