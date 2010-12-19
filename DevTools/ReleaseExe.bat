@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing binary release of Clipboard
@rem Format Spy.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2008
@rem
@rem v1.0 of 24 Mar 2008 - First version.
@rem ---------------------------------------------------------------------------

@echo off
setlocal
del ..\release\dd-cfs.zip
zip -j -9 ..\release\dd-cfs.zip ..\Exe\CFS-Setup-*.exe ..\Docs\ReadMe.txt
endlocal
