get-variable | remove-variable -ea SilentlyContinue

#http://deploywindows.info/2015/02/24/build-complex-gui-with-your-powershell-scripts/

function Get-Folder(){

        Add-Type -AssemblyName System.Windows.Forms
        $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        [void]$FolderBrowser.ShowDialog()
        return $FolderBrowser.SelectedPath

}
function New-MessageBox(){

    Param (

        $message,
        $title,
        $icon,
        $buttons
    )

    $messageBox = [System.Windows.Forms.MessageBox]::Show($message , $title , $buttons, $icon)
    return $messageBox

}
function Close-OnClick(){

<#

    .SYNOPSIS

    Generates Closing Message Boxes - first confiming the close, second confirming you have chosen not to close.

    Icon Codes:

        Asterisk............The message box contains a symbol consisting of a lowercase letter i in a circle.
        Error...............The message box contains a symbol consisting of white X in a circle with a red background.
        Exclamation.........The message box contains a symbol consisting of an exclamation point in a triangle with a yellow background.
        Hand................The message box contains a symbol consisting of a white X in a circle with a red background.
        Information.........The message box contains a symbol consisting of a lowercase letter i in a circle.
        None................The message box contain no symbols.
        Question............The message box contains a symbol consisting of a question mark in a circle. The question-mark message icon
                            is no longer recommended because it does not clearly represent a specific type of message and because the
                            phrasing of a message as a question could apply to any message type. In addition, users can confuse the
                            message symbol question mark with Help information. Therefore, do not use this question mark message symbol
                            in your message boxes. The system continues to support its inclusion only for backward compatibility.
        Stop................The message box contains a symbol consisting of white X in a circle with a red background.
        Warning.............The message box contains a symbol consisting of an exclamation point in a triangle with a yellow background.


    Button Codes:

        AbortRetryIgnore....The message box contains Abort, Retry, and Ignore buttons.
        OK..................The message box contains an OK button.
        OKCancel............The message box contains OK and Cancel buttons.
        RetryCancel.........The message box contains Retry and Cancel buttons.
        YesNo...............The message box contains Yes and No buttons.
        YesNoCancel	........The message box contains Yes, No, and Cancel buttons.

#>


    Param (

        $parentObject,
        $message,
        $title,
        $icon,
        $buttons,
        $returnMessage,
        $returnTitle,
        $returnIcon,
        $returnButtons

    )

    $continueBox = New-MessageBox -message $message -title $title -icon $icon -buttons $buttons
    if($continueBox -eq "Yes"){
        $parentObject.Close()
    }
    else{
        New-MessageBox -message $returnMessage -title $returnTitle -icon $returnIcon -buttons $returnButtons
    }
}
function Configure-EmailSettings(){

    # Get the content from the XAML file
    $emailxaml = [XML](Get-Content “emailsettings.xaml”)

    # Create an object for the XML content
    $emailxamlReader = New-Object System.Xml.XmlNodeReader $emailxaml

    # Load the content so we can start to work with it
    $emailform = [Windows.Markup.XamlReader]::Load($emailxamlReader)
    $emailform.owner=$mainform

    $grid_LayoutRoot=$emailform.FindName('gr_Container')
    $tb_EMailServer=$emailform.FindName('tb_EMailServer')
    $lbl_EMailServerError=$emailform.FindName('lbl_EMailServerError')
    $tb_EMailPort=$emailform.FindName('tb_EMailPort')
    $lbl_EMailPortError=$emailform.FindName('lbl_EMailPortError')
    $tb_EMailUsername=$emailform.FindName('tb_EMailUsername')
    $lbl_EMailUsernameError=$emailform.FindName('lbl_EMailUsernameError')
    $pb_EMailPassword=$emailform.FindName('pb_EMailPassword')
    $lbl_EMailPasswordError=$emailform.FindName('lbl_EMailPasswordError')
    $tb_EMailFromAddress=$emailform.FindName('tb_EMailFromAddress')
    $lbl_EMailFromAddressError=$emailform.FindName('lbl_EMailFromAddressError')
    $tb_EMailToAddress=$emailform.FindName('tb_EMailToAddress')
    $lbl_EMailToAddressError=$emailform.FindName('lbl_EMailToAddressError')
    $btn_EmailSettings_Save=$emailform.FindName('btn_EmailSettings_Save')
    $btn_EmailSettings_Discard=$emailform.FindName('btn_EmailSettings_Discard')

    

    $btn_EmailSettings_Discard.add_click({Close-OnClick -parentObject $emailform -message "This will clear any settings you have already entered.  Continue?" -title "Discard Email Settings?" -icon "Warning" -buttons 4 -returnMessage "Click 'OK' to return to the Email Settings.  Nothing you have already entered has been cleared." -returnTitle "Returning to Email Settings." -returnIcon "Information" -returnButtons 0})
    $btn_EmailSettings_Save.add_click({

        $script:tb_EMailServer=$tb_EMailServer.text
        $script:tb_EMailPort=$tb_EMailPort
        $script:tb_EMailUsername=$tb_EMailUsername
        $script:pb_EMailPassword=$pb_EMailPassword
        $script:tb_EMailFromAddress=$tb_EMailFromAddress
        $script:tb_EMailToAddress=$tb_EMailToAddress

        $emailform.close()
    })

    $emailform.add_mouseleftbuttondown({$emailform.DragMove()})

    $emailform.ShowDialog()

    # E-Mail Settings Window Elements
    $script:lbl_EmailNotifyStatusUpdatedBlock=@"
E-Mail Server: $script:tb_EMailServer).tex
E-Mail Server Port: $script:tb_EMailPort.text
E-Mail Username: $script:tb_EMailUsername.text
E-Mail Password: **************
E-Mail From Address: $script:tb_EMailFromAddress.text
E-Mail To Address: $script:tb_EMailToAddress.text
"@

    $script:lbl_EmailNotifySettings.Content=$script:lbl_EmailNotifyStatusUpdatedBlock
    $script:lbl_EmailNotifyStatus.Content="E-Mail Notifications Configured!"
    $script:lbl_EmailNotifyStatus.Foreground="#FF09BF00"

}


