Alternative Bypass
==================
**ufws** works only with online upgrades. Clean installation requires employing
an alternative bypass method. This document describes the least invasive method
to disable both clean installation and online upgrade checks.

Requirements
------------
The method described in this document requires [wimlib](https://wimlib.net/)
and an USB flash drive prepared with Windows 11 installation files.

Procedure
---------
Before proceeding the reader is required to confirm the following:
* Letter of USB flash drive with Windows 11 installation.
* Type of the installation image. Is it install.wim or install.esd? This shall
  be verified by checking contents of the sources directory on the USB flash
  drive.

In this example the drive letter shall be `F:` and the installation image shall
be `install.wim`.

As first phase of the procedure the reader shall open the Windows Command Prompt
in the location they extracted _wimlib_.

In order to proceed with the next phase of the procedure the reader shall check
the image count in the installation image. To achieve this the following shall
be typed in the Windows Command Prompt:
```
wimlib-imagex.exe info "F:\sources\install.wim" --header | find "Image Count"
```
The example result is:
```
Image Count                 = 11
```

The final phase of the procedure is to to modify `Installation Type` values in
the installation image to `Server`. In order to achieve this, the reader shall
type the following to the Windows Command Prompt while making sure to replace
the value `11` with correct image count:
```
for /L %i in (1,1,11) do wimlib-imagex.exe info "F:\sources\install.wim" %i --image-property WINDOWS/INSTALLATIONTYPE=Server
```
The result should be:
```
Setting the WINDOWS/INSTALLATIONTYPE property of image 1 to "Server".
Setting the WINDOWS/INSTALLATIONTYPE property of image 2 to "Server".
Setting the WINDOWS/INSTALLATIONTYPE property of image 3 to "Server".
Setting the WINDOWS/INSTALLATIONTYPE property of image 4 to "Server".
Setting the WINDOWS/INSTALLATIONTYPE property of image 5 to "Server".
Setting the WINDOWS/INSTALLATIONTYPE property of image 6 to "Server".
Setting the WINDOWS/INSTALLATIONTYPE property of image 7 to "Server".
Setting the WINDOWS/INSTALLATIONTYPE property of image 8 to "Server".
Setting the WINDOWS/INSTALLATIONTYPE property of image 9 to "Server".
Setting the WINDOWS/INSTALLATIONTYPE property of image 10 to "Server".
Setting the WINDOWS/INSTALLATIONTYPE property of image 11 to "Server".
```
If any errors appear, the reader is required to correct them at their own discretion.

The reader may now proceed with the installation.
