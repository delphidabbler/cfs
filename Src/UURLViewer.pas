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
  ///  <summary>
  ///  Abstract base class for viewers for URLs stored as text on clipboard.
  ///  </summary>
  TURLViewer = class abstract(TShellNameViewer,
    IViewer
  )
  protected
    function GetShellName(const FmtID: Word): UnicodeString; override; abstract;
      {Gets Unicode representation of shell name.
        @param FmtID [in] ID of clipboard format to be rendered.
        @return Required shell name.
      }
    { IViewer }
    function SupportsFormat(const FmtID: Word): Boolean; virtual; abstract;
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

type
  ///  <summary>
  ///  Viewer for URLs stored on clipboard as ASCII text.
  ///  </summary>
  TAnsiURLViewer = class sealed(TURLViewer,
    IViewer
  )
  protected
    function GetShellName(const FmtID: Word): UnicodeString; override;
      {Gets Unicode representation of URL name.
        @param FmtID [in] ID of clipboard format to be rendered.
        @return Required URL name.
      }
    function SupportsFormat(const FmtID: Word): Boolean; override;
      {Checks whether viewer supports a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if format is supported, False if not.
      }
  end;

type
  ///  <summary>
  ///  Viewer for URLs stored on clipboard as Unicode text.
  ///  </summary>
  TUnicodeURLViewer = class sealed(TURLViewer,
    IViewer
  )
  protected
    function GetShellName(const FmtID: Word): UnicodeString; override;
      {Gets Unicode representation of URL name.
        @param FmtID [in] ID of clipboard format to be rendered.
        @return Required URL name.
      }
    function SupportsFormat(const FmtID: Word): Boolean; override;
      {Checks whether viewer supports a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if format is supported, False if not.
      }
  end;


implementation


uses
  // Delphi
  SysUtils,
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

function TURLViewer.UIFrameClass: TFrameClass;
  {Gets the class type of the viewer frame.
    @return Required frame class.
  }
begin
  Result := TURLViewerFrame;
end;


{ TAnsiURLViewer }

function TAnsiURLViewer.GetShellName(const FmtID: Word): UnicodeString;
  {Gets Unicode representation of URL name.
    @param FmtID [in] ID of clipboard format to be rendered.
    @return Required URL name.
  }
begin
  // ANSI URLs should be in ASCII format if properly URL encoded.
  Result := TEncoding.ASCII.GetString(GetAsAnsiBytes(FmtID));
end;

function TAnsiURLViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  Result := FmtID = CF_INETURLA;
end;

{ TUnicodeURLViewer }

function TUnicodeURLViewer.GetShellName(const FmtID: Word): UnicodeString;
{Gets Unicode representation of URL name.
    @param FmtID [in] ID of clipboard format to be rendered.
    @return Required URL name.
  }
begin
  Result := TEncoding.Unicode.GetString(GetAsUnicodeBytes(FmtID));
end;

function TUnicodeURLViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  Result := FmtID = CF_INETURLW;
end;

initialization

// Register viewer
ViewerRegistrar.RegisterViewer(TAnsiURLViewer.Create);
ViewerRegistrar.RegisterViewer(TUnicodeURLViewer.Create);

end.

