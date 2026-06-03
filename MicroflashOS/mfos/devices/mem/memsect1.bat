
:parser

:: whitelist

set "cmdlist=about help clock clear reboot shutdown mkdir rename delete list cd home homewipe mfpkg mountsys modules toggles"

title Processing command...
echo [cmd] INFO: received command "%input%" >>"%logfile%"

:: analysis with "for"

for /f "tokens=1 delims= " %%a in ("%input%") do (set "command=%%a")

echo [cmd] DEBUG: extracted main command "%command%" >>"%logfile%"

:: compare %command% with command list

echo [cmd] DEBUG: checking "%command%" against whitelist >>"%logfile%"

set "found=nope"

for %%w in (%cmdlist%) do (
    if /i "%command%"=="%%w" set "found=yep"
)
if "%found%"=="nope" (
    echo.
    call :nocommand
    goto :eof
)

echo.
call :%input%
goto :eof
:help
echo System utilities:
echo.
echo about: Show some system info
echo clock: Print current date and time
echo clear: Clear console output
echo.
echo Power options:
echo.
echo reboot [recovery]: Reboot
echo shutdown: Power off
echo.
echo [help] INFO: load help section for /%sysDir%/core.mcm >>"%logfile%"
if exist "%disk0p1%\fsutils.mcm" (
    echo File management:
    echo.
    echo mkdir [directory]: Create a directory
    echo rename [target] [new name] Rename something to another thing
    echo delete [file/directory] [name]: Delete a file/directory
    echo list: List available files/directories
    echo cd [path]: Change to a directory
    echo.
    echo User management
    echo.
    echo home: Quickly return to user directory
    echo homewipe: Wipe all user directories
    echo [help] INFO: load help section for /%sysDir%/fsutils.mcm >>"%logfile%"
)
if exist "%userMods%\devtools.mfm" (
    echo.
    echo Developer commands:
    echo.
    echo mountsys: Mount and modify system disk contents
    echo modules: List all core and user modules
    echo toggles [create/delete/enabled/list] [toggle]: Manage toggles
    echo getvars: Print a list of ALL environment variables accessible
    echo [help] INFO: load help section for /%sysDir%/%modsDir%/devtools.mfm >>"%logfile%"
)
if exist "%disk0p1%\mfpkg.mcm" (
    echo.
    echo Package management:
    echo.
    echo mfpkg [install/uninstall/list] [package ID]: Package management
    echo mfpkg run [package]: Run an installed package
    echo [help] INFO: load help section for /%sysDir%/mfpkg.mcm >>"%logfile%"
)
goto :eof

:about
echo MicroflashOS version: %mfosVer%
echo [about] INFO: mfos version is %mfosVer% >>"%logfile%"
echo Mounted system disk: %disk0Label%
echo [about] INFO: mounted system disk is %disk0Label% >>"%logfile%"
echo.
echo Hostname: %userdomain%
echo [about] INFO: hostname is %userdomain% >>"%logfile%"
echo Processor: %processor_identifier% (%NUMBER_OF_PROCESSORS% cores)
echo [about] INFO: processor is %processor_identifier% with %NUMBER_OF_PROCESSORS% cores >>"%logfile%"
echo Architecture: %processor_architecture%
echo [about] INFO: architecture is %processor_architecture% >>"%logfile%"
echo.
echo Made by Kenneth White.
goto :eof

:reboot
set "enforcereboot=true"
goto :eof

:shutdown
title Shutting down...
echo Shutting down...
echo [kernel] INFO: intercepted shutdown request >>"%logfile%"
exit

:clock
echo Time: %time%
echo Date: %date%
echo [clock] INFO: fetched time is %time% and date is %date% >>"%logfile%"
goto :eof

:: Clear the shell

:clear
call :cmdok
if not exist "%toggles%\noclear" (
    cls
    echo [cmd] INFO: user requested shell clearance >>"%logfile%"
)
goto :eof


call :cmdok
title File Manager

:mkdir
if "%1"=="" (
    echo This command is used to make a directory.
    echo.
    echo Usage:
    echo.
    echo mkdir [directory]
    echo [fsutils] ERROR: no directory provided >>"%logfile%"
    goto :eof
)
if exist "%1/" (
    echo Directory "%1" already exists!
    echo [fsutils] ERROR: directory "%1" already exists >>"%logfile%"
    goto :eof
)
mkdir "%1"
if not exist "%1/" (
    echo Failed to create directory "%1"!
    echo [fsutils] ERROR: failed to create directory "%1" >>"%logfile%"
    goto :eof
)
echo Created directory "%1"
echo [fsutils] INFO: created directory "%1" >>"%logfile%"
goto :eof

