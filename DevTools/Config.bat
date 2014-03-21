@rem ---------------------------------------------------------------------------
@rem Script used to create the directories required to build Clipboard Format
@rem Spy.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2014
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

setlocal

cd ..

rem clear directories if they exist
if exist Bin del /Q Bin\*.*
if exist Exe del /Q Exe\*.*
if exist Release del /Q Release\*.*

rem create directories if they do not exist
if not exist Bin mkdir Bin
if not exist Exe mkdir Exe
if not exist Release mkdir Release

endlocal
