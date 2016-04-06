#cs ----------------------------------------------------------------------------
 Author:Drew Royster

 Script Function:
	Toggle list of commonly typed items.  Clicking on button copies to clipboard

#ce ----------------------------------------------------------------------------
;
#include <INet.au3>
#include <Misc.au3>
#include <GuiButton.au3>
#include <GuiToolBar.au3>
#include <GUIConstantsEx.au3>
#include <WinAPI.au3>
#include <File.au3>
#include <ButtonConstants.au3>
#include <WindowsConstants.au3>

;NOTE:change to work dynamically with different resolutions
Global $HEIGHT = 332
Global $WIDTH = 117
Global $BUTTON_SPACER = 32
Global $BUTTON_HEIGHT = 25
Global $BUTTON_WIDTH = 99
Global $FULLDESKTOPWIDTH = _WinAPI_GetSystemMetrics(78)
HotKeySet("{END}", "END")
HotKeySet("{INS}","Index")
Global $MARGIN = 8
Global $Active = WinGetTitle("")

;get mouse position
$pos = MouseGetPos()


;if text is highlighted will add to file
;InitAdd()

;check if file exists creates file if one doesn't exist
If FileExists(@ScriptDir & "/index.txt")=0 Then
   _FileCreate(@ScriptDir & "/index.txt")
EndIf

   ;reads data to file
   ReadFile()

   ;parse data
   Parse()

   ;create initial gui
   CreateGui()

;loop until button pressed
While 1
   If WinActive("ScriptRunner") = 0 Then ExitLoop
   $msg = GUIGetMsg()
   $leftClick = False
   Switch $msg
	  Case $BUTTON[0] To $BUTTON[$SIZE-1]
		 GUIDelete($popUp)
		 WinActivate($Active)
		 Run($DATA[$msg-3])
		 ExitLoop
	  Case $BUTTON[$FULL_SIZE-1]
		 GUICtrlSetData($BUTTON[$FULL_SIZE-1], "DONE")
		 While 1
			$msg = GUIGetMsg()
			Switch $msg
			Case $BUTTON[0] To $BUTTON[$SIZE-1]
			   _ArrayDelete($FULL, $msg-3)
			   GUICtrlSetData($BUTTON[$msg-3], "DELETED")
			Case $BUTTON[$FULL_SIZE-1]
			   GUIDelete()
			   SyncFile()
			   Parse()
			   CreateGui()
			   ExitLoop
			EndSwitch
		 WEnd
	  Case $BUTTON[$FULL_SIZE-2]
			   ;do nothing for now add button
			   GUIDelete()
			   $name = InputBox("Name", "Enter name", "Name of popup button", "", 220, 120,GuiInputXPos()-110)
			   $data = InputBox("Data", "Enter data", "Progam to run", "", 220, 120,GuiInputXPos()-110)
			   If ValidateInput($name) Or ValidateInput($data) Then
				  $full_string = $name & "`" & $data
				  _ArrayAdd($FULL, $full_string)
				  SyncFile()
				  Parse()
				  CreateGui()
			   Else
				  CreateGui()
			   EndIf
	  Case $GUI_EVENT_CLOSE
		 ExitLoop
	  EndSwitch
WEnd
Exit

Func SyncFile()
   FileDelete(@ScriptDir & "\index.txt")
   _FileCreate(@ScriptDir & "\index.txt")
   _FileWriteFromArray(@ScriptDir & "\index.txt", $FULL)
   $SIZE = UBound($FULL)
   If $SIZE<1 Then
	  $name = InputBox("Name", "Enter name", "Name of popup button", "", 220, 120, GuiInputXPos()-110)
	  $data = InputBox("Data", "Enter data", "Program to run", "", 220, 120,GuiInputXPos()-110)
	  If ValidateInput($name) And ValidateInput($data) Then
		 $full_string = $name & "`" & $data
		 Global $FULL[1]
		 $FULL[0]=$full_string
		 $SIZE=$SIZE+1
	  Else
		 MsgBox(1,"test","test")
		 Exit
	  EndIf
   EndIf
   $FULL_SIZE = $SIZE+2

