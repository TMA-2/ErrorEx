BeforeAll {
    # Import the module under test
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module $ModulePath -Force
}

Describe 'ErrorEx Module Tests' {
    Context 'Module Import' {
        It 'Should import without errors' {
            { Import-Module ErrorEx -Force } | Should -Not -Throw
        }

        It 'Should export Get-ActualError function' {
            $ExportedCommands = Get-Command -Module ErrorEx
            $ExportedCommands.Name | Should -Contain 'Get-ActualError'
        }

        It 'Should load FacilityCode enum' {
            [FacilityCode]::FACILITY_WIN32 | Should -Be 7
        }

        It 'Should load ErrorEx class' {
            { [ErrorEx]::new(0x80070005) } | Should -Not -Throw
        }
    }
}

Describe 'Get-ActualError Function Tests' {
    Context 'HResult Parameter' {
        It 'Should decode Access Denied error (0x80070005)' {
            $Result = Get-ActualError -HResult 0x80070005
            $Result.HResult | Should -Be 0x80070005
            $Result.ErrorCode | Should -Be 5
            $Result.FacilityCode | Should -Be 7
            $Result.Facility | Should -Be ([FacilityCode]::FACILITY_WIN32)
            $Result.IsFailure | Should -BeTrue
            $Result.IsCustomer | Should -BeFalse
        }

        It 'Should decode Unspecified error (0x80004005)' {
            $Result = Get-ActualError -HResult 0x80004005
            $Result.HResult | Should -Be 0x80004005
            $Result.ErrorCode | Should -Be 0x4005
            $Result.FacilityCode | Should -Be 0
            $Result.Facility | Should -Be ([FacilityCode]::FACILITY_NULL)
            $Result.IsFailure | Should -BeTrue
        }

        It 'Should decode File Not Found error (0x80070002)' {
            $Result = Get-ActualError -HResult 0x80070002
            $Result.HResult | Should -Be 0x80070002
            $Result.ErrorCode | Should -Be 2
            $Result.FacilityCode | Should -Be 7
            $Result.Facility | Should -Be ([FacilityCode]::FACILITY_WIN32)
            $Result.IsFailure | Should -BeTrue
        }

        It 'Should decode Success (0x00000000)' {
            $Result = Get-ActualError -HResult 0x00000000
            $Result.HResult | Should -Be 0
            $Result.ErrorCode | Should -Be 0
            $Result.IsFailure | Should -BeFalse
        }

        It 'Should format hex representation correctly' {
            $Result = Get-ActualError -HResult 0x80070005
            $Result.HResultHex | Should -Be '0x80070005'
        }

        It 'Should format binary representation correctly' {
            $Result = Get-ActualError -HResult 0x80070005
            $Result.HResultBin | Should -Match '^0b[01]{32}$'
        }
    }

    Context 'Exception Parameter' {
        It 'Should extract HRESULT from ErrorRecord' {
            try {
                throw [System.IO.FileNotFoundException]::new("Test file not found")
            }
            catch {
                $Result = Get-ActualError -Exception $_
                $Result | Should -Not -BeNullOrEmpty
                $Result.HResult | Should -Be $_.Exception.HResult
            }
        }
    }

    Context 'Output Type' {
        It 'Should return ErrorEx object' {
            $Result = Get-ActualError -HResult 0x80070005
            $Result | Should -BeOfType [ErrorEx]
        }

        It 'Should have all expected properties' {
            $Result = Get-ActualError -HResult 0x80070005
            $Result.PSObject.Properties.Name | Should -Contain 'HResult'
            $Result.PSObject.Properties.Name | Should -Contain 'HResultHex'
            $Result.PSObject.Properties.Name | Should -Contain 'HResultBin'
            $Result.PSObject.Properties.Name | Should -Contain 'Message'
            $Result.PSObject.Properties.Name | Should -Contain 'Facility'
            $Result.PSObject.Properties.Name | Should -Contain 'FacilityCode'
            $Result.PSObject.Properties.Name | Should -Contain 'ErrorCode'
            $Result.PSObject.Properties.Name | Should -Contain 'IsFailure'
            $Result.PSObject.Properties.Name | Should -Contain 'IsCustomer'
            $Result.PSObject.Properties.Name | Should -Contain 'IsNTStatus'
        }
    }
}

Describe 'ErrorEx Class Tests' {
    Context 'Bit Field Extraction' {
        It 'Should extract error code correctly' {
            $Error = [ErrorEx]::new(0x80070005)
            $Error.ErrorCode | Should -Be 5
        }

        It 'Should extract facility code correctly' {
            $Error = [ErrorEx]::new(0x80070005)
            $Error.FacilityCode | Should -Be 7
        }

        It 'Should set IsFailure correctly for failure codes' {
            $Error = [ErrorEx]::new(0x80070005)
            $Error.IsFailure | Should -BeTrue
        }

        It 'Should set IsFailure correctly for success codes' {
            $Error = [ErrorEx]::new(0x00000000)
            $Error.IsFailure | Should -BeFalse
        }

        It 'Should map facility code to enum' {
            $Error = [ErrorEx]::new(0x80070005)
            $Error.Facility | Should -Be ([FacilityCode]::FACILITY_WIN32)
        }
    }

    Context 'Known HRESULT Values' {
        It 'Should correctly decode E_ACCESSDENIED (0x80070005)' {
            $Error = [ErrorEx]::new(0x80070005)
            $Error.FacilityCode | Should -Be 7
            $Error.ErrorCode | Should -Be 5
        }

        It 'Should correctly decode E_FAIL (0x80004005)' {
            $Error = [ErrorEx]::new(0x80004005)
            $Error.FacilityCode | Should -Be 0
            $Error.ErrorCode | Should -Be 0x4005
        }

        It 'Should correctly decode RPC_E_SERVERFAULT (0x80010105)' {
            $Error = [ErrorEx]::new(0x80010105)
            $Error.Facility | Should -Be ([FacilityCode]::FACILITY_RPC)
            $Error.ErrorCode | Should -Be 0x0105
        }
    }
}

Describe 'FacilityCode Enum Tests' {
    Context 'Common Facilities' {
        It 'Should have Win32 facility defined' {
            [FacilityCode]::FACILITY_WIN32 | Should -Be 7
        }

        It 'Should have RPC facility defined' {
            [FacilityCode]::FACILITY_RPC | Should -Be 1
        }

        It 'Should have PowerShell facility defined' {
            [FacilityCode]::FACILITY_POWERSHELL | Should -Be 84
        }
    }
}
