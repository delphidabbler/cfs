@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing source code of Clipboard Format
@rem Spy.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2008-2014
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

setlocal

cd ..

set OutFile=Release\dd-cfs-src.zip

if exist %OutFile% del %OutFile%
if not exist Release mkdir Release

zip -r -9 %OutFile% Src
zip %OutFile% -d Src\CFS.dsk
zip -r -9 %OutFile% Bin\*.res
zip -j -9 %OutFile% Docs\SourcecodeLicenses.txt
zip -j -9 %OutFile% Docs\ReadMe-src.txt
zip -j -9 %OutFile% Docs\MPL.txt

endlocal
