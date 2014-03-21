{
 * FmViewer.pas
 *
 * Non-modal dialog box that hosts various clipboard viewers. Clipboard viewers
 * must be TFrame descendants. This dialog box interogates a viewer object to
 * discover what frame to display. It also manages viewer help by searching for
 * an ALink keyword that is the same as the name of the frame.
 *
 * This unit requires the DelphiDabbler TPJUserWdwState component Release 5.3 or
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
 * The Original Code is FmViewer.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2008-2014 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): None.
 *
 * ***** END LICENSE BLOCK *****
}


unit FmViewer;


interface


uses
  // Delphi
  Forms, StdCtrls, Classes, Controls, ExtCtrls, Windows, ActnList,
  // DelphiDabbler library
  PJWdwState,
  // Project
  FmBaseDlg, IntfViewers, FmBase;


type
  {
  TViewerDlg:
    A non-modal dialog box class that hosts various clipboard viewer frames.
  }
  TViewerDlg = class(TBaseDlgForm)
    actClose: TAction;
    actHelp: TAction;
    alMain: TActionList;
    btnClose: TButton;
    btnHelp: TButton;
    pnlBottom: TPanel;
    pnlView: TPanel;
    wsViewer: TPJUserWdwState;
    procedure actHelpExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure wsViewerReadData(Sender: TObject; var Data: TPJWdwStateData);
    procedure wsViewerSaveData(Sender: TObject;
      const Data: TPJWdwStateData);
    procedure actCloseExecute(Sender: TObject);
  private
    fViewer: IViewer;
      {Object that creates viewer frame and displays clipboard data in it}
    fViewFrame: TFrame;
      {Frame used to display current clipboard view}
    procedure TidyUp;
      {Clears up and frees and current viewer frame.
      }
    procedure CreateFrame;
      {Creates and hosts the viewer frame determined by the current viewer object.
      }
    procedure RenderView(const Title: string);
      {Displays current data.
        @param Title [in] Title to be displayed in dialog caption.
      }
  public
    class procedure Display(const AOwner: TComponent; const Viewer: IViewer;
      const Title: string);
      {Displays a viewer frame in the dialog box. If the dialog box is closed
      (not instantiated), it is created and shown.
        @param AOwner [in] Component that owns this dialog.
        @param Viewer [in] Viewer object that determines frame to be displayed
          and renders the view it displays.
        @param Title [in] Text to be displayed in dialog's caption.
      }
    destructor Destroy; override;
      {Class destructor. Nils the private instance variable.
      }
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  UHelpManager, UWindowSettings;


var
  // Reference to current instance of this dialog. Nil when dialog not
  // displayed.
  pvtInstance: TViewerDlg = nil;


{$R *.dfm}

resourcestring
  // Caption text
  sCaption = 'Viewing "%s"';


{ TViewerDlg }

procedure TViewerDlg.actCloseExecute(Sender: TObject);
  {Closes the dialog box.
    @param Sender [in] Not used.
  }
begin
  Close;
end;

procedure TViewerDlg.actHelpExecute(Sender: TObject);
  {Displays a help topic related to the displayed viewer frame. If the viewer
  has no associated help then a default "error" help topic is displayed.
    @param Sender [in] Not used.
  }
begin
  // Note: If a viewer frame has an associated help topic, that topic must have
  // an ALink keyword that is the same as the name of the viewer frame.
  THelpManager.ShowALink(fViewFrame.Name, cViewerErrTopic);
end;

procedure TViewerDlg.CreateFrame;
  {Creates and hosts the viewer frame determined by the current viewer object.
  }
begin
  fViewFrame := fViewer.UIFrameClass.Create(pvtInstance);
  fViewFrame.Parent := pnlView;
  fViewFrame.Align := alClient;
end;

destructor TViewerDlg.Destroy;
  {Class destructor. Nils the private instance variable.
  }
begin
  pvtInstance := nil;
  inherited;
end;

class procedure TViewerDlg.Display(const AOwner: TComponent;
  const Viewer: IViewer; const Title: string);
  {Displays a viewer frame in the dialog box. If the dialog box is closed (not
  instantiated), it is created and shown.
    @param AOwner [in] Component that owns this dialog.
    @param Viewer [in] Viewer object that determines frame to be displayed and
      renders the view it displays.
    @param Title [in] Text to be displayed in dialog's caption.
  }
begin
  if Assigned(pvtInstance) then
    // dialog box already exists - clear up previous view and frame
    pvtInstance.TidyUp
  else
    // dialog box doesn't exist (it was closed) - create it
    pvtInstance := TViewerDlg.Create(AOwner);
  with pvtInstance do
  begin
    // record viewer object then use it to create frame
    fViewer := Viewer;
    CreateFrame;
    // ensure dialog box is displayed and at front
    if not Visible then
      Show;
    SetFocus;
    // ensure dialog box is not minimised
    if WindowState = wsMinimized then
      WindowState := wsNormal;
    // display data in frame
    // (Note: this *must* be done after dialog is shown because viewer frames
    // that use the browser control fail to display otherwise)
    RenderView(Title);
  end;
end;

procedure TViewerDlg.FormClose(Sender: TObject; var Action: TCloseAction);
  {Triggered when form is closing. Ensures that current frame is removed and
  that dialog object will be freed.
    @param Sender [in] Not used.
    @param Action [in/out] Updated to ensure the dialog box instance is
      destroyed once form has closed.
  }
begin
  TidyUp;
  Action := caFree;
end;

procedure TViewerDlg.RenderView(const Title: string);
  {Displays current data.
    @param Title [in] Title to be displayed in dialog caption.
  }
begin
  Caption := Format(sCaption, [Title]);
  fViewer.RenderView(fViewFrame);   // viewer renders view in frame
end;

procedure TViewerDlg.TidyUp;
  {Clears up and frees and current viewer frame.
  }
begin
  if Assigned(fViewFrame) then
    fViewFrame.Parent := nil; // needed to avoid access violation in some frames
  FreeAndNil(fViewFrame);
end;

procedure TViewerDlg.wsViewerReadData(Sender: TObject;
  var Data: TPJWdwStateData);
  {Reads window state data that is used to restore the previous window size and
  position.
    @param Sender [in] Not used.
    @param Data [in/out] Set to window state data read from settings.
  }
begin
  TWindowSettings.Read(Name, Data);
end;

procedure TViewerDlg.wsViewerSaveData(Sender: TObject;
  const Data: TPJWdwStateData);
  {Writes current window state data to settings.
    @param Sender [in] Not used.
    @param Data [in] Window state information to be saved.
  }
begin
  TWindowSettings.Write(Name, Data);
end;

end.

