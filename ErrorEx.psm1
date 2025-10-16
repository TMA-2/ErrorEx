using module .\Classes\FacilityCode.psm1
using module .\Classes\ErrorEx.psm1
using namespace System.ComponentModel
using namespace System.Runtime.InteropServices

# Import classes/enums first (order matters!)
# Import-Module "$PSScriptRoot\Classes\FacilityCode.psm1"
# Import-Module "$PSScriptRoot\Classes\ErrorEx.psm1"

# Export types to module scope so functions can reference them
Export-ModuleMember -Function @()  # Explicitly empty to start

# Import public functions
. "$PSScriptRoot\Public\Get-ActualError.ps1"
. "$PSScriptRoot\Public\Find-ErrorByMessage.ps1"

# Export public functions
Export-ModuleMember -Function 'Get-ActualError','Find-ErrorByMessage' -Alias 'err'
