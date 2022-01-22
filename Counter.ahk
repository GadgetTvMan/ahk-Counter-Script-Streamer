;Ignore The 3 following lines
#Persistent
#InstallKeybdHook
#SingleInstance force

;Created by github.com/GadgetTvMan

Gosub, StartUpStuffs
;Turns those ugly 0's into Nothing! (When enabled)
;Settings are: 1 = on, 0 = off
IniRead, DisableZeros, %iniLocation%, Settings, DisableZeros

;List of all supported buttons:
;   http://www.autohotkey.com/docs/KeyList.htm
;Configure button used to Increment counter. Default F12
IncreaseCounterButton = %IncButton%
;Configure button used to Decrement counter. Default F11
DecreaseCounterButton = %DecButton%
;Configure button used to Reset counter. Default F10
ResetCounterButton = %RCButton%

;------------------------------------------------------------CODE----------------------------------------------------------------
;When you press the button assigned to "IncreaseCounterButton" it will increment and update the death counter in the .txt
;See "IncreaseCounter" for code
   Hotkey, %IncreaseCounterButton%, IncreaseCounter

;When you press the button assigned to "DecreaseCounterButton" it will decrement and update the death counter in the .txt
   Hotkey, %DecreaseCounterButton%, DecreaseCounter
 
;When you press the button assigned to "ResetCounterButton" it will set to null/zero and update the death counter in the .txt
   Hotkey, %ResetCounterButton%, ResetCounter
goto, MoreStartUpStuff
  IncreaseCounter:
        if PopUpIsUp = 0
        {
        ;Creates txt file if it doesn't exist.
        IfNotExist, %filePath%
            Gosub, CreateFile
        ;Created a file.
        ;Inputs number of deaths in counterVar variable.
        if counterVar =
            counterVar = 0
        counterVar := ++counterVar
        Gosub, UpdateTxt
        }
    return
   
    DecreaseCounter:
        if PopUpIsUp = 0
       {
        ;Creates txt file if it doesn't exist.
        IfNotExist, %filePath%
            Gosub, CreateFile
        ;Created a file.
        ;Inputs number of deaths in counterVar variable.
        
        if (counterVar = 0 and DisableZeros = 0)
        return

        if (counterVar = 1 and DisableZeros = 1)
            counterVar =
        counterVar := --counterVar
        Gosub, UpdateTxt
        }
    return

    ResetCounter:
        if PopUpIsUp = 0
        {
        ;Creates txt file if it doesn't exist.
        IfNotExist, %filePath%
            FileAppend,0, %filePath%
        ;Created a file.
        ;Inputs number of deaths in counterVar variable.
        FileReadLine, counterVar, %filePath%, 1
        if DisableZeros = 1
            counterVar =
        else
            counterVar = 0
        Gosub, UpdateTxt
        }
    return
    
    UpdateTxt:
        Gosub, CreateFile
        IniWrite,%counterVar%, %iniLocation%, Counter, count
    return

    CreateFile:
        if (counterVar = 0 and DisableZeros = 1)
            counterVar =
        FileDelete, %filePath%
        if (Prefix != "" and Prefix != " ")
            FileAppend,%Prefix% %counterVar%, %filePath%
        else
            FileAppend,%counterVar%, %filePath%
    return

    MoreStartUpStuff:
        PopUpIsUp = 0
    return

;Label made to configure some stuff at startup. called at the beginning of the file with "Gosub, <label>"
StartUpStuffs:
    ;Sets the variable "iniLocation" to the Settings.ini.
    iniLocation = %A_ScriptDir%\Settings.ini

    ;Checks if the Settings.ini file exists. if it doesnt, it creates and sets the default keys.
    Gosub, InitializeINI
    
    Gosub, ReadKeys
    Gosub, SetFilePath
    
    if PopUp = 1
        Gosub, RenderGUI
    else
        Gosub, CreateFile

return
SetFilePath:
    filePath := fileLocation . fileName
    return
InitializeINI:
    IfNotExist, %iniLocation%
    {
        IniWrite, F12,  %iniLocation%, Controls, Incrementkey
        IniWrite, F11,  %iniLocation%, Controls, Decrementkey
        IniWrite, F10,  %iniLocation%, Controls, ResetKey
        IniWrite, 1, %iniLocation%, Settings, DisableZeros
        IniWrite, 1, %iniLocation%, Settings, ConfigurationPopupOnStart
        IniWrite, "", %iniLocation%, Settings, fileLocation
        IniWrite, Counter.txt, %iniLocation%, Settings, fileName
        IniWrite, 0, %iniLocation%, Counter, count
        IniWrite, "", %iniLocation%, Counter, prefix
    }
    return
