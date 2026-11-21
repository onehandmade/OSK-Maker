#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; OSK Maker - design your own on-screen keyboard, then export it
; as a standalone .ahk script or a compiled .exe.
;
;   Key types:
;     Text = types the action text exactly as written (symbols, words)
;     Send = AutoHotkey Send syntax: z   ^c   {BackSpace}   {Esc}
;            (the Ctrl / Shift / Alt sticky buttons apply to Send keys)
;     Hold = press-and-hold toggle, e.g. Space or Ctrl+Space.
;            Press once to hold, press again to release. Held keys are
;            always released when the keyboard closes.
;
;   Command line (optional):
;     OSK_Maker.ahk /build layout.osk out.ahk
;     OSK_Maker.ahk /preset math|krita out.ahk
;
;   Version 2
;
;   Language: English (default) or Magyar (Hungarian). Pick it in the editor; the choice is
;   remembered in OSK_Maker.ini next to this script.
; ============================================================

DllCall("SetProcessDpiAwarenessContext", "ptr", -4)

global Keys := []
global Settings := Map()
global Lang := "en"
global I18N := Map()
global APP_AUTHOR := "Dani"
global APP_URL := "https://github.com/onehandmade/OSK-Maker"
global APP_VERSION := "2"

global G := "", LV := "", presetDD := ""
global edRow := "", edLabel := "", ddType := "", edAction := ""
global edTitle := "", edBg := "", edFont := "", edTrans := ""
global edWidth := "", edHeight := "", edHoverMs := ""
global chkSticky := "", chkHoverBtn := "", statusTxt := "", langDD := ""

SetDefaults()
InitI18N()
LoadLanguage()

if (A_Args.Length >= 1 && StrLower(A_Args[1]) = "/build" && A_Args.Length >= 3) {
    RunCliBuild(A_Args[2], A_Args[3])
    ExitApp()
}
if (A_Args.Length >= 1 && StrLower(A_Args[1]) = "/preset" && A_Args.Length >= 3) {
    if (StrLower(A_Args[2]) = "math")
        PresetMath()
    else
        PresetKrita()
    text := BuildScriptText(true)
    if (text != "")
        WriteTextFile(A_Args[3], text)
    ExitApp()
}

BuildEditor()

; ============================================================
; Editor window
; ============================================================
BuildEditor() {
    global G, LV, presetDD, edRow, edLabel, ddType, edAction
    global edTitle, edBg, edFont, edTrans, edWidth, edHeight, edHoverMs
    global chkSticky, chkHoverBtn, statusTxt, langDD, Lang

    edTitle := ""
    statusTxt := ""

    G := Gui("-Resize -MaximizeBox", T("winTitle"))
    G.SetFont("s10", "Segoe UI")
    G.OnEvent("Close", (*) => ExitApp())

    G.Add("Text", "x10 y14 w62", T("preset"))
    presetDD := G.Add("DropDownList", "x74 y10 w200 Choose1", [T("presetBlank"), T("presetMath"), T("presetKrita")])
    btnPreset := G.Add("Button", "x282 y9 w160 h26", T("loadPreset"))
    btnOpen := G.Add("Button", "x450 y9 w200 h26", T("openLayout"))
    btnSave := G.Add("Button", "x658 y9 w200 h26", T("saveLayout"))
    btnPreset.OnEvent("Click", LoadPreset)
    btnOpen.OnEvent("Click", OpenLayout)
    btnSave.OnEvent("Click", SaveLayout)

    LV := G.Add("ListView", "x10 y46 w900 r11 -Multi Grid", [T("colNum"), T("colRow"), T("colLabel"), T("colType"), T("colAction")])
    LV.ModifyCol(1, 40)
    LV.ModifyCol(2, 50)
    LV.ModifyCol(3, 220)
    LV.ModifyCol(4, 70)
    LV.ModifyCol(5, 500)
    LV.OnEvent("ItemSelect", OnLVSelect)

    G.Add("Text", "xm y+12 w40", T("lblRow"))
    edRow := G.Add("Edit", "x+2 yp-3 w50 Number", "1")
    G.Add("UpDown", "Range1-30", 1)
    G.Add("Text", "x+14 yp+3 w60", T("lblLabel"))
    edLabel := G.Add("Edit", "x+2 yp-3 w150")
    G.Add("Text", "x+14 yp+3 w55", T("lblType"))
    ddType := G.Add("DropDownList", "x+2 yp-3 w75 Choose1", ["Text", "Send", "Hold"])
    G.Add("Text", "x+14 yp+3 w70", T("lblAction"))
    edAction := G.Add("Edit", "x+2 yp-3 w280")

    btnAdd := G.Add("Button", "xm y+10 w190 h28", T("addKey"))
    btnUpd := G.Add("Button", "x+6 yp w180 h28", T("updateKey"))
    btnDel := G.Add("Button", "x+6 yp w100 h28", T("deleteKey"))
    btnUp := G.Add("Button", "x+6 yp w70 h28", T("moveUp"))
    btnDn := G.Add("Button", "x+6 yp w70 h28", T("moveDown"))
    btnAdd.OnEvent("Click", AddKey)
    btnUpd.OnEvent("Click", UpdateKey)
    btnDel.OnEvent("Click", DeleteKey)
    btnUp.OnEvent("Click", MoveKey.Bind(-1))
    btnDn.OnEvent("Click", MoveKey.Bind(1))

    G.Add("Text", "xm y+8 w900 h66", T("help"))

    G.Add("GroupBox", "xm y+6 w900 h112", T("grpSettings"))
    G.Add("Text", "xp+12 yp+26 w50", T("lblTitle"))
    edTitle := G.Add("Edit", "x+2 yp-3 w220")
    G.Add("Text", "x+14 yp+3 w95", T("lblBg"))
    edBg := G.Add("Edit", "x+2 yp-3 w70")
    G.Add("Text", "x+14 yp+3 w85", T("lblFont"))
    edFont := G.Add("Edit", "x+2 yp-3 w45 Number")
    G.Add("Text", "x+14 yp+3 w150", T("lblTrans"))
    edTrans := G.Add("Edit", "x+2 yp-3 w50 Number")

    G.Add("Text", "xm+12 y+16 w87", T("lblWidth"))
    edWidth := G.Add("Edit", "x+2 yp-3 w50 Number")
    G.Add("Text", "x+14 yp+3 w100", T("lblHeight"))
    edHeight := G.Add("Edit", "x+2 yp-3 w60 Number")
    G.Add("Text", "x+14 yp+3 w140", T("lblHover"))
    edHoverMs := G.Add("Edit", "x+2 yp-3 w60 Number")
    chkSticky := G.Add("Checkbox", "x+16 yp+3 w170", T("chkSticky"))
    chkHoverBtn := G.Add("Checkbox", "x+6 yp w130", T("chkHoverBtn"))

    btnPrev := G.Add("Button", "xm y+22 w130 h32", T("preview"))
    btnAhk := G.Add("Button", "x+8 yp w190 h32", T("genAhk"))
    btnExe := G.Add("Button", "x+8 yp w190 h32", T("genExe"))
    btnPrev.OnEvent("Click", PreviewKeyboard)
    btnAhk.OnEvent("Click", GenerateAhk)
    btnExe.OnEvent("Click", GenerateExe)

    G.Add("Text", "x+22 yp+6 w80", T("language"))
    langDD := G.Add("DropDownList", "x+2 yp-4 w120 Choose" . (Lang = "hu" ? 2 : 1), ["English", "Magyar"])
    btnAbout := G.Add("Button", "x+10 yp-2 w110 h32", T("about"))
    langDD.OnEvent("Change", OnLanguageChange)
    btnAbout.OnEvent("Click", ShowAbout)

    statusTxt := G.Add("Text", "xm y+10 w900", T("statusStart"))

    WriteSettingsToControls()
    RefreshLV()
    G.Show()
}

