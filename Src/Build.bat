@rem ---------------------------------------------------------------------------
@rem Script used to build the DelphiDabbler CLipboard Format Spy project
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2008-2014
@rem
@rem $Rev$
@rem $Date$
@rem
@rem Requires the following compilers and build tools:
@rem   Borland Delphi 2010
@rem   Borland BRCC32 from Delphi 2010 installation
@rem   DelphiDabbler HTML Resource Compiler from www.delphidabbler.com
@rem   DelphiDabbler Version Information Editor from www.delphidabbler.com
@rem   Microsoft HTML Help compiler v1.1
@rem   Inno Setup
@rem
@rem Also requires the following environment variables:
@rem   DELPHI2010 to be set to the install directory of Delphi 2010.
@rem   DELPHIDABLIBD2010 to be set to the install directory of the required
@rem     DelphiDabbler components on Delphi 2010.
@rem   INNOSETUP to be set to Unicode Inno Setup install directory.
@rem   VIEDROOT to be set to Version Information Editor install directory.
@rem   HHCROOT to be set to the HTML Help Compiler install directory.
@rem
@rem Switches: exactly one of the following must be provided
@rem   all - build everything
@rem   res - build binary resource files only
@rem   pas - build Delphi Pascal project only
@rem   exe - build Pascal and resource files
@rem   help - build help file
@rem   setup - build setup file
@rem
@rem ---------------------------------------------------------------------------

@echo off

setlocal


rem ----------------------------------------------------------------------------
rem Sign on
rem ----------------------------------------------------------------------------

echo DelphiDabbler Clipboard Format Spy Build Script
echo -----------------------------------------------
title DelphiDabbler Clipboard Format Spy Build File

goto Config


rem ----------------------------------------------------------------------------
rem Configure script per command line parameter
rem ----------------------------------------------------------------------------

:Config
echo Configuring script
rem reset all config variables

set BuildAll=
set BuildResources=
set BuildPascal=
set BuildExe=
set BuildHelp=
set BuildSetup=

rem check switch

if "%~1" == "all" goto Config_BuildAll
if "%~1" == "res" goto Config_BuildResources
if "%~1" == "pas" goto Config_BuildPascal
if "%~1" == "exe" goto Config_BuildExe
if "%~1" == "help" goto Config_BuildHelp
if "%~1" == "setup" goto Config_BuildSetup
set ErrorMsg=Unknown switch "%~1"
if "%~1" == "" set ErrorMsg=No switch specified
goto Error

rem set config variables

:Config_BuildAll
set BuildResources=1
set BuildPascal=1
set BuildHelp=1
set BuildSetup=1
goto Config_OK

:Config_BuildResources
set BuildResources=1
goto Config_OK

:Config_BuildPascal
set BuildPascal=1
goto Config_OK

:Config_BuildExe
set BuildResources=1
set BuildPascal=1
goto Config_OK

:Config_BuildHelp
set BuildHelp=1
goto Config_OK

:Config_BuildSetup
set BuildSetup=1
goto Config_OK

rem script configured OK

:Config_OK
echo Done.
goto CheckEnvVars


rem ----------------------------------------------------------------------------
rem Check that required environment variables exist
rem ----------------------------------------------------------------------------

:CheckEnvVars

echo Checking predefined environment environment variables
if not defined DELPHI2010 goto BadDELPHI2010Env
if not defined DELPHIDABLIBD2010 goto BadDELPHIDABLIBD2010Env
if not defined INNOSETUP goto BadINNOSETUPEnv
if not defined VIEDROOT goto BadVIEDROOTEnv
if not defined HHCROOT goto BadHHCROOTEnv
echo Done.
echo.
goto SetEnvVars

rem we have at least one undefined env variable

:BadDELPHI2010Env
set ErrorMsg=DELPHI2010 Environment variable not defined
goto Error

:BadDELPHIDABLIBD2010Env
set ErrorMsg=DELPHIDABLIBD2010 Environment variable not defined
goto Error

:BadINNOSETUPEnv
set ErrorMsg=INNOSETUP Environment varibale not defined
goto Error

:BadVIEDROOTEnv
set ErrorMsg=VIEDROOT Environment varibale not defined
goto Error

:BadHHCROOTEnv
set ErrorMsg=HHCROOT Environment varibale not defined
goto Error

rem ----------------------------------------------------------------------------
rem Set up required environment variables
rem ----------------------------------------------------------------------------

:SetEnvVars
echo Setting Up Environment

rem directories

rem full path to this file
set BuildDir=%~dp0
rem source directory
set SrcDir=.\
rem help source directory
set HelpSrcDir=%SrcDir%Help\
rem install script source directory
set InstallSrcDir=%SrcDir%
rem binary files directory
set BinDir=..\Bin\
rem executable files directory
set ExeDir=..\Exe\

rem executable programs

rem Delphi 2010 - use full path since maybe multple installations
set DCC32Exe="%DELPHI2010%\Bin\DCC32.exe"
rem Borland Resource Compiler - use full path since maybe multple installations
set BRCC32Exe="%DELPHI2010%\Bin\BRCC32.exe"
rem Inno Setup command line compiler
set ISCCExe="%INNOSETUP%\ISCC.exe"
rem Microsoft HTML Workshop - assumed to be on the path
set HHCExe="%HHCROOT%\HHC.exe"
rem DelphiDabbler Version Information Editor - assumed to be on the path
set VIEdExe="%VIEDROOT%\VIEd.exe"