:rename
if "%1"=="" (
    echo This command renames a file or a folder.
    echo.
    echo Usage:
    echo.
    echo rename [target] [new name]
    echo [fsutils] ERROR: no option selected >>"%logfile%"
    goto :eof
)
if not exist "%1" (
    echo Target does not exist!
    echo [fsutils] ERROR: target "%1" does not exist >>"%logfile%"
    goto :eof
)
if exist "%2" (
    echo An object with the same name is already present!
    echo [fsutils] ERROR: new name "%2" matches an existing name >>"%logfile%"
    goto :eof
)
ren "%1" "%2"
if not exist "%2" (
    echo Failed to rename "%1"!
    echo [fsutils] ERROR: failed to rename "%1" >>"%logfile%"
    goto :eof
)
echo Renamed "%1" to "%2"
echo [fsutils] INFO: renamed "%1" to "%2" >>"%logfile%"
goto :eof

:delete
if "%1"=="" (
    echo This command deletes something.
    echo.
    echo Usage:
    echo.
    echo delete [file/directory] [name]
    echo [fsutils] ERROR: no option selected >>"%logfile%"
    goto :eof
)
if "%1"=="file" (
    if not exist "%2" (
        echo File does not exist!
        echo [fsutils] ERROR: specified file "%2" does not exist >>"%logfile%"
        goto :eof
    )
    del "%2" /f /q
    if not exist "%2" (
        echo Deleted file "%2"
        echo [fsutils] INFO: deleted file "%2" >>"%logfile%"
        goto :eof
    )
    echo Failed to delete file!
    echo [fsutils] ERROR: failed to delete file "%2" >>"%logfile%"
    goto :eof
)
if "%1"=="directory" (
    if not exist "%2" (
        echo Directory does not exist!
        echo [fsutils] ERROR: specified directory "%2" does not exist >>"%logfile%"
        goto :eof
    )
    rd "%2" /s /q
    if not exist "%2/" (
        echo Deleted directory "%2"
        echo [fsutils] INFO: deleted directory "%2" >>"%logfile%"
        goto :eof
    )
    echo Failed to delete directory!
    echo [fsutils] ERROR: failed to delete directory "%1" >>"%logfile%"
    goto :eof
)
echo Invalid arguments.
echo [fsutils] ERROR: invalid arguments >>"%logfile%"
goto :eof

:list
echo [fsutils] INFO: listing objects in "%cd%" >>"%logfile%"
echo Directories:
echo.
dir /a:d /b
echo.
echo Files:
echo.
dir /a:-d /b
goto :eof

:cd
if "%1"=="" (
    echo This command is used to enter a directory or change your current directory.
    echo.
    echo Usage:
    echo.
    echo cd [path]
    echo [fsutils] ERROR: no path provided >>"%logfile%"
    goto :eof
)
if not exist "%1/" (
    echo Directory invalid!
    echo [fsutils] ERROR: invalid path >>"%logfile%"
    goto :eof
)
cd "%1"
echo Changed directory to "%1"
echo [fsutils] INFO: changed directory to "%1" >>"%logfile%"
echo [fsutils] DEBUG: current path is "%cd%" >>"%logfile%"
goto :eof

:home
if not exist "%userDir%" (
    echo.
    echo Userdata for current user not found!
    echo [fsutils] ERROR: could not find userdata for current user >>"%logfile%"
    goto :eof
)
cd /d "%userDir%"
echo Welcome home.
echo [fsutils] INFO: reverted current path to home directory >>"%logfile%"
echo [fsutils] DEBUG: current path is "%cd%" >>"%logfile%"
goto :eof

:homewipe
echo This command wipes userdata for all users, both logged out and logged in.
echo This effectively returns MicroflashOS to a "clean" state.
echo Back up any data before continuing!
echo.
call :userauth
if "%authorized%" == "true" (
    echo.
    if not exist "%disk0p2%" (
        echo Userdata partition not found!
        echo [fsutils] ERROR: could not load userdata partition >>"%logfile%"
        goto :eof
    )
    echo Found users:
    dir /a:d /b "%disk0p2%"
    echo.
    echo Wiping userdata...
    cd /d "%disk0%"
    rd "%userData%" /s /q
    if exist "%disk0p2%" (
        echo.
        echo Userdata wipe failed!
        echo [fsutils] ERROR: userdata partition wipe failed >>"%logfile%"
        goto :eof
    )
    echo [fsutils] INFO: userdata wipe successful >>"%logfile%"
    echo Wipe succeeded.
    echo.
    goto reboot
)
goto :eof
:cmdok
echo [cmd] INFO: command valid >>"%logfile%"
if not exist "%toggles%/incognito" (echo [valid] "%input%" >>"%history%")
goto :eof

