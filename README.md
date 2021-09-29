Clipboard Format Spy (CFS)
=========================

A windows program to list the Windows clipboard formats that are currently available and to display the contents in numerous supported formats.

> ### ***NOTE: This project is no longer being updated and has been archived.***
> ***There were 6 open issues when archived.***

Overview
--------

This program lists the available formats for any data that is currently stored on the Windows clipboard. It automatically updates the information displayed as the contents of the clipboard change.

For several formats CFS can also display the clipboard contents. For formats where CFS does not have a suitable custom viewer the contents are displayed in a hex viewer.

The clipboard can also be cleared.

For further information see the [program's web page](http://delphidabbler.com/software/cfs).
CFS should run on Windows 2000 to Windows 10. Not tested on later Windows versions.

Installation
------------

CFS is installed and removed using a standard Windows installer. Administrator rights are required for installation.

Full installation instructions are contained in [`ReadMe.txt`](Docs/ReadMe.txt) in the project's `Docs` directory.

Source Code
-----------

Up to and including release 4.1.1 the project's source code was maintained in a private Subversion repository. The Subversion repo was converted to Git on 21 July 2014, imported to GitHub and releases were tagged.

Consequently all changes up to release v4.1.1 were made to `master`. A `develop` branch was created at that point with the idea of leaving leaving `master` in a production ready state. However `develop` only received two commits before the project was archived.

Anyone wanting to take the project on can simply fork the repo.

Change Log
----------

The program's change log is recorded in [`ChangeLog.txt`](Docs/ChangeLog.txt) in the `Docs` directory.

License
-------

The program's EULA can be found in [`License.txt`](Docs/License.txt) in the `Docs` directory.

Much of the source code is released under the [Mozilla Public License v1.1](https://www.mozilla.org/MPL/1.1/).

> If anyone decides to take on this project and would like to change the license, please contact me via [Twitter](https://twitter.com/delphidabbler).
