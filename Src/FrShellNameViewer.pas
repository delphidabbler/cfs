{
 * FrShellNameViewer.pas
 *
 * Implements a base class for viewer frames that display shell names that are
 * provided as text.
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
 * The Original Code is FrShellNameViewer.pas.
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


unit FrShellNameViewer;


interface


uses
  // Delphi
  Forms, Menus, StdActns, Classes, ActnList, StdCtrls, Controls, ExtCtrls;


type

  {
  TShellNameViewerFrame:
    Base class for viewer frames that display shell names (files and urls) that
    are provided as text. Supports selecting of shell name and copying to
    clipboard as text.
  }
  TShellNameViewerFrame = class(TFrame)
    pnlView: TPanel;
    lblName: TLabel;
    edName: TEdit;
    btnGo: TButton;
    alView: TActionList;
    actCopy: TEditCopy;
    actSelectAll: TEditSelectAll;
    mnuView: TPopupMenu;
    miCopy: TMenuItem;
    miSelectAll: TMenuItem;
    actExec: TAction;
    procedure actExecUpdate(Sender: TObject);
  public
    procedure Display(const Name: string);
      {Displays the shell name in an edit box.
        @param Name [in] Name to display.
      }
  end;


implementation


{$R *.dfm}

{ TShellNameViewerFrame }

procedure TShellNameViewerFrame.actExecUpdate(Sender: TObject);
  {Enables execute action if and only if if a shell name is provided in edit
  control.
    @param Sender [in] Not used.
  }
begin
  actExec.Enabled := edName.Text <> '';  // enable action if have shell name
end;

procedure TShellNameViewerFrame.Display(const Name: string);
  {Displays the shell name in an edit box.
    @param Name [in] Name to display.
  }
begin
  edName.Text := Name;
end;

end.

