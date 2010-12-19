{
 * UTextTypeSniffer.pas
 *
 * Implements a class that examines data in a text buffer and makes assessment
 * of type of text in buffer.
 *
 * v1.0 of 07 Mar 2008  - Original version.
 *
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
 * The Original Code is UTextTypeSniffer.pas
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2008 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): None
 *
 * ***** END LICENSE BLOCK *****
}


unit UTextTypeSniffer;


interface


uses
  // Delphi
  SysUtils,
  // Project
  UDataBuffer;


type

  {
  TTextTypeSniffer:
    Class that examines data in a text buffer and makes assessment of type of
    text in buffer.
  }
  TTextTypeSniffer = class(TObject)
  private
    fData: IDataBuffer;
      {Buffer containing text to be "sniffed"}
    function FindAnsiTerminator: Integer;
      {Finds 0 based byte index in data buffer of the first Ansi string
      terminator (#0) character.
        @return Required index or -1 if there is no terminator.
      }
    function FindUnicodeTerminator: Integer;
      {Finds 0 based byte index in data buffer of the first Unicode string
      terminator (#0#0) character.
        @return Required index or -1 if there is no terminator.
      }
  public
    constructor Create(const Data: IDataBuffer);
      {Class constructor. Stores data to be sniffed.
        @param Data [in] Buffer containing data to check. Must have valid data.
        @except ETextTypeSniffer raised if data buffer object is invalid.
      }
    function IsValidTextBuffer: Boolean;
      {Checks if buffer may contain valid text. Doesn't determine type.
        @return True if valid text buffer, false otherwise.
      }
    function IsUnicode: Boolean;
      {Checks if data in buffer is Unicode (using heuristic).
        @return True if text is believed to be Unicode, False if not. Note, a
          false result does not indicate the text in valid Ansi text.
      }
  end;

  {
  ETextTypeSniffer:
    Class of exception raised by TTextTypeSniffer objects.
  }
  ETextTypeSniffer = class(Exception);


implementation


resourcestring
  // Error messages
  sBadData = 'Data passed to TTextTypeSniffer is not valid';

type
  {
  TBufferA, PBufferA:
    Types used to access data in buffer as AnsiChar
  }
  TBufferA = array[0..0] of AnsiChar;
  PBufferA = ^TBufferA;

  {
  TBufferW, PBufferW:
    Types used to access data in buffer as WideChar
  }
  TBufferW = array[0..0] of WideChar;
  PBufferW = ^TBufferW;


{ TTextTypeSniffer }

constructor TTextTypeSniffer.Create(const Data: IDataBuffer);
  {Class constructor. Stores data to be sniffed.
    @param Data [in] Buffer containing data to check. Must have valid data.
    @except ETextTypeSniffer raised if data buffer object is invalid.
  }
begin
  inherited Create;
  if not Data.IsValid then
    raise ETextTypeSniffer.Create(sBadData);
  fData := Data;
end;

function TTextTypeSniffer.FindAnsiTerminator: Integer;
  {Finds 0 based byte index in data buffer of the first Ansi string terminator
  (#0) character.
    @return Required index or -1 if there is no terminator.
  }
var
  P: PBufferA;      // pointer to data buffer
  Idx: Integer;     // index into data buffer
  BufSize: Integer; // buffer size in Ansi chars
begin
  P := fData.Lock;
  try
    // Scan thru buffer as AnsiChar searching for #0
    Idx := 0;
    BufSize := fData.Size div SizeOf(AnsiChar);   // belt and braces!
    while (Idx < BufSize) and (P[Idx] <> #0) do
      Inc(Idx);
    if Idx = BufSize then
      Result := -1
    else
      Result := Idx * SizeOf(AnsiChar);
  finally
    fData.Unlock;
  end;
end;

function TTextTypeSniffer.FindUnicodeTerminator: Integer;
  {Finds 0 based byte index in data buffer of the first Unicode string
  terminator (#0#0) character.
    @return Required index or -1 if there is no terminator.
  }
var
  P: PBufferW;      // wide pointer to data buffer
  Idx: Integer;     // index into data buffer
  BufSize: Integer; // buffer size in Wide chars
begin
  P := fData.Lock;
  try
    // Scan thru buffer as WideChar searching for #0#0
    Idx := 0;
    BufSize := fData.Size div SizeOf(WideChar);
    while (Idx < BufSize) and (Ord(P[Idx]) <> 0) do
      Inc(Idx);
    if Idx = BufSize then
      Result := -1
    else
      Result := Idx * SizeOf(WideChar);
  finally
    fData.Unlock;
  end;
end;

function TTextTypeSniffer.IsUnicode: Boolean;
  {Checks if data in buffer is Unicode (using heuristic).
    @return True if text is believed to be Unicode, False if not. Note, a false
      result does not indicate the text in valid Ansi text.
  }
var
  TermIdxA: Integer;  // index of Ansi string terminator (-1 if not found)
  TermIdxW: Integer;  // index of Unicode string terminator (-1 if not found)
begin
  {
    Note:

    The data in the buffer *may* be longer than the valid text. We assume
    (1) buffer can have garbage or padding data beyond end of string;
    (2) garbage data may have odd length;
    (3) garbage data may have any value (tho it is likely to be zeros).

    To test for unicode we use following facts, assumptions and observations:
    (1) a unicode string *must* be terminated by a #0#0 pair at an even byte
        offset;
    (2) observe that any zero byte in a unicode byte pair (such as the letter
        'A' - $41 $00) will terminate an Ansi string;
    (3) assume that if an Ansi string terminator is in the same place (or
        immediately before) a Unicode terminator, we have an Ansi string. This
        assumption could be wrong but, particularly in Western character sets,
        it is unlikely that a Unicode string will contain no zero bytes.

    Therefore we make the following checks:
    (1) that there is a valid terminating #0#0 byte pair at an even byte offset
        in the buffer.
    (2) that the terminating #0#0 byte pair occurs later in the buffer than any
        Ansi terminator.
  }

  // Assume failure
  Result := False;

  // Look for Unicode terminator #0#0 pair
  TermIdxW := FindUnicodeTerminator;
  if TermIdxW = -1 then
    // can't find unicode terminator
    Exit;

  // Find first Ansi string terminator #0. There must be one, and it must be
  // before or in the same place as the Unicode #0#0 pair
  TermIdxA := FindAnsiTerminator;
  if TermIdxA >= TermIdxW - 1 then
    Exit;

  // If we get here, we assume we have Unicode
  Result := True;
end;

function TTextTypeSniffer.IsValidTextBuffer: Boolean;
  {Checks if buffer may contain valid text. Doesn't determine type.
    @return True if valid text buffer, false otherwise.
  }
begin
  // Buffer can contain valid text only if it contains at least one #0 character
  Result := FindAnsiTerminator >= 0;
end;

end.