echo Done.
echo.

rem ----------------------------------------------------------------------------
rem Start of build process
rem ----------------------------------------------------------------------------

:Build
echo BUILDING ...
echo.

goto Build_Resources


rem ----------------------------------------------------------------------------
rem Build resource files
rem ----------------------------------------------------------------------------

:Build_Resources
if not defined BuildResources goto Build_Pascal
echo Building Resources
echo.

rem set required env vars

rem Ver info resource
set VerInfoBase=Version
set VerInfoSrc=%SrcDir%%VerInfoBase%.vi
set VerInfoTmp=%SrcDir%%VerInfoBase%.rc
set VerInfoRes=%BinDir%%VerInfoBase%.res
rem Main resource
set MainBase=Resources
set MainSrc=%SrcDir%%MainBase%.rc
set MainRes=%BinDir%%MainBase%.res

rem Compile version information resource

echo Compiling %VerInfoSrc% to %VerInfoRes%
rem VIedExe creates temp resource .rc file from .vi file
set ErrorMsg=
%VIEdExe% -makerc %VerInfoSrc%
if errorlevel 1 set ErrorMsg=Failed to compile %VerInfoSrc%
if not "%ErrorMsg%"=="" goto VerInfoRes_End
rem BRCC32Exe compiles temp resource .rc file to required .res
%BRCC32Exe% %VerInfoTmp% -fo%VerInfoRes%
if errorlevel 1 set ErrorMsg=Failed to compile %VerInfoTmp%
if not "%ErrorMsg%"=="" goto VerInfoRes_End
echo Done
echo.

:VerInfoRes_End
if exist %VerInfoTmp% del %VerInfoTmp%
if not "%ErrorMsg%"=="" goto Error

rem Compile Main resource

echo Compiling %MainSrc% to %MainRes%
%BRCC32Exe% %MainSrc% -fo%MainRes%
if errorlevel 1 goto MainRes_Error
echo Done
echo.
goto MainRes_End

:MainRes_Error
set ErrorMsg=Failed to compile %MainSrc%
goto Error

:MainRes_End

rem End of resource compilation

goto Build_Pascal


rem ----------------------------------------------------------------------------
rem Build Pascal project
rem ----------------------------------------------------------------------------

:Build_Pascal
if not defined BuildPascal goto Build_Help

rem Set up required env vars
set PascalBase=CFS
set PascalSrc=%SrcDir%%PascalBase%.dpr
set PascalExe=%ExeDir%%PascalBase%.exe
set DDabLib=%DELPHIDABLIBD2010%

if not defined BuildPascal goto Build_Help
echo Building Pascal Project
%DCC32Exe% -B %PascalSrc% -U"%DDabLib%"
if errorlevel 1 goto Pascal_Error
goto Pascal_End

:Pascal_Error
set ErrorMsg=Failed to compile %PascalSrc%
if exist %PascalExe% del %PascalExe%
goto Error

:Pascal_End
echo Done.
echo.

rem End of Pascal compilation

goto Build_Help


rem ----------------------------------------------------------------------------
rem Build help project
rem ----------------------------------------------------------------------------

:Build_Help
if not defined BuildHelp goto Build_Setup
echo Building Help Project

rem Set required environment variables
set HelpBase=CFS
set HelpChm=%ExeDir%%HelpBase%.chm
set HelpPrj=%HelpSrcDir%%HelpBase%.hhp

rem Compile help file: HHC returns 0 on failure, +ve on success
%HHCExe% %HelpPrj%
if errorlevel 1 goto Help_End
rem if we get here we have error
set ErrorMsg=Failed to compile %HelpPrj%
if exist %HelpChm% del %HelpChm%
goto Error

:Help_End
echo Done.
echo.

goto Build_Setup


rem ----------------------------------------------------------------------------
rem Build setup program
rem ----------------------------------------------------------------------------

:Build_Setup
if not defined BuildSetup goto Build_End
echo Building Setup Program

rem Set required environment variables
set SetupSrc=%InstallSrcDir%Install.iss
set SetupExeWild=%ExeDir%CFS-Setup-*

echo SRC - %SetupSrc%
echo EXE - %SetupExeWild%

rem ISCC does not return error code if compile fails so find another way to
rem detect errors

del %SetupExeWild%
%ISCCExe% %SetupSrc%
if exist %SetupExeWild% goto Setup_End
set ErrorMsg=Failed to compile %SetupSrc%
goto Error

:Setup_End
echo Done.
echo.

goto Build_End


rem ----------------------------------------------------------------------------
rem Build completed
rem ----------------------------------------------------------------------------

:Build_End
echo BUILD COMPLETE
echo.

goto End


rem ----------------------------------------------------------------------------
rem Handle errors
rem ----------------------------------------------------------------------------

:Error
echo.
echo *** ERROR: %ErrorMsg%
echo.


rem ----------------------------------------------------------------------------
rem Finished
rem ----------------------------------------------------------------------------

:End
echo.
echo DONE.
endlocal