SetStatus(msg) {
    global statusTxt
    if (statusTxt != "")
        statusTxt.Text := msg
}

; ============================================================
; Settings
; ============================================================
SetDefaults() {
    global Settings
    Settings := Map("title", "My On-Screen Keyboard", "bg", "1E1E1E", "fontSize", 14, "trans", 235, "widthPct", 60, "height", 200, "hoverDelay", 700, "sticky", 0, "hoverBtn", 1)
}

ClampInt(text, lo, hi, def) {
    t := Trim(text)
    if !IsInteger(t)
        return def
    v := Integer(t)
    return Max(lo, Min(hi, v))
}

ReadSettings(quiet := false) {
    global Settings, edTitle, edBg, edFont, edTrans, edWidth, edHeight, edHoverMs, chkSticky, chkHoverBtn
    title := Trim(edTitle.Text)
    if (title = "")
        title := "On-Screen Keyboard"
    bg := Trim(edBg.Text)
    if !RegExMatch(bg, "^[0-9A-Fa-f]{6}$") {
        if (!quiet)
            MsgBox(T("bgError"), "OSK Maker", "Icon!")
        return false
    }
    Settings["title"] := title
    Settings["bg"] := bg
    Settings["fontSize"] := ClampInt(edFont.Text, 6, 48, 14)
    Settings["trans"] := ClampInt(edTrans.Text, 30, 255, 235)
    Settings["widthPct"] := ClampInt(edWidth.Text, 10, 100, 60)
    Settings["height"] := ClampInt(edHeight.Text, 80, 1200, 200)
    Settings["hoverDelay"] := ClampInt(edHoverMs.Text, 100, 5000, 700)
    Settings["sticky"] := chkSticky.Value ? 1 : 0
    Settings["hoverBtn"] := chkHoverBtn.Value ? 1 : 0
    WriteSettingsToControls()
    return true
}

WriteSettingsToControls() {
    global Settings, edTitle, edBg, edFont, edTrans, edWidth, edHeight, edHoverMs, chkSticky, chkHoverBtn
    if (edTitle = "")
        return
    edTitle.Text := Settings["title"]
    edBg.Text := Settings["bg"]
    edFont.Text := Settings["fontSize"]
    edTrans.Text := Settings["trans"]
    edWidth.Text := Settings["widthPct"]
    edHeight.Text := Settings["height"]
    edHoverMs.Text := Settings["hoverDelay"]
    chkSticky.Value := Settings["sticky"] ? 1 : 0
    chkHoverBtn.Value := Settings["hoverBtn"] ? 1 : 0
}

; ============================================================
; Key list editing
; ============================================================
RefreshLV(selIdx := 0) {
    global Keys, LV
    LV.Delete()
    for i, k in Keys
        LV.Add("", i, k["row"], k["label"], k["type"], k["action"])
    if (selIdx >= 1 && selIdx <= Keys.Length)
        LV.Modify(selIdx, "Select Focus Vis")
}

GetSelectedIdx() {
    global LV
    return LV.GetNext(0)
}

OnLVSelect(ctrl, item, selected) {
    global Keys, edRow, edLabel, ddType, edAction
    if (!selected || item < 1 || item > Keys.Length)
        return
    k := Keys[item]
    edRow.Text := k["row"]
    edLabel.Text := k["label"]
    ddType.Choose(k["type"])
    edAction.Text := k["action"]
}

ReadKeyFields() {
    global edRow, edLabel, ddType, edAction
    label := StrReplace(edLabel.Text, "`t", " ")
    action := StrReplace(edAction.Text, "`t", " ")
    type := ddType.Text
    rowNum := IsInteger(edRow.Text) ? Integer(edRow.Text) : 1
    if (rowNum < 1)
        rowNum := 1
    if (label = "") {
        MsgBox(T("giveLabel"), "OSK Maker", "Icon!")
        return 0
    }
    if (action = "") {
        if (type = "Text") {
            action := label
        } else {
            MsgBox(T("needAction"), "OSK Maker", "Icon!")
            return 0
        }
    }
    return Map("row", rowNum, "label", label, "type", type, "action", action)
}

AddKey(*) {
    global Keys
    k := ReadKeyFields()
    if (!IsObject(k))
        return
    Keys.Push(k)
    RefreshLV(Keys.Length)
    SetStatus(T("added", k["label"]))
}

UpdateKey(*) {
    global Keys
    idx := GetSelectedIdx()
    if (!idx) {
        SetStatus(T("selectFirst"))
        return
    }
    k := ReadKeyFields()
    if (!IsObject(k))
        return
    Keys[idx] := k
    RefreshLV(idx)
    SetStatus(T("updated", k["label"]))
}

DeleteKey(*) {
    global Keys
    idx := GetSelectedIdx()
    if (!idx) {
        SetStatus(T("selectFirst"))
        return
    }
    Keys.RemoveAt(idx)
    RefreshLV(Min(idx, Keys.Length))
    SetStatus(T("deleted"))
}

MoveKey(dir, *) {
    global Keys
    idx := GetSelectedIdx()
    if (!idx)
        return
    j := idx + dir
    if (j < 1 || j > Keys.Length)
        return
    tmp := Keys[idx]
    Keys[idx] := Keys[j]
    Keys[j] := tmp
    RefreshLV(j)
}

; ============================================================
; Presets (based on the Math and Krita keyboards)
; ============================================================
LoadPreset(*) {
    global presetDD, Keys
    if (Keys.Length > 0) {
        if (MsgBox(T("replaceLayout"), "OSK Maker", "YesNo Icon?") != "Yes")
            return
    }
    choice := presetDD.Value
    if (choice = 2) {
        PresetMath()
    } else if (choice = 3) {
        PresetKrita()
    } else {
        Keys := []
        SetDefaults()
    }
    WriteSettingsToControls()
    RefreshLV()
    SetStatus(T("presetLoaded"))
}