EndFunc


;deletes gui and closes script
Func End()
   GUIDelete($popUp)
   Exit
EndFunc

Func Index()
   GUIDelete($popUp)
   Run("notepad index.txt", @ScriptDir)
   Exit
EndFunc

;sets gui x position to prevent gui appearing off the screen
Func GuiXPos()
   If $pos[0] <= ($GWidth/2) Then
	  Return 0
   ElseIf $pos[0] >= ($FULLDESKTOPWIDTH-($GWidth/2)) Then
	  Return ($FULLDESKTOPWIDTH-$GWidth)
   Else
	  Return $pos[0] - ($GWidth/2)
   EndIf
EndFunc

;sets gui y position to prevent gui appearing off the screen
Func GuiYPos()
   If $pos[1] <= ($HEIGHT/2) Then
	  Return 0
   ElseIf $pos[1] >= (@DesktopHeight-($HEIGHT/2)) Then
	  Return (@DesktopHeight-$HEIGHT)
   Else
	  Return ($pos[1]-($HEIGHT/2))
   EndIf
EndFunc

;determines which monitor to display input box On
Func GuiInputXPos()
   If $pos[0] > @DesktopWidth Then
	  Return $FULLDESKTOPWIDTH-(@DesktopWidth/2)
   Else
	  Return (@DesktopWidth/2)
   EndIf
EndFunc

;parses the data
Func Parse()
   Global $BUTTON_NAME[$SIZE]
   _ArrayAdd($BUTTON_NAME,"ADD")
   _ArrayAdd($BUTTON_NAME,"DELETE")
   Global $DATA[$SIZE]
   Local $i = 0
   Do
	  $tmp = StringSplit($FULL[$i],"`")
	  If @error = 1 Then MsgBox(1, "error", "Use (`) as delimeter to separate name from value" & @LF &  "No empty lines allowed")
	  $BUTTON_NAME[$i] = $tmp[1]
	  $DATA[$i] = $tmp[2]
	  $i = ($i+1)
   Until $i>($SIZE-1)

EndFunc

;determine gui width
Func GWidth()
   Select
	  Case $SIZE<=8
		 Return $WIDTH
	  Case $SIZE<=18
		 Return $WIDTH*2
	  Case $SIZE<=28
		 Return $WIDTH*3
	  Case $SIZE<=38
		 Return $WIDTH*4
   EndSelect
EndFunc

;determine gui height
Func GHeight()
   If $SIZE<=8 Then
	  Return ((($FULL_SIZE)*$BUTTON_SPACER)+$MARGIN)
   Else
	  Return $HEIGHT
   EndIf
EndFunc


;reads file and declares $SIZE and $FULL_SIZE
Func ReadFile()
   Global $FULL = FileReadToArray(@ScriptDir &"\index.txt")
   If @error Then
		 $name = InputBox("Name", "Enter name", "Name of popup button", "", 220, 120, GuiInputXPos()-110)
		 $data = InputBox("Data", "Enter data", "Value behind popup button", "", 220, 120,GuiInputXPos()-110)
		 If ValidateInput($name) And ValidateInput($data) Then
			$full_string = $name & "`" & $data
			Global $FULL[1]
			$FULL[0]=$full_string
			_FileWriteFromArray(@ScriptDir & "\index.txt", $FULL)
		 Else
			Exit
		 EndIf
   EndIf
   ;data size
   Global $SIZE = UBound($FULL)
   Global $FULL_SIZE = $SIZE+2

EndFunc

;checks if data from input box is valid
Func ValidateInput($string)
   If StringCompare($string, "Name of popup button") = 0 Or StringCompare($string, "Value behind popup button") = 0 Or StringCompare($string, "") = 0 Then
	  Return False
   Else
	  Return True
   EndIf
