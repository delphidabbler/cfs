{
 * FrLocaleViewer.pas
 *
 * Implements a viewer frame that displays selected information about a locale.
 *
 * v1.0 of 10 Mar 2008  - Original version.
 * v1.1 of 04 May 2008  - Added code to refresh scroll box to ensure contained
 *                        labels display correctly.
 *                      - Changed to get locale information from ULocale unit.
 *                        This code handles different OSs correctly.
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
    actCopy: TEditCopy;
    actSelectAll: TEditSelectAll;
    alView: TActionList;
    edAbbrevCountryName: TEdit;
    edAbbrevLangName: TEdit;
    edCountryCode: TEdit;
    edCountryName: TEdit;
    edDefCodePage: TEdit;
    edEngCountryName: TEdit;
    edISOLangName: TEdit;
    edLangID: TEdit;
    edLangName: TEdit;
    lblAbbrevCountryName: TLabel;
    lblAbbrevLangName: TLabel;
    lblCountry: TLabel;
    lblCountryCode: TLabel;
    lblCountryName: TLabel;
    lblDefCodePage: TLabel;
    lblEngCountryName: TLabel;
    lblEngLangName: TLabel;
    lblLangID: TLabel;
    lblLangName: TLabel;
    lblLanguage: TLabel;
    miCopy: TMenuItem;
    miSelectAll: TMenuItem;
    mnuView: TPopupMenu;
    pnlView: TPanel;
    sbView: TScrollBox;
  public
    procedure Display(const Locale: LCID);
      {Displays information about a specified locale.
        @param Locale [in] Locale identifier for which info is to be displayed.
      }
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  ULocale;


{$R *.dfm}


{ TLocaleViewerFrame }

procedure TLocaleViewerFrame.Display(const Locale: LCID);
  {Displays information about a specified locale.
    @param Locale [in] Locale identifier for which info is to be displayed.
  }

  // ---------------------------------------------------------------------------
  function LocaleInfo(const InfoType: LCTYPE): string;
    {Gets a specified piece of information from Locale.
      @param InfoType [in] Type of information required. Must be one of LOCALE_
        LCTYPE flags.
      @return Required information as string.
      @except Exception raised if can't get locale info.
    }
  begin
    GetLocaleData(Locale, InfoType, Result);
  end;
  // ---------------------------------------------------------------------------

begin
  // We need to refresh scroll box to ensure labels display properly
  sbView.Refresh;
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

