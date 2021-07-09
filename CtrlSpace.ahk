; ---------------------------------------------------------------------------------
; CtrlSpace 3.7 - a simple hotstring manager, designed for an efficiency boost
; Author: Ricardo Aranguren
;
; To create or edit a hotstring: Type the trigger key anywhere and press ctrl+space
; To use a hotstring: Type the trigger key anywhere and hit space bar
; For hotstrings containing keys, type the main key, hit enter, and then ctrl+space
;
; Changelog:
; 3.7 - disabled for Android Studio 64 bit
; 3.6 - disabled for NetBeans to allow auto completion with ctrl+space
; 3.5 - improved inline tooltip text
; 3.4 - now it works in Jabber
;
; ---------------------------------------------------------------------------------

#SingleInstance Force
#NoEnv
#Hotstring EndChars  `t
ListLines Off
SendMode Input
Menu, Tray, Icon, shell32.dll, 134
SetWorkingDir %A_ScriptDir%  	; Ensures a consistent starting directory.

GroupAdd INCOMPATIBLE, ahk_exe netbeans64.exe
GroupAdd INCOMPATIBLE, ahk_exe netbeans.exe
GroupAdd INCOMPATIBLE, ahk_exe studio64.exe

FileGetSize, fileSize, CtrlSpace_hotstrings.ahk, K
if (fileSize>1020) {
	TrayTip, CtrlSpace, The hotstrings file size is %fileSize% Kb and the maximum size is 1024 Kb. Consider deleting some of the hotstrings by leaving them empty in the editor.
}
Fileread, CtrlSpace_hotstrings, CtrlSpace_hotstrings.ahk	;preloads the entire file as a global variable

pos = 1
HotstringsCount = 0
While pos := RegExMatch(CtrlSpace_hotstrings,"::\K.+(?=::)",m,pos+strlen(m))
{
   trackHotstrings .= m "`n"
   HotstringsCount++
}

SetTimer, TipUpdater, 300
SetTimer, DeadMan, 5000

trackKeys = 0123456789abcdefghijklmnopqrstuvwxyz,.
Loop
{
	input k, L1 I V, {BackSpace}{Space}{Esc}
	if ErrorLevel = EndKey:BackSpace
		StringTrimRight, trackWord, trackWord, 1
	else if ErrorLevel = EndKey:Space
		trackWord =
	else IfInString, trackKeys, %k%
		trackWord .= k
	else
		trackWord =
}

TipUpdater:
	if strLen(trackWord)<3
		tooltip
	else if not trackWord = prevTrackWord
	{
		idleTip = 0
		trackTip =
		if not RegExMatch( SubStr(trackWord, 1, 1), "[\.,\d]")
			return
		b := SubStr(trackWord, 2)
		r = im)[\.,\d]\w*%b%\w*

		matchCount = 0
		pos = 1
		while pos := RegExMatch(trackHotstrings,r,m,pos+strlen(m))
			if InStr(m,trackWord)
			{
				trackTip .= m "`n"
				matchCount++
			}
			else
				trackTip .= "~ " m "`n"
		if trackTip  .test
			tooltip, Macros with "%trackWord%" (%matchCount%/%HotstringsCount%):`n%trackTip%, A_CaretX-(StrLen(trackWord)*8)-5, A_CaretY+18
		else
			tooltip
		prevTrackWord = %trackWord%
	}
	else
		if ++idleTip >10
		  tooltip
return

DeadMan:
	IniWrite, %A_TickCount%, CtrlSpace.ini, DeadMan, ticks
return


#ifwinnotactive ahk_group INCOMPATIBLE

^Space:: 	; When ctrl+space is pressed, cut last word typed, and input for a macro creation, then save + reload
if GuiOpen
	gosub GuiSubmit
else
{
	prevClipboard = %clipboard% 	;cut last word typed, keeping clipboard contents intact
	clipboard =
	sendinput +^{left}^c
	ClipWait
	macroKey = %clipboard%
	if RegExMatch( macroKey, "^\w+$") 	;if the word doesn't start with any symbol, for example "hello"
	{
		clipboard =
		sendinput +{left}^c 	;copy another character to the left, for example ".hello"
		ClipWait
		clipboard = %clipboard% ;trim
		if RegExMatch( clipboard, "^[,\.]\w+$") ;if it looks more like a macro now, for example ".hello"
			macroKey = %clipboard%
		else if RegExMatch( clipboard, "^[,\.]$") ; if we only copied one character, for example "."
			macroKey = %clipboard%%macroKey%
		else if clipboard <> %macroKey% ;else if we went a line above or an space to the left, select less
			sendinput +{right}
	}
	clipboard  = %prevClipboard%

	if RegExMatch( macroKey, "^[\w,\.]\w+$")	;if the word cut looks like a hotstring
	{
		r = im)^::%macroKey%::(.*)$
		StringReplace r, r, ::., ::\.
		macroExists := RegExMatch( CtrlSpace_hotstrings, r, x )	; looks for the key in preloaded file contents
		macroText := x1
		gosub GuiEditorCreate	; variables macroKey and macroText are global
	}
	else if RegExMatch( macroKey, "^\s+$") ;if user pressed enter, then ctrl+space, only a newline character gets copied
	{
		clipboard =
		sendinput ^a ;selects all and copies the current box text in %allText%
		sleep 500 ;(not sure why ^a^c didnt work and copied nothing. Should try another send method in the future)
		sendinput ^c
		ClipWait
		allText := RegExReplace( Clipboard, "\r\n?|\n\r?", "`n") ;converts carriage returns for the sendinput that will come
		Clipboard  = %prevClipboard%

		While RegExMatch( allText, "\s?([\d,\.]\w+)\s?", k) ;searches the text for hotstrings alone in a line
		{
			r = im)^::%k1%::(.*)$
			StringReplace r, r, ::., ::\.
			RegExMatch( CtrlSpace_hotstrings, r, x )	;looks for the key in preloaded file contents
			StringReplace allText, allText, %k1%, %x1%
		}
		sendinput %allText% 	;and posts the result
	}
	else
	{
		SendInput %macroKey% ;if the copied text is useless, type it back (could just send a ctrl+right to deselect if this causes trouble)
	}
}
return