EndFunc

#cs
*This function will create a gui depending on the size of the array adding the delete and add buttons to the end of it
#ce
Func CreateGui()

;call GWidth func to get the gui's width
Global $GWidth = GWidth()
Global $GHeight = GHeight()

Select
;Create GUi
   Case $FULL_SIZE<=10
	  $spacer = $MARGIN
	  Global $popUp = GUICreate("ScriptRunner", $GWidth, $GHeight, GuiXPos(), GuiYPos(), $WS_POPUP, $WS_EX_TOPMOST)
	  ;array of buttons
	  Global $BUTTON[$FULL_SIZE]
	  ;loop to place and name buttons
	  For $i = 0 to ($FULL_SIZE-1)
		 $BUTTON[$i] = GUICtrlCreateButton($BUTTON_NAME[$i], $MARGIN, $spacer, $BUTTON_WIDTH, $BUTTON_HEIGHT)
		 $spacer = $spacer + $BUTTON_SPACER
		 GUICtrlSetFont($BUTTON[$i], 11, 700, "Aharoni")
	  Next

   ;handles up to 18 values
	  Case $FULL_SIZE <= 20
		 Global $popUp = GUICreate("ScriptRunner", $GWidth, $GHeight, GuiXPos(), GuiYPos(), $WS_POPUP, $WS_EX_TOPMOST)
		 $spacer = 8
		 ;array of buttons
		 Global $BUTTON[$FULL_SIZE]
		 ;loop to place and name buttons
		 For $i = 0 to 9
			$BUTTON[$i] = GUICtrlCreateButton($BUTTON_NAME[$i], $MARGIN, $spacer, $BUTTON_WIDTH, $BUTTON_HEIGHT)
			$spacer = $spacer+32
			GUICtrlSetFont($BUTTON[$i], 11, 700, "Aharoni")
		 Next
		 $spacer = 8
		 For $i = 10 to ($FULL_SIZE-1)
			$BUTTON[$i] = GUICtrlCreateButton($BUTTON_NAME[$i], ($MARGIN+$WIDTH), $spacer, $BUTTON_WIDTH, $BUTTON_HEIGHT)
			$spacer = $spacer + $BUTTON_SPACER
			GUICtrlSetFont($BUTTON[$i], 11, 700, "Aharoni")
		 Next

	  ;handles up to 28 values
	  Case $FULL_SIZE <= 30
		 Global $popUp = GUICreate("ScriptRunner", $GWidth, $GHeight, GuiXPos(), GuiYPos(), $WS_POPUP, $WS_EX_TOPMOST)
		 $spacer = 8
		 ;array of buttons
		 Global $BUTTON[$FULL_SIZE]
		 ;loop to place and name buttons
		 For $i = 0 to 9
			$BUTTON[$i] = GUICtrlCreateButton($BUTTON_NAME[$i], $MARGIN, $spacer, $BUTTON_WIDTH, $BUTTON_HEIGHT)
			$spacer = $spacer + $BUTTON_SPACER
			GUICtrlSetFont($BUTTON[$i], 11, 700, "Aharoni")
		 Next
		 $spacer = 8
		 For $i = 10 to 19
			$BUTTON[$i] = GUICtrlCreateButton($BUTTON_NAME[$i], ($MARGIN+$WIDTH), $spacer, $BUTTON_WIDTH, $BUTTON_HEIGHT)
			$spacer = $spacer + $BUTTON_SPACER
			GUICtrlSetFont($BUTTON[$i], 11, 700, "Aharoni")
		 Next
		 $spacer = 8
		 For $i = 20 to ($FULL_SIZE-1)
			$BUTTON[$i] = GUICtrlCreateButton($BUTTON_NAME[$i], ($MARGIN+($WIDTH*2)), $spacer, $BUTTON_WIDTH, $BUTTON_HEIGHT)
			$spacer = $spacer + $BUTTON_SPACER
			GUICtrlSetFont($BUTTON[$i], 11, 700, "Aharoni")
		 Next

   ;handles up to 38 values
	  Case $FULL_SIZE <= 40
		 Global $popUp = GUICreate("ScriptRunner", $GWidth, $GHeight, GuiXPos(), GuiYPos(), $WS_POPUP, $WS_EX_TOPMOST)
		 $spacer = 8
		 ;array of buttons
		 Global $BUTTON[$FULL_SIZE]
		 ;loop to place and name buttons
		 For $i = 0 to 9
			$BUTTON[$i] = GUICtrlCreateButton($BUTTON_NAME[$i], $MARGIN, $spacer, $BUTTON_WIDTH, $BUTTON_HEIGHT)
			$spacer = $spacer + $BUTTON_SPACER
			GUICtrlSetFont($BUTTON[$i], 11, 700, "Aharoni")
		 Next
		 $spacer = 8
		 For $i = 10 to 19
			$BUTTON[$i] = GUICtrlCreateButton($BUTTON_NAME[$i], ($MARGIN+$WIDTH), $spacer, $BUTTON_WIDTH, $BUTTON_HEIGHT)
			$spacer = $spacer + $BUTTON_SPACER
			GUICtrlSetFont($BUTTON[$i], 11, 700, "Aharoni")
		 Next
		 $spacer = 8
		 For $i = 20 to 29
			$BUTTON[$i] = GUICtrlCreateButton($BUTTON_NAME[$i], ($MARGIN+($WIDTH*2)), $spacer, $BUTTON_WIDTH, $BUTTON_HEIGHT)
			$spacer = $spacer + $BUTTON_SPACER
			GUICtrlSetFont($BUTTON[$i], 11, 700, "Aharoni")
		 Next
		 $spacer = 8
		 For $i = 30 to $FULL_SIZE-1
			$BUTTON[$i] = GUICtrlCreateButton($BUTTON_NAME[$i], ($MARGIN+($WIDTH*3)), $spacer, $BUTTON_WIDTH, $BUTTON_HEIGHT)
			$spacer = $spacer+ $BUTTON_SPACER
			GUICtrlSetFont($BUTTON[$i], 11, 700, "Aharoni")
		 Next

   ;tells user of error if more than 38 items are added
   Case Else
	  MsgBox(1,"Error","ScriptRunner only supports up to 38 items")
	  Exit
   EndSelect