PresetMath() {
    global Keys, Settings
    SetDefaults()
    Settings["title"] := "Math On-Screen Keyboard"
    Settings["bg"] := "1E1E1E"
    Settings["fontSize"] := 14
    Settings["trans"] := 235
    Settings["widthPct"] := 60
    Settings["height"] := 200
    Settings["sticky"] := 0
    rows := [
        ["7", "8", "9", "/", "(", ")", "√", "⌫"],
        ["4", "5", "6", "*", "^", "x²", "x³", "π"],
        ["1", "2", "3", "-", "=", "≠", "≈", "∞"],
        ["0", ".", ",", "+", "±", "<", ">", "≤", "≥"],
        ["%", "!", "°", "∑", "∫", "θ", "α", "␣"]
    ]
    Keys := []
    for r, items in rows {
        for lbl in items {
            if (lbl = "⌫")
                Keys.Push(Map("row", r, "label", lbl, "type", "Send", "action", "{BackSpace}"))
            else if (lbl = "␣")
                Keys.Push(Map("row", r, "label", lbl, "type", "Send", "action", "{Space}"))
            else
                Keys.Push(Map("row", r, "label", lbl, "type", "Text", "action", lbl))
        }
    }
}

PresetKrita() {
    global Keys, Settings
    SetDefaults()
    Settings["title"] := "Krita Accessible Assistant"
    Settings["bg"] := "2B2B2B"
    Settings["fontSize"] := 11
    Settings["trans"] := 245
    Settings["widthPct"] := 55
    Settings["height"] := 215
    Settings["sticky"] := 1
    rows := [
        [["Undo (Z)", "Send", "z"], ["Redo (Y)", "Send", "y"], ["Copy (C)", "Send", "c"], ["Paste (V)", "Send", "v"], ["Backspace", "Send", "{BackSpace}"]],
        [["Brush (B)", "Send", "b"], ["Eraser (E)", "Send", "e"], ["Picker (I)", "Send", "i"], ["Fill (G)", "Send", "g"], ["Select All (A)", "Send", "a"]],
        [["Size - ([)", "Send", "["], ["Size + (])", "Send", "]"], ["Zoom In (+)", "Send", "^{NumpadAdd}"], ["Zoom Out (-)", "Send", "^{NumpadSub}"], ["Reset Zoom (0)", "Send", "^0"]],
        [["Mirror (M)", "Send", "m"], ["Rotate Reset (R)", "Send", "r"], ["Pan Canvas", "Hold", "Space"], ["Zoom Drag", "Hold", "Ctrl+Space"], ["Rotate Drag", "Hold", "Shift+Space"], ["Esc", "Send", "{Esc}"]]
    ]
    Keys := []
    for r, items in rows {
        for spec in items
            Keys.Push(Map("row", r, "label", spec[1], "type", spec[2], "action", spec[3]))
    }
}

; ============================================================
; Layout files (.osk) - simple tab-separated text
; ============================================================
SaveLayout(*) {
    global Keys, Settings
    if (!ReadSettings())
        return
    if (Keys.Length = 0) {
        MsgBox(T("noKeysSave"), "OSK Maker", "Icon!")
        return
    }
    path := FileSelect("S16", A_ScriptDir . "\layout.osk", T("dlgSaveLayout"), T("fltLayout"))
    if (path = "")
        return
    if !RegExMatch(path, "i)\.osk$")
        path .= ".osk"
    text := "OSKLAYOUT`t1`n"
    for name, val in Settings
        text .= "SET`t" . name . "`t" . CleanField(val) . "`n"
    for k in Keys
        text .= "KEY`t" . k["row"] . "`t" . CleanField(k["type"]) . "`t" . CleanField(k["label"]) . "`t" . CleanField(k["action"]) . "`n"
    if WriteTextFile(path, text)
        SetStatus(T("layoutSaved", path))
}

; Tabs and line breaks would break the tab-separated format
CleanField(v) {
    v := String(v)
    v := StrReplace(v, "`t", " ")
    v := StrReplace(v, "`r", " ")
    v := StrReplace(v, "`n", " ")
    return v
}

OpenLayout(*) {
    path := FileSelect(3, A_ScriptDir, T("dlgOpenLayout"), T("fltLayout"))
    if (path = "")
        return
    if LoadLayoutFile(path) {
        WriteSettingsToControls()
        RefreshLV()
        SetStatus(T("layoutLoaded", path))
    }
}

LoadLayoutFile(path) {
    global Keys, Settings
    try {
        f := FileOpen(path, "r", "UTF-8")
        text := f.Read()
        f.Close()
    } catch as err {
        MsgBox(T("couldNotRead", path, err.Message), "OSK Maker", "Icon!")
        return false
    }
    ; Accept Windows, Unix and old Mac line endings, and a stray BOM
    text := StrReplace(text, "`r`n", "`n")
    text := StrReplace(text, "`r", "`n")
    if (SubStr(text, 1, 1) = Chr(0xFEFF))
        text := SubStr(text, 2)
    lines := StrSplit(text, "`n")
    if (lines.Length = 0 || SubStr(lines[1], 1, 9) != "OSKLAYOUT") {
        MsgBox(T("notLayout"), "OSK Maker", "Icon!")
        return false
    }
    newKeys := []
    newSet := Map()
    for line in lines {
        if (line = "")
            continue
        p := StrSplit(line, "`t")
        if (p.Length >= 3 && p[1] = "SET") {
            newSet[p[2]] := p[3]
        } else if (p.Length >= 4 && p[1] = "KEY") {
            rowNum := IsInteger(p[2]) ? Integer(p[2]) : 1
            lbl := p[4]
            act := (p.Length >= 5) ? p[5] : ""
            if (act = "")
                act := lbl
            typ := p[3]
            if (typ != "Text" && typ != "Send" && typ != "Hold")
                typ := "Text"
            newKeys.Push(Map("row", rowNum, "type", typ, "label", lbl, "action", act))
        }
    }
    if (newKeys.Length = 0) {
        MsgBox(T("noKeysFile"), "OSK Maker", "Icon!")
        return false
    }
    SetDefaults()
    for name, val in newSet {
        if (!Settings.Has(name))
            continue
        if (name = "title" || name = "bg")
            Settings[name] := val
        else if IsInteger(val)
            Settings[name] := Integer(val)
    }
    Keys := newKeys
    return true
}

WriteTextFile(path, text) {
    try {
        f := FileOpen(path, "w", "UTF-8-RAW")
        f.Write(text)
        f.Close()
        return true
    } catch as err {
        MsgBox(T("couldNotWrite", path, err.Message), "OSK Maker", "Icon!")
        return false
    }
}

