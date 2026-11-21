# OSK Maker — Version 2

**English** | [Magyar](#magyar)

---

## English

Design your own on-screen keyboard (OSK), then export it as a standalone AutoHotkey script or a compiled `.exe`. Built with accessibility in mind, for example one-handed use, mouse-only input, or dwell (hover) clicking.

The keyboards it generates never take focus from the program you are typing into, so keys go straight to your game, art program, or document.

Created by Dani, who is handicapped and builds accessibility tools, mostly for games, where the game companies don't.

> **⚠️ AI warning:** This program was written with the help of an AI assistant (Claude by Anthropic). AI-written code can contain mistakes, and it has not been tested on every Windows setup or every game and program. Use it at your own risk: try it first with something unimportant, keep backups of your layouts (`.osk` files), and be careful when using generated keyboards or scripts with online or competitive games, where automated input may be against the rules.

### Requirements

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/) (v2.0 or newer)
- Optional: the Ahk2Exe compiler (install AutoHotkey with the compiler option) if you want `.exe` output

### Quick start

1. Double-click `OSK_Maker.ahk`.
2. Pick a preset (Math keyboard or Krita / drawing) and click **Load Preset**, or start from Blank and add your own keys.
3. Click **Preview** to try the keyboard right away.
4. Click **Generate .ahk...** or **Generate .exe...** to save the finished keyboard.

### Language and About

- Use the **Language** dropdown (English / Magyar) at the bottom right of the editor. English is the default. Your choice is saved in `OSK_Maker.ini` next to the script.
- The generated keyboard uses the language selected in the editor when you generate it.
- The **About** button shows who made OSK Maker and the version. Generated keyboards also get a small About button.
- The editor window has a fixed size (it cannot be maximized or resized).

### The editor

#### Key list

Each key has:

| Field | Meaning |
|-------|---------|
| Row | Keys with the same row number share a row. Rows are shown top to bottom in ascending order. |
| Label | The text shown on the button. |
| Type | `Text`, `Send`, or `Hold` (see below). |
| Action | What the key does. For Text keys, leave it empty to type the label itself. |

Buttons: **Add Key**, **Update Selected** (overwrites the selected key with the fields below the list), **Delete**, **Up** and **Down** (change order within the list).

Note: edits in the Row/Label/Type/Action fields are only applied when you click **Add Key** or **Update Selected**.

#### Key types

The type names stay in English in both languages.

- **Text** types the action text exactly as written. Good for symbols and words, such as `π`, `≤`, or `hello`.
- **Send** uses AutoHotkey Send syntax: `z`, `^c`, `{BackSpace}`, `{Esc}`, `^{NumpadAdd}`. The sticky Ctrl, Shift and Alt buttons (if enabled) are added in front of Send keys.
- **Hold** is a press-and-hold toggle, for example `Space` or `Ctrl+Space`. Click once to hold, click again to release. Held keys are always released when the keyboard closes. Use `+` to combine keys, such as `Shift+Space`.

#### Adding Backspace and Enter keys

Backspace and Enter are not letters, so they must use the **Send** type (a **Text** key would only type the characters you see). In the editor:

1. Set **Type** to `Send`.
2. Type the symbol you want on the button into **Label**.
3. Type the key name in braces into **Action**.
4. Click **Add Key** (or **Update Selected** to change an existing key).

| Key | Label (example) | Type | Action |
|-----|-----------------|------|--------|
| Backspace | `⌫` | Send | `{BackSpace}` |
| Enter | `↵` | Send | `{Enter}` |
| Delete | `⌦` | Send | `{Delete}` |
| Tab | `⇥` | Send | `{Tab}` |
| Escape | `Esc` | Send | `{Esc}` |
| Space | `␣` | Send | `{Space}` |
| Shift+Enter | `⇧↵` | Send | `+{Enter}` |

Tips:

- The braces `{ }` are required, and the key name is not case sensitive (`{backspace}` works too).
- The label is only decoration. You can use any text or symbol, for example `Bksp` or `Enter` if a symbol does not display well in your font. See "How to enter a symbol" below.
- To delete several characters in one click, repeat the key: `{BackSpace 5}`.
- If the sticky Ctrl/Shift/Alt buttons are enabled, they are applied to these keys too.