WriteKeys:
    IniWrite, %IncButton%,  %iniLocation%, Controls, Incrementkey
    IniWrite, %DecButton%,  %iniLocation%, Controls, Decrementkey
    IniWrite, %RCButton%,  %iniLocation%, Controls, ResetKey
    iniWrite, %DisableZeros%, %iniLocation%, Settings, DisableZeros
    IniWrite, %fileLocation%, %iniLocation%, Settings, fileLocation
    IniWrite, %fileName%, %iniLocation%, Settings, fileName
    IniWrite, %counterVar%, %iniLocation%, Counter, count
    IniWrite, %Prefix%, %iniLocation%, Counter, prefix
    return
ReadKeys:
    IniRead, IncButton, %iniLocation%, Controls, IncrementKey
    IniRead, DecButton, %iniLocation%, Controls, DecrementKey
    IniRead, RCButton, %iniLocation%, Controls, ResetKey
    IniRead, PopUp, %iniLocation%, Settings, ConfigurationPopupOnStart
    IniRead, DisableZeros, %iniLocation%, Settings, DisableZeros
    IniRead, fileLocation, %iniLocation%, Settings, fileLocation
    IniRead, fileName, %iniLocation%, Settings, fileName
    IniRead, counterVar, %iniLocation%, Counter, count
    IniRead, Prefix, %iniLocation%, Counter, prefix
    return
Write-ReadKeys:
    Gosub, WriteKeys
    Gosub, ReadKeys
    Gosub, CreateFile
    return

RenderGUI:
    PopUpIsUp = 1
    MsgBox, 4, Counter Script, Would you like to configure the hotkeys?
    IfMsgBox No
    {
        MsgBox, 4, Counter Script, Would you like to see these PopUp on next start up? `nDont worry, you can renable this popup in the settings.ini
        IfMsgBox No
            IniWrite, 0, %iniLocation%, Settings, ConfigurationPopupOnStart
        GoSub, Write-ReadKeys
        ;PopUpIsUp = 0
        return
    }
    IfMsgBox Yes
    {
        zeroChooseIndex := DisableZeros + 1
        Gui, Add, Text,, Increment Key:
        Gui, Add, Text,, Decrement Key:
        Gui, Add, Text,, Reset Counter Key:
        Gui, Add, Text,, Prefix For Count:
        Gui, Add, Text,, File Location:
        Gui, Add, Text,, File Name:
        Gui, Add, Text,, File Name:
        Gui, Add, Text,, Enable(1)/Disable(0) Zeros:
        Gui, Add, DropDownList,Choose%zeroChooseIndex% vDisableZeros xs, 0|1
        Gui, Add, Edit, W80 ym vIncButton, %IncButton% ; The ym option starts a new column of controls.
        Gui, Add, Edit, W80 vDecButton, %DecButton%
        Gui, Add, Edit, W80 vRCButton, %RCButton%
        Gui, Add, Edit, r1 W80 vPrefix, %Prefix%
        Gui, Add, Edit, W125 vFileLocation, %FileLocation%
        FileLocation_TT := "Leave blank to use script directory"
        Gui, Add, Edit, W80 vFileName, %FileName%
        Gui, Add, Button,, List of Supported keys
        Gui, Add, Button, default W100 xm, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
        Gui, Show, W290, Configuration GUI
        OnMessage(0x200, "WM_MOUSEMOVE")
        
        return
        GuiClose:
            if A_GuiEvent = Normal
                Gui Destroy
                PopUpIsUp = 0
            return
        ButtonOK:
            Gui, Submit  ; Save the input from the user to each control's associated variable.
            MsgBox, 4, Counter Script, Would you like to see this PopUp on next start up? `nDont worry, you can renable this popup in the settings.ini
            IfMsgBox No
                IniWrite, 0, %iniLocation%, Settings, ConfigurationPopupOnStart
            GoSub, Write-ReadKeys
            Gosub, SetFilePath
            PopUpIsUp = 0
            return
        
        ButtonListofSupportedKeys:
        if A_GuiEvent = Normal
            run http://www.autohotkey.com/docs/KeyList.htm
        return
        
        WM_MOUSEMOVE()
        {
            static CurrControl, PrevControl, _TT
            CurrControl := A_GuiControl
            If (CurrControl <> PrevControl){
                    SetTimer, DisplayToolTip, -300 	; shorter wait, shows the tooltip quicker
                    PrevControl := CurrControl
            }
            return
            
            DisplayToolTip:
            try
                    ToolTip % %CurrControl%_TT
            catch
                    ToolTip
            SetTimer, RemoveToolTip, -2000
            return
            
            RemoveToolTip:
            ToolTip
            return
        }
    }
return
