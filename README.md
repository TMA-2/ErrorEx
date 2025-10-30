# ErrorEx

Decodes Windows HRESULT error codes into their component parts and provides detailed error information.

## Installation

```powershell
Import-Module ErrorEx
```

## Description

The ErrorEx module provides tools for decoding Windows HRESULT error codes (32-bit error values used by COM/Win32 APIs) into their component parts:

- **Severity**: Whether the code represents a failure or success
- **Customer Flag**: Whether the error is customer-defined or Microsoft-defined
- **NT Status Flag**: Whether the error was mapped from an NTSTATUS code
- **Facility Code**: Which Windows subsystem generated the error (Win32, RPC, DirectX, etc.)
- **Error Code**: The actual error number within that facility

## HRESULT Structure

HRESULTs are 32-bit values with the following bit layout:
|   Bit | Type       |
| ----: | ---------- |
|  15-0 | Error Code |
| 27-16 | Facility   |
|    28 | NT Status  |
|    29 | Customer   |
|    30 | Reserved   |
|    31 | Severity   |

Where:
- **S (Severity)**: 1 = Failure, 0 = Success
- **R (Reserved)**: Microsoft reserved
- **C (Customer)**: 1 = Customer-defined, 0 = Microsoft-defined
- **N (NT Status)**: 1 = Mapped from NTSTATUS
- **Facility**: Which subsystem (11 bits, 0-2047)
- **Error Code**: The actual error number (16 bits, 0-65535)

## Usage

### Decode an HRESULT code

```powershell
# Access Denied (0x80070005)
Get-ActualError -HResult 0x80070005

# Unspecified error (0x80004005)
Get-ActualError -HResult 0x80004005

# User cancelled installation
Get-ActualError -HResult 1602
```

### Decode an error from an ErrorRecord

```powershell
try {
    # Some operation that fails
    Get-Item "C:\NonExistent" -ErrorAction Stop
}
catch {
    Get-ActualError -Exception $_
}
```

## Output

The `Get-ActualError` function returns an `ErrorEx` object with these properties:

| Property       | Type           | Description                                   |
| -------------- | -------------- | --------------------------------------------- |
| `ErrorCode`    | int            | The 16-bit error code                         |
| `HResult`      | int            | The full 32-bit HRESULT value                 |
| `HResultHex`   | string         | Hex representation (e.g., "0x80070005")       |
| `HResultBin`   | string         | Binary representation                         |
| `Message`      | string         | Human-readable error message                  |
| `Severity`     | string         | "Failure" or "Success"                        |
| `Facility`     | FacilityCode   | The facility enum value                       |
| `FacilityCode` | int            | The facility number                           |
| `IsFailure`    | bool           | True if severity bit is set                   |
| `IsCustomer`   | bool           | True if customer-defined                      |
| `IsNTStatus`   | bool           | True if mapped from NTSTATUS                  |
| `TypedError`   | Exception      | The typed .NET exception object               |
| `Win32Error`   | Win32Exception | Win32Exception object with additional details |

## Common HRESULT Codes

|        Code | Hex        | Description       | Facility |
| ----------: | ---------- | ----------------- | -------- |
| -2147024891 | 0x80070005 | Access Denied     | Win32    |
| -2147467259 | 0x80004005 | Unspecified error | NULL     |
| -2147024894 | 0x80070002 | File not found    | Win32    |
|           0 | 0x00000000 | Success           | NULL     |

## Links

- [Windows Error Codes](https://learn.microsoft.com/en-us/windows/win32/debug/system-error-codes)
- [HRESULT Structure](https://devblogs.microsoft.com/oldnewthing/20061103-07/?p=29133)
- [Error Code Lookup](https://errorcodelookup.com/)

## License

All Rights Reserved

Copyright (c) 2025 Jonathan Dunham
