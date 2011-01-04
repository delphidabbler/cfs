{
 * FmMain.pas
 *
 * Main Clipboard Format Spy window handling and program logic.
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
 * The Original Code is FmMain.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 1997-2011 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): None.
 *
 * ***** END LICENSE BLOCK *****
}


unit FmMain;


interface


uses
  // Delphi
  Menus, Classes, ActnList, ImgList, Controls, ComCtrls, ToolWin, ExtCtrls,
  Forms, Messages,
  // DelphiDabbler library
  PJCBView, PJWdwState,
  // Project
  FmBase, IntfViewers, UClipboardLVMgr, UStatusBarMgr, UViewerMenuMgr;


type
  {
  TMainForm:
    Implements main program window.
  }
  TMainForm = class(TBaseForm)
    actAbout: TAction;
    actClearClipboard: TAction;
    actExit: TAction;
    actHelp: TAction;
    alMain: TActionList;
    bvlEmpty: TBevel;
    cbvClipView: TPJCBViewer;
    ilGrey: TImageList;
    ilMain: TImageList;
    lvDetails: TListView;
    mnuViewers: TPopupMenu;
    pnlEmpty: TPanel;
    tbAbout: TToolButton;
    tbClearClipboard: TToolButton;
    tbExit: TToolButton;
    tbHelp: TToolButton;
    tbMain: TToolBar;
    tbSpacer1: TToolButton;
    tbSpacer2: TToolButton;
    wsMain: TPJUserWdwState;
    procedure actAboutExecute(Sender: TObject);
    procedure actClearClipboardExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure cbvClipViewClipboardChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mnuViewersPopup(Sender: TObject);
    procedure wsMainReadData(Sender: TObject; var Data: TPJWdwStateData);
    procedure wsMainSaveData(Sender: TObject; const Data: TPJWdwStateData);
  private
    fStatusBarMgr: TStatusBarMgr;
      {Object that creates and manages display of status bar}
    fViewerMenuMgr: TViewerMenuMgr;
      {Object that manages the pop-up menu that displays available clipboard
      viewers for a selected clipboard format}
    fClipboardLVMgr: TClipboardLVMgr;
      {Object that manages display of clipboard formats in list view}
    procedure DisplayOwnerExe;
      {Display name of exe file of process that owns the clipboard in status
      bar.
      }
    procedure UpdateDisplay;
      {Updates display according to current state of clipboard.
      }
    procedure ViewerMenuClickHandler(const Viewer: IViewer; const FmtID: Word);
      {Event handler for viewer menu items.
        @param Viewer [in] Viewer object that can display view.
        @param FmtID [in] Format for which viewer object is needed.
      }
    procedure LVDblClickHander(Sender: TObject);
      {Handles clipboard list view double click events. Performs any default
      menu action on list view's associated pop-up menu.
        @param Sender [in] Not used.
      }
  end;


var
  MainForm: TMainForm;


implementation

uses
  // Delphi
  SysUtils, Windows,
  // Project
  FmAbout, FmViewer, UCBUtils, UHelpManager, UMessageBox, UWindowSettings;

{$R *.DFM}


const
  // Constants describing minimum window / pane size
  cMinWdwWidth = 362;
  cMinWdwHeight = 200;


{ TMainForm }

procedure TMainForm.actAboutExecute(Sender: TObject);
  {Displays the About Box.
    @param Sender [in] Not used.
  }
begin
  TAboutBox.Execute(Self);
end;

procedure TMainForm.actClearClipboardExecute(Sender: TObject);
  {Clears the clipboard.
    @param Sender [in] Not used.
  }
begin
  // This action causes CBViewer component to trigger OnClipboardChanged event
  // which then causes the display to be updated.
  UCBUtils.ClearClipboard;
end;

procedure TMainForm.actExitExecute(Sender: TObject);
  {Exits the program.
    @param Sender [in] Not used.
  }
begin
  Close;
end;

procedure TMainForm.actHelpExecute(Sender: TObject);
  {Displays help file at contents page.
    @param Sender [in] Not used.
  }
begin
  THelpManager.Contents;
end;

procedure TMainForm.cbvClipViewClipboardChanged(Sender: TObject);
  {Clipboard change event handler. Refreshes display to show information about
  formats on clipboard.
    @param Sender [in] Not used.
  }
