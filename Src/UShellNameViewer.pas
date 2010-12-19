{
 * UShellNameViewer.pas
 *
 * Implements a base class for viewers that display shell names provided as
 * simple text.
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
 * The Original Code is UShellNameViewer.pas.
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


unit UShellNameViewer;


interface


uses
  // Delphi
  Forms,
  // Project
  UBaseTextViewer;


type

  {
  TShellNameViewer:
    Base class for viewers that display shell names provided as simple text.
  }
  TShellNameViewer = class(TBaseTextViewer)
  private
    fShellName: string;
      {Name of referenced shell reference. Could be file name or URL}
  protected
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
  end;


implementation


uses
  // Project
  FrShellNameViewer;


{ TShellNameViewer }

procedure TShellNameViewer.ReleaseClipData;
  {Frees the data rendered when RenderClipData was last called.
  }
begin
  // simply delete the stored text
  fShellName := '';
end;

procedure TShellNameViewer.RenderClipData(const FmtID: Word);
  {Reads data for a specified format from the clipboard and renders it into
  a format suitable for display.
    @param FmtID [in] ID of clipboard format to be rendered.
  }
begin
  // get shell name from clipboard text
  fShellName := CopyClipboardText(FmtID);
end;

procedure TShellNameViewer.RenderView(const Frame: TFrame);
  {Displays the rendered clipboard data in viewer frame.
    @param Frame [in] Frame in which to display the data.
  }
begin
  // pass shell name to frame for display
  (Frame as TShellNameViewerFrame).Display(fShellName);
end;

end.

