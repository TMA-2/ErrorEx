@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'ErrorEx.psm1'

    # Version number of this module.
    ModuleVersion = '0.1.1'

    # ID used to uniquely identify this module
    GUID = 'a8b9c7d6-e5f4-4a3b-9c2d-1e0f9a8b7c6d'

    # Author of this module
    Author = 'Jonathan Dunham'

    # Company or vendor of this module
    CompanyName = 'Jonathan Dunham'

    # Copyright statement for this module
    Copyright = '(c) 2025 Jonathan Dunham. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Decodes Windows HRESULT error codes into their component parts and provides detailed error information.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @(
        'Get-ActualError'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @('ErrorEx.Types.ps1xml')

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            # Tags applied to this module
            Tags = @('Error', 'HRESULT', 'Win32', 'Diagnostics', 'Debugging')

            # A URL to the license for this module
            LicenseUri = ''

            # A URL to the main website for this project
            ProjectUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'See CHANGELOG.md'
        }
    }
}
