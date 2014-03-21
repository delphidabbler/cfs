{
 * UMetafileViewer.pas
 *
 * Provides a viewer for metafile handles stored on clipboard.
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
 * The Original Code is UMetafileViewer.pas.
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


unit UMetafileViewer;


interface


uses
  // Delphi
  Graphics,
  // Project
  IntfViewers, UGraphicViewer;


type

  {
  TMetafileViewer:
    Provides a viewer for metafile handles stored on clipboard.
  }
  TMetafileViewer = class(TGraphicViewer,
    IViewer
  )
  protected
    function GetGraphicClass: TGraphicClass; override;
      {Provides class to enable base class to create graphic object.
        @return TMetafile class.
      }
    { IViewer }
    function SupportsFormat(const FmtID: Word): Boolean;
      {Checks whether viewer supports a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if format is supported, False if not.
      }
    function IsPrimaryViewer(const FmtID: Word): Boolean;
      {Checks if the viewer is the "primary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True. This viewer is always a primary viewer.
      }
    function MenuText(const FmtID: Word): string;
      {Gets text to display in viewer menu.
        @param FmtID [in] ID of required clipboard format.
        @return Required menu text.
      }
  end;


implementation


uses
  // Project
  UClipFmt, UViewers;


{ TMetafileViewer }

function TMetafileViewer.GetGraphicClass: TGraphicClass;
  {Provides class to enable base class to create graphic object.
    @return TMetafile class.
  }
begin
  Result := TMetafile;
end;

function TMetafileViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True. This viewer is always a primary viewer.
  }
begin
  Result := True;
end;

function TMetafileViewer.MenuText(const FmtID: Word): string;
  {Gets text to display in viewer menu.
    @param FmtID [in] ID of required clipboard format.
    @return Required menu text.
  }
resourcestring
  sMenuText = 'View metafile'; // same menu text always used
begin
  Result := sMenuText;
end;

function TMetafileViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  Result := (FmtID = CF_ENHMETAFILE) or (FmtID = CF_METAFILEPICT);
end;

initialization

// Register viewer
ViewerRegistrar.RegisterViewer(TMetafileViewer.Create);

end.

