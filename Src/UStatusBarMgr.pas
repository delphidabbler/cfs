{
 * UStatusBarMgr.pas
 *
 * Creates and manages a status bar that can display messages on the left and
 * a link to the DelphiDabbler website on the right.
 *
 * This unit requires the DelphiDabbler TPJHotLabel component Release 2.1 or
 * later.
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
 * The Original Code is UStatusBarMgr.pas
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


unit UStatusBarMgr;


interface


uses
  // Delphi
  ComCtrls, Controls, Windows,
  // DelphiDabbler library
  PJHotLabel;


type

  {
  TStatusBarMgr:
    Class that creates and manages a status bar that can display messages on the
    left and a link to the DelphiDabbler website on the right.
  }
  TStatusBarMgr = class(TObject)
  private
    fStatusBar: TStatusBar;
      {Status bar}
    fHotLabel: TPJHotLabel;
      {Hot label used for web link}
    procedure DrawPanelHandler(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
      {Called when status bar panels are redrawn. Positions hot label component
      to right of status bar.
        @param StatusBar [in] Reference to status bar triggering event.
        @param Panel [in] Reference to panel being redrawn.
        @param Rect [in] Bounding rectangle of drawing area of panel being
          drawn.
      }
    procedure ResizeHandler(Sender: TObject);
      {Called when status bar is resized. Adjusts width of left hand panel when
      status bar is resized.
        @param Sender [in] Not used.
      }
  public
    constructor Create(const SBOwner: TWinControl);
      {Class constructor. Creates status bar including parented hot label.
        @param SBOwner [in] Windowed control that hosts (and owns) status bar.
      }
    procedure DisplayText(const Text: string);
      {Displays text in left hand panel of status bar.
        @param Text [in] Text to be displayed.
      }
  end;


implementation


uses
  // Project
  UGlobals;


resourcestring
  // Text displayed in web link
  sURLDesc = 'www.delphidabbler.com';


{ TStatusBarMgr }

constructor TStatusBarMgr.Create(const SBOwner: TWinControl);
  {Class constructor. Creates status bar including parented hot label.
    @param SBOwner [in] Windowed control that hosts (and owns) status bar.
  }
begin
  inherited Create;
  // Create status bar with two panels (it will be freed when SBOwner is freed)
  fStatusBar := TStatusBar.Create(SBOwner);
  fStatusBar.Parent := SBOwner;
  fStatusBar.SimplePanel := False;
  fStatusBar.Panels.Add;
  fStatusBar.Panels.Add;
  fStatusBar.Panels[1].Style := psOwnerDraw;
  fStatusBar.OnDrawPanel := DrawPanelHandler;
  fStatusBar.OnResize := ResizeHandler;
  // Create hot label component parented by status bar (freed when status bar is
  // freed)
  fHotLabel := TPJHotLabel.Create(SBOwner);
  fHotLabel.Parent := fStatusBar;
  fHotLabel.CaptionIsURL := False;
  fHotLabel.Caption := sURLDesc;
  fHotLabel.URL := cWebAddress;
end;

procedure TStatusBarMgr.DisplayText(const Text: string);
  {Displays text in left hand panel of status bar.
    @param Text [in] Text to be displayed.
  }
begin
  fStatusBar.Panels[0].Text := Text;
end;

procedure TStatusBarMgr.DrawPanelHandler(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
  {Called when status bar panels are redrawn. Positions hot label component to
  right of status bar.
    @param StatusBar [in] Reference to status bar triggering event.
    @param Panel [in] Reference to panel being redrawn.
    @param Rect [in] Bounding rectangle of drawing area of panel being drawn.
  }
begin
  if Panel = fStatusBar.Panels[1] then
  begin
    fHotLabel.Left := Rect.Right - fHotLabel.Width - 16;
    fHotLabel.Top := Rect.Top
      + (Rect.Bottom - Rect.Top - fHotLabel.Height) div 2;
  end;
end;

procedure TStatusBarMgr.ResizeHandler(Sender: TObject);
  {Called when status bar is resized. Adjusts width of left hand panel when
  status bar is resized.
    @param Sender [in] Not used.
  }
begin
  fStatusBar.Panels[0].Width := fStatusBar.Width
    - (fHotLabel.Width + 12 + 12);
end;

end.