RunCliBuild(layoutPath, outPath) {
    global Keys
    if !LoadLayoutFile(layoutPath)
        return
    text := BuildScriptText(true)
    if (text != "")
        WriteTextFile(outPath, text)
}

; ============================================================
; Script generation
; ============================================================
EscAhk(s) {
    s := StrReplace(s, "``", "````")
    s := StrReplace(s, '"', '``"')
    return s
}

Q(s) {
    return '"' . EscAhk(s) . '"'
}

BuildScriptText(skipControls := false) {
    global Keys, Settings
    if (Keys.Length = 0) {
        MsgBox(T("addOneKey"), "OSK Maker", "Icon!")
        return ""
    }
    if (!skipControls && !ReadSettings())
        return ""

    ; Collect distinct row numbers, sorted ascending
    rowNums := []
    for k in Keys {
        found := false
        for n in rowNums {
            if (n = k["row"])
                found := true
        }
        if (!found)
            rowNums.Push(k["row"])
    }
    total := rowNums.Length
    pass := 1
    while (pass < total) {
        j := 1
        while (j <= total - pass) {
            if (rowNums[j] > rowNums[j + 1]) {
                tmp := rowNums[j]
                rowNums[j] := rowNums[j + 1]
                rowNums[j + 1] := tmp
            }
            j += 1
        }
        pass += 1
    }

    out := "#Requires AutoHotkey v2.0`n#SingleInstance Force`n`n"
    out .= "; Generated by OSK Maker. Edit the values and KeyRows below if you like.`n"
    out .= "global OSK_Title := " . Q(Settings["title"]) . "`n"
    out .= "global OSK_BgColor := " . Q(Settings["bg"]) . "`n"
    out .= "global OSK_FontSize := " . Integer(Settings["fontSize"]) . "`n"
    out .= "global OSK_Trans := " . Integer(Settings["trans"]) . "`n"
    out .= "global OSK_WidthPct := " . Integer(Settings["widthPct"]) . "`n"
    out .= "global OSK_Height := " . Integer(Settings["height"]) . "`n"
    out .= "global OSK_HoverDelay := " . Integer(Settings["hoverDelay"]) . "`n"
    out .= "global OSK_Sticky := " . (Integer(Settings["sticky"]) ? "true" : "false") . "`n"
    out .= "global OSK_HoverBtn := " . (Integer(Settings["hoverBtn"]) ? "true" : "false") . "`n`n"
    out .= BuildLangBlock() . "`n"

    out .= "global KeyRows := [`n"
    rowTexts := []
    for rn in rowNums {
        pieces := []
        for k in Keys {
            if (k["row"] != rn)
                continue
            pieces.Push("        Map(" . Q("label") . ", " . Q(k["label"]) . ", " . Q("type") . ", " . Q(k["type"]) . ", " . Q("action") . ", " . Q(k["action"]) . ")")
        }
        rowTexts.Push("    [`n" . JoinList(pieces, ",`n") . "`n    ]")
    }
    out .= JoinList(rowTexts, ",`n") . "`n]`n`n"

    for line in GetTemplateLines()
        out .= line . "`n"
    return out
}

JoinList(arr, sep) {
    result := ""
    for i, v in arr
        result .= (i = 1 ? "" : sep) . v
    return result
}

; ============================================================
; Preview / export
; ============================================================
FindAhkExe() {
    candidates := [A_AhkPath, A_ProgramFiles . "\AutoHotkey\v2\AutoHotkey64.exe", A_ProgramFiles . "\AutoHotkey\v2\AutoHotkey32.exe", EnvGet("LOCALAPPDATA") . "\Programs\AutoHotkey\v2\AutoHotkey64.exe"]
    for c in candidates {
        if (c != "" && FileExist(c))
            return c
    }
    return ""
}

FindCompiler() {
    ahkDir := ""
    if (A_AhkPath != "")
        SplitPath(A_AhkPath, , &ahkDir)
    candidates := [A_ProgramFiles . "\AutoHotkey\Compiler\Ahk2Exe.exe", EnvGet("LOCALAPPDATA") . "\Programs\AutoHotkey\Compiler\Ahk2Exe.exe"]
    if (ahkDir != "")
        candidates.Push(ahkDir . "\..\Compiler\Ahk2Exe.exe")
    for c in candidates {
        if FileExist(c)
            return c
    }
    return ""
}

PreviewKeyboard(*) {
    text := BuildScriptText()
    if (text = "")
        return
    ahk := FindAhkExe()
    if (ahk = "") {
        MsgBox(T("noAhk"), "OSK Maker", "Icon!")
        return
    }
    path := A_Temp . "\osk_maker_preview.ahk"
    if !WriteTextFile(path, text)
        return
    Run('"' . ahk . '" "' . path . '"')
    SetStatus(T("previewStarted"))
}

GenerateAhk(*) {
    text := BuildScriptText()
    if (text = "")
        return
    path := FileSelect("S16", A_ScriptDir . "\my_keyboard.ahk", T("dlgSaveAhk"), T("fltAhk"))
    if (path = "")
        return
    if !RegExMatch(path, "i)\.ahk$")
        path .= ".ahk"
    if WriteTextFile(path, text)
        SetStatus(T("saved", path))
}

GenerateExe(*) {
    text := BuildScriptText()
    if (text = "")
        return
    compiler := FindCompiler()
    base := FindAhkExe()
    if (compiler = "" || base = "") {
        MsgBox(T("noCompiler"), "OSK Maker", "Icon!")
        return
    }
    exePath := FileSelect("S16", A_ScriptDir . "\my_keyboard.exe", T("dlgSaveExe"), T("fltExe"))
    if (exePath = "")
        return
    if !RegExMatch(exePath, "i)\.exe$")
        exePath .= ".exe"
    srcPath := A_Temp . "\osk_maker_build.ahk"
    if !WriteTextFile(srcPath, text)
        return
    SetStatus(T("compiling"))
    try FileDelete(exePath)
    try {
        RunWait('"' . compiler . '" /in "' . srcPath . '" /out "' . exePath . '" /base "' . base . '"', , "Hide")
    } catch as err {
        MsgBox(T("compilerStartFail", err.Message), "OSK Maker", "Icon!")
        return
    }
    if FileExist(exePath)
        SetStatus(T("compiled", exePath))
    else
        MsgBox(T("compileFail"), "OSK Maker", "Icon!")
}

