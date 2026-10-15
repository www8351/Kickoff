<div dir="rtl">

# 🚀 `Kickoff`

פקודה אחת פותחת סביבת עבודה של קלוד קוד. הכללים הגלובליים, גיט, הגיבויים וקובץ הכללים של הפרויקט מוכנים לפני שקלוד עולה.

![Windows](https://img.shields.io/badge/platform-Windows-blue) ![PowerShell](https://img.shields.io/badge/shell-PowerShell-blue)

## 🎬 ככה זה נראה

הרצה ראשונה של `ccode` בתיקייה חדשה שיש בה קוד ואין בה מאגר גיט:

```text
[Global] ~/.claude/CLAUDE.md synced.
[Git] .gitignore created.
[Git] Repository initialized.
[Git] commit-msg hook verified, trailers stripped.
[Git] Baseline commit created.
[Protocol] CLAUDE.md provisioned (v6). Bootstrap runs on your first message.
```

אחר כך קלוד קוד עולה נקי ומחכה להודעה הראשונה שלך.

הפעלת שורת המכסה באותה תיקייה:

```text
[Quota] statusLine active for 'my-project'. Restart Claude Code.
```

## ✋ מה הוא עושה

הפרופיל נותן שתי פקודות: `ccode` ו`qline`.

`ccode` עובר על השלבים האלה, בסדר הזה, בכל הרצה:

1. 📝 כותב את קובץ הכללים הגלובלי `~/.claude/CLAUDE.md`. הטקסט קבוע בתוך הפרופיל: סגנון כתיבה, כללי עברית וכתיבה מימין לשמאל, שפת התיעוד, תוספים, והרגלי עבודה בגיט.
2. 🚧 בודק את התיקייה. תיקיית הבית, `Downloads`, `Desktop`, `Documents` ו`OneDrive` נדחות מיד. תיקייה בלי `.git`, בלי `CLAUDE.md` ובלי קובץ קוד נפוץ, למשל `.py`, `.js`, `.ps1`, `.md` או `.json`, שואלת קודם. כל תשובה חוץ מ`y` מבטלת.
3. 💾 מגבה את קובצי המצב של הפרויקט: `LEDGER.md`, `LEDGER-archive.md`, `CLAUDE.md`, ואם הם קיימים גם את הקבצים הישנים `STATUS.md`, `PROGRESS.md` ו`DECISIONS.md`. העותקים נשמרים ב`~/.claude/backups/<שם התיקייה>`. נשמרות 20 תמונות המצב האחרונות.
4. 🌱 מכין את גיט. יוצר `.gitignore`, או מוסיף לסופו את הבלוק המנוהל אם אין בו שורה `# ccode-managed`. מריץ `git init` אם צריך. מתקין וו `commit-msg`. יוצר קומיט בסיס אם במאגר עוד אין אף קומיט.
5. 📋 בודק את `CLAUDE.md` של הפרויקט. חסר: נכתב מהתבנית המובנית. עדכני: נשאר. ישן, בלי סימון גרסה, או שחסר בו חלק חובה: הקובץ הישן נשמר בשם `CLAUDE.md.bak-<חותמת זמן>` ומוחלף.
6. ▶️ מפעיל את `claude` עם כל הארגומנטים שנתת ל`ccode`. שום הודעת פתיחה לא נשלחת.

התבנית של הפרויקט אומרת לקלוד קוד לנהל שני קבצים. `README.md` מתאר את הפרויקט. `LEDGER.md` מחזיק שלושה חלקים, `ISSUES`, `ACTIONS` ו`DECISIONS`, וכל רשומה כתובה בשלוש שורות: `Issue`, `Action`, `Status`. החלטה שמסומנת `FINAL` נשארת סגורה עד שאתה כותב `unlock decision` יחד עם שם הרשומה. רשומות `ACTIONS` בנות יותר מ 90 יום מתקצרות לשורה אחת כל אחת ועוברות ל`LEDGER-archive.md`. אם קיימים קבצים ישנים בשם `STATUS.md`, `PROGRESS.md` או `DECISIONS.md`, קלוד ממזג אותם לתוך `LEDGER.md` ומוחק אותם בהודעה הראשונה שלך.

הבלוק ב`.gitignore` משאיר כל קובץ `.md` מקומי, חוץ מ`README.md`, `LEDGER.md` וקובצי `.md` תחת `docs`. הקובץ `CLAUDE.md` לא נכנס לגיט. הבלוק מתעלם גם מסודות (`.env`, `*.pem`, `*.key`, `*.pfx`, `*.p12`, `secrets.*`, `credentials.*`), משאריות של פייתון ונוד, מקובצי לוג, מ`CLAUDE.md.bak*`, מ`.claude/worktrees/` ומ`.claude/settings.local.json`.

קומיט הבסיס מוסיף הכול, ואז מוציא כל קובץ ששמו נראה כמו סוד: קובצי `.env`, מפתחות ותעודות, `id_rsa`, `id_ed25519`, `id_ecdsa`, או שם שמכיל `secret` או `credential`. מה שהוצא מודפס באדום.

הוו `commit-msg` מוחק מכל הודעת קומיט שורות `Co-Authored-By: Claude`, כל שורת `Co-Authored-By` עם `noreply@anthropic.com`, ושורות `Generated with Claude Code`. בגיט 2.36 ומעלה, `ccode` מריץ את הוו על הודעת בדיקה ומדווח אם הוא עבד.

`qline` מפעיל שורת מכסה בפרויקט הנוכחי בלבד:

1. 📦 בהרצה הראשונה הוא משכפל את [Claude_Quota_Line](https://github.com/www8351/Claude_Quota_Line) ל`~/.claude/quota-line-src`. בהרצות הבאות הוא מריץ עליו `git pull`, אלא אם נתת `-NoUpdate`.
2. 📄 מעתיק את `statusline.ps1` ל`~/.claude/quota-line`. עותק אחד משרת את כל הפרויקטים במחשב.
3. ⚙️ כותב רשומת `statusLine` לקובץ `.claude/settings.local.json` של הפרויקט. הרשומה מריצה את הסקריפט עם `pwsh` אם הוא מותקן, ואחרת עם `powershell`. הפרמטר שנשלח כברירת מחדל הוא `-Align right`.
4. 🙈 מוסיף את `.claude/settings.local.json` ל`.gitignore`, אם הקובץ קיים והשורה חסרה בו.

```powershell
qline                          # turn on in this project
qline -Off                     # turn off in this project
qline -NoUpdate                # turn on without pulling the source
qline -ExtraArgs "<params>"    # pass parameters to statusline.ps1
```

אחרי `qline` מפעילים מחדש את קלוד קוד כדי לראות את השינוי.

## 🚫 מה הוא אף פעם לא עושה

* לא נוגע בקובץ הגלובלי `~/.claude/settings.json`. שורת המכסה יושבת בקובץ ההגדרות של כל פרויקט בנפרד, ולכן פרויקט בלי `qline` לא מציג שורת מכסה בכלל.
* לא מתקין תוספים או מיומנויות. אלה מגיעים ממערכת התוספים של קלוד קוד עצמו.
* לא דוחף, ולא מוסיף מאגר מרוחק.
* לא יוצר קומיטים אחרי קומיט הבסיס. בהרצות הבאות הוא רק מדווח על שינויים שעוד לא נשמרו.
* לא שולח לקלוד הודעה בעלייה. קלוד עולה נקי ומחכה לך.
* לא מוחק בעצמו את הקבצים הישנים `STATUS.md`, `PROGRESS.md` או `DECISIONS.md`. הוא מגבה אותם ומדפיס הודעה. המיזוג קורה בתוך קלוד קוד, בהודעה הראשונה שלך, אחרי שאתה מאשר את המחיקה.

## 📥 התקנה

צריך פאוורשל של חלונות, גיט, וקלוד קוד עם הפקודה `claude` בנתיב החיפוש. `qline` צריך גם גישה לרשת בשביל השכפול הראשון. אם `pwsh` מותקן, שורת המכסה משתמשת בו, אבל הוא לא חובה. גם `bash` לא חובה. הוא משמש רק כדי לסמן את הוו כקובץ הרצה. גיט 2.36 ומעלה מאפשר את בדיקת הוו. בגרסה ישנה יותר הבדיקה מדולגת.

קובץ הפרופיל מחליף את `$PROFILE` כולו. כל מה שיש היום בפרופיל שלך נעלם אחרי ההעתקה, אז שומרים גיבוי.

1. בעמוד המאגר לוחצים `Code` ואז `Download ZIP`, ומחלצים את הקובץ.
2. פותחים פאוורשל בתיקייה שחולצה.
3. מגבים את הפרופיל הנוכחי, אם יש כזה:
   ```powershell
   if (Test-Path $PROFILE) { Copy-Item $PROFILE "$PROFILE.bak" }
   ```
4. מעתיקים את הקובץ במקומו:
   ```powershell
   New-Item -ItemType Directory -Force -Path (Split-Path $PROFILE) | Out-Null
   Copy-Item .\Microsoft.PowerShell_profile.ps1 $PROFILE
   ```
5. סוגרים את פאוורשל ופותחים אותו מחדש.

אחר כך משתמשים:

1. נכנסים עם `cd` לתיקיית פרויקט. לא לתיקיית הבית, ולא ל`Downloads`, `Desktop`, `Documents` או `OneDrive` עצמן. תיקייה בתוכן עובדת.
2. מריצים `ccode`.
3. לא חובה: מריצים `qline`, ואז מפעילים מחדש את קלוד קוד.

## ⚠️ לפני ההרצה הראשונה

כל הרצה של `ccode` דורסת את `~/.claude/CLAUDE.md` עם הכללים שבתוך הפרופיל. מה שהיה שם מוחלף, ואין גיבוי. זה קורה בכל הרצה, גם בתיקייה שהבדיקה דוחה. כדי לשמור כללים גלובליים משלך, כותבים אותם בטקסט שבתוך `Sync-ClaudeGlobalRules` בפרופיל, לפני שמריצים `ccode`.

כל הרצה גם כותבת מחדש את הוו `commit-msg` של המאגר. וו שכתבת שם בעצמך מוחלף.

מריצים קודם בתיקיית ניסיון ריקה עם קובץ קוד אחד, וקוראים את השורות שהוא מדפיס.

## ❓ שאלות ותשובות

**למה `ccode` דוחה את תיקיית `Downloads` שלי?**
בתיקיות העליונות האלה תמיד יש איזה קובץ `.json` או `.md`, כך שבדיקת הקבצים הייתה מעבירה אותן בטעות. לכן הן נדחות בלי בדיקה. רק התיקייה עצמה חסומה. תיקיית פרויקט בתוך `Downloads` עובדת.

**ערכתי את `CLAUDE.md` של הפרויקט, ו`ccode` החליף אותו. למה?**
הוא מחליף את הקובץ כשסימון הגרסה ישן מ 6 או חסר, או כשאחת מהמילים האלה נעלמה: `LEDGER.md`, `ISSUES`, `ACTIONS`, `DECISIONS`, `Decision Permanence`. עריכה ששומרת על הסימון ועל המילים האלה נשארת. הקובץ הישן נמצא בפרויקט בשם `CLAUDE.md.bak-<חותמת זמן>`, וגם ב`~/.claude/backups`.

**איפה הגיבויים שלי?**
ב`~/.claude/backups/<שם התיקייה>`, עותק אחד עם חותמת זמן לכל קובץ בכל הרצה. 20 תמונות המצב האחרונות נשמרות, הישנות יותר נמחקות. שני פרויקטים עם אותו שם תיקייה חולקים תיקיית גיבוי אחת.

**לפרויקט שלי כבר יש `.gitignore`. מה קורה לו?**
אם אין בו שורה `# ccode-managed`, הבלוק המנוהל נוסף בסופו. אם השורה קיימת, לא נוגעים בקובץ.

**קומיט הבסיס יכול לתפוס את הסודות שלי?**
קבצים ש`.gitignore` מתעלם מהם לא נכנסים בכלל. קובץ שעבר בכל זאת ושמו נראה כמו סוד מוצא מהקומיט ומודפס באדום. עוברים על הרשימה ומוסיפים ביד רק מה שבטוח. הבדיקה קוראת שמות קבצים, לא תוכן.

**איך מעבירים דגלים לקלוד קוד?**
כותבים אותם אחרי `ccode`. הכול עובר ישר ל`claude`.

**איך מסירים את שורת המכסה?**
מריצים `qline -Off` בפרויקט. הפקודה מוחקת את רשומת `statusLine` ומשאירה את שאר קובץ ההגדרות כמו שהוא.

## 🤝 עובד עם

פאוורשל 5.1 של חלונות. `qline` מעדיף `pwsh` כשהוא מותקן.

![PowerShell](https://img.shields.io/badge/shell-PowerShell-blue)

## 📦 מה יש במאגר

המאגר הזה מחזיק את גרסת שורת הפקודה. גרסה שולחנית מתוכננת.

</div>

---

# 🚀 `Kickoff`

One command opens a Claude Code workspace. Global rules, git, backups and the project rules file are in place before Claude starts.

![Windows](https://img.shields.io/badge/platform-Windows-blue) ![PowerShell](https://img.shields.io/badge/shell-PowerShell-blue)

## 🎬 What it looks like

First `ccode` in a new folder that holds code but no git repository:

```text
[Global] ~/.claude/CLAUDE.md synced.
[Git] .gitignore created.
[Git] Repository initialized.
[Git] commit-msg hook verified, trailers stripped.
[Git] Baseline commit created.
[Protocol] CLAUDE.md provisioned (v6). Bootstrap runs on your first message.
```

Then Claude Code starts clean and waits for your first message.

Turning on the quota line in the same folder:

```text
[Quota] statusLine active for 'my-project'. Restart Claude Code.
```

## ✋ What it does

The profile gives you two commands: `ccode` and `qline`.

`ccode` runs these steps, in this order, on every run:

1. 📝 Writes the global rules file `~/.claude/CLAUDE.md`. The text is fixed inside the profile: writing style, Hebrew and RTL rules, documentation language, plugins, and git habits.
2. 🚧 Checks the folder. Your home folder, `Downloads`, `Desktop`, `Documents` and `OneDrive` are refused outright. A folder with no `.git`, no `CLAUDE.md` and no common code file (for example `.py`, `.js`, `.ps1`, `.md` or `.json`) asks first. Any answer other than `y` aborts.
3. 💾 Backs up the project state files: `LEDGER.md`, `LEDGER-archive.md`, `CLAUDE.md`, and the old `STATUS.md`, `PROGRESS.md` and `DECISIONS.md` if they exist. Copies go to `~/.claude/backups/<folder name>`. The 20 most recent snapshots are kept.
4. 🌱 Sets up git. Creates `.gitignore`, or appends the managed block if the file has no `# ccode-managed` line. Runs `git init` if needed. Installs a `commit-msg` hook. Makes a baseline commit if the repository has no commits yet.
5. 📋 Checks the project `CLAUDE.md`. Missing: written from the built in template. Current: kept. Outdated, without a version marker, or missing a required section: the old file is saved as `CLAUDE.md.bak-<timestamp>` and replaced.
6. ▶️ Starts `claude` with whatever arguments you gave `ccode`. No opening prompt is injected.

The project template tells Claude Code to keep two files. `README.md` describes the project. `LEDGER.md` holds three sections, `ISSUES`, `ACTIONS` and `DECISIONS`, and every entry is three lines: `Issue`, `Action`, `Status`. A decision marked `FINAL` stays closed until you write `unlock decision` together with the entry name. `ACTIONS` entries older than 90 days are condensed to one line each and moved to `LEDGER-archive.md`. If old `STATUS.md`, `PROGRESS.md` or `DECISIONS.md` files exist, Claude merges them into `LEDGER.md` and deletes them on your first message.

The `.gitignore` block keeps every `.md` file local except `README.md`, `LEDGER.md` and `.md` files under `docs`. `CLAUDE.md` stays out of git. The block also ignores secrets (`.env`, `*.pem`, `*.key`, `*.pfx`, `*.p12`, `secrets.*`, `credentials.*`), Python and Node leftovers, log files, `CLAUDE.md.bak*`, `.claude/worktrees/` and `.claude/settings.local.json`.

The baseline commit stages everything, then unstages any file whose name looks like a secret: `.env` files, keys and certificates, `id_rsa`, `id_ed25519`, `id_ecdsa`, or a name containing `secret` or `credential`. Whatever it skipped is printed in red.

The `commit-msg` hook removes `Co-Authored-By: Claude` lines, any `Co-Authored-By` line with `noreply@anthropic.com`, and `Generated with Claude Code` lines from every commit message. On git 2.36 or newer, `ccode` runs the hook on a test message and reports whether it worked.

`qline` turns on a quota status line for the current project only:

1. 📦 The first run clones [Claude_Quota_Line](https://github.com/www8351/Claude_Quota_Line) to `~/.claude/quota-line-src`. Later runs `git pull` it, unless you pass `-NoUpdate`.
2. 📄 Copies `statusline.ps1` to `~/.claude/quota-line`. One copy serves every project on the machine.
3. ⚙️ Writes a `statusLine` entry into the project's `.claude/settings.local.json`. The entry runs the script with `pwsh` when it is installed, otherwise with `powershell`. The default parameter is `-Align right`.
4. 🙈 Adds `.claude/settings.local.json` to `.gitignore`, if the file exists and the line is missing.

```powershell
qline                          # turn on in this project
qline -Off                     # turn off in this project
qline -NoUpdate                # turn on without pulling the source
qline -ExtraArgs "<params>"    # pass parameters to statusline.ps1
```

Restart Claude Code after `qline` to see the change.

## 🚫 What it never does

* Never touches the global `~/.claude/settings.json`. The quota line lives in each project's own settings file, so a project without `qline` shows no quota line at all.
* Never installs plugins or skills. Those come from Claude Code's own plugin system.
* Never pushes, and never adds a remote.
* Never commits after the baseline. Later runs only report uncommitted changes.
* Never sends Claude a prompt on startup. Claude starts clean and waits for you.
* Never deletes the old `STATUS.md`, `PROGRESS.md` or `DECISIONS.md` itself. It backs them up and prints a notice. The merge happens inside Claude Code, on your first message, after you approve the deletions.

## 📥 Install

You need Windows PowerShell, Git, and Claude Code with the `claude` command on your PATH. `qline` also needs network access for the first clone. `pwsh` is used for the quota line when it is installed, but it is not required. Bash is optional. It is used only to mark the hook as executable. Git 2.36 or newer enables the hook self test. Older git skips it.

The profile file is a full replacement for `$PROFILE`. Anything in your current profile is gone after the copy, so keep a backup.

1. On the repository page click `Code`, then `Download ZIP`, and extract it.
2. Open PowerShell in the extracted folder.
3. Back up your current profile, if you have one:
   ```powershell
   if (Test-Path $PROFILE) { Copy-Item $PROFILE "$PROFILE.bak" }
   ```
4. Copy the file over it:
   ```powershell
   New-Item -ItemType Directory -Force -Path (Split-Path $PROFILE) | Out-Null
   Copy-Item .\Microsoft.PowerShell_profile.ps1 $PROFILE
   ```
5. Close PowerShell and open it again.

Then use it:

1. `cd` into a project folder. Not your home folder, and not `Downloads`, `Desktop`, `Documents` or `OneDrive` themselves. A folder inside them is fine.
2. Run `ccode`.
3. Optional: run `qline`, then restart Claude Code.

## ⚠️ Before the first run

Every `ccode` run overwrites `~/.claude/CLAUDE.md` with the rules built into the profile. Whatever you had there is replaced, and no backup is made. This happens on every run, even in a folder the guard refuses. To keep your own global rules, put them in the text inside `Sync-ClaudeGlobalRules` in the profile before you run `ccode`.

Every run also rewrites the repository's `commit-msg` hook. A hook you wrote there yourself is replaced.

Try it first in an empty test folder with one code file, and read the lines it prints.

## ❓ Questions and answers

**Why does `ccode` refuse my Downloads folder?**
Those top level folders always hold some `.json` or `.md` file, so the file check would pass them by mistake. They are refused flat. Only the folder itself is blocked. A project folder inside `Downloads` works.

**I edited my project `CLAUDE.md` and `ccode` replaced it. Why?**
It replaces the file when the version marker is older than 6 or missing, or when one of these words is gone: `LEDGER.md`, `ISSUES`, `ACTIONS`, `DECISIONS`, `Decision Permanence`. Edits that keep the marker and those words survive. The old file is in the project as `CLAUDE.md.bak-<timestamp>`, and in `~/.claude/backups`.

**Where are my backups?**
In `~/.claude/backups/<folder name>`, one timestamped copy per file per run. The 20 most recent snapshots stay, older ones are deleted. Two projects with the same folder name share one backup folder.

**My project already has a `.gitignore`. What happens to it?**
If it has no `# ccode-managed` line, the managed block is appended at the end. If the line is there, the file is left alone.

**Can the baseline commit pick up my secrets?**
Files matched by `.gitignore` are never staged. A file that slips through and looks like a secret by name is unstaged and listed in red. Review the list and add those files by hand only if they are safe. The check reads file names, not content.

**How do I pass flags to Claude Code?**
Put them after `ccode`. Everything goes straight to `claude`.

**How do I remove the quota line?**
Run `qline -Off` in the project. It removes the `statusLine` entry and leaves the rest of the settings file alone.

## 🤝 Works with

Windows PowerShell 5.1. `qline` prefers `pwsh` when it is installed.

![PowerShell](https://img.shields.io/badge/shell-PowerShell-blue)

## 📦 In this repo

This repo holds the shell version. A desktop version is planned.
