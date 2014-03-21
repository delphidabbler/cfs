@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing binary release of Clipboard
@rem Format Spy.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2008-2014
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off
setlocal
if exist ..\Release\dd-cfs.zip del ..\Release\dd-cfs.zip
if not exist ..\Release mkdir ..\Release
zip -j -9 ..\Release\dd-cfs.zip ..\Exe\CFS-Setup-*.exe ..\Docs\ReadMe.txt
endlocal
