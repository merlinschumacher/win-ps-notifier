<#PSScriptInfo

.VERSION 1.0

.GUID  25e79ef2-e08f-4396-b484-e5691545feab

.AUTHOR merlin.schumacher@gmail.com

.COPYRIGHT GPLv3 - Merlin Schumacher

.TAGS notification, windows, desktop-notifcation, pop-up, popup

.LICENSEURI https://raw.githubusercontent.com/merlinschumacher/win-ps-notifier/main/LICENSE

.PROJECTURI https://github.com/merlinschumacher/win-ps-notifier

#>

<#
.SYNOPSIS

Shows a notification on the screen.

.DESCRIPTION

Shows a notification on the screen. The notification can either be a popup message or a balloon notifcation.

.PARAMETER Title 
Specify the title for the notification.

.PARAMETER Body 

Specify the body for the notification.

.PARAMETER NotificationType

Specifies the type of notification. It can be either 'popup' or 'balloon'. The default is 'popup'.

.PARAMETER IconType 

Specifies the icon to be shown in the notification. It can be either 'info', 'warning', 'error' or 'none'. The default is 'info'.

.PARAMETER ShowCancel

Specifies whether the notification should have a cancel button. The default is 'false'. 
Notice: This only works with the 'popup' notification type.

.PARAMETER OpenUrlOnClose

Specifies whether the script should open a specified URL when the notification is acknowledged. The default is 'false'.

.PARAMETER TargetUrl 

Specifies the URL to be opened when the notification is closed. The default is 'https://github.com/merlinschumacher/win-ps-notifier'. 

.INPUTS

None.

.OUTPUTS

None.

.EXAMPLE

PS> win-ps-notifier.ps1 -NotificationType balloon -IconType info -Title "Title" -Message "Message"

.EXAMPLE

PS> win-ps-notifier.ps1 -IconType warning -Title "Title" -Message "Message" -OpenUrlOnClose true -TargetUrl "http://merlinschumacher.de"

.LINK

https://github.com/merlinschumacher/win-ps-notifier

#>

param (
    [Parameter()]
    [string]
    $Title = "This is a win-ps-notifier notification!",
    
    [Parameter()]
    [string]
    $Body = "This is the body of the notification.",
    
    [Parameter()]
    [ValidateSet('popup', 'balloon')]
    [string]
    $NotificationType = "popup",
    
    [Parameter()]
    [string]
    [ValidateSet('none', 'info', 'warning', 'error')]
    $IconType = "info",
    
    [Parameter()]
    [Switch]
    $ShowCancel = $false,
    
    [Parameter()]
    [Switch]
    $OpenUrlOnClose = $false,
    
    [Parameter()]
    [string]
    $TargetUrl = "https://github.com/merlinschumacher/win-ps-notifier"
)

# Load needed assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

function Show-Popup {
   
    # Decide which buttons to use in the notification
    if ($ShowCancel) {
        $PopupButtons = "OKCancel"
    } else {
        $PopupButtons = "OK"
    }
    
    # Show the notification
    $returnValue = [System.Windows.Forms.MessageBox]::Show($Body,$Title, $PopupButtons, $IconType)

    # If the user clicked the OK button open the URL. Otherwise exit.
    switch ( $returnValue) {
        OK {
            if ($OpenUrlOnClose) {
                Start-Process $TargetUrl 
            }
        }
        Default { exit }
    }

}
function Show-BalloonTip {

    # Remove all existing click events from the balloon tip. 
    Remove-Event BalloonClicked_event -ea SilentlyContinue
    Unregister-Event -SourceIdentifier BalloonClicked_event -ea silentlycontinue
    Remove-Event BalloonClosed_event -ea SilentlyContinue
    Unregister-Event -SourceIdentifier BalloonClosed_event -ea silentlycontinue

    # Register new global instance of balloon tip.
    $global:balloon = New-Object System.Windows.Forms.NotifyIcon
    # Get the path of the current process executable
    $path = (Get-Process -id $pid).Path
    # Set the top left icon of the balloon tip to the one of the executable
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
    # Set the main icon of the balloon tip to the one defined in the parameters
    $balloon.BalloonTipIcon = $IconType
    # Set the body of the balloon tip to the one defined in the parameters
    $balloon.BalloonTipText = $Body
    # Set the title of the balloon tip to the one defined in the parameters
    $balloon.BalloonTipTitle = $Title 
    # Set the balloon tip to be visible 
    $balloon.Visible = $true

    # Register the event that is fired when the balloon tip is clicked.
    # create an object to be passed to the event
    $data = new-object psobject -property @{openUrlOnClose = $OpenUrlOnClose; targetUrl = $TargetUrl }
    # Register the event
    Register-ObjectEvent $balloon BalloonTipClicked BalloonClicked_event -MessageData $data -Action {
        if ($event.MessageData.openUrlOnClose) {
            Start-Process $event.MessageData.targetUrl
        }
        $balloon.Visible = $false 
    } | Out-Null
    
    # Register the event that is fired when the balloon tip is closed via the X.
    register-objectevent $balloon BalloonTipClosed BalloonClosed_event -Action { 
        $balloon.Visible = $false 
        exit
    } | Out-Null

    # Show the balloon tip for the specified time 
    $balloon.ShowBalloonTip($TimeOut * 1000)
}

# Decide which notification to show
if ($NotificationType -eq "popup") {
    Show-Popup
}
else {
    Show-BalloonTip
}