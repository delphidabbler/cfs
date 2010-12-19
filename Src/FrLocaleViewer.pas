{
 * FrLocaleViewer.pas
 *
 * Implements a viewer frame that displays selected information about a locale.
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
 * The Original Code is FrLocaleViewer.pas.
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


unit FrLocaleViewer;


interface


uses
  // Delphi
  Forms, Menus, StdActns, Classes, ActnList, StdCtrls, Controls, ExtCtrls,
  Windows;


type
  {
  TLocaleViewerFrame:
    Viewer frame that displays selected information about a locale in read only
    edit controls. Supports selecting and copying text from each edit control.
  }
  TLocaleViewerFrame = class(TFrame)
    pnlView: TPanel;
    sbView: TScrollBox;
    lblLangID: TLabel;
    lblLangName: TLabel;
    lblEngLangName: TLabel;
    lblAbbrevLangName: TLabel;
    edLangID: TEdit;
    edLangName: TEdit;
    edISOLangName: TEdit;
    edAbbrevLangName: TEdit;
    edCountryCode: TEdit;
    lblCountryCode: TLabel;
    lblCountryName: TLabel;
    edCountryName: TEdit;
    edEngCountryName: TEdit;
    lblEngCountryName: TLabel;
    lblAbbrevCountryName: TLabel;
    edAbbrevCountryName: TEdit;
    edDefCodePage: TEdit;
    lblDefCodePage: TLabel;
    lblLanguage: TLabel;
    lblCountry: TLabel;
    alView: TActionList;
    actCopy: TEditCopy;
    actSelectAll: TEditSelectAll;
    mnuView: TPopupMenu;
    miCopy: TMenuItem;
    miSelectAll: TMenuItem;
  public
    procedure Display(const Locale: LCID);
      {Displays information about a specified locale.
        @param Locale [in] Locale identifier for which info is to be displayed.
      }
  end;


implementation


{$R *.dfm}


{ TLocaleViewerFrame }

procedure TLocaleViewerFrame.Display(const Locale: LCID);
  {Displays information about a specified locale.
    @param Locale [in] Locale identifier for which info is to be displayed.
  }
  // ---------------------------------------------------------------------------
  function LocaleInfo(const InfoType: LCTYPE): string;
    {Gets a specified piece of information from Locale.
      @return Required information as stirng.
    }
  var
    BufSize: Integer; // size of buffer needed for requested info
  begin
    BufSize := GetLocaleInfo(Locale, InfoType, nil, 0);       // gets buf size
    SetLength(Result, BufSize);
    GetLocaleInfo(Locale, InfoType, PChar(Result), BufSize);  // reads the info
  end;
  // ---------------------------------------------------------------------------
begin
  // Store required locale information in edit controls
  edLangID.Text             := LocaleInfo(LOCALE_ILANGUAGE);
  edLangName.Text           := LocaleInfo(LOCALE_SLANGUAGE);
  edISOLangName.Text        := LocaleInfo(LOCALE_SENGLANGUAGE);
  edAbbrevLangName.Text     := LocaleInfo(LOCALE_SABBREVLANGNAME);
  edCountryCode.Text        := LocaleInfo(LOCALE_ICOUNTRY);
  edCountryName.Text        := LocaleInfo(LOCALE_SCOUNTRY);
  edEngCountryName.Text     := LocaleInfo(LOCALE_SENGCOUNTRY);
  edAbbrevCountryName.Text  := LocaleInfo(LOCALE_SABBREVCTRYNAME);
  edDefCodePage.Text        := LocaleInfo(LOCALE_IDEFAULTCODEPAGE);
end;

end.

