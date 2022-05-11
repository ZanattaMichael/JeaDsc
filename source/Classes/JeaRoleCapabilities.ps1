<#
    .SYNOPSIS
        The JeaRoleCapabilities DSC resource creates the Role Capabilities file
        in the specified location using the specified settings.

    .DESCRIPTION
        The JeaRoleCapabilities DSC resource creates the Role Capabilities file
        in the specified location using the specified settings.

    .PARAMETER Ensure
        Specifies whether the Role Capabilities file should be created or removed
        (not exist).

    .PARAMETER Path
        Where to store the file.

    .PARAMETER ModulesToImport
        Specifies the modules that are automatically imported into sessions that
        use the role capability file. By default, all of the commands in listed
        modules are visible. When used with VisibleCmdlets or VisibleFunctions,
        the commands visible from the specified modules can be restricted.
        Hashtable with keys ModuleName, ModuleVersion and GUID.

    .PARAMETER VisibleAliases
        Limits the aliases in the session to those aliases specified in the value
        of this parameter, plus any aliases that you define in the AliasDefinition
        parameter. Wildcard characters are supported. By default, all aliases that
        are defined by the Windows PowerShell engine and all aliases that modules
        export are visible in the session.

    .PARAMETER VisibleCmdlets
        Limits the cmdlets in the session to those specified in the value of this
        parameter. Wildcard characters and Module Qualified Names are supported.

    .PARAMETER VisibleFunctions
        Limits the functions in the session to those specified in the value of this
        parameter, plus any functions that you define in the FunctionDefinitions
        parameter. Wildcard characters are supported.

    .PARAMETER VisibleExternalCommands
        Limits the external binaries, scripts and commands that can be executed in
        the session to those specified in the value of this parameter. Wildcard
        characters are supported.

    .PARAMETER VisibleProviders
        Limits the Windows PowerShell providers in the session to those specified
        in the value of this parameter. Wildcard characters are supported.

    .PARAMETER ScriptsToProcess
        Specifies scripts to add to sessions that use the role capability file.

    .PARAMETER AliasDefinitions
        Adds the specified aliases to sessions that use the role capability file.
        Hashtable with keys Name, Value, Description and Options.

    .PARAMETER FunctionDefinitions
        Adds the specified functions to sessions that expose the role capability.
        Hashtable with keys Name, Scriptblock and Options.

    .PARAMETER VariableDefinitions
        Specifies variables to add to sessions that use the role capability file.
        Hashtable with keys Name, Value, Options.

    .PARAMETER EnvironmentVariables
        Specifies the environment variables for sessions that expose this role
        capability file. Hashtable of environment variables.

    .PARAMETER TypesToProcess
        Specifies type files (.ps1xml) to add to sessions that use the role
        capability file. The value of this parameter must be a full or absolute
        path of the type file names.

    .PARAMETER FormatsToProcess
        Specifies the formatting files (.ps1xml) that run in sessions that use the
        role capability file. The value of this parameter must be a full or absolute
        path of the formatting files.

    .PARAMETER Description
        Specifies the assemblies to load into the sessions that use the role
        capability file.

    .PARAMETER AssembliesToLoad
        Description of the role.

    .PARAMETER Reasons
        Reasons of why the resource isn't in desired state.
#>

[DscResource()]
class JeaRoleCapabilities:RoleCapabilitiesUtility
{
    [DscProperty()]
    [Ensure]$Ensure = [Ensure]::Present

    [DscProperty(Key)]
    [string]$Path

    [DscProperty()]
    [string[]]$ModulesToImport

    [DscProperty()]
    [string[]]$VisibleAliases

    [DscProperty()]
    [string[]]$VisibleCmdlets

    [DscProperty()]
    [string[]]$VisibleFunctions

    [DscProperty()]
    [string[]]$VisibleExternalCommands

    [DscProperty()]
    [string[]]$VisibleProviders

    [DscProperty()]
    [string[]]$ScriptsToProcess

    [DscProperty()]
    [string[]]$AliasDefinitions

    [DscProperty()]
    [string[]]$FunctionDefinitions

    [DscProperty()]
    [string[]]$VariableDefinitions

    [DscProperty()]
    [string[]]$EnvironmentVariables

    [DscProperty()]
    [string[]]$TypesToProcess

    [DscProperty()]
    [string[]]$FormatsToProcess

    [DscProperty()]
    [string]$Description

    [DscProperty()]
    [string[]]$AssembliesToLoad

    [DscProperty(NotConfigurable)]
    [Reason[]]$Reasons

