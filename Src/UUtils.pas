{
 * UUtils.pas
 *
 * Miscellaneous utility routines.
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
 * The Original Code is UUtils.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2008-2011 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): None
 *
 * ***** END LICENSE BLOCK *****
}


unit UUtils;


interface


uses
  // Delphi
  Windows;


function AttrsToStr(const Attrs: Integer): string;
  {Builds a string representation of file attributes by concatenating letters
  that each represent an attribute.
    @param Attrs [in] File attributes to be converted to string.
    @return Required string representation. May be ''.
  }

function WinFileTimeToDateTime(FT: TFileTime): TDateTime;
  {Converts Windows FILETIME value to Delphi TDateTime.
  is valid or can't be converted.
    @param FT [in] Value to be converted.
    @return TDateTime equivalent value.
    @except Exception raised if FT is not a valid value.
  }


function IntToFixed(const Value: Integer;
  const SeparateThousands: Boolean): string;
  {Converts an integer into a string representation with optionally delimited
  thousands.
    @param Value [in] Value to be converted to string.
    @param SeparateThousands [in] Flag indicating whether thousands should be
      separated by locale's thousand separator.
    @return Formatted number as string.
  }

procedure Pause(const ADelay: Cardinal);
  {Pauses program. Performs a busy wait.
    @param ADelay [in] Length of time to wait in msec.
  }

function FileAge(const FileName: string): Integer;
  {Gets the OS time stamp for a file.
    @param FileName [in] Name of file.
    @return Required OS time stamp or -1 if file does not exist or is a
      directory.
  }


implementation


uses
  // Delphi
  SysUtils, Forms;


function AttrsToStr(const Attrs: Integer): string;
  {Builds a string representation of file attributes by concatenating letters
  that each represent an attribute.
    @param Attrs [in] File attributes to be converted to string.
    @return Required string representation. May be ''.
  }
begin
  Result := '';
  if (Attrs and faReadOnly) <> 0 then
    Result := Result + 'R';
  if (Attrs and faHidden) <> 0 then
    Result := Result + 'H';
  if (Attrs and faSysFile) <> 0 then
    Result := Result + 'S';
  if (Attrs and faArchive) <> 0 then
    Result := Result + 'A';
end;

function WinFileTimeToDateTime(FT: TFileTime): TDateTime;
  {Converts Windows FILETIME value to Delphi TDateTime.
  is valid or can't be converted.
    @param FT [in] Value to be converted.
    @return TDateTime equivalent value.
    @except Exception raised if FT is not a valid value.
  }
var
  SysTime: TSystemTime; // stores date/time in system time format
begin
  // Convert file time to system time, raising exception on error
  Win32Check(FileTimeToSystemTime(FT, SysTime));
  // Convert system time to Delphi date time, raising excpetion on error
  Result := SystemTimeToDateTime(SysTime);
end;

function FloatToFixed(const Value: Extended; const DecimalPlaces: Byte;
  const SeparateThousands: Boolean): string;
  {Converts a floating point number to a fixed decimal string with optionally
  separated thousands.
    @param Value [in] Value to be converted to string.
    @param DecimalPlaces [in] Number of decimal places to include in formatted
      number.
    @param SeparateThousands [in] Flag indicating whether thousands should be
      separated by locale's thousand separator.
    @return Formatted number as string.
  }
const
  // Formats specification for use of thousands separator: 'f' => no separator,
  // 'n' => separate thousands
  cFmtSpec: array[Boolean] of Char = ('f', 'n');
begin
  Result := Format(
    '%.*' + cFmtSpec[SeparateThousands], [DecimalPlaces, Value]
  );
end;

function IntToFixed(const Value: Integer;
  const SeparateThousands: Boolean): string;
  {Converts an integer into a string representation with optionally delimited
  thousands.
    @param Value [in] Value to be converted to string.
    @param SeparateThousands [in] Flag indicating whether thousands should be
      separated by locale's thousand separator.
    @return Formatted number as string.
  }
begin
  Result := FloatToFixed(Value, 0, SeparateThousands);
end;

procedure Pause(const ADelay: Cardinal);
  {Pauses program. Performs a busy wait.
    @param ADelay [in] Length of time to wait in msec.
  }
var
  StartTC: Cardinal;  // tick count when routine called
begin
  StartTC := GetTickCount;
  repeat
    Application.ProcessMessages;
  until Int64(GetTickCount) - Int64(StartTC) >= ADelay;
end;

function FileAge(const FileName: string): Integer;
  {Gets the OS time stamp for a file.
    @param FileName [in] Name of file.
    @return Required OS time stamp or -1 if file does not exist or is a
      directory.
  }
var
  FH: Integer;  // file handle
begin
  // This function is provided to avoid using FileAge unit in SysUtils since
  // the routine is deprecated in Delphi 2010
  Result := -1;
  if DirectoryExists(FileName) then
    Exit;   // FileName is a directory
  FH := FileOpen(FileName, fmOpenRead or fmShareDenyNone);
  if FH <> -1 then
  begin
    Result := FileGetDate(FH);
    FileClose(FH);
  end;
end;

end.

