Configuration MultipleFunctionDefinitions {
    param (
        $Path
    )

    Import-DscResource -ModuleName JeaDsc

    node localhost {

        JeaRoleCapabilities MultipleFunctionDefinitions {
            Path = $Path
            VisibleCmdlets = "@{ Name = 'Get-DscLocalConfigurationManager'; Parameters = @{ Name = '*' } }"
            FunctionDefinitions = "@{ Name = 'Test'; ScriptBlock = { Test-DscConfiguration -Detailed } }", "@{ Name = 'GD'; ScriptBlock = { Get-Date } }"
            VisibleFunctions = 'GD', 'Test'
        }
    }
}
