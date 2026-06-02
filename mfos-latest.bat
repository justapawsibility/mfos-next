::  Source code of MicroflashOS
::  A "fantasy operating system" made by KNBnoob1!
::  Website: https://knbn1.github.io

:: Contributors: nightlydevice, nglammm, justapawsibility

@echo off

:: Define some version strings

set "mfosVer=2026.06.03"
set "fbVer=5.2"
set "pkgRepo=GigaflashOS Unified Repository [Revision 3]"

:: Define default directories

set "sysDir=mfos"
set "modsDir=usermods"
set "userData=userdata"
set "userSysData=mfosdata"
set "disk0Label=MicroflashOS"

:: default user - defined by Batch environment variable %username%

set user=defaultuser0

:: Boot process stage 0 - Bootloader

:bootstagezero

cd /d "%~dp0"
title MicroflashOS Bootloader

:: System disk stuffs

set "disk0=%~dp0%disk0Label%"
set "disk0p1=%disk0%\%sysDir%"
set "disk0p2=%disk0%\%userData%"

:: Special directories

set "devices=%disk0p1%\devices"
set "userDir=%disk0p2%\%user%"
set "userSysDatadir=%userDir%\%userSysData%"
set "toggles=%userSysDatadir%\toggles"
set "userMods=%userSysDatadir%\%modsDir%"
set "pkgDir=%userSysDatadir%\packages"
set "pkgMeta=%pkgDir%\installed"

:: Startup parameters

if exist "%toggles%\echoon" (@echo on)
if not exist "%toggles%\noclear" (cls)
if not exist "%toggles%\nolog" (set "logfile=%~dp0mfos-log.txt") else (set "logfile=NUL")
if not exist "%toggles%\incognito" (set "history=%userDir%/mfos-history.txt") else (set "history=NUL")

:: Start logging

echo. >>"%logfile%"
echo %time% %date% >>"%logfile%"
echo ========================================= >>"%logfile%"
echo [bootloader] INFO: to log or not to log, that is the question >>"%logfile%"
echo [bootloader] INFO: logging system initialized
echo [bootloader] INFO: log file: %logfile%

if exist "%toggles%\slowboot" (call :slowboot)

:: Transfer control to kernel

echo [bootloader] INFO: loading bundled kernel into memory... >>"%logfile%"
echo [kernel] INFO: hello world, my version is %mfosVer% >>"%logfile%"
echo [kernel] INFO: terminating bootloader... done >>"%logfile%"
echo.

:: System disk check

title Finding system disk...
if exist "%disk0Label%" (
    echo System disk "%disk0Label%" mounted as /
    echo [kernel] INFO: system disk is "%disk0Label%" mounted as / >>"%logfile%"
) else (
    echo Unable to mount system disk!
    echo [kernel] ERROR: system disk mount failure >>"%logfile%"
    goto bootfail
)

:: Boot process stage 1 - Initialize devices

:bootstageone

echo [kernel] INFO: begin boot process stage 1 >>"%logfile%"

if exist "%toggles%\slowboot" (call :slowboot)

echo.
title Initializing devices...
echo Initializing devices...
echo.

if not exist "%devices%" (cd /d "%disk0p1%" && md devices)
if not exist "%devices%\mem" (cd /d "%devices%" && md mem)

echo System disk - /%sysDir%/>"%devices%\disk0p1"
if not exist "%devices%\disk0p1" (call :devinitfail disk0p1)
echo INIT "disk0p1"
echo [kdevinit] INFO: system partition initialized >>"%logfile%"

:: insert redirector thing

::echo call %%1 >"%devices%/mem/memsect1.bat"
::echo goto :eof >>"%devices%/mem/memsect1.bat"

echo.>"%devices%\mem\memsect1.bat"
if not exist "%devices%\mem\memsect1.bat" (call :devinitfail memsect1)
echo INIT "memsect1"
echo [kdevinit] INFO: memory sector 1 initialized >>"%logfile%"

echo Memory sector 2 - Userspace>"%devices%\mem\memsect2.bat"
if not exist "%devices%\mem\memsect2.bat" (call :devinitfail memsect2)
echo INIT "memsect2"
echo [kdevinit] INFO: memory sector 2 initialized >>"%logfile%"

echo Memory sector 3 - Secret Block>"%devices%\mem\memsect3"
if not exist "%devices%\mem\memsect3" (call :devinitfail memsect3)
echo INIT "memsect3"
echo [kdevinit] INFO: memory sector 3 initialized >>"%logfile%"

echo Human Interface Devices>"%devices%\hids"
if not exist "%devices%\hids" (call :devinitfail hids)
echo INIT "hids"
echo [kdevinit] INFO: human interface devices initialized >>"%logfile%"

echo Auditory devices: headphones, speakers, microphones, etc.>"%devices%\audio"
if not exist "%devices%\audio" (call :devinitfail audio)
echo INIT "audio"
echo [kdevinit] INFO: audio subsystem initialized >>"%logfile%"

