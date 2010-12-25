{
 * FrTextViewer.pas
 *
 * Implements a viewer frame that displays plain text documents.
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
 * The Original Code is FrTextViewer.pas.
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


unit FrTextViewer;


interface


uses
  // Delphi
  StdCtrls, Controls, ExtCtrls, StdActns, Classes, ActnList, Menus, Forms;


type
  {
  TTextViewerFrame:
    Viewer frame that displays plain text documents. Can display either Ansi or
    OEM text. Can also display Unicode text that has been converted Ansi.
    Supports selecting and copying of text to clipboard. Displayed text can
    optionally be word wrapped.
  }
  TTextViewerFrame = class(TFrame)
    edView: TMemo;
    mnuView: TPopupMenu;
    alView: TActionList;
    actCopy: TEditCopy;
    actSelectAll: TEditSelectAll;
    miCopy: TMenuItem;
    miSelectAll: TMenuItem;
    pnlControl: TPanel;
    chkWordWrap: TCheckBox;
    procedure chkWordWrapClick(Sender: TObject);
  private
    procedure SetMargins;
     {Sets left and right margins in edit control.
    }
    procedure SetWordWrap(const Flag: Boolean);
      {Switches word wrapping on and off.
        @param Flag [in] Indicates whether word wrapping is required.
      }
  public
    constructor Create(AOwner: TComponent); override;
      {Class constructor. Sets up frame and reads display preferences from
      settings.
        @param AOwner [in] Component that owns the frame.
      }
    destructor Destroy; override;
      {Class destructor. Tears down frame and stores current preferences.
      }
    procedure Display(const Text: UnicodeString);
      {Displays required text.
        @param Text [in] Text to be displayed.
      }
  end;


implementation


uses
  // Delphi
  Messages, Windows,
  // Project
  USettings;


{$R *.dfm}

{ TTextViewerFrame }

procedure TTextViewerFrame.chkWordWrapClick(Sender: TObject);
  {Handles click on "word wrap" check box. Toggles whether text is displayed
  word wrapped.
    @param Sender [in] Not used.
  }
begin
  SetWordWrap(chkWordWrap.Checked);
end;

constructor TTextViewerFrame.Create(AOwner: TComponent);
  {Class constructor. Sets up frame and reads display preferences from settings.
    @param AOwner [in] Component that owns the frame.
  }
var
  SettingSection: ISettingsSection; // provides access to settings
begin
  inherited Create(AOwner);
  SettingSection := Settings.OpenSection(Name);
  SetWordWrap(SettingSection.ReadBool('WordWrap', True));
end;

destructor TTextViewerFrame.Destroy;
  {Class destructor. Tears down frame and stores current preferences.
  }
var
  SettingSection: ISettingsSection; // provides access to settings
begin
  SettingSection := Settings.OpenSection(Name);
  SettingSection.WriteBool('WordWrap', edView.WordWrap);
  inherited;
end;

procedure TTextViewerFrame.Display(const Text: UnicodeString);
  {Displays required text.
    @param Text [in] Text to be displayed.
  }
begin
  edView.Lines.BeginUpdate;
  try
    edView.Text := Text;
    SetMargins;
  finally
    edView.Lines.EndUpdate
  end;
end;

procedure TTextViewerFrame.SetMargins;
  {Sets left and right margins in edit control.
  }
begin
  edView.Perform(EM_SETMARGINS, EC_LEFTMARGIN or EC_RIGHTMARGIN, 4);
end;

procedure TTextViewerFrame.SetWordWrap(const Flag: Boolean);
  {Switches word wrapping on and off.
    @param Flag [in] Indicates whether word wrapping is required.
  }
begin
  chkWordWrap.Checked := Flag;
  edView.WordWrap := Flag;
  if Flag then
    edView.ScrollBars := ssVertical
  else
    edView.ScrollBars := ssBoth;
  SetMargins; // need to reset margins when word wrapping changes
end;

end.