# Initialize the Windows Presentation Framework
Add-Type -AssemblyName PresentationFramework

# Get the content from the XAML file
$xaml = [XML](Get-Content “xboxdownloads.xaml”)

# Create an object for the XML content
$xamlReader = New-Object System.Xml.XmlNodeReader $xaml

# Load the content so we can start to work with it
$mainform = [Windows.Markup.XamlReader]::Load($xamlReader)

#Put your code here
# Main Window Elements
$gr_Container=$mainform.FindName('gr_Container')
$lbl_ApiKey=$mainform.FindName('lbl_ApiKey')
$tb_ApiKey=$mainform.FindName('tb_ApiKey')
$lbl_SaveLocation=$mainform.FindName('lbl_SaveLocation')
$lbl_SaveLocationUpdate=$mainform.FindName('lbl_SaveLocationUpdate')
$btn_SaveLocationSearch=$mainform.FindName('btn_SaveLocationSearch')
$cb_XboxOneNotify=$mainform.FindName('cb_XboxOneNotify')
$cb_EmailNotify=$mainform.FindName('cb_EmailNotify')
$sp_EmailNotify=$mainform.FindName('sp_EmailNotify')
$gr_EmailNotify=$mainform.FindName('gr_EmailNotify')
$lbl_EmailNotifyStatus=$mainform.FindName('lbl_EmailNotifyStatus')
$btn_EmailNotifyConfigure=$mainform.FindName('btn_EmailNotifyConfigure')
$lbl_EmailNotifySettings=$mainform.FindName('lbl_EmailNotifySettings')
$btn_SaveSettings=$mainform.FindName('btn_SaveSettings')




# Main Window Actions

$tb_ApiKey.add_GotFocus({if($tb_ApiKey.Text -eq '' -or $tb_ApiKey.Text -eq 'Enter XBOXAPI.COM Key...'){$tb_ApiKey.Text='';$tb_ApiKey.Foreground="#000000"};})
$tb_ApiKey.add_LostFocus({if($tb_ApiKey.text -eq ''){$tb_ApiKey.Text='Enter XBOXAPI.COM Key...'};if($tb_ApiKey.Text -eq 'Enter XBOXAPI.COM Key...'){$tb_ApiKey.Foreground="#FF8B8B8B"}})

$saveLocation=$btn_SaveLocationSearch.Add_Click({

    Add-Type -AssemblyName System.Windows.Forms
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    [void]$FolderBrowser.ShowDialog()
    $selectedFolder=$FolderBrowser.SelectedPath
    if($selectedFolder -eq ''){
       $lbl_SaveLocationUpdate.content="Search for location..." 
       $lbl_SaveLocationUpdate.Foreground="#FF8B8B8B"
    }
    else{
        $lbl_SaveLocationUpdate.content=$selectedFolder
        $lbl_SaveLocationUpdate.Foreground="#000000"
    }

})

$lbl_EmailNotifyStatusDefaultBlock=@"
E-Mail Server:
E-Mail Server Port:
E-Mail Username:
E-Mail Password:
E-Mail From Address:
E-Mail To Address:
"@

$cb_EmailNotify.add_click({

    if($cb_EmailNotify.IsChecked -eq "True"){
        $sp_EmailNotify.Opacity=1
        $lbl_EmailNotifyStatus.Opacity=1
        $btn_EmailNotifyConfigure.IsEnabled="True"
    }
    else{
        $sp_EmailNotify.Opacity=.25
        $lbl_EmailNotifyStatus.Opacity=.5
        $btn_EmailNotifyConfigure.IsEnabled="False"
        $lbl_EmailNotifySettings.Content=$lbl_EmailNotifyStatusDefaultBlock
    }

})

$btn_EmailNotifyConfigure.add_click({Configure-EmailSettings})

# Show the form
$mainform.ShowDialog()