if exist "%toggles%\slowboot" (call :slowboot)

:: Boot process stage 2 - Load core modules

:bootstagetwo

echo [kernel] INFO: begin boot process stage 2 >>"%logfile%"

echo.
title Loading core modules...
echo Loading core modules...
echo.

for %%C in (cmd core fsutils compact proctector mfpkg) do (
    if exist "%disk0p1%\%%C.mcm" (
        type "%disk0p1%\%%C.mcm" >>"%devices%\mem\memsect1.bat"
        call :loadmodok /%sysDir%/%%C.mcm
    ) else (
        call :loadmodfail /%sysDir%/%%C.mcm
    )
)

if exist "%toggles%\slowboot" (call :slowboot)

:: Boot process stage 3 - Userdata partition

:bootstagethree

echo [kernel] INFO: begin boot process stage 3 >>"%logfile%"

title Checking userdata partition...

echo.
if not exist "%disk0p2%" (
    echo Userdata partition not found!
    echo [kdevinit] WARN: failed to initialize userdata partition >>"%logfile%"
    echo.
    echo Creating userdata partition...
    echo [kusrinit] INFO: creating userdata partition >>"%logfile%"
    cd /d "%disk0%"
    md "%userData%"
    echo.
    if not exist "%disk0p2%" (
        echo Userdata partition creation failed!
        echo [kusrinit] ERROR: userdata partition creation failed >>"%logfile%"
        goto pauseexit
    )
)

echo Userdata partition>"%devices%\disk0p2"
echo Userdata partition is /%userData%/
echo [kdevinit] INFO: userdata partition initialized >>"%logfile%"


if not exist "%userDir%" (
    echo Userdata for user %user% not found!
    echo [kusrinit] WARN: no userdata found for user %user% >>"%logfile%"
    echo.
    echo Creating userdata for %user%...
    echo [kusrinit] INFO: creating userdata for user %user% >>"%logfile%"
    cd /d "%disk0p2%"
    md "%user%"
    echo.
    if not exist "%userDir%\" (
        echo Userdata creation for %user% failed!
        echo [kusrinit] ERROR: userdata creation for user %user% failed >>"%logfile%"
        goto pauseexit
    )
)

if not exist "%userSysDatadir%" (
    echo Setting up userdata for %user%...
    echo [kusrinit] INFO: setting up userdata for %user% >>"%logfile%"
    cd /d "%userDir%"
    md "%userSysData%"
    echo.
    if not exist "%userSysDatadir%\" (
        echo Failed to create user system data!
        echo [kusrinit] ERROR: user system data creation for user %user% failed >>"%logfile%"
        goto pauseexit
    )
)

if not exist "%toggles%\" (
    echo Creating toggle directory...
    echo [kusrinit] INFO: creating toggle directory for %user% >>"%logfile%"
    cd /d "%userSysDatadir%"
    md toggles
    echo.
    if not exist "%userSysDatadir%\toggles" (
        echo Toggle directory creation failed!
        echo [kusrinit] ERROR: toggle directory creation for user %user% failed >>"%logfile%"
        goto pauseexit
    )
)

if not exist "%pkgDir%\" (
    echo Creating package directory...
    echo [kusrinit] INFO: creating package directory for %user% >>"%logfile%"
    cd /d "%userSysDatadir%"
    md packages
    cd /d "%pkgDir%"
    md installed
    echo.
    if not exist "%pkgDir%\" if not exist "%pkgMeta%\" (
        echo Package directory creation failed!
        echo [kusrinit] ERROR: package directory creation for user %user% failed >>"%logfile%"
        goto pauseexit
    )
)

if not exist "%userMods%\" (
    echo Creating module directory...
    echo [kusrinit] INFO: creating module directory for %user% >>"%logfile%"
    cd /d "%userSysDatadir%"
    md %modsDir%
    echo.
    if not exist "%userMods%\" (
        echo Module directory creation failed!
        echo [kusrinit] ERROR: module directory creation for user %user% failed >>"%logfile%"
        goto pauseexit
    )
)

if exist "%userDir%" (
    echo Logging in as %user%
    echo [kusrinit] INFO: logging in as %user% >>"%logfile%"
)

if exist "%toggles%\slowboot" (call :slowboot)
echo.

:: Load user modules

for %%U in (flashbreak devtools) do (
    if exist "%userMods%\%%U.mfm" (
        type "%disk0p1%\%%U.mfm" >>"%devices%\mem\memsect1.bat"
        call :loadmodok /%userData%/%user%/%userSysData%/%modsDir%/%%U.mfm
    )
)

if exist "%toggles%\slowboot" (call :slowboot)

:: F145HBR34K stage 3 patcher

:bootstagethree-fbpatch

