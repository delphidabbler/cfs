{
 * UProcessUtils.pas
 *
 * Utility routines that call into the operating system to display files or
 * interrogate processes.
 *
 * $Rev$
 * $Date$
 *
 * ***** BEGIN LICENSE BLOCK *****
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is UProcessUtils.pas
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2008-2014 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): None
 *
 * ***** END LICENSE BLOCK *****
}


unit UProcessUtils;


interface


uses
  // Delphi
  Windows;


function GetProcessName(const PID: DWORD): string;
  {Gets name of exe file for a given process.
    @param PID [in] Identifier of required process.
    @return Process exe name or '' if no such process or can't read processes.
  }

function ExploreFolder(const Folder: string ): Boolean;
  {Displays a folder in Windows explorer.
    @param Folder [in] Folder to be displayed.
    @return True if Explorer executed and False if not.
  }

function OpenFile(const FileName: string): Boolean;
  {Opens a file in the associated program.
    @param Name of file to open.
    @return True if a program is found to display the file, False if not.
  }


implementation


uses
  // Delphi
  ShellAPI, TlHelp32;


function OpenFile(const FileName: string): Boolean;
  {Opens a file in the associated program.
    @param Name of file to open.
    @return True if a program is found to display the file, False if not.
  }
begin
  Result := ShellExecute(0, '', PChar(FileName), '', '', SW_SHOWNORMAL) > 32;
end;

function ExploreFolder(const Folder: string ): Boolean;
  {Displays a folder in Windows explorer.
    @param Folder [in] Folder to be displayed.
    @return True if Explorer executed and False if not.
  }
begin
  Result := ShellExecute(
    0, 'explore', PChar(Folder), '', '', SW_SHOWNORMAL
  ) > 32;
end;

function GetProcessName(const PID: DWORD): string;
  {Gets name of exe file for a given process.
    @param PID [in] Identifier of required process.
    @return Process exe name or '' if no such process or can't read processes.
  }
var
  Snapshot: THandle;    // snapshot of process
  PE: TProcessEntry32;  // structure holding info about a process
  EndOfList: Boolean;   // indicates end of process list reached
begin
  // Assume failure
  Result := '';
  // Get snapshot containing process list
  Snapshot := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  if Snapshot = THandle(-1) then
    Exit;
  try
    // Look up process in process list
    PE.dwSize := SizeOf(PE);
    EndOfList := not Process32First(Snapshot, PE);
    while not EndOfList do
    begin
      if PE.th32ProcessID = PID then
      begin
        // Found process: record exe name
        Result := PE.szExeFile;
        Break;
      end;
      EndOfList := not Process32Next(Snapshot, PE);
    end;
  finally
    // Free the snapshot
    CloseHandle(Snapshot);
  end;
end;

end.

