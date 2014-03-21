{
 * UCBUtils.pas
 *
 * Clipboard format utility functions.
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
 * The Original Code is UCBUtils.pas
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 1997-2014 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit UCBUtils;


interface


function CBCodeToString(const FmtID: Word): string;
  {Gets a description of a clipboard format code.
    @param FmtID [in] Clipboard format for which description required.
    @return Required description or '' if code is not known.
  }

function ClipboardOwnerExe: string;
  {Gets file name of executable that owns the clipboard.
    @return Required exe name or '' if clipboard has no owner.
  }

procedure ClearClipboard;
  {Clears the clipboard.
  }

function IsDataInGlobalMemFormat(const FmtID: Word): Boolean;
  {Checks if clipboard data in in global memory format, i.e. has a valid HGlobal
  handle.
    @return True if format is in global memory, false otherwise.
  }

function CanOpenClipboard: Boolean;
  {Checks if clipboard can be opened.
    @return True if clipboard can be opened, false if not.
  }


implementation


uses
  // Delphi
  Windows, Clipbrd,
  // Project
  UClipFmt, UProcessUtils;


function CanOpenClipboard: Boolean;
  {Checks if clipboard can be opened.
    @return True if clipboard can be opened, false if not.
  }
begin
  Result := Windows.OpenClipboard(0);
  if Result then
    Windows.CloseClipboard;
end;

function IsDataInGlobalMemFormat(const FmtID: Word): Boolean;
  {Checks if clipboard data in in global memory format, i.e. has a valid HGlobal
  handle.
    @return True if format is in global memory, false otherwise.
  }
begin
  Result := GlobalSize(Clipboard.GetAsHandle(FmtID)) > 0;
end;

procedure ClearClipboard;
  {Clears the clipboard.
  }
begin
  // We open clipboard with no owning window. This causes EmptyClipBoard to
  // set the clipboard owner to nul.
  OpenClipBoard(0);
  try
    EmptyClipBoard;
  finally
    CloseClipBoard;
  end;
end;

function ClipboardOwnerExe: string;
  {Gets file name of executable that owns the clipboard.
    @return Required exe name or '' if clipboard has no owner.
  }
var
  Wnd: HWND;  // window that owns clipboard
  PID: DWORD; // id of process that owns the clipboard owner window
begin
  // Assume failure
  Result := '';
  // Get window that owns clipboard
  Wnd := GetClipboardOwner;
  if (Wnd = 0) or not IsWindow(Wnd) then
    Exit;
  // Get ID of process that owns the clipboard owner window
  GetWindowThreadProcessId(Wnd, PID);
  // Now get exe name for this process
  Result := GetProcessName(PID);
end;

function GetRegisteredClipFmtName(const Fmt: Word): string;
  {Gets the name of a registered clipboard format represented by a format ID.
    @param Fmt [in] Format ID.
    @return Name of registered format represented by ID, or '' if no such
      format.
  }
var
  Buffer: array[0..255] of char;  // buffer for Windows API call
begin
  if GetClipBoardFormatName(Fmt, Buffer, SizeOf(Buffer)-1) > 0 then
    Result := Buffer
  else
    Result := '';
end;

function GetStdClipFmtName(const FmtID: Word): string;
  {Gets constant name associated with a standard clipboard format id.
    @param FmtID [in] Format id for which constant name is required.
    @return Constant name or '' if FmtID is not a known standard windows format.
  }
const
  // Map of formats to names
  cNameMap: array[0..21] of record
    Format: Word; // format id
    Name: string; // constant name
  end =
  (
    (Format: CF_BITMAP;           Name: 'CF_BITMAP';),
    (Format: CF_DIB;              Name: 'CF_DIB';),
    (Format: CF_DIBV5;            Name: 'CF_DIBV5';),
    (Format: CF_DIF;              Name: 'CF_DIF';),
    (Format: CF_DSPBITMAP;        Name: 'CF_DSPBITMAP';),
    (Format: CF_DSPENHMETAFILE;   Name: 'CF_DSPENHMETAFILE';),
    (Format: CF_DSPMETAFILEPICT;  Name: 'CF_DSPMETAFILEPICT';),
    (Format: CF_DSPTEXT;          Name: 'CF_DSPTEXT';),
    (Format: CF_ENHMETAFILE;      Name: 'CF_ENHMETAFILE';),
    (Format: CF_HDROP;            Name: 'CF_HDROP';),
    (Format: CF_LOCALE;           Name: 'CF_LOCALE';),
    (Format: CF_METAFILEPICT;     Name: 'CF_METAFILEPICT';),
    (Format: CF_OEMTEXT;          Name: 'CF_OEMTEXT';),
    (Format: CF_OWNERDISPLAY;     Name: 'CF_OWNERDISPLAY';),
    (Format: CF_PALETTE;          Name: 'CF_PALETTE';),
    (Format: CF_PENDATA;          Name: 'CF_PENDATA';),
    (Format: CF_RIFF;             Name: 'CF_RIFF';),
    (Format: CF_SYLK;             Name: 'CF_SYLK';),
    (Format: CF_TEXT;             Name: 'CF_TEXT';),
    (Format: CF_TIFF;             Name: 'CF_TIFF';),
    (Format: CF_UNICODETEXT;      Name: 'CF_UNICODETEXT';),
    (Format: CF_WAVE;             Name: 'CF_WAVE';)
  );
var
  Idx: Integer; // loops through entries in map
begin
  Result := '';
  for Idx := Low(cNameMap) to High(cNameMap) do
  begin
    if FmtID = cNameMap[Idx].Format then
    begin
      Result := cNameMap[Idx].Name;
      Break;
    end;
  end;
end;

function CBCodeToString(const FmtID: Word): string;
  {Gets a description of a clipboard format code.
    @param FmtID [in] Clipboard format for which description required.
    @return Required description or '' if code is not known.
  }
begin
  // Check if code is a standard Windows format
  Result := GetStdClipFmtName(FmtID);
  if Result = '' then
    // Not a standard format: assume a registered format - get name from Windows
    // API call (this call doesn't work for standard formats)
    Result := GetRegisteredClipFmtName(FmtID);
end;

end.

