{
 * UGraphicViewer.pas
 *
 * Base class for viewers that render image clipboard formats that are stored as
 * GDI handles.
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
 * The Original Code is UGraphicViewer.pas.
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


unit UGraphicViewer;


interface


uses
  // Delphi
  Forms, Graphics,
  // Project
  IntfViewers;


type

  {
  TGraphicViewer:
    Base class for viewers that render image clipboard formats that are stored
    as GDI handles.
  }
  TGraphicViewer = class(TInterfacedObject)
  private
    fGraphic: TGraphic;
      {Reference to graphic object created from clipboard data}
  protected
    function GetGraphicClass: TGraphicClass; virtual; abstract;
      {Gets class of graphic to be created in RenderView method.
        @return Required graphics class.
      }
    { IViewer }
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
      {Class destructor. Ensures any remaining clipboard data is released.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, Clipbrd,
  // Project
  FrGraphicViewer;


{ TGraphicViewer }

destructor TGraphicViewer.Destroy;
  {Class destructor. Ensures any remaining clipboard data is released.
  }
begin
  ReleaseClipData;  // do this in case caller doesn't release
  inherited;
end;

procedure TGraphicViewer.ReleaseClipData;
  {Frees the data rendered when RenderClipData was last called.
  }
begin
  FreeAndNil(fGraphic);
end;

procedure TGraphicViewer.RenderClipData(const FmtID: Word);
  {Reads data for a specified format from the clipboard and renders it into a
  format suitable for display.
    @param FmtID [in] ID of clipboard format to be rendered.
  }
begin
  ReleaseClipData;                    // make sure data rendered last is freed
  fGraphic := GetGraphicClass.Create; // create requierd type of graphic object
  Clipboard.Open;
  try
    fGraphic.LoadFromClipboardFormat(FmtID, Clipboard.GetAsHandle(FmtID), 0);
  finally
    Clipboard.Close;
  end;
end;

procedure TGraphicViewer.RenderView(const Frame: TFrame);
  {Displays the rendered clipboard data in viewer frame.
    @param Frame [in] Frame in which to display the data.
  }
begin
  (Frame as TGraphicViewerFrame).Display(fGraphic);
end;

function TGraphicViewer.UIFrameClass: TFrameClass;
  {Gets the class type of the viewer frame.
    @return Required frame class.
  }
begin
  Result := TGraphicViewerFrame;
end;

end.

