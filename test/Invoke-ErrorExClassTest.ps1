<#
.SYNOPSIS
    Test harness for ErrorEx class development.

.DESCRIPTION
    Runs in a fresh PowerShell runspace to test the ErrorEx class without
    requiring session restart. Use this during active class development.

.PARAMETER ErrorCode
    Specific error code to test. If not provided, runs a suite of common codes.

.PARAMETER Detailed
    Show all properties instead of just the key ones.

.EXAMPLE
    .\Test\Invoke-ErrorExClassTest.ps1

    Runs test suite with common error codes.

.EXAMPLE
    .\Test\Invoke-ErrorExClassTest.ps1 -ErrorCode 1603 -Detailed

    Tests specific error code with full property output.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [int]$ErrorCode,

    [switch]$Detailed
)

function Invoke-ErrorExInRunspace {
    param(
        [int[]]$Codes,
        [bool]$ShowDetailed
    )

    $ps = [powershell]::Create()
    try {
        $scriptBlock = @"
using module '$PSScriptRoot\..\Classes\ErrorEx.psm1'

`$ErrorCodes = @($($Codes -join ', '))
`$Detailed = `$$ShowDetailed

foreach (`$Code in `$ErrorCodes) {
    Write-Host ""
    Write-Host "Testing Error Code: `$Code" -ForegroundColor Cyan
    Write-Host ('-' * 60) -ForegroundColor DarkGray

    try {
        `$err = [ErrorEx]::new(`$Code)

        if (`$Detailed) {
            `$err | Format-List *
        }
        else {
            `$err | Format-List ErrorCode, HResult, HResultHex, Facility, FacilityCode, Message, Severity, IsFailure, IsCustomer, IsNTStatus
        }
    }
    catch {
        Write-Host "ERROR: `$_" -ForegroundColor Red
        Write-Host `$_.Exception.GetType().FullName -ForegroundColor DarkRed
    }
}
"@

        $ps.AddScript($scriptBlock)
        $result = $ps.Invoke()

        # Output results
        $result

        # Show errors if any
        if ($ps.HadErrors) {
            Write-Host "`nErrors encountered:" -ForegroundColor Red
            $ps.Streams.Error | ForEach-Object {
                Write-Host $_.ToString() -ForegroundColor Red
            }
        }

        # Show warnings if any
        if ($ps.Streams.Warning.Count -gt 0) {
            Write-Host "`nWarnings:" -ForegroundColor Yellow
            $ps.Streams.Warning | ForEach-Object {
                Write-Host $_.ToString() -ForegroundColor Yellow
            }
        }
    }
    finally {
        $ps.Dispose()
    }
}

# Determine which codes to test
$TestCodes = if ($PSBoundParameters.ContainsKey('ErrorCode')) {
    @($ErrorCode)
}
else {
    Write-Host "Running ErrorEx Class Test Suite" -ForegroundColor Green
    Write-Host "=" * 60 -ForegroundColor Green

    @(
        # Win32 errors
        1,      # ERROR_INVALID_FUNCTION
        2,      # ERROR_FILE_NOT_FOUND
        5,      # ERROR_ACCESS_DENIED
        1603,   # ERROR_INSTALL_FAILURE
        1618,   # ERROR_INSTALL_ALREADY_RUNNING

        # HRESULTs
        0x80070005,  # E_ACCESSDENIED (Win32 facility)
        0x80004005,  # E_FAIL (Null facility)
        0x80070002,  # File not found
        0x8007052E,  # Logon failure
        0x80131621,  # File load exception
        0x00000000   # S_OK (Success)
    )
}

# Run tests
Invoke-ErrorExInRunspace -Codes $TestCodes -ShowDetailed:$Detailed

Write-Host "`nTest complete!" -ForegroundColor Green