; ============================================================
; Keyboard engine template (written into every generated script)
; ============================================================
GetTemplateLines() {
    return [
        '; ============================================================',
        '; On-screen keyboard engine (generated by OSK Maker)',
        '; The window never takes focus (WS_EX_NOACTIVATE), so the app you',
        '; are typing into keeps focus and receives the keys directly.',
        '; ============================================================',
        'DllCall("SetProcessDpiAwarenessContext", "ptr", -4)',
        '',
        'global KeyControls := []',
        'global KeyMap := Map()',
        'global ModMap := Map()',
        'global ModButtons := Map()',
        'global StickyOn := Map("Ctrl", false, "Shift", false, "Alt", false)',
        'global HeldKeys := Map()',
        'global TopBarH := 40',
        'global TopX := 10',
        'global HoverModeOn := false',
        'global HoverCandidateHwnd := 0',
        'global HoverStartTick := 0',
        'global HoverFired := false',
        'global HoverEntry := 0',
        '',
        'OnExit(OnScriptExit)',
        '',
        'OSK := Gui("+AlwaysOnTop +Resize -MaximizeBox +E0x08000000", OSK_Title)',
        'OSK.BackColor := OSK_BgColor',
        'OSK.OnEvent("Size", OnResize)',
        'OSK.OnEvent("Close", (*) => ExitApp())',
        '',
        '; ---- Top bar ----',
        'OSK.SetFont("s10 Bold cWhite", "Segoe UI")',
        'AddTopButton(OSK_Lang["snapBottom"], 105, SnapToBottom)',
        'AddTopButton(OSK_Lang["snapTop"], 85, SnapToTop)',
        'if (OSK_HoverBtn)',
        '    AddTopButton(OSK_Lang["hoverOff"], 100, ToggleHoverMode)',
        'if (OSK_Sticky) {',
        '    for modName in ["Ctrl", "Shift", "Alt"] {',
        '        modBtn := AddTopButton(modName . ": " . OSK_Lang["off"], 85, ToggleSticky.Bind(modName))',
        '        ModButtons[modName] := modBtn',
        '        ModMap[modBtn.Hwnd] := Map("name", modName, "btn", modBtn)',
        '    }',
        '}',
        'if (HasHoldKeys())',
        '    AddTopButton(OSK_Lang["releaseHeld"], 115, OnReleaseClick)',
        'AddTopButton(OSK_Lang["about"], 80, ShowAbout)',
        '',
        '; ---- Initial size and position ----',
        'MonitorGetWorkArea(, &waLeft, &waTop, &waRight, &waBottom)',
        'screenW := waRight - waLeft',
        'initW := Round(screenW * OSK_WidthPct / 100)',
        'initH := OSK_Height',
        'initX := waLeft + Round((screenW - initW) / 2)',
        'initY := waBottom - initH - 10',
        'OSK.Show(Format("x{} y{} w{} h{}", initX, initY, initW, initH))',
        'WinSetTransparent(OSK_Trans, OSK)',
        '',
        'CreateKeys()',
        'LayoutKeys()',
        '',
        '; ---------------- Helpers ----------------',
        '',
        'AddTopButton(text, w, handler) {',
        '    global OSK, TopX',
        '    w := Max(w, StrLen(text) * 9 + 24)',
        '    btn := OSK.Add("Button", Format("x{} y6 w{} h28", TopX, w), text)',
        '    btn.OnEvent("Click", handler)',
        '    TopX += w + 6',
        '    return btn',
        '}',
        '',
        'HasHoldKeys() {',
        '    global KeyRows',
        '    for rowItems in KeyRows {',
        '        for spec in rowItems {',
        '            if (spec["type"] = "Hold")',
        '                return true',
        '        }',
        '    }',
        '    return false',
        '}',
        '',
        'LabelFor(spec) {',
        '    global HeldKeys, OSK_Lang',
        '    if (spec["type"] = "Hold" && HeldKeys.Has(spec["action"]))',
        '        return spec["label"] . " [" . OSK_Lang["held"] . "]"',
        '    return spec["label"]',
        '}',
        '',
        '; ---------------- Keys: create once, move on resize ----------------',
        '',
        'CreateKeys() {',
        '    global KeyControls, KeyMap, KeyRows, OSK, OSK_FontSize',
        '    OSK.SetFont("s" . OSK_FontSize . " Bold cWhite", "Segoe UI")',
        '    KeyControls := []',
        '    KeyMap := Map()',
        '    for rowIndex, rowItems in KeyRows {',
        '        for colIndex, spec in rowItems {',
        '            btn := OSK.Add("Button", "x0 y0 w40 h30", LabelFor(spec))',
        '            btn.OnEvent("Click", PressKey.Bind(spec, btn))',
        '            KeyControls.Push(Map("btn", btn, "row", rowIndex, "col", colIndex, "cols", rowItems.Length))',
        '            KeyMap[btn.Hwnd] := Map("spec", spec, "btn", btn)',
        '        }',
        '    }',
        '}',
        '',
        'LayoutKeys() {',
        '    global KeyControls, KeyRows, OSK, TopBarH',
        '    OSK.GetClientPos(, , &clientW, &clientH)',
        '    if (clientW < 100 || clientH < 60)',
        '        return',
        '    numRows := KeyRows.Length',
        '    if (numRows = 0)',
        '        return',
        '    marginX := 10',
        '    marginY := 10',
        '    gap := 6',
        '    topOffset := TopBarH + marginY',
        '    availH := clientH - topOffset - marginY',
        '    rowH := (availH - gap * (numRows - 1)) / numRows',
        '    if (rowH < 12)',
        '        rowH := 12',
        '    rowW := clientW - marginX * 2',
        '    for item in KeyControls {',
        '        keyW := (rowW - gap * (item["cols"] - 1)) / item["cols"]',
        '        xPos := marginX + (item["col"] - 1) * (keyW + gap)',
        '        yPos := topOffset + (item["row"] - 1) * (rowH + gap)',
        '        item["btn"].Move(Round(xPos), Round(yPos), Round(keyW), Round(rowH))',
        '    }',
        '}',
        '',
        'OnResize(GuiObj, MinMax, Width, Height) {',
        '    global OSK_WidthPct, OSK_Height',
        '    if (MinMax = -1)',
        '        return',
        '    if (MinMax = 1) {',
        '        WinRestore(GuiObj.Hwnd)',
        '        MonitorGetWorkArea(, &wl, &wt, &wr, &wb)',
        '        rw := Round((wr - wl) * OSK_WidthPct / 100)',
        '        WinMove(wl + Round(((wr - wl) - rw) / 2), wb - OSK_Height - 10, rw, OSK_Height, GuiObj.Hwnd)',
        '        return',
        '    }',
        '    LayoutKeys()',
        '}',
        '',
        'SnapToBottom(*) {',
        '    global OSK',
        '    OSK.GetPos(&curX, &curY, &curW, &curH)',
        '    MonitorGetWorkArea(, &wl, &wt, &wr, &wb)',
        '    OSK.Move(, wb - curH)',
        '}',
        '',
        'SnapToTop(*) {',
        '    global OSK',
        '    MonitorGetWorkArea(, &wl, &wt, &wr, &wb)',
        '    OSK.Move(, wt)',
        '}',
        '',
        '; ---------------- Key actions ----------------',
        '',
        'GetStickyPrefix() {',
        '    global StickyOn',
        '    prefix := ""',
        '    if (StickyOn["Ctrl"])',
        '        prefix .= "^"',
        '    if (StickyOn["Shift"])',
        '        prefix .= "+"',
        '    if (StickyOn["Alt"])',
        '        prefix .= "!"',
        '    return prefix',
        '}',
        '',
        'ResetSticky() {',
        '    global StickyOn, ModButtons, OSK_Lang',
        '    for name, btn in ModButtons {',
        '        if (StickyOn[name]) {',
        '            StickyOn[name] := false',
        '            btn.Text := name . ": " . OSK_Lang["off"]',
        '        }',
        '    }',
        '}',
        '',
        'ToggleSticky(name, btn, *) {',
        '    global StickyOn, OSK_Lang',
        '    StickyOn[name] := !StickyOn[name]',
        '    btn.Text := name . ": " . (StickyOn[name] ? OSK_Lang["on"] : OSK_Lang["off"])',
        '}',
        '',
        'PressKey(spec, btn, *) {',
        '    type := spec["type"]',
        '    if (type = "Text") {',
        '        SendText(spec["action"])',
        '    } else if (type = "Send") {',
        '        Send(GetStickyPrefix() . spec["action"])',
        '    } else if (type = "Hold") {',
        '        ToggleHold(spec, btn)',
        '    }',
        '    ResetSticky()',
        '}',
        '',
        'ToggleHold(spec, btn) {',
        '    global HeldKeys',
        '    id := spec["action"]',
        '    parts := StrSplit(id, "+")',
        '    if (HeldKeys.Has(id)) {',
        '        idx := parts.Length',
        '        while (idx >= 1) {',
        '            keyName := Trim(parts[idx])',
        '            if (keyName != "")',
        '                Send("{" . keyName . " up}")',
        '            idx -= 1',
        '        }',
        '        HeldKeys.Delete(id)',
        '    } else {',
        '        for part in parts {',
        '            keyName := Trim(part)',
        '            if (keyName != "")',
        '                Send("{" . keyName . " down}")',
        '        }',
        '        HeldKeys[id] := true',
        '    }',
        '    btn.Text := LabelFor(spec)',
        '}',
        '',
        'ReleaseHeldKeys() {',
        '    global HeldKeys',
        '    for id, state in HeldKeys.Clone() {',
        '        parts := StrSplit(id, "+")',
        '        idx := parts.Length',
        '        while (idx >= 1) {',
        '            keyName := Trim(parts[idx])',
        '            if (keyName != "")',
        '                try Send("{" . keyName . " up}")',
        '            idx -= 1',
        '        }',
        '    }',
        '    HeldKeys := Map()',
        '}',
        '',
        'OnReleaseClick(*) {',
        '    global KeyMap',
        '    ReleaseHeldKeys()',
        '    for hwnd, entry in KeyMap {',
        '        entry["btn"].Text := LabelFor(entry["spec"])',
        '    }',
        '}',
        '',
        'OnScriptExit(*) {',
        '    ReleaseHeldKeys()',
        '}',
        '',
        'ShowAbout(*) {',
        '    global OSK_Lang',
        '    MsgBox(OSK_Lang["aboutBody"], OSK_Lang["aboutTitle"], "Iconi 262144")',
        '}',
        '',
        '; ---------------- Hover mode (dwell to click) ----------------',
        '',
        'ToggleHoverMode(ctrlObj, *) {',
        '    global HoverModeOn, HoverCandidateHwnd, HoverFired, OSK_Lang',
        '    HoverModeOn := !HoverModeOn',
        '    ctrlObj.Text := HoverModeOn ? OSK_Lang["hoverOn"] : OSK_Lang["hoverOff"]',
        '    HoverCandidateHwnd := 0',
        '    HoverFired := false',
        '    SetTimer(HoverCheck, HoverModeOn ? 60 : 0)',
        '}',
        '',
        'HoverCheck() {',
        '    global HoverModeOn, KeyMap, ModMap, OSK, OSK_HoverDelay',
        '    global HoverCandidateHwnd, HoverStartTick, HoverFired, HoverEntry',
        '',
        '    if (!HoverModeOn)',
        '        return',
        '',
        '    MouseGetPos(, , &winUnderMouse, &ctrlHwnd, 2)',
        '',
        '    if (winUnderMouse != OSK.Hwnd) {',
        '        HoverCandidateHwnd := 0',
        '        HoverFired := false',
        '        return',
        '    }',
        '',
        '    entry := 0',
        '    if KeyMap.Has(ctrlHwnd)',
        '        entry := KeyMap[ctrlHwnd]',
        '    else if ModMap.Has(ctrlHwnd)',
        '        entry := ModMap[ctrlHwnd]',
        '',
        '    if (!IsObject(entry)) {',
        '        HoverCandidateHwnd := 0',
        '        HoverFired := false',
        '        return',
        '    }',
        '',
        '    if (ctrlHwnd != HoverCandidateHwnd) {',
        '        HoverCandidateHwnd := ctrlHwnd',
        '        HoverEntry := entry',
        '        HoverStartTick := A_TickCount',
        '        HoverFired := false',
        '        return',
        '    }',
        '',
        '    if (!HoverFired && (A_TickCount - HoverStartTick >= OSK_HoverDelay)) {',
        '        HoverFired := true',
        '        if HoverEntry.Has("spec")',
        '            PressKey(HoverEntry["spec"], HoverEntry["btn"])',
        '        else',
        '            ToggleSticky(HoverEntry["name"], HoverEntry["btn"])',
        '    }',
        '}'
    ]
}

