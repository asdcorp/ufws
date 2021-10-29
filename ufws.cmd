:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                                           ::
:: ufws (UnFuck Windows Setup)                                               ::
:: Copyright (C) 2021 uwuowouwu420                                           ::
::                                                                           ::
:: This program is free software: you can redistribute it and/or modify      ::
:: it under the terms of the GNU General Public License as published by      ::
:: the Free Software Foundation, either version 3 of the License, or         ::
:: (at your option) any later version.                                       ::
::                                                                           ::
:: This program is distributed in the hope that it will be useful,           ::
:: but WITHOUT ANY WARRANTY; without even the implied warranty of            ::
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             ::
:: GNU General Public License for more details.                              ::
::                                                                           ::
:: You should have received a copy of the GNU General Public License         ::
:: along with this program.  If not, see <https://www.gnu.org/licenses/>.    ::
::                                                                           ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
if "[%~1]" EQU "[?headless?]" (
    if "[%_media%]" EQU [] msg "%USERNAME%" "ufws failed"
    goto :start_setup
)
goto :main

:help
echo Usage:
echo %~nx0 ^<install_source_path^> [param1] [param2] ...
echo.
echo Examples:
echo %~nx0 E:
echo %~nx0 D:\extracted_iso
echo %~nx0 E: /Console
echo %~nx0 E: /Pkey XXXXX-XXXXX-XXXXX-XXXXX-XXXXX /Console
exit /b

:copy_from_media
if not exist "%_media%\%~1" exit /b
mkdir "%systemdrive%\$WINDOWS.~BT\%~1"
xcopy /cherkyq "%_media%\%~1" "%systemdrive%\$WINDOWS.~BT\%~1"
exit /b

:main
set "_version=1.4"
set "_media="
set "_install_file="
set "_params="
set "_auto=1"

if exist "%~dp0sources\SetupHost.exe" set "_media=%~dp0"
if "[%~1]" NEQ "[]" (
    set "_auto=0"
    set "_media=%~1"
    for /F "usebackq tokens=1,*" %%i in ('%*') do set "_params=%%j"
)
if "[%_media%]" EQU "[]" call :help & exit /b 1

reg query HKEY_USERS\S-1-5-19 >NUL 2>&1
if %ERRORLEVEL% NEQ 0 echo This script requires to be run as an administrator & pause & exit /b 1

for %%i in (esd wim swm) do if exist "%_media%\sources\install.%%i" set "_install_file=install.%%i"
if "[%_install_file%]" EQU "[]" echo Specified volume does not appear to be an install source & exit /b 1
if not exist "%_media%\sources\SetupHost.exe" echo SetupHost.exe is missing & exit /b 1
if not exist "%_media%\sources\SetupPrep.exe" echo SetupPrep.exe is missing & exit /b 1

echo ======================================================================
echo ufws (UnFuck Windows Setup) %_version%
echo https://github.com/uwuowouwu420/ufws
echo ======================================================================
echo.

echo Checking for previous setup residues and cleaning them...
start /b /wait "" "%_media%\sources\SetupPrep.exe" /Cleanup

echo Preparing setup...
mkdir "%systemdrive%\$WINDOWS.~BT"
attrib +h "%systemdrive%\$WINDOWS.~BT"

call :copy_from_media Boot
call :copy_from_media Efi
call :copy_from_media Langpacks

mkdir "%systemdrive%\$WINDOWS.~BT\Sources"
pushd %systemdrive%\$WINDOWS.~BT\Sources
echo \appraiserres.dll\ >ignore.txt
echo .wim\ >>ignore.txt
echo .esd\ >>ignore.txt
echo .swm\ >>ignore.txt
xcopy /cherkyq /EXCLUDE:ignore.txt "%_media%\sources" .
del /f ignore.txt
popd

echo.
if %_auto% EQU 1 powershell -NoProfile -Command Start-Process -FilePath "%~f0" -ArgumentList "?headless?" -WindowStyle Hidden
if %_auto% EQU 1 if %ERRORLEVEL% EQU 0 exit /b

echo Running Setup... Do not close this window during the setup process!

:start_setup
pushd %systemdrive%\$WINDOWS.~BT\Sources
if exist appraiserres.dll del /f appraiserres.dll
SetupHost.exe /Install /Media /InstallFile "%_media%\sources\%_install_file%" /MediaPath "%systemdrive%\$WINDOWS.~BT" %_params%
set "_setuperr=%ERRORLEVEL%"
popd

if %_setuperr% EQU -2147023429 goto :start_setup

reg query HKLM\SYSTEM\Setup\MoSetup /v Cleanup >NUL 2>&1
if %ERRORLEVEL% EQU 0 echo Cleaning up... & start /b /wait "" "%_media%\sources\SetupPrep.exe" /Cleanup

echo Done. Thanks.
exit /b %_setuperr%
