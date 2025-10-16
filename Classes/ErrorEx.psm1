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
        # Convert from Win32 error code if applicable
        $HResultCode = $this.ConvertFromWin32Error($HResultCode)

        # Store the converted HRESULT
        $this.HResult = $HResultCode

        # Extract bit fields first to determine facility
        $this.ExtractBitFields($HResultCode)

        # Get typed exception from Marshal (best for .NET exceptions)
        $this.TypedError = [Marshal]::GetExceptionForHR($HResultCode)

        # Get message based on facility
        if ($this.Facility -eq [FacilityCode]::FACILITY_WIN32) {
            # Use Win32Exception for Win32 errors
            $this.Win32Error = [Win32Exception]::new($HResultCode)
            $this.Message = $this.Win32Error.Message
        }
        elseif ($null -ne $this.TypedError -and ![string]::IsNullOrWhiteSpace($this.TypedError.Message)) {
            # Use the typed exception message for .NET and other facilities
            $this.Message = $this.TypedError.Message
        }
        else {
            # Fallback to Win32Exception
            $this.Win32Error = [Win32Exception]::new($HResultCode)
            $this.Message = $this.Win32Error.Message
        }

        # Format hex and binary representations
        $this.HResultHex = '0x{0:X8}' -f $HResultCode
        $this.HResultBin = '0b{0}' -f [Convert]::ToString($HResultCode, 2).PadLeft(32, '0')

        # Set severity as readable string
        if ($this.HResult -gt 0 -and $this.HResult -lt 0x10000) {
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
        # Win32 error codes are positive values < 65536
        # HRESULTs have bit 31 set (appear as negative int32)
        if ($Code -gt 0 -and $Code -lt 0x10000) {
            return [int]0x80070000 -bor $Code
        }
        else {
            return $Code
        }
    }

    hidden [void] ExtractBitFields([int]$Code) {
        # Bits 0-15: Error Code
        $this.ErrorCode = $Code -band 0xFFFF

        # Bits 16-26: Facility Code (11 bits)
        $this.FacilityCode = ($Code -shr 16) -band 0x7FF

        # Bit 27: NT Status flag
        $this.IsNTStatus = (($Code -shr 27) -band 1) -eq 1

        # Bit 28: Customer flag
        $this.IsCustomer = (($Code -shr 28) -band 1) -eq 1

        # Bit 29: Reserved (we don't use this)

        # Bit 31: Severity/Failure flag (topmost bit)
        $this.IsFailure = $Code -lt 0

        # Map facility code to enum name
        $this.Facility = [FacilityCode]$this.FacilityCode
    }
}
