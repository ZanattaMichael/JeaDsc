<#
    .SYNOPSIS
        The JeaSessionConfiguration DSC resource configures the PowerShell session
        configurations, which define the mapping of users to roles and general
        session security settings.

    .DESCRIPTION
        The JeaSessionConfiguration DSC resource configures the PowerShell session
        configurations, which define the mapping of users to roles and general
        session security settings.

        >**Note:** Scriptblock logging is not enabled by this resource and should
        >be done using the [registry resource](https://docs.microsoft.com/en-us/powershell/dsc/registryresource).


    .PARAMETER Ensure
       The optional state that ensures the endpoint is present or absent. The
       default value is [Ensure]::Present.

    .PARAMETER Name
        The mandatory endpoint name. Uses 'Microsoft.PowerShell' by default.

    .PARAMETER RoleDefinitions
        The role definition map to be used for the endpoint. This should be a string
        that represents the Hashtable used for the RoleDefinitions property in
        `New-PSSessionConfigurationFile`, such as:
        ```
        RoleDefinitions = '@{ Everyone = @{ RoleCapabilities = "BaseJeaCapabilities" } }'
        ```

    .PARAMETER RunAsVirtualAccount
        Run the endpoint under a Virtual Account.

    .PARAMETER RunAsVirtualAccountGroups
        The optional groups to be used when the endpoint is configured to run as a
        Virtual Account

    .PARAMETER GroupManagedServiceAccount
        The optional Group Managed Service Account (GMSA) to use for this endpoint.
        If configured, will disable the default behavior of running as a Virtual
        Account.

    .PARAMETER TranscriptDirectory
        The optional directory for transcripts to be saved to.

    .PARAMETER ScriptsToProcess
        The optional startup script for the endpoint.

    .PARAMETER SessionType
        The optional session type for the endpoint.

    .PARAMETER MountUserDrive
        The optional switch to enable mounting of a restricted user drive.

    .PARAMETER UserDriveMaximumSize
        The optional size of the user drive. The default is 50MB.

    .PARAMETER RequiredGroups
        The optional expression declaring which domain groups (for example,
        two-factor authenticated users) connected users must be members of. This
        should be a string that represents the Hashtable used for the RequiredGroups
        property in `New-PSSessionConfigurationFile`, such as:
        ```
        RequiredGroups = '@{ And = "RequiredGroup1", @{ Or = "OptionalGroup1", "OptionalGroup2" } }'
        ```

    .PARAMETER ModulesToImport
        The optional modules to import when applied to a session. This should be
        a string that represents a string, a Hashtable, or array of strings and/or
        Hashtables.
        ```
        ModulesToImport = "'MyCustomModule', @{ ModuleName = 'MyCustomModule'; ModuleVersion = '1.0.0.0'; GUID = '4d30d5f0-cb16-4898-812d-f20a6c596bdf' }"
        ```

    .PARAMETER VisibleAliases
        The optional aliases to make visible when applied to a session.

    .PARAMETER VisibleCmdlets
        The optional cmdlets to make visible when applied to a session. This should
        be a string that represents a string, a Hashtable, or array of strings and/or
        Hashtables.
        ```
        VisibleCmdlets = "'Invoke-Cmdlet1', @{ Name = 'Invoke-Cmdlet2'; Parameters = @{ Name = 'Parameter1'; ValidateSet = 'Item1', 'Item2' }, @{ Name = 'Parameter2'; ValidatePattern = 'L*' } }"
        ```

    .PARAMETER VisibleFunctions
        The optional functions to make visible when applied to a session. This should
        be a string that represents a string, a Hashtable, or array of strings and/or
        Hashtables.
        ```
        VisibleFunctions = "'Invoke-Function1', @{ Name = 'Invoke-Function2'; Parameters = @{ Name = 'Parameter1'; ValidateSet = 'Item1', 'Item2' }, @{ Name = 'Parameter2'; ValidatePattern = 'L*' } }"
        ```

    .PARAMETER VisibleExternalCommands
        The optional external commands (scripts and applications) to make visible when applied to a session.

    .PARAMETER VisibleProviders
        The optional providers to make visible when applied to a session.

    .PARAMETER AliasDefinitions
        The optional aliases to be defined when applied to a session. This should be
        a string that represents a Hashtable or array of Hashtable.
        ```
        AliasDefinitions = "@{ Name = 'Alias1'; Value = 'Invoke-Alias1'}, @{ Name = 'Alias2'; Value = 'Invoke-Alias2'}"
        ```

    .PARAMETER FunctionDefinitions
        The optional functions to define when applied to a session. This should be
        a string that represents a Hashtable or array of Hashtable.
        ```
        FunctionDefinitions = "@{ Name = 'MyFunction'; ScriptBlock = { param($MyInput) $MyInput } }"
        ```

    .PARAMETER VariableDefinitions
        The optional variables to define when applied to a session. This should be
        a string that represents a Hashtable or array of Hashtable.
        ```
        VariableDefinitions = "@{ Name = 'Variable1'; Value = { 'Dynamic' + 'InitialValue' } }, @{ Name = 'Variable2'; Value = 'StaticInitialValue' }"
        ```

    .PARAMETER EnvironmentVariables
        The optional environment variables to define when applied to a session.
        This should be a string that represents a Hashtable.
        ```
        EnvironmentVariables = "@{ Variable1 = 'Value1'; Variable2 = 'Value2' }"
        ```

    .PARAMETER TypesToProcess
        The optional type files (.ps1xml) to load when applied to a session.

    .PARAMETER FormatsToProcess
        The optional format files (.ps1xml) to load when applied to a session.

    .PARAMETER AssembliesToLoad
        The optional assemblies to load when applied to a session.

    .PARAMETER LanguageMode
        The optional language mode to load. Can be `'NoLanguage'` (recommended),
        `'RestrictedLanguage'`, `'ConstrainedLanguage'`, or `'FullLanguage'` (Default).

    .PARAMETER ExecutionPolicy
        The optional ExecutionPolicy. Execution policy to apply when applied to a
        session. `'Unrestricted'`, `'RemoteSigned'`, `'AllSigned'`, `'Restricted'`,
        `'Default'`, `'Bypass'`, `'Undefined'`.

    .PARAMETER HungRegistrationTimeout
        The optional number of seconds to wait for registering the endpoint to complete.
        Use `0` for no timeout. Default value is `10`.

    .PARAMETER Reasons
        Contains the not compliant properties detected in Get() method.
#>

[DscResource()]
class JeaSessionConfiguration:SessionConfigurationUtility
{
    [DscProperty()]
    [Ensure] $Ensure = [Ensure]::Present

    [DscProperty(Key)]
    [string] $Name = 'Microsoft.PowerShell'

    [Dscproperty()]
    [string] $RoleDefinitions

    [DscProperty()]
    [nullable[bool]] $RunAsVirtualAccount

    [DscProperty()]
    [string[]] $RunAsVirtualAccountGroups

    [DscProperty()]
    [string] $GroupManagedServiceAccount

    [DscProperty()]
    [string] $TranscriptDirectory

    [DscProperty()]
    [string[]] $ScriptsToProcess

    [DscProperty()]
    [string] $SessionType

    [Dscproperty()]
    [bool] $MountUserDrive

    [Dscproperty()]
    [long] $UserDriveMaximumSize

    [Dscproperty()]
    [string[]] $RequiredGroups

    [Dscproperty()]
    [string[]] $ModulesToImport

    [Dscproperty()]
    [string[]] $VisibleAliases

    [Dscproperty()]
    [string[]] $VisibleCmdlets

    [Dscproperty()]
    [string[]] $VisibleFunctions

    [Dscproperty()]
    [string[]] $VisibleExternalCommands

    [Dscproperty()]
    [string[]] $VisibleProviders

    [Dscproperty()]
    [string[]] $AliasDefinitions

    [Dscproperty()]
    [string[]] $FunctionDefinitions

    [Dscproperty()]
    [string] $VariableDefinitions

    [Dscproperty()]
    [string] $EnvironmentVariables

    [Dscproperty()]
    [string[]] $TypesToProcess

    [Dscproperty()]
    [string[]] $FormatsToProcess

    [Dscproperty()]
    [string[]] $AssembliesToLoad

    ## Enables and disables the session configuration and determines whether it can be used for remote or local sessions on the computer.
    ## Values can be: Disabled, Local, Remote (Default)
    [Dscproperty()]
    [String] $AccessMode = 'Remote'

    ## The optional language mode to load
    ## Can be 'NoLanguage' (recommended), 'RestrictedLanguage', 'ConstrainedLanguage', or 'FullLanguage' (Default)
    [Dscproperty()]
    [string] $LanguageMode

    [Dscproperty()]
    [string] $ExecutionPolicy

    [Dscproperty()]
    [int] $HungRegistrationTimeout = 10

    [DscProperty(NotConfigurable)]
    [Reason[]]$Reasons

    [void] Set()
    {
        $ErrorActionPreference = 'Stop'

        $this.TestParameters()

        $psscPath = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName() + '.pssc')
        Write-Verbose -Message ($script:localizedDataSession.StoringPSSessionConfigurationFile -f $psscPath)
        $desiredState = Convert-ObjectToHashtable -Object $this
        $desiredState.Add('Path', $psscPath)

        if ($this.Ensure -eq [Ensure]::Present)
        {
            foreach ($parameter in $desiredState.Keys.Where( { $desiredState[$_] -match '@{' }))
            {
                $desiredState[$parameter] = Convert-StringToObject -InputString $desiredState[$parameter]
            }
        }

        Write-Verbose ("Set(): AccessMode: {0}" -f $this.AccessMode)

        ## Register the endpoint
        try
        {
            ## If we are replacing Microsoft.PowerShell, create a 'break the glass' endpoint
            if ($this.Name -eq 'Microsoft.PowerShell')
            {
                $breakTheGlassName = 'Microsoft.PowerShell.Restricted'
                if (-not ($this.GetPSSessionConfiguration($breakTheGlassName)))
                {
                    $this.RegisterPSSessionConfiguration($breakTheGlassName, $null, $this.HungRegistrationTimeout, $this.AccessMode)
                }
            }

            ## Remove the previous one, if any.
            if ($this.GetPSSessionConfiguration($this.Name))
            {
                $this.UnregisterPSSessionConfiguration($this.Name)
            }

            if ($this.Ensure -eq [Ensure]::Present)
            {
                ## Create the configuration file
                #New-PSSessionConfigurationFile @configurationFileArguments
                $desiredState = Sync-Parameter -Command (Get-Command -Name New-PSSessionConfigurationFile) -Parameters $desiredState
                New-PSSessionConfigurationFile @desiredState

                ## Register the configuration file
                $this.RegisterPSSessionConfiguration($this.Name, $psscPath, $this.HungRegistrationTimeout, $this.AccessMode)
            }
        }
        catch
        {
            Write-Error -ErrorRecord $_
        }
        finally
        {
            if (Test-Path $psscPath)
            {
                Remove-Item $psscPath
            }
        }
    }

    # Tests if the resource is in the desired state.
    [bool] Test()
    {
        $this.TestParameters()

        $currentState = Convert-ObjectToHashtable -Object $this.Get()
        $desiredState = Convert-ObjectToHashtable -Object $this

        # short-circuit if the resource is not present and is not supposed to be present
        if ($currentState.Ensure -ne $desiredState.Ensure)
        {
            Write-Verbose -Message ($script:localizedDataSession.FailureListKillWinRMProcess -f $currentState.Name,$desiredState.Ensure,$currentState.Ensure )
            return $false
        }
        if ($this.Ensure -eq [Ensure]::Absent)
        {
            if ($currentState.Ensure -eq [Ensure]::Absent)
            {
                return $true
            }

            Write-Verbose ($script:localizedDataSession.PSSessionConfigurationNamePresent -f $currentState.Name)
            return $false
        }

        # If the AccessMode is not within desired state.
        if ($currentState.AccessMode -ne $desiredState.AccessMode)
        {
            return $false
        }

        $cmdlet = Get-Command -Name New-PSSessionConfigurationFile
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

        $compare = Test-DscParameterState -CurrentValues $currentState -DesiredValues $desiredState -TurnOffTypeChecking -SortArrayValues -ReverseCheck

        return $compare
    }

    # Gets the resource's current state.
    [JeaSessionConfiguration] Get()
    {
        $currentState = New-Object JeaSessionConfiguration
        $CurrentState.Name = $this.Name
        $CurrentState.Ensure = [Ensure]::Present

        $sessionConfiguration = $this.GetPSSessionConfiguration($this.Name)

        #
        # Determine the AccessMode for the Session Configuration

        if ($sessionConfiguration.Enabled -eq $false)
        {
            # If the Session Configuration is Disabled, then it's disabled.
            $currentState.AccessMode = 'Disabled'
        }
        elseif (($sessionConfiguration.Permission -split ', ') -contains 'NT AUTHORITY\NETWORK AccessDenied')
        {
            # If the Session Configuration is Enabled and has a 'NT AUTHORITY\NETWORK AccessDenied' SDDL. Then it's local.
            $currentState.AccessMode = 'Local'
        }
        elseif ([String]::IsNullOrEmpty($sessionConfiguration.Permission))
        {
            # It's not configured
            $currentState.AccessMode = 'NotConfigured'
        }
        else
        {
            # If permissions are present then it's Remote.
            $currentState.AccessMode = 'Remote'
        }

        if (-not $sessionConfiguration -or -not $sessionConfiguration.ConfigFilePath)
        {
            $currentState.Ensure = [Ensure]::Absent
            if ($this.Ensure -eq [Ensure]::Present)
            {
                $currentState.Reasons = [Reason]@{
                    Code = '{0}:{0}:Ensure' -f $this.GetType()
                    Phrase = $script:localizedDataSession.ReasonEpSessionNotFound -f $this.Name
                }
            }

            return $currentState
        }

        $configFile = Import-PowerShellDataFile $sessionConfiguration.ConfigFilePath

        'Copyright', 'GUID', 'Author', 'CompanyName', 'SchemaVersion' | Foreach-Object {
            $configFile.Remove($_)
        }

        foreach ($property in $configFile.Keys)
        {
            $propertyType = ($this | Get-Member -Name $property -MemberType Property).Definition.Split(' ')[0]
            $currentState.$property = foreach ($propertyValue in $configFile[$property])
            {
                if ($propertyValue -is [hashtable] -and $propertyType -ne 'hashtable')
                {
                    if ($propertyValue.ScriptBlock -is [scriptblock])
                    {
                        $code = $propertyValue.ScriptBlock.Ast.Extent.Text
                        $code -match '(?<=\{\{)(?<Code>((.|\s)*))(?=\}\})' | Out-Null
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

        #
        # PSSessionConfigurationFile Processing

        # Compare current and desired state to add reasons
        $valuesToCheck = $this.psobject.Properties.Name.Where({$_ -notin 'Name','Reasons'})

        $compareState = Compare-DscParameterState `
            -CurrentValues ($currentState | Convert-ObjectToHashtable) `
            -DesiredValues ($this | Convert-ObjectToHashtable) `
            -ValuesToCheck $valuesToCheck | Where-Object {$_.InDesiredState -eq $false }

        $currentState.Reasons = switch ($compareState)
        {
            {$_.Property -eq 'Ensure'}{
                [Reason]@{
                    Code = '{0}:{0}:{1}' -f $this.GetType(),$_.Property
                    Phrase = $script:localizedDataSession.ReasonEnsure -f $this.Path
                }
                continue
            }
            {$_.Property -eq 'Description'}{
                [Reason]@{
                    Code = '{0}:{0}:{1}' -f $this.GetType(),$_.Property
                    Phrase = $script:localizedDataSession.ReasonDescription -f $this.Description
                }
                continue
            }
            default {
                [Reason]@{
                    Code = '{0}:{0}:{1}' -f $this.GetType(),$_.Property
                    Phrase = $script:localizedDataSession."Reason$($_.Property)"
                }
            }
        }

        return $currentState

    }
}
