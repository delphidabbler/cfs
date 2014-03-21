{
 * UDIBViewer.pas
 *
 * Implements a viewer for device independent bitmaps stored on clipboard.
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
 * The Original Code is UDIBViewer.pas.
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


unit UDIBViewer;


interface


uses
  // Delphi
  Forms, Graphics,
  // Project
  IntfViewers, UGlobalMemViewer;


type

  {
  TDIBViewer:
    Viewer for device independent bitmaps stored on clipboard.
  }
  TDIBViewer = class(TGlobalMemViewer,
    IViewer
  )
  private
    fBitmap: TGraphic;
      {Bitmap created from DIB data from clipboard}
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
        @return True. This is always a primary viewer.
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
      {Class destructor. Ensures any remaining rendered data is released.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, Classes, Windows,
  // Project
  FrGraphicViewer, UClipFmt, UDataBuffer, UViewers;


{ TDIBViewer }

destructor TDIBViewer.Destroy;
  {Class destructor. Ensures any remaining rendered data is released.
  }
begin
  ReleaseClipData;
  inherited;
end;

function TDIBViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True. This is always a primary viewer.
  }
begin
  Result := True;
end;

function TDIBViewer.MenuText(const FmtID: Word): string;
  {Gets text to display in viewer menu.
    @param FmtID [in] ID of required clipboard format.
    @return Required menu text.
  }
resourcestring
  sMenuText = 'View Bitmap';  // only menu text required
begin
  Result := sMenuText;
end;

procedure TDIBViewer.ReleaseClipData;
  {Frees the data rendered when RenderClipData was last called.
  }
begin
  FreeAndNil(fBitmap);
end;

procedure TDIBViewer.RenderClipData(const FmtID: Word);
  {Reads data for a specified format from the clipboard and renders it into
  a format suitable for display.
    @param FmtID [in] ID of clipboard format to be rendered.
  }
var
  BMF: TBitmapFileheader;   // dummy bitmap file header
  Data: IDataBuffer;        // buffer to hold copy of clipboard data
  BmpData: TMemoryStream;   // stream used to build required bitmap data
begin
  // NOTE: This method is adapted from on code by Grahame Marsh accompanying an
  // article on OLE drag and drop from UNDU.
  // As Grahame observes the code is very inefficient for large bitmaps: there
  // could be up to *five* copies in memory: the original in its application,
  // the clipboard copy, the data buffer copy, the memory stream and the bitmap.
  // If this proves too much overhead then bypass CopyClipboardData and hold
  // the clipboard open while reading text. This will reduce the count to four.
  // Further optimisations may be necessary

  // first make sure any previous rendered data is released
  ReleaseClipData;
  // make copy of clipboard data
  Data := CopyClipboardMemData(FmtID);
  // create bitmap to load data
  fBitmap := Graphics.TBitmap.Create;
  try
    // set up a dummy bitmap file header with correct magic number
    FillChar(BMF, SizeOf(BMF), 0);
    BMF.bfType := $4D42;
    // write file header to mem stream, followed by data from resources
    BmpData := TMemoryStream.Create;
    try
      BmpData.Write(BMF, sizeof (BMF));
      BmpData.Write(Data.Lock^, Data.Size);
      // load the memory stream into the bitmap
      BmpData.Position := 0;
      fBitmap.LoadFromStream(BmpData)
    finally
      // dispose of the mem stream
      FreeAndNil(BmpData);
    end
  finally
    // data buffer will be freed when it goes out of scope
    Data.Unlock;
  end
end;

procedure TDIBViewer.RenderView(const Frame: TFrame);
  {Displays the rendered clipboard data in viewer frame.
    @param Frame [in] Frame in which to display the data.
  }
begin
  (Frame as TGraphicViewerFrame).Display(fBitmap);
end;

function TDIBViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  Result := FmtID = CF_DIB;
end;

function TDIBViewer.UIFrameClass: TFrameClass;
  {Gets the class type of the viewer frame.
    @return Required frame class.
  }
begin
  Result := TGraphicViewerFrame;
end;


initialization

// Register viewer
ViewerRegistrar.RegisterViewer(TDIBViewer.Create);

end.

