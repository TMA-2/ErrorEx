using module .\FacilityCode.psm1
using namespace System.ComponentModel
using namespace System.Runtime.InteropServices

# HRESULT Structure (32-bit):
# Bit 31:      Severity (S) - 1 = Failure, 0 = Success
# Bit 30:      Reserved (R) - Microsoft reserved
# Bit 29:      Customer (C) - 1 = Customer-defined, 0 = Microsoft-defined
# Bit 28:      NT Status (N) - 1 = Mapped from NTSTATUS
# Bits 27-16:  Facility Code (11 bits) - Which subsystem generated the error
# Bits 15-0:   Error Code (16 bits) - The actual error number
class ErrorEx {
    # Public Properties
    [int]$HResult
    [string]$HResultHex
    [string]$HResultBin
    [string]$Message
    [string]$Severity
    [FacilityCode]$Facility
    [int]$FacilityCode
    [int]$ErrorCode
    [bool]$IsFailure
    [bool]$IsCustomer
    [bool]$IsNTStatus
    [Exception]$TypedError
    [Win32Exception]$Win32Error

    # Constructor with HResult
    ErrorEx([int]$HResultCode) {
        $this.HResult = $HResultCode

        # Convert from Win32 error code if applicable
        $HResultCode = $this.ConvertFromWin32Error($HResultCode)

        # Get error message from Win32Exception
        $this.Win32Error = [Win32Exception]::new($HResultCode)
        $this.Message = $this.Win32Error.Message

        # Get typed exception from Marshal
        $this.TypedError = [Marshal]::GetExceptionForHR($HResultCode)

        # Format hex and binary representations
        $this.HResultHex = '0x{0:X8}' -f $HResultCode
        $this.HResultBin = '0b{0}' -f [Convert]::ToString($HResultCode, 2).PadLeft(32, '0')

        # Extract bit fields using local variable to avoid modifying HResult property
        $this.ExtractBitFields($HResultCode)

        # Set severity as readable string
        if ($HResultCode -lt 0x80000000 -and $HResultCode -ne 0) {
            $this.Severity = 'Indeterminate (Win32 error code)'
        }
        elseif ($this.IsFailure) {
            $this.Severity = 'Failure'
        }
        else {
            $this.Severity = 'Success'
        }
    }

    hidden [int] ConvertFromWin32Error([int]$Code) {
        if ($Code -lt 0x80000000 -and $Code -ne 0) {
            return [int]0x80070000 -bor $Code
        }
        else {
            return $Code
        }
    }

    hidden [void] ExtractBitFields([int]$Code) {
        # Bits 0-15: Error Code
        $this.ErrorCode = $Code -band 0xFFFF
        $Code = $Code | shr 16

        # Bits 16-26: Facility Code (11 bits)
        $this.FacilityCode = $Code -band 0x7FF
        $Code = $Code | shr 11

        # Bit 27: NT Status flag
        $this.IsNTStatus = ($Code -band 1) -eq 1
        $Code = $Code | shr 1

        # Bit 28: Customer flag
        $this.IsCustomer = ($Code -band 1) -eq 1
        $Code = $Code | shr 1

        # Bit 29: Reserved (skip)
        $Code = $Code | shr 1

        # Bit 31: Severity/Failure flag
        $this.IsFailure = ($Code -band 1) -eq 1

        # Map facility code to enum name
        $this.Facility = [FacilityCode]$this.FacilityCode
    }
}

Export-ModuleMember -Variable 'this'