;sets background color
GUISetBkColor(0x808080)

;Sets Add Button to
GUICtrlSetFont($BUTTON[$FULL_SIZE-2], 12, 700, "Aharoni")
GUICtrlSetColor($BUTTON[$FULL_SIZE-2], 0x228b22)
;Sets Delete Button Color to Red
GUICtrlSetFont($BUTTON[$FULL_SIZE-1], 12, 700, "Aharoni")
GUICtrlSetColor($BUTTON[$FULL_SIZE-1], 0xff0000)
;show gui
GUISetState(@SW_SHOWNORMAL, $popUp)

;set transparency
WinSetTrans($popUp, "", 200)

;rounds corners
;_GuiRoundCorners($popUp,0,0,20,20)

EndFunc

; Round corners function
Func _GuiRoundCorners($h_win, $i_x1, $i_y1, $i_x3, $i_y3); thanks gafrost
    Local $XS_pos, $XS_ret, $XS_ret2
    $XS_pos = WinGetPos($h_win)
    $XS_ret = DllCall("gdi32.dll", "long", "CreateRoundRectRgn", "long", $i_x1, "long", $i_y1, "long", $XS_pos[2], "long", $XS_pos[3], "long", $i_x3, "long", $i_y3)
    If $XS_ret[0]Then
        $XS_ret2 = DllCall("user32.dll", "long", "SetWindowRgn", "hwnd", $h_win, "long", $XS_ret[0], "int", 1)
    EndIf
EndFunc  ;==>_GuiRoundCorners