    [JeaRoleCapabilities] Get()
    {
        $currentState = [JeaRoleCapabilities]::new()
        $currentState.Path = $this.Path
        if (Test-Path -Path $this.Path)
        {
            $currentStateFile = Import-PowerShellDataFile -Path $this.Path

            'Copyright', 'GUID', 'Author', 'CompanyName' | Foreach-Object {
                $currentStateFile.Remove($_)
            }

            foreach ($property in $currentStateFile.Keys)
            {
                $propertyType = ($this | Get-Member -Name $property -MemberType Property).Definition.Split(' ')[0]
                $currentState.$property = foreach ($propertyValue in $currentStateFile[$property])
                {
                    if ($propertyValue -is [hashtable] -and $propertyType -ne 'hashtable')
                    {
                        if ($propertyValue.ScriptBlock -is [scriptblock])
                        {
                            $code = $propertyValue.ScriptBlock.Ast.Extent.Text
                            $code -match '(?<=\{)(?<Code>((.|\s)*))(?=\})' | Out-Null
                            $propertyValue.ScriptBlock = [scriptblock]::Create($Matches.Code)
                        }

                        ConvertTo-Expression -Object $propertyValue
                    }
                    elseif ($propertyValue -is [hashtable] -and $propertyType -eq 'hashtable')
                    {
                        $propertyValue
                    }
                    else
                    {
                        $propertyValue
                    }
                }
            }
            $currentState.Ensure = [Ensure]::Present

            # Compare current and desired state to add reasons
            $valuesToCheck = $this.psobject.Properties.Name.Where({$_ -notin 'Path','Reasons'})

            $compareState = Compare-DscParameterState `
                -CurrentValues ($currentState | Convert-ObjectToHashtable) `
                -DesiredValues ($this | Convert-ObjectToHashtable) `
                -ValuesToCheck $valuesToCheck | Where-Object {$_.InDesiredState -eq $false }

            $currentState.Reasons = switch ($compareState)
            {
                {$_.Property -eq 'Ensure'}{
                    [Reason]@{
                        Code = '{0}:{0}:{1}' -f $this.GetType(),$_.Property
                        Phrase = $script:localizedDataRole.ReasonEnsure -f $this.Path
                    }
                    continue
                }
                {$_.Property -eq 'Description'}{
                    [Reason]@{
                        Code = '{0}:{0}:{1}' -f $this.GetType(),$_.Property
                        Phrase = $script:localizedDataRole.ReasonDescription -f $this.Description
                    }
                    continue
                }
                default {
                    [Reason]@{
                        Code = '{0}:{0}:{1}' -f $this.GetType(),$_.Property
                        Phrase = $script:localizedDataRole."Reason$($_.Property)"
                    }
                }
            }
        }
        else
        {
            $currentState.Ensure = [Ensure]::Absent
            if ($this.Ensure -eq [Ensure]::Present)
            {
                $currentState.Reasons = [Reason]@{
                    Code = '{0}:{0}:Ensure' -f $this.GetType()
                    Phrase = $script:localizedDataRole.ReasonFileNotFound -f $this.Path
                }
            }
        }

        return $currentState
    }

    [void] Set()
    {
        $invalidConfiguration = $false

        if ($this.Ensure -eq [Ensure]::Present)
        {
            $desiredState = Convert-ObjectToHashtable -Object $this

            foreach ($parameter in $desiredState.Keys.Where( { $desiredState[$_] -match '@{' }))
            {
                $desiredState[$parameter] = Convert-StringToObject -InputString $desiredState[$parameter]
            }

            $desiredState = Sync-Parameter -Command (Get-Command -Name New-PSRoleCapabilityFile) -Parameters $desiredState

            if ($desiredState.ContainsKey('FunctionDefinitions'))
            {
                foreach ($functionDefinitionName in $desiredState['FunctionDefinitions'].Name)
                {
                    if ($functionDefinitionName -notin $desiredState['VisibleFunctions'])
                    {
                        Write-Verbose ($script:localizedDataRole.FunctionDefinedNotVisible -f $functionDefinitionName)
                        Write-Error ($script:localizedDataRole.FunctionDefinedNotVisible -f $functionDefinitionName)
                        $invalidConfiguration = $true
                    }
                }
            }

            if (-not $invalidConfiguration)
            {
                $parentPath = Split-Path -Path $desiredState.Path -Parent
                mkdir -Path $parentPath -Force

                $fPath = $desiredState.Path
                $desiredState.Remove('Path')
                $content = $desiredState | ConvertTo-Expression
                $content | Set-Content -Path $fPath -Force
            }
        }
        elseif ($this.Ensure -eq [Ensure]::Absent -and (Test-Path -Path $this.Path))
        {
            Remove-Item -Path $this.Path -Confirm:$false -Force
        }

    }

    [bool] Test()
    {
        if (-not ($this.ValidatePath()))
        {
            Write-Error -Message $script:localizedDataRole.InvalidPath
            return $false
        }
        if ($this.Ensure -eq [Ensure]::Present -and -not (Test-Path -Path $this.Path))
        {
            return $false
        }
        elseif ($this.Ensure -eq [Ensure]::Present -and (Test-Path -Path $this.Path))
        {

            $currentState = Convert-ObjectToHashtable -Object $this.Get()
            $desiredState = Convert-ObjectToHashtable -Object $this

            $cmdlet = Get-Command -Name New-PSRoleCapabilityFile
            $desiredState = Sync-Parameter -Command $cmdlet -Parameters $desiredState
            $currentState = Sync-Parameter -Command $cmdlet -Parameters $currentState
            $propertiesAsObject = $cmdlet.Parameters.Keys |
                Where-Object { $_ -in $desiredState.Keys } |
                    Where-Object { $cmdlet.Parameters.$_.ParameterType.FullName -in 'System.Collections.IDictionary', 'System.Collections.Hashtable', 'System.Collections.IDictionary[]', 'System.Object[]' }
            foreach ($p in $propertiesAsObject)
            {
                if ($cmdlet.Parameters.$p.ParameterType.FullName -in 'System.Collections.Hashtable', 'System.Collections.IDictionary', 'System.Collections.IDictionary[]', 'System.Object[]')
                {
                    $desiredState."$($p)" = $desiredState."$($p)" | Convert-StringToObject
                    $currentState."$($p)" = $currentState."$($p)" | Convert-StringToObject
                }
            }

            $compare = Test-DscParameterState -CurrentValues $currentState -DesiredValues $desiredState -SortArrayValues -TurnOffTypeChecking -ReverseCheck

            return $compare
        }
        elseif ($this.Ensure -eq [Ensure]::Absent -and (Test-Path -Path $this.Path))
        {
            return $false
        }
        elseif ($this.Ensure -eq [Ensure]::Absent -and -not (Test-Path -Path $this.Path))
        {
            return $true
        }

        return $false
    }
}