if exist "%userMods%\devtools.mfm" (
    if exist "%userMods%\flashbreak.mfm" (
        title F145HBR34K Stage 3 Intervention
        echo.
        echo Loading F145HBR34K...
        echo [fb-s3init] INFO: loading jailbreak... >>"%logfile%"
        echo.
        set "fbloaded=nope"
        echo [fb-s3init] INFO: loading module patches... >>"%logfile%"

        for %%F in (cmd fsutils proctector) do (
        if not exist "%disk0p1%\%%F.mcm" (call :fbpatchfail /%sysDir%/%%F.mfm)
            echo Patching /%sysDir%/%%F.mcm
            :: echo Injected F145HBR34K code into module.>"%disk0p1%\%%F.mcm"
            echo [fb-s3init] INFO: patched /%sysDir%/%%F.mcm >>"%logfile%"
        )

        if not exist "%userMods%\devtools.mfm" (call :fbpatchfail /%userData%/%userSysData%/packages/devtools.mfm)

        echo Patching /%sysDir%/%modsDir%/devtools.mfm
        :: echo Injected F145HBR34K code into module.>"%userMods%\devtools.mfm"
        echo [fb-s3init] INFO: patched /%userData%/%userSysData%/packages/devtools.mfm >>"%logfile%"
        echo.
        echo Patches complete!
        echo [fb-s3init] INFO: patches complete >>"%logfile%"
        echo.
        set "fbloaded=yessir"
        echo Resuming boot process...
        echo [fb-s3init] INFO: resuming boot process >>"%logfile%"
        if exist "%toggles%\slowboot" (call :slowboot)
    )
)

:: Boot process complete!

:bootcomplete

title Boot process complete!
echo.
echo MicroflashOS system files loaded!
echo [kernel] INFO: boot process completed >>"%logfile%"
cd /d "%userDir%"

if exist "%toggles%\slowboot" (call :slowboot)

:: Welcome messages

if not exist "%toggles%\noclear" (cls)
echo.
if not exist "%disk0p1%\cmd.mcm" (
    echo [kernel] ERROR: could not load /%sysDir%/cmd.mcm >>"%logfile%"
    echo Command line could not be loaded.
    goto :pauseexit
)
echo Welcome to MicroflashOS!
echo [cmd] INFO: initialized prompt >>"%logfile%"
echo.
if not exist "%userDir%" (
    echo Userdata for user %user% not found.
    echo [kusrinit] ERROR: no userdata for user %user% >>"%logfile%"
    echo.
    goto reboot
)
echo Logged in as %user%
echo [cmd] INFO: current user: %user% >>"%logfile%"
echo.
echo Type HELP for a list of commands.
echo Commands are not case-sensitive.

:: User prompt

:prompt

if not exist "%disk0p1%\cmd.mcm" (
    echo [kernel] ERROR: could not load /%sysDir%/cmd.mcm >>"%logfile%"
    echo Command line could not be loaded.
    exit
)

:: check if a reboot has been enforced

if "%enforcereboot%" == "true" (
    set "enforcereboot=false"
    echo The system will now reboot.
    call "%devices%\mem\memsect1.bat" halt
    title Rebooting...
    echo [kernel] INFO: intercepted reboot request >>"%logfile%"
    goto bootstagezero
)

:: Titlebar stuff

set "titlebar=MicroflashOS %mfosVer%"
title %titlebar%
if exist "%userMods%\devtools.mfm" (title %titlebar% [DevTools])
if "%fbloaded%"=="yessir" (
    title %titlebar% [DevTools] [F145HBR34K %fbVer%]
    echo [flashbreak] INFO: modified titlebar >>"%logfile%"
)

if exist "%toggles%\showdir" (
    echo [cmd] DEBUG: showing current directory >>"%logfile%"
    echo Current directory: %cd%
    echo.
)

:: Reset last run command variable

set "input="
set "command="

:: receive input from the user:

echo.

echo [cmd] INFO: load user prompt >>"%logfile%"
echo [cmd] INFO: waiting for user input >>"%logfile%"

set /p "input=%user%@%userdomain%: "

if "%input%" == getvars (set)

call "%devices%\mem\memsect1.bat"

goto prompt

:: Boot process

:bootfail
echo.
title Startup Failure!
echo MicroflashOS startup failed. Entering recovery...
call :halt
echo [kernel] INFO: booting to recovery... >>"%logfile%"
echo [kernel] INFO: booting to recovery...
goto recovery

:devinitfail
echo [kdevinit] ERROR: failed to initialize "%1" >>"%logfile%"
echo Could not initialize device "%1"
goto pauseexit

:loadmodok
echo Loaded %1
echo [kmodsinit] INFO: loaded %1 >>"%logfile%"
goto :eof

:loadmodfail
echo.
echo FAIL %1
echo [kmodsinit] ERROR: failed to load %1 >>"%logfile%"
goto bootfail

:fbpatchfail
echo Module %1 not found!
echo Jailbreak unsuccessful.
echo [fb-s3init] ERROR: failed to load %1 >>"%logfile%"
set fbloaded=nope
goto bootcomplete

:slowboot
echo.
echo Slowboot toggle tripped!
call :halt
echo [bootloader] DEBUG: slowboot toggle tripped >>"%logfile%"
goto :eof

:halt
echo.
pause
goto :eof