##### How to enter a symbol

Windows has no simple key for symbols such as `⌫` or `↵`, so copy them and paste them into the **Label** field.

**Copy and paste (easiest):** select a symbol here, copy it (**Ctrl+C**), and paste it into the Label field (**Ctrl+V**).

`⌫` Backspace &nbsp; `↵` Enter &nbsp; `⌦` Delete &nbsp; `⇥` Tab &nbsp; `␣` Space &nbsp; `⇧` Shift

**Windows Character Map (always works):**

1. Press the Windows key, type `Character Map`, and open it.
2. Tick **Advanced view** at the bottom.
3. In the **Go to Unicode** box, type the code: `232B` for `⌫`, `21B5` for `↵`, `2326` for `⌦`, `21E5` for `⇥`, `2423` for `␣`, `21E7` for `⇧`.
4. Click **Select**, then **Copy**.
5. Click in the Label field in OSK Maker and paste with **Ctrl+V**.

**Windows symbol panel:** press **Win + .** (the period key) and look in the symbols or arrows tab.

Typing a symbol by voice (speech-to-text) usually does not work, so pasting is more reliable. If a symbol does not work for you, type plain text such as `Bksp` or `Enter` in the Label field. The label is only decoration; the **Action** field (`{BackSpace}`, `{Enter}`) is what makes the key work.

#### Keyboard settings

| Setting | Meaning |
|---------|---------|
| Title | Window title of the generated keyboard. |
| Background | 6-digit hex color, for example `1E1E1E`. |
| Font size | Button text size (6 to 48). |
| Opacity | Window transparency (30 to 255). |
| Width % | Keyboard width as a percentage of the screen (10 to 100). |
| Height (px) | Keyboard height (80 to 1200). |
| Hover delay (ms) | How long the pointer must rest on a key in hover mode before it clicks (100 to 5000). |
| Sticky Ctrl/Shift/Alt | Adds toggle buttons whose state applies to the next Send key. |
| Hover button | Adds a **Hover: On/Off** button for dwell clicking. |

### Saving and loading layouts

- **Save Layout...** writes a `.osk` file (plain tab-separated text, UTF-8). Settings and all keys are saved.
- **Open Layout...** loads a `.osk` file back into the editor.
- Presets can be loaded, edited, and then saved as your own layout.

Layout file format, if you want to edit by hand:

```
OSKLAYOUT<TAB>1
SET<TAB>name<TAB>value
KEY<TAB>row<TAB>type<TAB>label<TAB>action
```

### What the generated keyboard does

- Always on top and resizable; does not steal focus.
- **Snap Bottom** and **Snap Top** buttons move it to the screen edge.
- **Hover** mode clicks a key after the pointer rests on it for the hover delay.
- **Ctrl / Shift / Alt** sticky buttons apply to the next Send key, then reset.
- **Release Held** appears when the layout has Hold keys, and releases everything currently held.
- **About** shows a short note about OSK Maker.
- Maximizing the window restores it to the configured size and position instead.

### Command line

```
OSK_Maker.ahk /build layout.osk out.ahk
OSK_Maker.ahk /preset math out.ahk
OSK_Maker.ahk /preset krita out.ahk
```

- `/build` turns a saved `.osk` layout into a keyboard script without opening the editor.
- `/preset` generates a keyboard script from the built-in `math` or `krita` preset.

The language used for command-line builds is the one saved in `OSK_Maker.ini` (English if there is none).

### Troubleshooting

- **Preview does nothing:** AutoHotkey v2 was not found. Install it, or run OSK Maker through the v2 interpreter.
- **Generate .exe fails:** Ahk2Exe was not found. Use **Generate .ahk...** and compile it yourself.
- **Background color error:** use exactly six hex digits, such as `2B2B2B`.
- **Cannot save or open a file:** the message shows the underlying Windows error. Try saving to a folder you have write access to, such as Documents.
- **A key types the wrong thing:** check its Type. Text sends literal characters, while Send interprets `^`, `+`, `!` and `{braces}` as AutoHotkey syntax.

---

<a id="magyar"></a>

## Magyar