:: Dependencies unmet

:nocommand
echo Invalid command.
if not exist "%toggles%/incognito" (echo [invalid] "%input%" >>"%history%")
echo [cmd] ERROR: command "%input%" invalid >>"%logfile%"
goto :eof

:nodev
echo DevTools not found. Install pID 001.
echo [cmd] ERROR: required dependency "DevTools" is missing >>"%logfile%"
goto :eof

:nofb
echo F145HBR34K not found. Install pID 002.
echo [cmd] ERROR: required dependency "F145HBR34K" is missing >>"%logfile%"
goto :eof

:: Recovery mode

:modinstfail
echo Failed to install module "%1"
goto :pauseexit

:: Package-related stuff

:nopkg
echo Package not installed!
goto :eof

:instdone
echo Installed package ID %pkgtarget%
echo [mfpkg] INFO: installed pID %pkgtarget% >>"%logfile%"
goto :eof

:uninstdone
echo Uninstalled package ID %pkgtarget%
echo [mfpkg] INFO: uninstalled pID %pkgtarget% >>"%logfile%"
cd /d %curdir%
goto :eof

:insfail
echo Failed to install package %pkgtarget%
echo [mfpkg] ERROR: failed to install pID %pkgtarget% >>"%logfile%"
goto :eof

:inregfail
echo Failed to register package %pkgtarget%
echo [mfpkg] ERROR: failed to register pID %pkgtarget% >>"%logfile%"
goto :eof

:uninsfail
echo Failed to uninstall package %pkgtarget%
echo [mfpkg] ERROR: failed to uninstall pID %pkgtarget% >>"%logfile%"
goto :eof

:unregfail
echo Failed to unregister package %pkgtarget%
echo [mfpkg] ERROR: failed to unregister pID %pkgtarget% >>"%logfile%"
goto :eof

:: Common pause and exit functions

:pauseexit
call :halt
exit

:halt
echo.
pause
goto :eof
echo [proctector] INFO: requesting user authorization >>"%logfile%"
set /p "confirmation=Type "CONFIRM" (case-sensitive) to confirm this action: "
if "%confirmation%" == "CONFIRM" (
    set "confirmation="
    set "authorized=true"
    echo [proctector] INFO: authorized >>"%logfile%"
    goto :eof
) else (
    echo.
    echo User authorization failed!
    echo [kernel] ERROR: user authorization failed >> "%logfile%"
    goto :eof
)
:mfpkg
title MicroflashOS Package Manager
setlocal enabledelayedexpansion
if "%1"=="list" (
    echo Installed packages:
    echo.
    dir /a:-d /b "%pkgMeta%/"
    echo [mfpkg] INFO: listed installed packages >>"%logfile%"
    goto :eof
)
if "%1"=="install" (
    if "%2"=="" (
        echo No package ID specified.
        echo [mfpkg] ERROR: no package ID specified >>"%logfile%"
        goto :eof
    )
    set "pkgtarget=%2"
    set "pkgcmd=mfpkg-dl-!pkgtarget!"
    title Finding package...
    set "pkgfound=false"
    for /f "tokens=1 delims=:" %%A in ('findstr /r "^:" "%~f0"') do (
        if /i "%%A"=="!pkgcmd!" set "pkgfound=true"
    )
    if "!pkgfound!"=="false" (
        echo Package ID is invalid.
        echo [mfpkg] ERROR: installation pID invalid >>"%logfile%"
        goto :eof
    )
    set "pkgfound="
    goto !pkgcmd!
)
if "%1"=="uninstall" (
    if "%2"=="" (
        echo No package ID specified.
        echo [mfpkg] ERROR: no package ID specified >>"%logfile%"
        goto :eof
    )
    set "pkgtarget=%2"
    set "pkgcmd=mfpkg-rm-!pkgtarget!"
    title Finding package...
    set "pkgfound=false"
    for /f "tokens=1 delims=:" %%A in ('findstr /r "^:" "%~f0"') do (
        if /i "%%A"=="!pkgcmd!" set "pkgfound=true"
    )
    if "!pkgfound!"=="false" (
        echo Package ID is invalid.
        echo [mfpkg] ERROR: installation pID invalid >>"%logfile%"
        goto :eof
    )
    set "pkgfound="
    goto !pkgcmd!
)

