{
 * UHTMLClipViewer.pas
 *
 * Implements a viewer object for HTML clips.
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
 * The Original Code is UHTMLClipViewer.pas.
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


unit UHTMLClipViewer;


interface


uses
  // Delphi
  Forms,
  // Project
  IntfViewers, UHTMLClip, UBaseTextViewer;


type

  {
  THTMLClipViewer:
     Viewer object for HTML clips.
  }
  THTMLClipViewer = class(TBaseTextViewer,
    IViewer
  )
  private
    fClip: THTMLClip;
      {Stores parsed HTML clip}
  protected
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
      {Class destructor. Enures that any remaining rendered data is released.
      }
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  FrHTMLClipViewer, UClipFmt, UViewers;


{ THTMLClipViewer }

destructor THTMLClipViewer.Destroy;
  {Class destructor. Enures that any remaining rendered data is released.
  }
begin
  ReleaseClipData;
  inherited;
end;

function THTMLClipViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True. This is always a primary viewer.
  }
begin
  Result := True;
end;

function THTMLClipViewer.MenuText(const FmtID: Word): string;
  {Gets text to display in viewer menu.
    @param FmtID [in] ID of required clipboard format.
    @return Required menu text.
  }
resourcestring
  sMenuText = 'View HTML Clip'; // the only menu text
begin
  Result := sMenuText;
end;

procedure THTMLClipViewer.ReleaseClipData;
  {Frees the data rendered when RenderClipData was last called.
  }
begin
  FreeAndNil(fClip);
end;

procedure THTMLClipViewer.RenderClipData(const FmtID: Word);
  {Reads data for a specified format from the clipboard and renders it into
  a format suitable for display.
    @param FmtID [in] ID of clipboard format to be rendered.
  }
var
  UTF8Bytes: TBytes;
  UTF8Str: UTF8String;
begin
  ReleaseClipData;        // ensure any previously rendered data is released
  // we pass copy of clipboard data to THTMLClip object for parsing
  // TODO: Move this code down into base class and generalise
  UTF8Bytes := GetAsAnsiBytes(FmtID);
  SetLength(UTF8Str, Length(UTF8Bytes));
  if Length(UTF8Str) > 0 then
    Move(Pointer(UTF8Bytes)^, Pointer(UTF8Str)^, Length(UTF8Bytes));
  fClip := THTMLClip.Create(UTF8Str);
end;

procedure THTMLClipViewer.RenderView(const Frame: TFrame);
  {Displays the rendered clipboard data in viewer frame.
    @param Frame [in] Frame in which to display the data.
  }
begin
  // frame gets information about clip and contained HTML from THTMLClip object
  (Frame as THTMLClipViewerFrame).Display(fClip);
end;

function THTMLClipViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  Result := FmtId = CF_HTML;
end;

function THTMLClipViewer.UIFrameClass: TFrameClass;
  {Gets the class type of the viewer frame.
    @return Required frame class.
  }
begin
  Result := THTMLClipViewerFrame;
end;


initialization

// Register viewer
ViewerRegistrar.RegisterViewer(THTMLClipViewer.Create);

end.