[English](#english)

Tervezd meg a saját képernyő-billentyűzetedet (OSK), majd exportáld önálló AutoHotkey szkriptként vagy lefordított `.exe` fájlként. Akadálymentességet szem előtt tartva készült, például egykezes használathoz, csak egérrel történő bevitelhez vagy rámutatásos (hover) kattintáshoz.

A generált billentyűzetek soha nem veszik el a fókuszt attól a programtól, amelybe gépelsz, így a billentyűk közvetlenül a játékodba, rajzprogramodba vagy dokumentumodba érkeznek.

Készítette Dani, aki mozgássérült, és akadálymentesítő eszközöket készít, főként játékokhoz, ott, ahol a játékgyártók nem teszik.

> **⚠️ MI-figyelmeztetés:** Ezt a programot egy MI-asszisztens (az Anthropic Claude-ja) segítségével írták. Az MI által írt kód tartalmazhat hibákat, és nem tesztelték minden Windows-beállításon, sem minden játékkal vagy programmal. Saját felelősségedre használd: először próbáld ki valami lényegtelen dologgal, tarts biztonsági másolatot az elrendezéseidről (`.osk` fájlok), és légy óvatos a generált billentyűzetekkel és szkriptekkel online vagy versenyjátékokban, ahol az automatikus bevitel szabályellenes lehet.

### Követelmények

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/) (v2.0 vagy újabb)
- Opcionális: az Ahk2Exe fordító (telepítsd az AutoHotkey-t a fordító opcióval), ha `.exe` kimenetet szeretnél

### Gyors kezdés

1. Kattints duplán az `OSK_Maker.ahk` fájlra.
2. Válassz egy sablont (Matematikai billentyűzet vagy Krita / rajzolás), és kattints a **Sablon betöltése** gombra, vagy indulj az Üres sablonnal, és add hozzá a saját billentyűidet.
3. Kattints az **Előnézet** gombra, hogy rögtön kipróbáld a billentyűzetet.
4. A kész billentyűzet mentéséhez kattints a **.ahk készítése...** vagy a **.exe készítése...** gombra.

### Nyelv és Névjegy

- Használd a szerkesztő jobb alsó sarkában lévő **Nyelv** legördülő menüt (English / Magyar). Az alapértelmezett nyelv az angol. A választásod a szkript melletti `OSK_Maker.ini` fájlba kerül.
- A generált billentyűzet azt a nyelvet használja, amelyik a szerkesztőben ki volt választva a generáláskor.
- A **Névjegy** gomb megmutatja, ki készítette az OSK Makert, és melyik verziót használod. A generált billentyűzetek is kapnak egy kis Névjegy gombot.
- A szerkesztő ablak mérete rögzített (nem lehet maximalizálni vagy átméretezni).

### A szerkesztő

#### Billentyűlista

Minden billentyűnek ezek a mezői vannak:

| Mező | Jelentés |
|------|----------|
| Sor | Az azonos sorszámú billentyűk egy sorba kerülnek. A sorok fentről lefelé, növekvő sorrendben jelennek meg. |
| Felirat | A gombon megjelenő szöveg. |
| Típus | `Text`, `Send` vagy `Hold` (lásd alább). |
| Művelet | Mit csinál a billentyű. Text típusnál hagyd üresen, ha magát a feliratot szeretnéd begépelni. |

Gombok: **Billentyű hozzáadása**, **Kijelölt módosítása** (felülírja a kijelölt billentyűt a lista alatti mezők tartalmával), **Törlés**, **Fel** és **Le** (a lista sorrendjének módosítása).

Megjegyzés: a Sor/Felirat/Típus/Művelet mezők módosításai csak akkor lépnek érvénybe, ha rákattintasz a **Billentyű hozzáadása** vagy a **Kijelölt módosítása** gombra.

#### Billentyűtípusok

A típusok nevei mindkét nyelven angolul maradnak.