begin
  UpdateDisplay;
end;

procedure TMainForm.DisplayOwnerExe;
  {Display name of exe file of process that owns the clipboard in status bar.
  }
resourcestring
  // Status bar text
  sOwnerProcess = 'Owner: %s';
  sNoOwnerProcess = 'Owner: <none>';
var
  CBOwner: string;  // name of process that owns clipboard
begin
  CBOwner := UCBUtils.ClipboardOwnerExe;
  if CBOwner <> '' then
    fStatusBarMgr.DisplayText(Format(sOwnerProcess, [CBOwner]))
  else
    fStatusBarMgr.DisplayText(sNoOwnerProcess);
end;

procedure TMainForm.FormCreate(Sender: TObject);
  {Form creation event handler. Intialises the application.
    @param Sender [in] Not used.
  }
begin
  inherited;

  // Set form caption to be same as title of application
  Caption := Application.Title;

  // Set final event handler
  Application.OnException := TMessageBox.ExceptionHandler;

  // Set minimum window size
  Constraints.MinWidth := cMinWdwWidth;
  Constraints.MinHeight := cMinWdwHeight;

  // Create object that provides and manages status bar
  fStatusBarMgr := TStatusBarMgr.Create(Self);

  // Create object that manages viewer popup menu
  fViewerMenuMgr := TViewerMenuMgr.Create(
    mnuViewers, ViewerMenuClickHandler
  );

  // Create and configure object used to display clipboard in list view control
  fClipboardLVMgr := TClipboardLVMgr.Create(
    lvDetails, pnlEmpty
  );
  fClipboardLVMgr.OnDblClick := LVDblClickHander;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
  {Form destruction event handler. Tidies up.
    @param Sender [in] Not used.
  }
begin
  THelpManager.Quit;
  fClipboardLVMgr.Free;
  fViewerMenuMgr.Free;
  fStatusBarMgr.Free;
  inherited;
end;

procedure TMainForm.FormShow(Sender: TObject);
  {Form show event handler. Updates display with current state of clipboard.
    @param Sender [in] Not used.
  }
begin
  UpdateDisplay;
end;

procedure TMainForm.LVDblClickHander(Sender: TObject);
  {Handles clipboard list view double click events. Performs any default menu
  action on list view's associated pop-up menu.
    @param Sender [in] Not used.
  }
begin
  fViewerMenuMgr.DoDefaultAction(fClipboardLVMgr.SelectedFormat);
end;

procedure TMainForm.mnuViewersPopup(Sender: TObject);
  {Handles list view's menu OnPopup event. Prepares menu for currently selected
  clipboard format in list view.
    @param Sender [in] Not used.
  }
begin
  fViewerMenuMgr.UpdateMenu(fClipboardLVMgr.SelectedFormat);
end;

procedure TMainForm.UpdateDisplay;
  {Updates display according to current state of clipboard.
  }
begin
  fClipboardLVMgr.Update;   // update display in list view
  DisplayOwnerExe;          // show clipboard owner's exe name in status bar
end;

procedure TMainForm.ViewerMenuClickHandler(const Viewer: IViewer;
  const FmtID: Word);
  {Event handler for viewer menu items.
    @param Viewer [in] Viewer object that can display view.
    @param FmtID [in] Format for which viewer object is needed.
  }
begin
  // get viewer to prepare data for display
  Viewer.RenderClipData(FmtID);
  try
    // display view
    TViewerDlg.Display(Self, Viewer, UCBUtils.CBCodeToString(FmtID));
  finally
    // permit Viewer to release (free) clipboard data
    Viewer.ReleaseClipData;
  end;
end;

procedure TMainForm.wsMainReadData(Sender: TObject;
  var Data: TPJWdwStateData);
  {Reads window state data that is used to restore the previous window size and
  position.
    @param Sender [in] Not used.
    @param Data [in/out] Set to window state data read from settings.
  }
begin
  TWindowSettings.Read(Name, Data);
end;

procedure TMainForm.wsMainSaveData(Sender: TObject;
  const Data: TPJWdwStateData);
  {Writes current window state data to settings.
    @param Sender [in] Not used.
    @param Data [in] Window state information to be saved.
  }
begin
  TWindowSettings.Write(Name, Data);
end;

end.

