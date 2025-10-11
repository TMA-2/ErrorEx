# TODO

## General
- [ ] Add PlatyPS-generated help documentation in `/Docs`
- [ ] Add comprehensive Pester tests
- [ ] Consider adding Format.ps1xml for custom table/list views
- [ ] Add CI/CD pipeline for testing and publishing

## Get-ActualError
- [ ] Add `-PassThru` parameter to return original ErrorRecord with added ErrorEx property
- [ ] Add tab completion for common HRESULT values
- [ ] Support pipeline input for arrays of HRESULTs
- [ ] Add `-AsJson` parameter for structured output

## ErrorEx Class
- [ ] Add method to convert ErrorCode back to HRESULT
- [ ] Add method to lookup related error codes
- [ ] Add static method `[ErrorEx]::FromWin32([int]$Win32Error)` to convert Win32 error codes
- [ ] Consider adding `ToString()` override for better display

## New Functions
- [ ] `ConvertFrom-Win32Error` - Convert Win32 error codes to HRESULT
- [ ] `ConvertTo-HRESULT` - Convert facility + error code to HRESULT
- [ ] `Get-FacilityInfo` - Get information about a specific facility code
- [ ] `Find-ErrorCode` - Search for error codes by message text

## Documentation
- [ ] Add more examples to README
- [ ] Create tutorial/guide for common scenarios
- [ ] Document all facility codes with descriptions
- [ ] Add troubleshooting section

## Testing
- [ ] Test against known HRESULT values
- [ ] Test bit extraction accuracy
- [ ] Test edge cases (negative numbers, boundary values)
- [ ] Test with real-world ErrorRecord objects