- **Text** pontosan úgy gépeli be a művelet szövegét, ahogy meg van adva. Jó szimbólumokhoz és szavakhoz, például `π`, `≤` vagy `hello`.
- **Send** AutoHotkey Send szintaxist használ: `z`, `^c`, `{BackSpace}`, `{Esc}`, `^{NumpadAdd}`. A ragadó Ctrl, Shift és Alt gombok (ha engedélyezve vannak) a Send billentyűk elé kerülnek.
- **Hold** nyomva tartó kapcsoló, például `Space` vagy `Ctrl+Space`. Egy kattintás lenyomva tartja, még egy kattintás felengedi. A tartott billentyűk a billentyűzet bezárásakor mindig felengedődnek. A billentyűket `+` jellel kombinálhatod, például `Shift+Space`.

#### Backspace és Enter billentyű hozzáadása

A Backspace és az Enter nem betűk, ezért a **Send** típust kell használniuk (a **Text** billentyű csak a látható karaktereket gépelné be). A szerkesztőben:

1. Állítsd a **Típust** `Send`-re.
2. A **Felirat** mezőbe írd be a gombra szánt szimbólumot.
3. A **Művelet** mezőbe írd be a billentyű nevét kapcsos zárójelben.
4. Kattints a **Billentyű hozzáadása** gombra (meglévő billentyű módosításához a **Kijelölt módosítása** gombra).

| Billentyű | Felirat (példa) | Típus | Művelet |
|-----------|-----------------|-------|---------|
| Backspace | `⌫` | Send | `{BackSpace}` |
| Enter | `↵` | Send | `{Enter}` |
| Delete | `⌦` | Send | `{Delete}` |
| Tab | `⇥` | Send | `{Tab}` |
| Escape | `Esc` | Send | `{Esc}` |
| Szóköz | `␣` | Send | `{Space}` |
| Shift+Enter | `⇧↵` | Send | `+{Enter}` |

Tippek:

- A kapcsos zárójelek `{ }` kötelezőek, a billentyű neve pedig nem kis- és nagybetű érzékeny (a `{backspace}` is működik).
- A felirat csak dekoráció. Bármilyen szöveget vagy szimbólumot használhatsz, például `Bksp` vagy `Enter` feliratot, ha a betűtípusodban egy szimbólum nem jelenik meg jól. Lásd lent: "Szimbólum beírása".
- Több karakter törléséhez egy kattintással ismételd a billentyűt: `{BackSpace 5}`.
- Ha a ragadó Ctrl/Shift/Alt gombok engedélyezve vannak, ezekre a billentyűkre is vonatkoznak.

##### Szimbólum beírása

A Windowsban nincs egyszerű billentyű az olyan szimbólumokhoz, mint a `⌫` vagy a `↵`, ezért másold ki őket, és illeszd be a **Felirat** mezőbe.

**Másolás és beillesztés (a legegyszerűbb):** jelölj ki egy szimbólumot itt, másold ki (**Ctrl+C**), és illeszd be a Felirat mezőbe (**Ctrl+V**).

`⌫` Backspace &nbsp; `↵` Enter &nbsp; `⌦` Delete &nbsp; `⇥` Tab &nbsp; `␣` Szóköz &nbsp; `⇧` Shift

**Windows Karaktertábla (mindig működik):**

1. Nyomd meg a Windows gombot, írd be: `Karaktertábla` (angol Windowsban `Character Map`), és nyisd meg.
2. Jelöld be alul a **Speciális nézet** (Advanced view) négyzetet.
3. A **Ugrás Unicode-ra** (Go to Unicode) mezőbe írd be a kódot: `232B` a `⌫`-hoz, `21B5` a `↵`-hoz, `2326` a `⌦`-hoz, `21E5` a `⇥`-hoz, `2423` a `␣`-hoz, `21E7` a `⇧`-hoz.
4. Kattints a **Kijelölés** (Select), majd a **Másolás** (Copy) gombra.
5. Kattints az OSK Maker Felirat mezőjébe, és illeszd be a **Ctrl+V**-vel.

**Windows szimbólumpanel:** nyomd meg a **Win + .** (pont) billentyűkombinációt, és keresd a szimbólumok vagy nyilak fület.

Szimbólum hangalapú beírása (beszédfelismeréssel) általában nem működik, ezért a beillesztés megbízhatóbb. Ha egy szimbólum nem működik, írj egyszerű szöveget a Felirat mezőbe, például `Bksp` vagy `Enter`. A felirat csak dekoráció; a **Művelet** mező (`{BackSpace}`, `{Enter}`) teszi működővé a billentyűt.