; ============================================================
; Languages (English / Magyar) and About window
; ============================================================
InitI18N() {
    global I18N
    I18N := Map()

    I18N["en"] := Map(
        "winTitle", "OSK Maker - On-Screen Keyboard Builder",
        "preset", "Preset:",
        "presetBlank", "Blank",
        "presetMath", "Math keyboard",
        "presetKrita", "Krita / drawing",
        "loadPreset", "Load Preset",
        "openLayout", "Open Layout...",
        "saveLayout", "Save Layout...",
        "colNum", "#",
        "colRow", "Row",
        "colLabel", "Label",
        "colType", "Type",
        "colAction", "Action",
        "lblRow", "Row:",
        "lblLabel", "Label:",
        "lblType", "Type:",
        "lblAction", "Action:",
        "addKey", "Add Key",
        "updateKey", "Update Selected",
        "deleteKey", "Delete",
        "moveUp", "Up",
        "moveDown", "Down",
        "help", "Text = types the action text as written.   Send = AutoHotkey Send syntax (z, ^c, {BackSpace}); the sticky Ctrl/Shift/Alt buttons apply to Send keys.   Hold = press-and-hold toggle such as Space or Ctrl+Space (released when pressed again, or when the keyboard closes).   Keys with the same Row number share a row.",
        "grpSettings", "Keyboard settings",
        "lblTitle", "Title:",
        "lblBg", "Background:",
        "lblFont", "Font size:",
        "lblTrans", "Opacity (30-255):",
        "lblWidth", "Width %:",
        "lblHeight", "Height (px):",
        "lblHover", "Hover delay (ms):",
        "chkSticky", "Sticky Ctrl/Shift/Alt",
        "chkHoverBtn", "Hover button",
        "preview", "Preview",
        "genAhk", "Generate .ahk...",
        "genExe", "Generate .exe...",
        "language", "Language:",
        "about", "About",
        "ok", "OK",
        "statusStart", "Load a preset or add your first key.",
        "added", "Added key '{1}'.",
        "updated", "Updated key '{1}'.",
        "selectFirst", "Select a key in the list first.",
        "deleted", "Key deleted.",
        "presetLoaded", "Preset loaded.",
        "layoutSaved", "Layout saved: {1}",
        "layoutLoaded", "Layout loaded: {1}",
        "previewStarted", "Preview started. Close the keyboard window to stop it.",
        "saved", "Saved: {1}",
        "compiling", "Compiling...",
        "compiled", "Compiled: {1}",
        "bgError", "Background must be a 6-digit hex color, for example 1E1E1E.",
        "giveLabel", "Give the key a label first.",
        "needAction", "Send and Hold keys need an Action.",
        "replaceLayout", "Replace the current layout with the preset?",
        "noKeysSave", "There are no keys to save yet. Add some keys or load a preset first.",
        "notLayout", "This is not an OSK layout file.",
        "noKeysFile", "The layout file contains no keys.",
        "couldNotRead", "Could not read {1}`n`n{2}",
        "couldNotWrite", "Could not write {1}`n`n{2}",
        "addOneKey", "Add at least one key first.",
        "noAhk", "AutoHotkey v2 was not found, so the preview cannot start.",
        "noCompiler", "Ahk2Exe (the AutoHotkey compiler) was not found.`n`nInstall AutoHotkey v2 with the compiler option, or use 'Generate .ahk' and compile that file yourself.",
        "compilerStartFail", "The compiler could not be started: {1}",
        "compileFail", "Compiling did not produce an .exe. Try 'Generate .ahk' and compile it with Ahk2Exe manually.",
        "dlgSaveLayout", "Save layout",
        "fltLayout", "OSK layout (*.osk)",
        "dlgOpenLayout", "Open layout",
        "dlgSaveAhk", "Save keyboard script",
        "fltAhk", "AutoHotkey script (*.ahk)",
        "dlgSaveExe", "Save keyboard program",
        "fltExe", "Program (*.exe)",
        "aboutTitle", "About OSK Maker",
        "aboutBy", "Created by {1}",
        "aboutVersion", "Version {1}",
        "aboutBody", "I am handicapped, and I build accessibility tools, mostly for games, where the game companies don't.`n`nOSK Maker lets you design your own on-screen keyboard and export it as a standalone .ahk script or .exe, so the keyboard fits you and not the other way around.",
        "k_snapBottom", "Snap Bottom",
        "k_snapTop", "Snap Top",
        "k_hoverOff", "Hover: Off",
        "k_hoverOn", "Hover: On",
        "k_on", "ON",
        "k_off", "OFF",
        "k_releaseHeld", "Release Held",
        "k_held", "HELD",
        "k_about", "About",
        "k_aboutTitle", "About this keyboard",
        "k_aboutBody", "This keyboard was made with OSK Maker, an accessibility tool created by {1}.`n`n{1} is handicapped and builds accessibility tools, mostly for games, where the game companies don't."
    )

    I18N["hu"] := Map(
        "winTitle", "OSK Maker - Képernyő-billentyűzet készítő",
        "preset", "Sablon:",
        "presetBlank", "Üres",
        "presetMath", "Matematikai billentyűzet",
        "presetKrita", "Krita / rajzolás",
        "loadPreset", "Sablon betöltése",
        "openLayout", "Elrendezés megnyitása...",
        "saveLayout", "Elrendezés mentése...",
        "colNum", "#",
        "colRow", "Sor",
        "colLabel", "Felirat",
        "colType", "Típus",
        "colAction", "Művelet",
        "lblRow", "Sor:",
        "lblLabel", "Felirat:",
        "lblType", "Típus:",
        "lblAction", "Művelet:",
        "addKey", "Billentyű hozzáadása",
        "updateKey", "Kijelölt módosítása",
        "deleteKey", "Törlés",
        "moveUp", "Fel",
        "moveDown", "Le",
        "help", "Text = a művelet szövegét pontosan úgy írja be, ahogy meg van adva.   Send = AutoHotkey Send szintaxis (z, ^c, {BackSpace}); a ragadó Ctrl/Shift/Alt gombok a Send billentyűkre vonatkoznak.   Hold = nyomva tartó kapcsoló, például Space vagy Ctrl+Space (újabb megnyomásra vagy a billentyűzet bezárásakor felengedi).   Az azonos Sor számú billentyűk egy sorba kerülnek.",
        "grpSettings", "Billentyűzet beállításai",
        "lblTitle", "Cím:",
        "lblBg", "Háttér:",
        "lblFont", "Betűméret:",
        "lblTrans", "Fedettség (30-255):",
        "lblWidth", "Szélesség %:",
        "lblHeight", "Magasság (px):",
        "lblHover", "Rámutatási idő (ms):",
        "chkSticky", "Ragadó Ctrl/Shift/Alt",
        "chkHoverBtn", "Rámutatás gomb",
        "preview", "Előnézet",
        "genAhk", ".ahk készítése...",
        "genExe", ".exe készítése...",
        "language", "Nyelv:",
        "about", "Névjegy",
        "ok", "OK",
        "statusStart", "Tölts be egy sablont, vagy add hozzá az első billentyűt.",
        "added", "Billentyű hozzáadva: '{1}'.",
        "updated", "Billentyű módosítva: '{1}'.",
        "selectFirst", "Előbb jelölj ki egy billentyűt a listában.",
        "deleted", "Billentyű törölve.",
        "presetLoaded", "Sablon betöltve.",
        "layoutSaved", "Elrendezés mentve: {1}",
        "layoutLoaded", "Elrendezés betöltve: {1}",
        "previewStarted", "Az előnézet elindult. A leállításhoz zárd be a billentyűzet ablakát.",
        "saved", "Mentve: {1}",
        "compiling", "Fordítás...",
        "compiled", "Lefordítva: {1}",
        "bgError", "A háttér 6 számjegyű hexadecimális szín legyen, például 1E1E1E.",
        "giveLabel", "Előbb adj feliratot a billentyűnek.",
        "needAction", "A Send és Hold billentyűkhöz meg kell adni a Műveletet.",
        "replaceLayout", "Lecseréled a jelenlegi elrendezést a sablonra?",
        "noKeysSave", "Még nincs mit menteni. Adj hozzá billentyűket, vagy tölts be egy sablont.",
        "notLayout", "Ez nem OSK elrendezésfájl.",
        "noKeysFile", "Az elrendezésfájl nem tartalmaz billentyűket.",
        "couldNotRead", "Nem sikerült beolvasni: {1}`n`n{2}",
        "couldNotWrite", "Nem sikerült írni: {1}`n`n{2}",
        "addOneKey", "Előbb adj hozzá legalább egy billentyűt.",
        "noAhk", "Az AutoHotkey v2 nem található, ezért az előnézet nem indítható.",
        "noCompiler", "Az Ahk2Exe (az AutoHotkey fordítója) nem található.`n`nTelepítsd az AutoHotkey v2-t a fordító opcióval, vagy használd a '.ahk készítése' gombot, és fordítsd le a fájlt saját magad.",
        "compilerStartFail", "A fordítót nem sikerült elindítani: {1}",
        "compileFail", "A fordítás nem hozott létre .exe fájlt. Próbáld a '.ahk készítése' gombot, és fordítsd le kézzel az Ahk2Exe-vel.",
        "dlgSaveLayout", "Elrendezés mentése",
        "fltLayout", "OSK elrendezés (*.osk)",
        "dlgOpenLayout", "Elrendezés megnyitása",
        "dlgSaveAhk", "Billentyűzet-szkript mentése",
        "fltAhk", "AutoHotkey szkript (*.ahk)",
        "dlgSaveExe", "Billentyűzet-program mentése",
        "fltExe", "Program (*.exe)",
        "aboutTitle", "Az OSK Maker névjegye",
        "aboutBy", "Készítette: {1}",
        "aboutVersion", "Verzió: {1}",
        "aboutBody", "Mozgássérült vagyok, és akadálymentesítő eszközöket készítek, főként játékokhoz, ott, ahol a játékgyártók nem teszik.`n`nAz OSK Maker segítségével megtervezheted a saját képernyő-billentyűzetedet, és önálló .ahk szkriptként vagy .exe fájlként exportálhatod, így a billentyűzet igazodik hozzád, és nem fordítva.",
        "k_snapBottom", "Alulra",
        "k_snapTop", "Felülre",
        "k_hoverOff", "Rámutatás: Ki",
        "k_hoverOn", "Rámutatás: Be",
        "k_on", "BE",
        "k_off", "KI",
        "k_releaseHeld", "Tartott felengedése",
        "k_held", "TARTVA",
        "k_about", "Névjegy",
        "k_aboutTitle", "A billentyűzetről",
        "k_aboutBody", "Ezt a billentyűzetet az OSK Maker segítségével készítették, amelyet {1} fejlesztett akadálymentesítő eszközként.`n`n{1} mozgássérült, és akadálymentesítő eszközöket készít, főként játékokhoz, ott, ahol a játékgyártók nem teszik."
    )
}

