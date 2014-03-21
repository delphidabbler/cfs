@rem ---------------------------------------------------------------------------
@rem Script used to delete Clipboard Format Spy's temp and backup source files
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2008-2014
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off
setlocal

echo Tidying
echo ~~~~~~~
echo.

set SrcDir=..\Src

echo Deleting *.~* from "%SrcDir%" and subfolders
del /S %SrcDir%\*.~* 
echo.

echo Deleting *.dpp from "%SrcDir%" and subfolders
del /S %SrcDir%\*.ddp 
echo.

echo Done.

endlocal
