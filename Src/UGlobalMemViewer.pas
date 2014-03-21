{
 * UGlobalMemViewer.pas
 *
 * Base class of all clipboard viewers that read clipboard data from HGLOBAL
 * memory. Provides access to a copy of data on clipboard.
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
 * The Original Code is UGlobalMemViewer.pas.
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


unit UGlobalMemViewer;


interface


uses
  // Project
  UDataBuffer;


type

  {
  TGlobalMemViewer:
    Base class of all clipboard viewers that read clipboard data from HGLOBAL
    memory. Provides access to a copy of data on clipboard.
  }
  TGlobalMemViewer = class(TInterfacedObject)
  protected
    function CopyClipboardMemData(const FmtID: Word): IDataBuffer;
      {Makes a copy of data on clipboard in a buffer object.
        @param FmtID [in] Required clipboard format.
        @return Data buffer instance containing a copy of clipboard data in
          required format.
      }
  end;


implementation


uses
  // Delphi
  Clipbrd, Windows,
  // Project
  IntfViewers;


resourcestring
  // Error message
  sReadError = 'Can''t read global data from clipboard';


{ TGlobalMemViewer }

function TGlobalMemViewer.CopyClipboardMemData(const FmtID: Word): IDataBuffer;
  {Makes a copy of data on clipboard in a buffer object.
    @param FmtID [in] Required clipboard format.
    @return Data buffer instance containing a copy of clipboard data in required
      format.
  }
var
  DataHandle: THandle;  // handle to clipboard data in required format
  DataSize: Integer;    // size of clipboard data
  Data: Pointer;        // pointer to clipboard data
begin
  Clipboard.Open;
  try
    // We make a *copy* of the clipboard data so that clipboard can be closed
    // ASAP. Note that any handles to clipboard data after clipboard has closed
    // are not valid. This can be inefficient when clipboard contains a lot of
    // data.
    DataHandle := Clipboard.GetAsHandle(FmtID);
    if DataHandle = 0 then
      raise EViewer.Create(sReadError); // raise exception if handle not valid
    DataSize := GlobalSize(DataHandle); // returns 0 if invalid handle
    try
      Data := GlobalLock(DataHandle);   // returns nil if invalid handle
      // create data buffer: params (nil, 0) flag an invalid buffer
      Result := TDataBuffer.Create(Data, DataSize)
    finally
      GlobalUnlock(DataHandle);
    end;
  finally
    Clipboard.Close;
  end;
end;

end.

