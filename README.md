# win-ps-notifier

A simple PowerShell script to send a desktop notification bubble or popup in Windows

## Parameters

The script supports the following parameters:

`-Title`
Specify the title for the notification.

`-Body`
Specify the body for the notification.

`-NotificationType`
Specifies the type of notification. It can be either 'popup' or 'balloon'. The default is 'popup'.

`-IconType`
Specifies the icon to be shown in the notification. It can be either 'info', 'warning', 'error' or 'none'. The default is 'info'.

`-ShowCancel`
Specifies whether the notification should have a cancel button. The default is 'false'. *Notice: This only works with the 'popup' notification type.*

`-OpenUrlOnClose`
Specifies whether the script should open a specified URL when the notification is acknowledged. The default is 'false'.

`-TargetUrl`
Specifies the URL to be opened when the notification is closed. The default is 'https://github.com/merlinschumacher/win-ps-notifier'.

## Images

![A simple balloon notification](balloon.png?raw=true "A simple balloon notification")

![A popup notification with a cancel button](popup.png?raw=true "A simple balloon notification")

## Usage examples

```powershell
powershell.exe –noprofile -WindowStyle hidden -File "win-ps-notifier.ps1" -Title "This is a notification" -Body "Don't worry, be happy!" 
```

```powershell
PS> win-ps-notifier.ps1 -NotificationType balloon -IconType warning -Title "Title" -Message "Message"
```

```powershell
PS> win-ps-notifier.ps1 -IconType info -Title "Title" -Message "Message" -OpenUrlOnClose true -TargetUrl "http://merlinschumacher.de"
```
