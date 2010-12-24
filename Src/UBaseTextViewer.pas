{
 * UBaseTextViewer.pas
 *
 * Implements a base class for all viewers that read text from the clipboard.
 * Provides access to text on clipboard.
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
 * The Original Code is UBaseTextViewer.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2008-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): None
 *
 * ***** END LICENSE BLOCK *****
}


unit UBaseTextViewer;


interface


uses
  // Delphi
  SysUtils,
  // Project
  UGlobalMemViewer;


type

  // TODO: comment new methods
  {
  TBaseTextViewer:
    Base class for all viewers that read text from the clipboard. Provides
    access to text on clipboard.
  }
  TBaseTextViewer = class(TGlobalMemViewer)
  protected
    function CopyClipboardText(const FmtID: Word): string; deprecated;
      {Makes a copy of textual clipboard data and returns it as text. Text can
      be either Ansi or Unicode.
        @param FmtID [in] Required clipboard format.
        @return Required text.
      }
    function GetAsAnsiBytes(const FmtID: Word): TBytes;
    function GetAsUnicodeBytes(const FmtID: Word): TBytes;
  end;


implementation


uses
  // Project
  UDataBuffer, UTextTypeSniffer;


{ TBaseTextViewer }

function TBaseTextViewer.CopyClipboardText(const FmtID: Word): string;
  {Makes a copy of textual clipboard data and returns it as text. Text can be
  either Ansi or Unicode.
    @param FmtID [in] Required clipboard format.
    @return Required text.
  }
var
  Data: IDataBuffer;          // data buffer containing copy of clipboard data
  Buffer: Pointer;            // pointer into data buffer
  Sniffer: TTextTypeSniffer;  // used to test whether text is Unicode or ANSI
begin
  // Take copy of clipboard data
  // NOTE: Three copies of clipboard text exist during this method, which is
  // inefficient. 1st is copy on clipboard, second is copy in data buffer and
  // third is text in result string. Data buffer is freed at the end of the
  // method. If this proves too much overhead then bypass CopyClipboardData
  // and hold clipboard open while reading text.
  Data := CopyClipboardMemData(FmtID);
  // Create sniffer object to check whether data is Unicode or Ansi text
  Sniffer := TTextTypeSniffer.Create(Data);
  try
    // Get data in correct format
    Buffer := Data.Lock;
    try
      if Sniffer.IsUnicode then
        Result := PWideChar(Buffer) // Unicode: convert back to string
      else
        // *** THIS IS WRONG!!
        Result := PChar(Buffer);    // Ansi: just return it
    finally
      Data.Unlock;
    end;
  finally
    FreeAndNil(Sniffer);
  end;
end;

function TBaseTextViewer.GetAsAnsiBytes(const FmtID: Word): TBytes;
var
  Data: IDataBuffer;          // data buffer containing copy of clipboard data
  Buffer: Pointer;            // pointer into data buffer
  Len: Integer;               // length of "string" from data buffer
begin
  // We make assumption here that an ANSI character is 1 byte
  Assert(SizeOf(AnsiChar) = 1);
  // Take copy of clipboard data
  Data := CopyClipboardMemData(FmtID);
  // Get data in correct format
  Buffer := Data.Lock;
  try
    // copy clipboard data into byte array: format must have ASCII text
    SetLength(Result, Data.Size);
    Move(Buffer^, Pointer(Result)^, Data.Size);
    // remove all trailing zeros - we don't want these in final string
    Len := Length(Result);
    while (Len > 0) and (Result[Len - 1] = 0) do
      Dec(Len);
    SetLength(Result, Len);
  finally
    Data.Unlock;
  end;
end;

function TBaseTextViewer.GetAsUnicodeBytes(const FmtID: Word): TBytes;
var
  Data: IDataBuffer;          // data buffer containing copy of clipboard data
  Buffer: Pointer;            // pointer into data buffer
  Len: Integer;               // length of "string" from data buffer
begin
  // We make assumption here that a Unicode character is 2 bytes
  Assert(SizeOf(WideChar) = 2);
  // Take copy of clipboard data
  Data := CopyClipboardMemData(FmtID);
  // Get data in correct format
  Buffer := Data.Lock;
  try
    // copy clipboard data into byte array: format must have Unicode text
    SetLength(Result, Data.Size);
    Move(Buffer^, Pointer(Result)^, Data.Size);
    // ensure correct length (multiple of 2)
    Len := Length(Result);
    if Odd(Len) then
      Dec(Len);
    // remove all trailing WideChar zeros - we don't want these in final string
    while (Len >= 2) and (Result[Len - 1] = 0) and (Result[Len - 2] = 0) do
      Dec(Len, 2);
    SetLength(Result, Len);
  finally
    Data.Unlock;
  end;
end;

end.

