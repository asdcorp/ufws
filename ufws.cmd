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
set "_media="
set "_install_file="

if exist "%~dp0sources\SetupHost.exe" set "_media=%~dp0"
if "[%1]" NEQ "[]" set "_media=%1"
if "[%_media%]" EQU "[]" call :help & exit /b 1

reg query HKEY_USERS\S-1-5-19 >NUL 2>&1
if %ERRORLEVEL% NEQ 0 echo This script requires to be run as an administrator & pause & exit /b 1

for %%i in (esd wim swm) do if exist "%_media%\sources\install.%%i" set "_install_file=install.%%i"
if "[%_install_file%]" EQU "[]" echo Specified volume does not appear to be an install source & exit /b 1
if not exist "%_media%\sources\SetupHost.exe" echo SetupHost.exe is missing & exit /b 1

echo +===============================================================+
echo ^|                ufws (UnFuck Windows Setup) 1.0                ^|
echo +===============================================================+
echo.

echo Checking for previous setup residues and cleaning them...
call :cleanup

echo Preparing setup...
mkdir "%systemdrive%\$WINDOWS.~BT"
attrib +h "%systemdrive%\$WINDOWS.~BT"

mkdir "%systemdrive%\$WINDOWS.~BT\Boot"
mkdir "%systemdrive%\$WINDOWS.~BT\Efi"
mkdir "%systemdrive%\$WINDOWS.~BT\Sources"

xcopy /cherkyq "%_media%\boot" "%systemdrive%\$WINDOWS.~BT\Boot"
xcopy /cherkyq "%_media%\efi" "%systemdrive%\$WINDOWS.~BT\Efi"

pushd %systemdrive%\$WINDOWS.~BT\Sources
echo \appraiserres.dll\ >ignore.txt
echo .wim\ >>ignore.txt
echo .esd\ >>ignore.txt
echo .swm\ >>ignore.txt
xcopy /cherkyq /EXCLUDE:ignore.txt "%_media%\sources" .
del /f ignore.txt
popd

echo.
echo Running Setup... Do not close this window during the setup process!
:start_setup
pushd %systemdrive%\$WINDOWS.~BT\Sources
if exist appraiserres.dll del /f appraiserres.dll
SetupHost.exe /Install /Media /InstallFile "%_media%\sources\%_install_file%" /MediaPath "%systemdrive%\$WINDOWS.~BT"
popd

set "_setuperr=%ERRORLEVEL%"
if %_setuperr% EQU -2147023429 goto :start_setup

reg query HKEY_LOCAL_MACHINE\SYSTEM\Setup\MoSetup /v Cleanup >NUL 2>&1
if %ERRORLEVEL% EQU 0 echo Cleaning up... & call :cleanup

echo Done. Thanks.
exit /b %_setuperr%

:cleanup
if exist "%systemdrive%\$WINDOWS.~BT" rmdir /q /s "%systemdrive%\$WINDOWS.~BT" >NUL 2>&1
if exist "%systemdrive%\$WINDOWS.~BT" (
    takeown /f "%systemdrive%\$WINDOWS.~BT" /a /r /d y >NUL 2>&1
    icacls "%systemdrive%\$WINDOWS.~BT" /grant "%USERDOMAIN%\%USERNAME%":^(F^) /t >NUL 2>&1
    rmdir /q /s "%systemdrive%\$WINDOWS.~BT" >NUL 2>&1
)
reg delete HKLM\SYSTEM\Setup\MoSetup\Tracking /f >NUL 2>&1
reg delete HKLM\SYSTEM\Setup\MoSetup\Volatile /f >NUL 2>&1
reg delete HKLM\SYSTEM\Setup\MoSetup /v CorrelationVector /f >NUL 2>&1
reg delete HKLM\SYSTEM\Setup\MoSetup /v Cleanup /f >NUL 2>&1
exit /b

:help
echo Usage:
echo %~nx0 ^<install_source_path^>
echo.
echo Examples:
echo %~nx0 E:
echo %~nx0 D:\extracted_iso
exit /b
