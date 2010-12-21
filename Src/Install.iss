;===============================================================================
; Install.iss
;
; Clipboard Format Spy install file generation script for use with Inno Setup.
; 
; The Unicode version of Inno Setup 5.4.0 or later is required.
;
; $Rev$
; $Date$
;===============================================================================
;
; ***** BEGIN LICENSE BLOCK *****
;
; Version: MPL 1.1
;
; The contents of this file are subject to the Mozilla Public License Version
; 1.1 (the "License"); you may not use this file except in compliance with the
; License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
;
; Software distributed under the License is distributed on an "AS IS" basis,
; WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
; the specific language governing rights and limitations under the License.
;
; The Original Code is Install.iss
;
; The Initial Developer of the Original Code is Peter Johnson
; (http://www.delphidabbler.com/).
;
; Portions created by the Initial Developer are Copyright (C) 2008-2010 Peter
; Johnson. All Rights Reserved.
;
; Contributor(s): None
;
; ***** END LICENSE BLOCK *****
;
;===============================================================================

; Deletes "Release " from beginning of S
#define DeleteToVerStart(str S) \
  /* assumes S begins with "Release " followed by version as x.x.x */ \
  Local[0] = Copy(S, Len("Release ") + 1, 99), \
  Local[0]

; The following defines use these macros that are predefined by ISPP:
;   SourcePath - path where this script is located
;   GetStringFileInfo - gets requested version info string from an executable
;   GetFileProductVersion - gets product version info string from an executable

#define ExeFile "CFS.exe"
#define HelpFile "CFS.chm"
#define LicenseFile "License.rtf"
#define ShortcutFile "CFS.url"
#define ReadmeFile "ReadMe.txt"
#define ChangeLogFile "ChangeLog.txt"
#define InstDocsDir "Docs"
#define InstUninstDir "Uninstall"
#define OutDir SourcePath + "..\Exe"          /* SourcePath is predefined */
#define SrcExePath SourcePath + "..\Exe\"
#define SrcDocsPath SourcePath + "..\Docs\"
#define ExeProg SrcExePath + ExeFile
#define Company "DelphiDabbler.com"
#define AppPublisher "DelphiDabbler"
#define AppName "Clipboard Format Spy"
#define AppVersion DeleteToVerStart(GetFileProductVersion(ExeProg))
#define Copyright GetStringFileInfo(ExeProg, LEGAL_COPYRIGHT)
#define WebAddress "www.delphidabbler.com"
#define WebURL "http://" + WebAddress + "/"
#define AppURL WebURL + "cfs"

[Setup]
AppID={{5589C954-675C-49A7-AAA8-4AAFEA401098}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppPublisher} {#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#WebURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
AppReadmeFile={app}\{#InstDocsDir}\{#ReadmeFile}
AppCopyright={#Copyright} ({#WebAddress})
AppComments=
AppContact=
DefaultDirName={pf}\{#AppPublisher}\CFS4
DefaultGroupName={#AppName}
AllowNoIcons=false
LicenseFile={#SrcDocsPath}{#LicenseFile}
Compression=lzma/ultra
SolidCompression=true
OutputDir={#OutDir}
OutputBaseFilename=CFS-Setup-{#AppVersion}
MinVersion=0,5
RestartIfNeededByRun=false
PrivilegesRequired=poweruser
UsePreviousAppDir=true
UsePreviousGroup=true
UsePreviousSetupType=false
UsePreviousTasks=false
ShowLanguageDialog=no
LanguageDetectionMethod=none
InternalCompressLevel=ultra
InfoAfterFile=
InfoBeforeFile=
VersionInfoVersion={#AppVersion}
VersionInfoCompany={#Company}
VersionInfoDescription=Installer for {#AppName}
VersionInfoTextVersion={#AppVersion}
VersionInfoCopyright={#Copyright}
UninstallFilesDir={app}\{#InstUninstDir}
UpdateUninstallLogAppName=true
UninstallDisplayIcon={app}\{#ExeFile}
UserInfoPage=false

[Files]
; Executable files
Source: {#SrcExePath}{#ExeFile}; DestDir: {app}; Flags: uninsrestartdelete
Source: {#SrcExePath}{#HelpFile}; DestDir: {app}; Flags: ignoreversion
; Documentation
Source: {#SrcDocsPath}{#LicenseFile}; DestDir: {app}\{#InstDocsDir}; Flags: ignoreversion
Source: {#SrcDocsPath}{#ReadmeFile}; DestDir: {app}\{#InstDocsDir}; Flags: isreadme ignoreversion
Source: {#SrcDocsPath}{#ChangeLogFile}; DestDir: {app}\{#InstDocsDir}; Flags: ignoreversion

[INI]
; Shortcut to CFS home page
Filename: {app}\{#ShortcutFile}; Section: InternetShortcut; Key: URL; String: {#AppURL}

[Icons]
Name: {group}\{#AppName}; Filename: {app}\{#ExeFile}
Name: {group}\{cm:ProgramOnTheWeb,{#AppName}}; Filename: {app}\{#ShortcutFile}
Name: {group}\{cm:UninstallProgram,{#AppName}}; Filename: {uninstallexe}

[Run]
Filename: {app}\{#ExeFile}; Description: {cm:LaunchProgram,{#AppName}}; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Specify this shortcut since it is created by installer rather than copied
Type: files; Name: {app}\{#ShortcutFile}

[Dirs]
Name: {app}\{#InstDocsDir}; Flags: uninsalwaysuninstall
Name: {app}\{#InstUninstDir}; Flags: uninsalwaysuninstall

[Registry]
; Register application and its path
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\{#ExeFile}; ValueType: string; ValueData: {app}\{#ExeFile}; Flags: uninsdeletekey
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\{#ExeFile}; ValueType: string; ValueName: Path; ValueData: {app}\; Flags: uninsdeletekey

[Messages]
; Brand installer
BeveledLabel={#Company}