#### Billentyűzet beállításai

| Beállítás | Jelentés |
|-----------|----------|
| Cím | A generált billentyűzet ablakának címe. |
| Háttér | 6 számjegyű hexadecimális szín, például `1E1E1E`. |
| Betűméret | A gombok szövegének mérete (6–48). |
| Fedettség | Az ablak átlátszatlansága (30–255). |
| Szélesség % | A billentyűzet szélessége a képernyő százalékában (10–100). |
| Magasság (px) | A billentyűzet magassága (80–1200). |
| Rámutatási idő (ms) | Mennyi ideig kell a mutatónak egy billentyűn pihennie rámutatásos módban, mielőtt kattint (100–5000). |
| Ragadó Ctrl/Shift/Alt | Kapcsológombokat ad hozzá, amelyek állapota a következő Send billentyűre vonatkozik. |
| Rámutatás gomb | Egy **Rámutatás: Be/Ki** gombot ad hozzá a rámutatásos kattintáshoz. |

### Elrendezések mentése és betöltése

- Az **Elrendezés mentése...** egy `.osk` fájlt ír (egyszerű, tabulátorral tagolt UTF-8 szöveg). A beállítások és az összes billentyű mentésre kerül.
- Az **Elrendezés megnyitása...** egy `.osk` fájlt tölt vissza a szerkesztőbe.
- A sablonokat be lehet tölteni, szerkeszteni, majd saját elrendezésként elmenteni.

Az elrendezésfájl formátuma, ha kézzel szeretnéd szerkeszteni:

```
OSKLAYOUT<TAB>1
SET<TAB>name<TAB>value
KEY<TAB>row<TAB>type<TAB>label<TAB>action
```

### Mit tud a generált billentyűzet

- Mindig legfelül van, átméretezhető, és nem veszi el a fókuszt.
- Az **Alulra** és **Felülre** gombok a képernyő széléhez igazítják.
- A **Rámutatás** mód kattint egy billentyűre, miután a mutató a rámutatási ideig rajta pihent.
- A **Ctrl / Shift / Alt** ragadó gombok a következő Send billentyűre vonatkoznak, majd visszaállnak.
- A **Tartott felengedése** gomb akkor jelenik meg, ha az elrendezésben vannak Hold billentyűk, és felenged mindent, ami éppen nyomva van tartva.
- A **Névjegy** egy rövid ismertetőt mutat az OSK Makerről.
- Az ablak maximalizálása helyett a beállított méretére és helyére állítja vissza.

### Parancssor

```
OSK_Maker.ahk /build layout.osk out.ahk
OSK_Maker.ahk /preset math out.ahk
OSK_Maker.ahk /preset krita out.ahk
```

- A `/build` egy mentett `.osk` elrendezésből billentyűzet-szkriptet készít a szerkesztő megnyitása nélkül.
- A `/preset` a beépített `math` vagy `krita` sablonból készít billentyűzet-szkriptet.

A parancssoros buildek nyelve az `OSK_Maker.ini` fájlban elmentett nyelv (ha nincs ilyen, angol).

### Hibaelhárítás

- **Az előnézet nem csinál semmit:** az AutoHotkey v2 nem található. Telepítsd, vagy futtasd az OSK Makert a v2 értelmezővel.
- **A .exe készítése sikertelen:** az Ahk2Exe nem található. Használd a **.ahk készítése...** gombot, és fordítsd le magad.
- **Háttérszín hiba:** pontosan hat hexadecimális számjegyet használj, például `2B2B2B`.
- **Nem lehet fájlt menteni vagy megnyitni:** az üzenet megmutatja a mögöttes Windows-hibát. Próbálj olyan mappába menteni, ahová van írási jogod, például a Dokumentumokba.
- **Egy billentyű rosszat gépel:** ellenőrizd a Típusát. A Text szó szerinti karaktereket küld, a Send viszont a `^`, `+`, `!` és `{kapcsos zárójelek} jeleket AutoHotkey szintaxisként értelmezi.
