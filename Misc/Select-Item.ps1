using namespace System.Management.Automation.Host

<#
.SYNOPSIS
    Allows the user to select simple items. Returns either the value or index of the selected item.
.DESCRIPTION
    Produces a list on the screen with a caption followed by a message. The user can select one of the options.
    Note that help text is not supported in this version.
.NOTES
    Adapted from code in the links.
.PARAMETER TextChoices
    An array of strings. The hot key in each choice must be prefixed with an & sign.
.PARAMETER Default
    The zero based item in the array which will be the default choice if the user hits Enter.
    NOTE: If Default > N -1 (N = # of choices), then will default to N-1.
.PARAMETER Caption
    The First line of text displayed.
.PARAMETER Message
    The Second line of text displayed.
.PARAMETER ReturnKey
    If specified will return the value of the selected item. Else, will return index.
.EXAMPLE
    $params = @{
        TextChoices = "&Rock", "&Paper", "&Scissors"
        Message = "Choose Rock, Paper or Scissors"
        Caption = "Rock Paper Scissors"
    }
    Select-Item @params
.EXAMPLE
    @('A','B'), @(1..2) | Select-Item -Default 3
.EXAMPLE
    $choices = @{'Rock' ="&Rock"; 'Paper' = "&Paper"; 'Scissors' = '&Scissors'}
    Select-Item $choices -Caption 'Rock Paper Scissors' -ReturnKey
.LINK
    https://jamesone111.wordpress.com/2009/06/24/how-to-get-user-input-more-nicely-in-powershell/
    https://jamesone111.wordpress.com/2011/12/10/powershell-hashtables-splatting-nesting-driving-selections-and-generally-simplifying-life/
#>

function Select-Item {
    [CmdletBinding(DefaultParameterSetName = 'TextChoices')]
    param
    (
        [Parameter(ParameterSetName = 'TextChoices', Mandatory = $true, ValueFromPipeLine = $true)]
        [ValidateNotNull()]
        [String[]] $TextChoices,
        [Parameter(ParameterSetName = 'Hashtable', Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [hashtable] $ChoiceMap,
        [ValidateNotNullorEmpty()]
        [String] $Caption = 'Please make a selection',
        [ValidateNotNullorEmpty()]
        [String] $Message = 'Choices are presented below',
        [uint64] $Default = 0,
        [switch] $ReturnKey
    )

    begin {
        $choicedesc = [System.Collections.ObjectModel.Collection[ChoiceDescription]]::new()
        [bool] $useTextChoices = $PSCmdlet.ParameterSetName -eq 'TextChoices'
    }

    process {
        if ($useTextChoices) {
            foreach ($choice in $TextChoices) {
                $choicedesc.Add([ChoiceDescription]::new($choice))
            }
        } else {
            foreach ($key in $ChoiceMap.keys) {
                $choicedesc.Add([ChoiceDescription]::new($key, $ChoiceMap[$key]))
            }
        }
    }
    end {
        [int] $index = $Host.UI.PromptForChoice($Caption, $Message, $choicedesc,
            [Math]::Max( $Default, $choicedesc.Count - 1))
        if ($ReturnKey) { $choicedesc[$index].Label } else { $index }
    }
}
