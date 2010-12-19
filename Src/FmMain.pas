{
 * FmMain.pas
 *
 * Main Clipboard Format Spy window handling and program logic.
 *
 * This unit requires the following DelphiDabbler components:
 *   - TPJCBViewer Release 1.2 or later
 *   - TPJUserWdwState Release 5.3 or later
 *
 * v1.0 of 09 Mar 1997  - Original version named CBInfoFm.pas.
 * v1.1 of 21 Jul 1997  - Removed caption from form and set it at run-time (in
 *                        new FormCreate event handler) to be same as
 *                        application title.
 *                      - Also removed empty clauses, re-ordered source code and
 *                        improved commenting.
 * v2.0 of 07 Jul 1998  - Revised to use new code based on a generic template
 *                        used for all spies, altered to add required
 *                        functionality and to remove unwanted features. This
 *                        unit now implements main user interface and reads
 *                        clipboard (using logic from v1.0).
 *                      - Renamed to Main_f.pas.
 * v2.0a of 27 Aug 1998 - Removed "Test" notes from first line of text in form's
 *                        tabbed list box component and replaced with spaces.
 *                        Some text is required as a kludge to allow tabs to be
 *                        set so spaces were used to avoid being visible.
 * v3.0 of 07 Dec 1999  - Total re-write of code to provide new interface. All
 *                        the program's functionality (except for a small amount
 *                        of support code that deals with clipboard format names
 *                        and code) is now in this unit. Other units have been
 *                        dropped.
 *                      - Made use of TPJRegWdwState component to remember
 *                        window's position and size between executions instead
 *                        of using custom code in a separate unit.
 *                      - Made use of TPJCBView component to allow display to be
 *                        updated automatically when clipboard changes rather
 *                        than requiring user to click button to refresh
 *                        the display.
 *                      - Replaced tabbed list box with a ListView component.
 *                      - Allowed user to sort display on either code or
 *                        description of clipboard format by clicking column
 *                        headers.
 *                      - Removed code that asked user if they wanted to save
 *                        window state. This now happens automatically.
 *                      - Removed About Box from system menu and placed on a
 *                        button bar (where help and exit buttons now appear).
 *                      - Added facility to clear clipboard by clicking button.
 * v3.1 of 31 Mar 2000  - Added pop-up menu to main body of window that can:
 *                        - toggle toolbar on and off;
 *                        - access PJSoft website;
 *                        - access all toolbar functions if toolbar is switched
 *                          off;
 *                        - determine whether program's setting are saved on
 *                          exit.
 *                      - Removed WMGetMinMaxInfo message handler - in Delphi
 *                        4 we can now use form's Constraints property to set
 *                        min size.
 * v3.2 of 27 Jul 2003  - Replaced use of CBView unit with PJCBView unit for
 *                        clipboard viewer component.
 *                      - Hard-wired website address into program rather than
 *                        accessing from registry. Now access DelphiDabbler.com.
 *                      - Replaced all string literals with resourcestrings.
 *                      - Replaced literals for registry keys with constants.
 * v3.3 of 28 Nov 2003  - Now uses actions for main user interface code.
 *                      - Uses Windows toolbar rather than panel and
 *                        speedbuttons.
 *                      - Removed exit button.
 *                      - Added button for DelphiDabbler website.
 *                      - Updated button glyphs (grey scale and colours when
 *                        moused over). Also echoed glyphs in popup menu.
 *                      - Changed to use HKCU\Software\DelphiDabbler key in
 *                        registry as parent for this program's entries rather
 *                        than HKCU\Software\PJSoft.
 *                      - Constrained window to always appear within workspace.
 * v3.4 of 31 Dec 2003  - Modified to compile with Delphi 7 and to have Windows
 *                        XP style on that OS.
 *                      - Added XPMan unit to include XP manifest in program's
 *                        resources.
 *                      - Clipboard viewer component doesn't now trigger event
 *                        on creation since doing so was displaying incorrectly
 *                        at startup when clipboard was empty under Windows XP.
 *                        We now update the display when the form is first
 *                        shown.
 *                      - No longer use mono spaced font in main display.
 * v4.0 of 24 Mar 2008  - Renamed unit from Main_f.pas to FmMain.pas.
 *                      - Removed main window's pop-up menu and hence ability to
 *                        toggle toolbar on and off and ability to prevent
 *                        settings being saved on exit.
 *                      - Removed toolbar command that accesses website.
 *                      - Added Exit button to toolbar
 *                      - Changed to automatically store window settings in
 *                        registry's HKCU\Software\DelphiDabbler\CFS\4 via new
 *                        Settings object. All other settings removed.
 *                      - Changed to use a custom dialog to display about box
 *                        rather than the DelphiDabbler About Box component.
 *                        Removed associated version information component.
 *                      - Changed to use HTML help instead of WinHelp.
 *                      - Added status bar to display name of process that owns
 *                        clipboard along with a link to website.
 *                      - Moved clipboard clearing code UCBUtils unit.
 *                      - Moved list view management code to separate manager
 *                        unit. Extra column added for size. All columns can now
 *                        be sorted. List view now hidden when clipboard empty.
 *                      - Added pop-up menu to list view, along with supporting
 *                        object that enables clipboard formats to be viewed
 *                        using registered viewers.
 *                      - Removed XPMan unit (replaced with custom manifest
 *                        resource).
 *                      - Added application exception handler to display error
 *                        message.
 * v4.1 of 04 May 2008  - Bug fix. Window wasn't saving or restoring its
 *                        settings. Added missing TPJCBViewer component.
 * v4.2 of 19 Jun 2008  - Changed to descend from TBaseForm instead of TForm.
 *                        New base class used to apply Delphi Alt key bug fix.
 *                      - Modified to change task bar handling. Main form window
 *                        is now used by task bar instead of Application
 *                        object's hidden window. This change was required for
 *                        compatibility with Vista.
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
 * The Original Code is FmMain.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 1997-2008 Peter
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
    procedure WMSyscommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
      {Handles system command messages. Overrides default processing of
      minimizing and restoration of main window. This is required now we have
      inhibited application object's default processing of these messages.
        @param Msg [in/out] Details of system command. Result field set to 0 if
          we handle message to prevent default processing.
      }
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
  protected
    procedure CreateParams(var Params: TCreateParams); override;
      {Updates style of window to ensure this main window appears on task bar.
        @params Params [in/out] In: current parameters. Out: adjusted
          parameters: we update ExStyle field with new window styles.
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

procedure TMainForm.CreateParams(var Params: TCreateParams);
  {Updates style of window to ensure this main window appears on task bar.
    @params Params [in/out] In: current parameters. Out: adjusted parameters:
      we update ExStyle field with new window styles.
  }
begin
  inherited;
  Params.ExStyle := Params.ExStyle and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
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

  // Remove hidden application window from task bar: this form is now use on
  // task bar. This required so task bar button conforms to Vista requirements.
  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(
    Application.Handle,
    GWL_EXSTYLE,
    GetWindowLong(Application.Handle, GWL_EXSTYLE)
      and not WS_EX_APPWINDOW or WS_EX_TOOLWINDOW
  );
  ShowWindow(Application.Handle, SW_SHOW);

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

procedure TMainForm.WMSyscommand(var Msg: TWMSysCommand);
  {Handles system command messages. Overrides default processing of minimizing
  and restoration of main window. This is required now we have inhibited
  application object's default processing of these messages.
    @param Msg [in/out] Details of system command. Result field set to 0 if we
      handle message to prevent default processing.
  }
begin
  // Note: according to Win API low order four bits of Msg.CmdType are reserved
  // for use by windows. We therefore mask out those bytes before processing.
  case (Msg.CmdType and $FFF0) of
    SC_MINIMIZE:
    begin
      ShowWindow(Handle, SW_MINIMIZE);
      Msg.Result := 0;
    end;
    SC_RESTORE:
    begin
      ShowWindow(Handle, SW_RESTORE);
      Msg.Result := 0;
    end;
    else
      inherited;
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

