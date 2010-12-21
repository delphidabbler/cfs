{
 * UURLViewer.pas
 *
 * Implements a viewer object for URLs stored as text on the clipboard.
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
 * The Original Code is UURLViewer.pas.
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


unit UURLViewer;


interface


uses
  // Project
  IntfViewers, UShellNameViewer;


type

  {
  TURLViewer:
    Viewer for URLs stored as text on the clipboard.
  }
  TURLViewer = class(TShellNameViewer,
    IViewer
  )
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
    function UIFrameClass: TFrameClass;
      {Gets the class type of the viewer frame.
        @return Required frame class.
      }
  end;


implementation


uses
  // Project
  FrURLViewer, UClipFmt, UViewers;


{ TURLViewer }

function TURLViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True. This is always a primary viewer.
  }
begin
  Result := True;
end;

function TURLViewer.MenuText(const FmtID: Word): string;
  {Gets text to display in viewer menu.
    @param FmtID [in] ID of required clipboard format.
    @return Required menu text.
  }
resourcestring
  sMenuText = 'View URL';   // always use this menu text
begin
  Result := sMenuText;
end;

function TURLViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  // we support both ansi and unicode formats
  Result := (FmtID = CF_INETURLA) or (FmtID = CF_INETURLW);
end;

function TURLViewer.UIFrameClass: TFrameClass;
  {Gets the class type of the viewer frame.
    @return Required frame class.
  }
begin
  Result := TURLViewerFrame;
end;


initialization

// Register viewer
ViewerRegistrar.RegisterViewer(TURLViewer.Create);

end.

