using module .\..\Classes\ErrorEx.psm1

function Get-ActualError {
    <#
    .SYNOPSIS
        Decodes HRESULT error codes into their component parts.

    .DESCRIPTION
        Takes an HRESULT error code or ErrorRecord and extracts the bit fields:
        - Severity (IsFailure)
        - Customer flag (IsCustomer)
        - NT Status flag (IsNTStatus)
        - Facility code (which subsystem generated the error)
        - Error code (the actual error number)

        Returns an ErrorEx object with human-readable error information.

    .PARAMETER HResult
        The HRESULT error code to decode (32-bit integer).

    .PARAMETER Exception
        An ErrorRecord from which to extract the HRESULT.

    .EXAMPLE
        Get-ActualError -HResult 0x80004005

        Decodes the common "Unspecified error" HRESULT.

    .EXAMPLE
        try { throw "test" } catch { Get-ActualError -Exception $_ }

        Decodes the HRESULT from an ErrorRecord.

    .OUTPUTS
        ErrorEx
    #>
    [OutputType([ErrorEx])]
    [CmdletBinding(DefaultParameterSetName = 'HResult')]
    param (
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ParameterSetName = 'HResult'
        )]
        [int]$HResult,

        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ParameterSetName = 'Error'
        )]
        [ErrorRecord]$Exception
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Error') {
            $HResult = $Exception.Exception.HResult
        }

        # ErrorEx constructor handles all bit extraction
        return [ErrorEx]::new($HResult)
    }
}