if "%1"=="run"
    if "%2"=="" (
        echo Please enter a package name.
        goto :eof
    )
    if not exist "%pkgDir%\%2.mfp" (
        echo Package not installed.
        goto :eof
    )
    echo [cmd] INFO: package "%2.mfp" found, executing >>"%logfile%"
    type "%pkgDir%\%2.mfp">"%exeCache%\mfp-%2.bat"
    :: brute force arguments into this
    call "%exeCache%\mfp-%2.bat" %3 %4 %5 %6 %7 %8 %9
    goto :eof
)

echo Invalid arguments.
echo [mfpkg] ERROR: invalid arguments >>"%logfile%"
goto :eof
:: DevTools

:mountsys
title MicroflashOS System Partition Mounter
if not exist "%disk0p1%/" (
    echo System partition not found!
    echo [mountsys] ERROR: system partition not found >>"%logfile%"
    goto :eof
)
echo Mounting disk0p1...
echo.
cd /d "%disk0p1%/"
echo [mountsys] INFO: mounted system partition >>"%logfile%"
echo The system partition has been made accessible to the current user.
echo.
echo Modifying the system partition directly may break your device.
echo Use with caution!
goto :eof

:modules
echo [modules] INFO: listing installed modules... >>"%logfile%"
echo Core modules:
echo.
dir /a:-d /b "%disk0p1%/"
echo.
echo User modules:
echo.
dir /a:-d /b "%userMods%/"
goto :eof

:toggles
if "%1"=="" (
    echo Manage your toggles.
    echo.
    echo Usage:
    echo.
    echo toggles [create/delete/enabled/list] [toggle]
    echo [toggle-manager] ERROR: no option selected >>"%logfile%"
    goto :eof
)
if "%1"=="create" (
    if "%2"=="" (
        echo Please enter a toggle name.
        echo [toggle-manager] ERROR: no toggle specified >>"%logfile%"
        goto :eof
    )
    echo "%2">"%toggles%/%2"
    if not exist "%toggles%/%2" (
        echo Failed to write toggle "%2"!
        echo [toggle-manager] ERROR: could not write toggle "%2" >>"%logfile%"
        echo.
        goto :eof
    )
    echo Toggle "%2" written.
    echo [toggle-manager] INFO: written toggle "%2" >>"%logfile%"
    goto :eof
)
if "%1"=="delete" (
    if "%2"=="" (
        echo Please enter a toggle name.
        echo [toggle-manager] ERROR: no toggle specified >>"%logfile%"
        goto :eof
    )
    if not exist "%toggles%/%2" (
        echo Toggle "%2" does not exist!
        echo [toggle-manager] ERROR: toggle "%2" nonexistent >>"%logfile%"
        goto :eof
    )
    del "%toggles%/%2" /f /q
    if exist "%toggles%/%2" (
        echo Failed to delete toggle "%2"!
        echo [toggle-manager] ERROR: could not delete toggle "%2" >>"%logfile%"
        goto :eof
    )
    echo Toggle "%2" deleted.
    echo [toggle-manager] INFO: deleted toggle "%2" >>"%logfile%"
    goto :eof
)
if "%1"=="enabled" (
    echo Enabled toggles:
    echo [toggle-manager] INFO: listing enabled toggles... >>"%logfile%"
    echo.
    dir /a:-d /b "%toggles%/"
    goto :eof
)
if "%1"=="list" (
    echo Toggles in MicroflashOS as of this version [%mfosVer%]:
    echo [toggle-manager] INFO: listing available toggles... >>"%logfile%"
    echo.
    echo Tweaks:
    echo.
    echo showdir: Shows current directory in command line before prompt
    echo incognito: Disables writing to the command history file
    echo allowdisabled: Allow using disabled commands
    echo.
    echo Debugging tools:
    echo.
    echo slowboot: Add pauses during boot sequence
    echo echoon: Disables echo OFF so command that generated shell output is shown
    echo noclear: Disable clearing shell output (this also affects the "clear" command
    echo nolog: Disables system logging functions within MicroflashOS
    goto :eof
)
echo Invalid arguments!
echo [toggle-manager] ERROR: invalid arguments >>"%logfile%"
goto :eof
