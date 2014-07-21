Clipboard Format Spy (CFS)
=========================

A windows program to list the Windows clipboard formats that are currently available and to display the contents in numerous supported formats.

Overview
--------

This program lists the available formats for any data that is currently stored on the Windows clipboard. It automatically updates the information displayed as the contents of the clipboard change.

For several formats CFS can also display the clipboard contents. For formats where CFS does not have a suitable custom viewer the contents are displayed in a hex viewer.

The clipboard can also be cleared.

For further information see the [program's web page](http://delphidabbler.com/software/cfs). Some [screen shots](http://delphidabbler.com/software/cfs/screenshot) are also available.

CFS currently runs on all versions of Windows from 2000 onwards.

> Note that Windows 2000 support may be dropped in a future version.

Installation
------------

CFS is installed and removed using a standard Windows installer. Administrator rights are required for installation.

Full installation instructions are contained in [`ReadMe.txt`](Docs/ReadMe.txt) in the project's `Docs` directory.

Source Code
-----------

Up to and including release 4.1.1 the project's source code was maintained in a private Subversion repository. The Subversion repo was converted to Git on 21 July 2014 and imported to GitHub and releases were tagged.

Consequently all changes up to release v4.1.1 were made to `master`. Following tag `v4.1.1` and the creation of `README.md` the [Git Flow](http://nvie.com/posts/a-successful-git-branching-model/) methodology was adopted. All development work is now done on the `develop` branch leaving `master` in a production ready state.

### Contributions

Contributions are welcome. Just fork the repo and create a feature branch off the `develop` branch. Commit your changes to you feature branch then submit a pull request when ready.

Change Log
----------

The program's change log is recorded in [`ChangeLog.txt`](Docs/ChangeLog.txt) in the `Docs` directory.

License
-------

The program's EULA can be found in [`License.txt`](Docs/License.txt) in the `Docs` directory.

Much of the source code is released under the [Mozilla Public License v1.1](https://www.mozilla.org/MPL/1.1/).

> It is planned to simplify licensing and move to the [Mozilla Public License v2.0](https://www.mozilla.org/MPL/2.0/) in due course.
