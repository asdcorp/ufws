ufws (UnFuck Windows Setup)
===========================
**ufws** (imagine being drunk beyond all fuck and attempting to say _oops_)
is a simple script to bypass Windows 11 system requirements when upgrading from
Windows 10. For clean installation bypass check `alternative_bypass.md`.

**ufws** is meant to be used with an unmodified installation medium. Any issues
caused by usage of such medium will be ignored. Never use more than one bypass
method on single installation medium.

Archival notice
---------------
As of build 27686 Microsoft has made changes to the setup process, causing this
tool to no longer work. Both `ufws.cmd` and `lufws.cmd` scripts are affected.
For this reason the project is being archived, as no further development is
being planned.

At the time of writing this notice, the only known working bypass for builds
past 27686 is the one shown in the [alternative_bypass.md](alternative_bypass.md)
file.

Usage
-----
**ufws** can be used in two ways. You can run it from an administrative command
prompt or directly.

### Running directly
Place **ufws** in the root of the installation media and run it as an
administrator. It will detect the path and automatically start the setup wizard.

For direct usage from root of installation media you can also use `lufws.cmd`
which is a lite version of **ufws** with different bypass method.

### Running from administrative command prompt
```
ufws.cmd <install_source_path> [param1] [param2] ...
```

#### Examples
```
ufws.cmd E:
ufws.cmd D:\extracted_iso
ufws.cmd E: /Console
ufws.cmd E: /Pkey XXXXX-XXXXX-XXXXX-XXXXX-XXXXX /Console
```

License
-------
This script is licensed under the terms of the GNU General Public License v3.0
