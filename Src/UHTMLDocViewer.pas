{
 * UHTMLDocViewer.pas
 *
 * Implements a viewer object for complete or partial HTML documents stored on
 * clipboard.
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
 * The Original Code is UHTMLDocViewer.pas.
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


unit UHTMLDocViewer;


interface


uses
  // Delphi
  Forms,
  // Project
  IntfViewers, UBaseTextViewer;


type

  {
  THTMLDocViewer:
    Viewer for complete or partial HTML documents stored on clipboard.
  }
  THTMLDocViewer = class(TBaseTextViewer,
    IViewer
  )
  private
    fHTML: string;
      {Contains HTML source code to be displayed}
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
  end;


implementation


uses
  // Delphi
  FrHTMLViewer,
  // Project
  UClipFmt, UViewers;


{ THTMLDocViewer }

function THTMLDocViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True. This is always a primary viewer.
  }
begin
  Result := True;
end;

function THTMLDocViewer.MenuText(const FmtID: Word): string;
  {Gets text to display in viewer menu.
    @param FmtID [in] ID of required clipboard format.
    @return Required menu text.
  }
resourcestring
  sMenuText = 'View HTML';    // we display this menu for both formats
begin
  Result := sMenuText;
end;

procedure THTMLDocViewer.ReleaseClipData;
  {Frees the data rendered when RenderClipData was last called.
  }
begin
  // we simply delete the source code text
  fHTML := '';
end;

procedure THTMLDocViewer.RenderClipData(const FmtID: Word);
  {Reads data for a specified format from the clipboard and renders it into
  a format suitable for display.
    @param FmtID [in] ID of clipboard format to be rendered.
  }
begin
  // HTML source is stored as simple text on clipboard (may be unicode)
  fHTML := CopyClipboardText(FmtID);
end;

procedure THTMLDocViewer.RenderView(const Frame: TFrame);
  {Displays the rendered clipboard data in viewer frame.
    @param Frame [in] Frame in which to display the data.
  }
begin
  // we simply pass the HTML source to the frame
  (Frame as THTMLViewerFrame).Display(fHTML);
end;

function THTMLDocViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  // these formats either provide complete or partial HTML documents
  Result := (FmtID = CF_HYPERTEXT) or (FmtID = CF_MIME_HTML);
end;

function THTMLDocViewer.UIFrameClass: TFrameClass;
  {Gets the class type of the viewer frame.
    @return Required frame class.
  }
begin
  Result := THTMLViewerFrame;
end;


initialization

// Register viewer
ViewerRegistrar.RegisterViewer(THTMLDocViewer.Create);

end.