GuiEditorCreate:
	prevWin := WinExist("A")	; remembers the window

	Stringreplace, macroText, macroText, {enter 2}, `n`n, All	;converts {enter} codes for a wysiwyg experience
	StringReplace, macroText, macroText, {enter}, `n, All
	StringReplace, macroText, macroText, {tab}, `t, All
	StringReplace, macroText, macroText, {!}, !, All
	StringReplace, macroText, macroText, {#}, #, All

	Gui, Font, S10
	Gui, Add, Edit, x12 y9 w440 h170 vmacroText WantReturn WantTab, %macroText%	;a window with an edit box
	Gui, Add, Button, x22 y189 w200 h30 gGuiSubmit, Save (Ctrl+Space)	;a submit button
	Gui, Add, Button, x242 y189 w200 h30 gGuiEscape, Cancel (Esc)	;and a cancel button
	Gui, -MinimizeBox -Resize AlwaysOnTop
	Gui, Show, , %macroKey%	;using the Key as the window title for now, cos I like it ok?
	GuiOpen = 1	;to submit the form, it uses ctrl+space, so it needs to keep track of whether the editor is open or not
	send {end}	;by default, the edit control has all text selected, this moves the cursor to the end
return

GuiEscape:
GuiClose:
	Gui, Destroy
	GuiOpen = 0
	currWin := WinExist("A")		;which window gets focus after closing the Gui?
	if currWin = %prevWin% 			;if still the same as before
		SendInput %macroKey%		;type the macro
return

GuiSubmit:
	Gui Submit
	GuiOpen = 0
	macroText:=RegExReplace(RegExReplace(macroText,"^\s*",""),"\s*$","")
	StringReplace, macroText, macroText, `r`n, {enter}, All
	StringReplace, macroText, macroText, `n, {enter}, All

	Stringreplace, macroText, macroText, {enter}{enter}, {enter 2}, All
	Stringreplace, macroText, macroText, !, {!}, All
	StringReplace, macroText, macroText, #, {#}, All

	currWin := WinExist("A")		;which window gets focus after closing this one?
	if currWin = %prevWin% 			;if still the same as before
		SendInput %macroText%		;type the macro

	if macroExists	;if the macro exists, the variable is updated and the file is re-created
	{
		if macroText
			StringReplace CtrlSpace_hotstrings, CtrlSpace_hotstrings, %x%, ::%macroKey%::%macroText%
		else
		{
			StringReplace CtrlSpace_hotstrings, CtrlSpace_hotstrings, %x%, ;delete hotstring if empty
			Sort CtrlSpace_hotstrings ,u	;deletes extra empty lines. Is fast because is already sorted
		}

		FileMove CtrlSpace_hotstrings.ahk, CtrlSpace_hotstrings.bak, 1
		if Errorlevel
		{
			MsgBox, 16,, ERROR: failed to create temporary file CtrlSpace_hotstrings.bak
			ExitApp
		}
		FileAppend %CtrlSpace_hotstrings%, CtrlSpace_hotstrings.ahk
		if Errorlevel
		{
			MsgBox, 16,, ERROR: failed append into CtrlSpace_hotstrings.ahk,
			ExitApp
		}
		FileDelete CtrlSpace_hotstrings.bak
	}
	else	;if the macro is new, it is just appended to the end of the text file
	{
		FileAppend ,`n::%macroKey%::%macroText%, CtrlSpace_hotstrings.ahk
		if Errorlevel
		{
			MsgBox, 16,, ERROR: failed append into CtrlSpace_hotstrings.ahk, check the permissions
			ExitApp
		}
	}
	Reload
return

#include *i CtrlSpace_hotstrings.ahk ; lets Autohotkey load all edited hotstrings
