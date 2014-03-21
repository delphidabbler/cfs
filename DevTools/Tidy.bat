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

cd ..

del /S *.~* 2>nul
del /S ~* 2>nul
del /S *.dsk 2>nul
del /S *.local 2>nul
del /S *.identcache 2>nul
del /S *.tvsconfig 2>nul
rem remove __history folders
for /F "usebackq" %%i in (`dir /S /B /A:D __history*`) do rmdir /S /Q %%i

echo.
echo Done.

endlocal
