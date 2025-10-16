using module .\..\Classes\FacilityCode.psm1
using module .\..\Classes\ErrorEx.psm1
using namespace System.Collections.Generic


<# Create cache on module import
[Dictionary[int, ErrorEx]]$ErrorCache = @{}
$Win32Range = @(0, 15999)
$FacilitiesRange = @(0x8A010000, 0x8A01FFFF)
for ($i = $Win32Range[0]; $i -lt $Win32Range[1]; $i++) {
    try {
        # Add to cache
        $ErrorCache[$i] = Get-ActualError -HResult $i -ErrorAction Stop
    }
    catch { continue }
}
for ($i = $FacilitiesRange[0]; $i -lt $FacilitiesRange[1]; $i++) {
    try {
        # Add to cache
        $ErrorCache[$i] = Get-ActualError -HResult $i -ErrorAction Stop
    }
    catch { continue }
}
#>

function Find-ErrorByMessage {
    <#
    .SYNOPSIS
        Searches for error codes by message text.

    .DESCRIPTION
        Searches through Win32 error codes and common HRESULTs to find matches
        for the specified message text. Returns ErrorEx objects for each match.

    .PARAMETER Message
        The message text to search for (supports wildcards).

    .PARAMETER Facility
        Optional facility code to narrow the search.

    .PARAMETER MaxResults
        Maximum number of results to return (default: 50).

    .EXAMPLE
        Find-ErrorByMessage -Message "*access*denied*"

        Finds all errors with "access" and "denied" in the message.

    .EXAMPLE
        Find-ErrorByMessage -Message "*file*" -Facility FACILITY_WIN32 -MaxResults 10

        Finds up to 10 Win32 errors with "file" in the message.
    #>
    [OutputType([ErrorEx])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Message,

        [Parameter()]
        [FacilityCode]$Facility,

        [Parameter()]
        [int]$MaxResults = 50
    )

    process {
        # Define search ranges
        $SearchRanges = if ($PSBoundParameters.ContainsKey('Facility')) {
            @(
                @{
                    Start = (0x80000000 -bor ($Facility.value__ -shl 16))
                    End   = (0x80000000 -bor ($Facility.value__ -shl 16) -bor 0xFFFF)
                }
            )
        }
        else {
            # Win32 errors (most common)
            @(
                @{ Start = 1; End = 15999 }  # Common Win32 errors
            )
        }

        foreach ($Range in $SearchRanges) {
            $Count = 0
            for ($Code = $Range.Start; $Code -le $Range.End -and $Count -lt $MaxResults; $Code++) {
                try {
                    $ErrorObj = Get-ActualError -HResult $Code -ErrorAction Stop

                    # Skip if no meaningful message
                    if ([string]::IsNullOrWhiteSpace($ErrorObj.Message) -or
                        $ErrorObj.Message -match '^Unknown error') {
                        continue
                    }

                    # Check message match
                    if ($ErrorObj.Message -like $Message) {
                        $ErrorObj
                        $Count++
                    }
                }
                catch {
                    continue
                }
            }
        }

        if ($Count -eq 0) {
            Write-Warning "No errors found matching pattern: $Message"
        }
    }
}
