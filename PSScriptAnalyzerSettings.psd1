# https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/rules/readme?view=ps-modules
@{
    IncludeRules = @(
        'PSAlignAssignmentStatement',
        'PSAvoidAssignmentToAutomaticVariable',
        'PSAvoidDefaultValueForMandatoryParameter',
        'PSAvoidDefaultValueSwitchParameter',
        'PSAvoidGlobalVars',
        'PSAvoidGlobalFunctions',
        'PSAvoidLongLines',
        'PSAvoidMultipleTypeAttributes',
        'PSAvoidNullOrEmptyHelpMessageAttribute',
        'AvoidSemicolonsAsLineTerminators',
        'PSAvoidShouldContinueWithoutForce',
        'PSAvoidTrailingWhitespace',
        'PSAvoidUsingBrokenHashAlgorithms',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        'PSAvoidUsingDoubleQuotesForConstantString',
        'PSAvoidUsingEmptyCatchBlock',
        'PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingPositionalParameters',
        'PSAvoidUsingUsernameAndPasswordParams',
        'PSAvoidUsingWriteHost',
        'PSMisleadingBacktick',
        'PSPlaceOpenBrace',
        'PSPlaceCloseBrace',
        'PSPossibleIncorrectComparisonWithNull',
        'PSPossibleIncorrectUsageOfAssignmentOperator',
        'PSPossibleIncorrectUsageOfRedirectionOperator',
        'PSReservedCmdletChar',
        'PSReservedParams',
        'PSReviewUnusedParameter',
        'PSShouldProcess',
        'PSUseBOMForUnicodeEncodedFile',
        'PSUseCmdletCorrectly',
        'PSUseConsistentIndentation',
        'PSUseConsistentWhitespace',
        'PSUseCorrectCasing',
        'PSUseLiteralInitializerForHashtable',
        'PSUseOutputTypeCorrectly',
        'PSUseProcessBlockForPipelineCommand',
        'PSUsePSCredentialType',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSupportsShouldProcess',
        'PSUseSingleValueFromPipelineParameter',
        'PSUseSingularNouns',
        'PSUseUsingScopeModifierInNewRunspaces'
    )

    Rules        = @{
        PSAlignAssignmentStatement      = @{
            Enable                                  = $true
            AlignHashtableKvpWithInterveningComment = $false
            CheckEnum                               = $true
            AlignEnumMemberWithInterveningComment   = $false
            CheckHashtable                          = $true
        }

        PSAvoidLongLines                = @{
            Enable            = $true
            MaximumLineLength = 120
        }

        PSPlaceOpenBrace                = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace               = @{
            Enable             = $true
            NewLineAfter       = $false
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }

        PSUseCompatibleCmdlets          = @{
            compatibility = @('core-6.1.0-windows')
        }

        PSUseCompatibleSyntax           = @{
            Enable         = $true
            TargetVersions = @(
                '7.6',
                '6.0'
            )
        }

        PSUseConsistentIndentation      = @{
            Enable              = $true
            IndentationSize     = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind                = 'space'
        }

        PSUseConsistentParameterSetName = @{
            Enable = $true
        }

        PSUseConsistentWhitespace       = @{
            Enable                                  = $true
            CheckInnerBrace                         = $true
            CheckOpenBrace                          = $true
            CheckOpenParen                          = $true
            CheckOperator                           = $true
            CheckPipe                               = $true
            CheckPipeForRedundantWhitespace         = $true
            CheckSeparator                          = $true
            CheckParameter                          = $true
            IgnoreAssignmentOperatorInsideHashTable = $true
        }

        PSUseCorrectCasing              = @{
            Enable        = $true
            CheckCommands = $true
            CheckKeyword  = $true
            CheckOperator = $true
        }

        PSUseSingularNouns              = @{
            Enable        = $true
            NounAllowList = 'Data', 'Windows', 'Settings', 'Attributes'
        }
    }
}
