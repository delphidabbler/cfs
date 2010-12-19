{
 * FrGraphicViewer.pas
 *
 * Implements a viewer frame that displays a TGraphic descendant.
 *
 * v1.0 of 10 Mar 2008  - Original version.
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
 * The Original Code is FrGraphicViewer.pas.
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


unit FrGraphicViewer;


interface


uses
  // Delphi
  Forms, Menus, Classes, ActnList, Controls, ExtCtrls, Graphics;


type

  {
  TGraphicViewerFrame:
    Viewer frame that displays a TGraphic descendant. Supports copying of the
    graphic to the clipboard.
  }
  TGraphicViewerFrame = class(TFrame)
    actCopy: TAction;
    alView: TActionList;
    imgView: TImage;
    miCopy: TMenuItem;
    mnuView: TPopupMenu;
    sbView: TScrollBox;
    procedure actCopyExecute(Sender: TObject);
    procedure FrameResize(Sender: TObject);
  private
    procedure ArrangeControls;
      {Aligns image within display. If image is smaller than display it is centred.
      }
  public
    procedure Display(const Graphic: TGraphic);
      {Displays a graphic.
        @param Graphic [in] Graphic to be displayed.
      }
  end;


implementation


uses
  // Delphi
  Windows, Clipbrd,
  // Project
  UClipFmt;


{$R *.dfm}

{ TGraphicViewerFrame }

procedure TGraphicViewerFrame.actCopyExecute(Sender: TObject);
  {Copies the displayed graphic object to the clipboard. Clipboard format
  depends on type of graphic. If a palette is used it is also copied.
    @param Sender [in] Not used.
    @except Raises exception if displayed graphic does not support clipboard.
  }
var
  ImgFmt: Word;             // image format to be used
  ImgHandle: THandle;       // handle to image being copied
  PaletteHandle: HPALETTE;  // handle to palette (0 if no palette)
begin
  // Get clipboard format for image (supported by TBitmap and TMetafile)
  imgView.Picture.SaveToClipboardFormat(ImgFmt, ImgHandle, PaletteHandle);
  Clipboard.Open;
  try
    // Store image on clipboard
    Clipboard.SetAsHandle(ImgFmt, ImgHandle);
    if PaletteHandle <> 0 then
      // We also have a palette: store this on clipboard
      Clipboard.SetAsHandle(CF_PALETTE, PaletteHandle);
  finally
    Clipboard.Close;
  end;
end;

procedure TGraphicViewerFrame.ArrangeControls;
  {Aligns image within display. If image is smaller than display it is centred.
  }
begin
  if sbView.Width < ClientWidth then
    sbView.Left := (ClientWidth - sbView.Width) div 2
  else
    sbView.Left := 0;
  if sbView.Height < ClientHeight then
    sbView.Top := (ClientHeight - sbView.Height) div 2
  else
    sbView.Top := 0;
end;

procedure TGraphicViewerFrame.Display(const Graphic: TGraphic);
  {Displays a graphic.
    @param Graphic [in] Graphic to be displayed.
  }
begin
  // store graphic in image control and make image control same size as image
  imgView.Picture.Assign(Graphic);
  imgView.Width := Graphic.Width;
  imgView.Height := Graphic.Height;
  // make scroll box same size as image
  sbView.Width := imgView.Width;
  sbView.Height := imgView.Height;
  // align image within frame
  ArrangeControls;
end;

procedure TGraphicViewerFrame.FrameResize(Sender: TObject);
  {Called when frame is resized. Re-aligns image within frame.
    @param Sender [in] Not used.
  }
begin
  ArrangeControls;
end;

end.

