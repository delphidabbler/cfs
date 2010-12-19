{
 * UBinaryViewer.pas
 *
 * Implements a viewer object that displays binary clipboard data for any
 * clipboard format that uses global memory. Always acts as a secondary viewer.
 *
 * v1.0 of 09 Mar 2008  - Original version.
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
 * The Original Code is UBinaryViewer.pas.
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


unit UBinaryViewer;


interface


uses
  // Delphi
  Classes, Forms,
  // Project
  IntfViewers, UDataBuffer, UGlobalMemViewer;


type

  {
  TBinaryViewer:
    Implements a viewer object that displays binary clipboard data for any
    clipboard format that uses global memory. Always acts as a secondary viewer.
  }
  TBinaryViewer = class(TGlobalMemViewer,
    IViewer
  )
  private
    fDataStm: TStream;
      {Stream onto data buffer containing copy of clipboard data}
  protected
    { IViewer }
    function SupportsFormat(const FmtID: Word): Boolean;
      {Checks whether viewer supports a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if format is supported, False if not.
      }
    function IsPrimaryViewer(const FmtID: Word): Boolean;
      {Checks if the viewer is the "primary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return False. This is always a secondary viewer.
      }
    function MenuText(const FmtID: Word): string;
      {Gets text to display in viewer menu.
        @param FmtID [in] ID of required clipboard format.
        @return Required menu text.
      }
    procedure RenderClipData(const FmtID: Word);
      {Reads data for a specified format from the clipboard and renders it into
      a format suitable for display.
        @param FmtID [in] ID of clipboard format to be rendered.
      }
    procedure ReleaseClipData;
      {Frees the data rendered when RenderClipData was last called.
      }
    procedure RenderView(const Frame: TFrame);
      {Displays the rendered clipboard data in viewer frame.
        @param Frame [in] Frame in which to display the data.
      }
    function UIFrameClass: TFrameClass;
      {Gets the class type of the viewer frame.
        @return Required frame class.
      }
  public
    destructor Destroy; override;
      {Class destructor. Releases any remaining rendered data.
      }
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  FrBinaryViewer, UCBUtils, UViewers;


{ TBinaryViewer }

destructor TBinaryViewer.Destroy;
  {Class destructor. Releases any remaining rendered data.
  }
begin
  ReleaseClipData;
  inherited;
end;

function TBinaryViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return False. This is always a secondary viewer.
  }
begin
  Result := False;  // binary viewer is always a secondary viewer
end;

function TBinaryViewer.MenuText(const FmtID: Word): string;
  {Gets text to display in viewer menu.
    @param FmtID [in] ID of required clipboard format.
    @return Required menu text.
  }
resourcestring
  sMenuText = 'View As Binary'; // same menu text for all formats
begin
  Result := sMenuText;
end;

procedure TBinaryViewer.ReleaseClipData;
  {Frees the data rendered when RenderClipData was last called.
  }
begin
  FreeAndNil(fDataStm);
end;

procedure TBinaryViewer.RenderClipData(const FmtID: Word);
  {Reads data for a specified format from the clipboard and renders it into a
  format suitable for display.
    @param FmtID [in] ID of clipboard format to be rendered.
  }
begin
  // open stream onto clipboard data copy
  fDataStm := TDataBufferStream.Create(CopyClipboardMemData(FmtID));
end;

procedure TBinaryViewer.RenderView(const Frame: TFrame);
  {Displays the rendered clipboard data in viewer frame.
    @param Frame [in] Frame in which to display the data.
  }
begin
  // we pass the binary data in a stream
  fDataStm.Position := 0;
  (Frame as TBinaryViewerFrame).Display(fDataStm);
end;

function TBinaryViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  // we support all HGLOBAL based formats
  Result := UCBUtils.IsDataInGlobalMemFormat(FmtID);
end;

function TBinaryViewer.UIFrameClass: TFrameClass;
  {Gets the class type of the viewer frame.
    @return Required frame class.
  }
begin
  Result := TBinaryViewerFrame;
end;

initialization

// Register viewer
ViewerRegistrar.RegisterViewer(TBinaryViewer.Create);

end.

