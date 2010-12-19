{
 * ULocaleViewer.pas
 *
 * Implements a viewer object that displays locale information from the
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
 * The Original Code is ULocaleViewer.pas.
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


unit ULocaleViewer;


interface


uses
  // Delphi
  Forms, Windows,
  // Project
  IntfViewers, UGlobalMemViewer;


type
  {
  TLocaleViewer:
    Viewer object that displays locale information from the clipboard.
  }
  TLocaleViewer = class(TGlobalMemViewer,
    IViewer
  )
  private
    fLocale: LCID;
      {Locale identifier for display}
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
  // Project
  FrLocaleViewer, UDataBuffer, UViewers;


{ TLocaleViewer }

function TLocaleViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True. This is always a primary viewer.
  }
begin
  Result := True;
end;

function TLocaleViewer.MenuText(const FmtID: Word): string;
  {Gets text to display in viewer menu.
    @param FmtID [in] ID of required clipboard format.
    @return Required menu text.
  }
resourcestring
  sMenuText = 'View Locale Information';  // always display this menu text
begin
  Result := sMenuText;
end;

procedure TLocaleViewer.ReleaseClipData;
  {Frees the data rendered when RenderClipData was last called.
  }
begin
  // we simply set the locale ID to 0
  fLocale := 0;
end;

procedure TLocaleViewer.RenderClipData(const FmtID: Word);
  {Reads data for a specified format from the clipboard and renders it into a
  format suitable for display.
    @param FmtID [in] ID of clipboard format to be rendered.
  }
type
  PLCID = ^LCID;      // pointer to locale identifier
var
  Data: IDataBuffer;  // buffer containing clipboard data
begin
  fLocale := 0;
  Data := CopyClipboardMemData(FmtID);
  if Data.IsValid then
  begin
    // get locale from clipboard data copy
    fLocale := PLCID(Data.Lock)^;
    Data.Unlock;
  end;
end;

procedure TLocaleViewer.RenderView(const Frame: TFrame);
  {Displays the rendered clipboard data in viewer frame.
    @param Frame [in] Frame in which to display the data.
  }
begin
  // hand locale id to frame for interpretation
  (Frame as TLocaleViewerFrame).Display(fLocale);
end;

function TLocaleViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  Result := FmtID = CF_LOCALE;
end;

function TLocaleViewer.UIFrameClass: TFrameClass;
  {Gets the class type of the viewer frame.
    @return Required frame class.
  }
begin
  Result := TLocaleViewerFrame;
end;


initialization

// Register viewer
ViewerRegistrar.RegisterViewer(TLocaleViewer.Create);

end.

