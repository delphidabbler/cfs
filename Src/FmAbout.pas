{
 * FmAbout.pas
 *
 * Main Clipboard Format Spy window handling and program logic.
 *
 * This unit requires the following DelphiDabbler components:
 *   - TPJVersionInfo Release 3.1.1 or later.
 *   - TPJHotLabel Release 2.1 or later.
 *
 * v1.0 of 08 Mar 2008  - Original version.
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
 * The Original Code is FmAboutpas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2008 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): None.
 *
 * ***** END LICENSE BLOCK *****
}


unit FmAbout;


interface


uses
  // Delphi
  StdCtrls, Graphics, Controls, ExtCtrls, Classes, Forms,
  // DelphiDabbler library
  PJHotLabel, PJVersionInfo;

type
  TAboutBox = class(TForm)
    pnlMain: TPanel;
    imgIcon: TImage;
    lblProductName: TLabel;
    lblVersion: TLabel;
    lblCopyright: TLabel;
    lblComments: TLabel;
    btnButton: TButton;
    hlblWebsite: TPJHotLabel;
    viMain: TPJVersionInfo;
    lblLicense: TLabel;
    lblCommentsEnd: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure lblLicenseClick(Sender: TObject);
  public
    class procedure Execute(const AOwner: TComponent);
      {Displays About Box.
        @param AOwner [in] Owning control.
      }
  end;


implementation


uses
  // Project
  UHelpManager;

{$R *.dfm}


{ TAboutBox }

class procedure TAboutBox.Execute(const AOwner: TComponent);
  {Displays About Box.
    @param AOwner [in] Owning control.
  }
begin
  with TAboutBox.Create(AOwner) do
    try
      ShowModal
    finally
      Free;
    end;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
  {Displays required application title and version information in dialog box.
  }
begin
  // Use application tile for form caption and product name
  Caption := Caption + ' ' + Application.Title;
  lblProductName.Caption := Application.Title;
  // Get release number and copyright from version information
  lblVersion.Caption := viMain.ProductVersion;
  lblCopyright.Caption := viMain.LegalCopyright;
end;

procedure TAboutBox.lblLicenseClick(Sender: TObject);
  {Displays license in help window when license label is clicked.
    @param Sender [in] Not used.
  }
begin
  THelpManager.ShowTopic(cLicenseTopic);
end;

end.