T(key, args*) {
    global I18N, Lang
    s := ""
    if (I18N.Has(Lang) && I18N[Lang].Has(key))
        s := I18N[Lang][key]
    else if (I18N["en"].Has(key))
        s := I18N["en"][key]
    else
        return key
    return args.Length ? Format(s, args*) : s
}

LoadLanguage() {
    global Lang
    ini := A_ScriptDir . "\OSK_Maker.ini"
    def := "en"
    v := IniRead(ini, "OSK", "Language", def)
    Lang := (v = "hu") ? "hu" : "en"
}

SaveLanguage() {
    global Lang
    ini := A_ScriptDir . "\OSK_Maker.ini"
    try IniWrite(Lang, ini, "OSK", "Language")
}

OnLanguageChange(ctrl, *) {
    global Lang
    newLang := (ctrl.Value = 2) ? "hu" : "en"
    if (newLang = Lang)
        return
    ReadSettings(true)
    Lang := newLang
    SaveLanguage()
    SetTimer(RebuildEditor, -10)
}

RebuildEditor() {
    global G
    x := "", y := ""
    try G.GetPos(&x, &y)
    try G.Destroy()
    BuildEditor()
    if (IsInteger(x) && x > -10000)
        G.Move(x, y)
}

ShowAbout(*) {
    global G, APP_AUTHOR, APP_URL, APP_VERSION
    AG := Gui("+Owner" . G.Hwnd . " -MinimizeBox -MaximizeBox", T("aboutTitle"))
    AG.SetFont("s10", "Segoe UI")
    AG.SetFont("s16 Bold")
    AG.Add("Text", "x20 y16 w480", "OSK Maker")
    AG.SetFont("s11 Bold")
    AG.Add("Text", "x20 y+4 w480", T("aboutBy", APP_AUTHOR))
    AG.SetFont("s10 Norm")
    AG.Add("Text", "x20 y+2 w480", T("aboutVersion", APP_VERSION))
    AG.Add("Text", "x20 y+14 w480", T("aboutBody"))
    lnk := AG.Add("Link", "x20 y+14 w480", 'GitHub: <a href="' . APP_URL . '">' . APP_URL . '</a>')
    lnk.OnEvent("Click", (ctrl, id, href) => Run(href))
    btn := AG.Add("Button", "x20 y+18 w100 h30 Default", T("ok"))
    btn.OnEvent("Click", CloseAboutDlg.Bind(AG))
    AG.OnEvent("Close", CloseAboutDlg.Bind(AG))
    AG.OnEvent("Escape", CloseAboutDlg.Bind(AG))
    G.Opt("+Disabled")
    AG.Show("AutoSize")
}

CloseAboutDlg(dlg, *) {
    global G
    G.Opt("-Disabled")
    dlg.Destroy()
}

; Like Q(), but keeps line breaks (written as `n escapes in the generated script)
QL(s) {
    s := EscAhk(s)
    return '"' . StrReplace(s, "`n", "``n") . '"'
}

; Texts for the generated keyboard, in the language chosen in the editor
BuildLangBlock() {
    keys := ["snapBottom", "snapTop", "hoverOff", "hoverOn", "on", "off", "releaseHeld", "held", "about", "aboutTitle", "aboutBody"]
    out := "global OSK_Lang := Map(`n"
    for i, key in keys {
        if (key = "aboutBody")
            val := T("k_aboutBody", APP_AUTHOR)
        else
            val := T("k_" . key)
        out .= "    " . Q(key) . ", " . QL(val) . (i < keys.Length ? ",`n" : "`n")
    }
    out .= ")`n"
    return out
}
