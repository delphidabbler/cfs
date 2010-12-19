{
 * UAltBugFix.pas
 *
 * Implements a fix for Delphi's Alt key bug (reported on CodeGear Quality
 * Central as bug report #37403):
 *
 *   "There seems to be a problem with THEMES support in Delphi, in which
 *   TButton, TCheckBox, TRadioButton and TStaticText standard controls vanish
 *   in VISTA when the ALT key is pressed. (only TStaticText vanishes in XP). If
 *   the OS is set to default, pressing the ALT key in XP and Vista has the
 *   behavior of displaying the underline under the accelerator keys.
 *
 *   "The mentioned controls vanish the first time ALT is pressed. They can be
 *   restored by repainting the control in code. Once restored, they are not
 *   affected by subsequent ALT key presses - unless a pagecontrol on the form
 *   changes to a new tabsheet, then all affected controls, both on the tabsheet
 *   and on the form, will vanish on next ALT press. Due to the pagecontrol
 *   issue there is no way to set a flag to do the repaint op only once. In MDI
 *   applications, an ALT key press has the same affect on all child forms at
 *   the same time.
 *
 * Portions of this code are based on a component created by Per-Erik Andersson,
 * inspired by J Hamblin of Qtools Software. The code was extensively modified
 * and extended to work with customised standard windows dialog boxes as well as
 * forms.
 *
 * v1.0 of 18 Jun 2008  - Original version.
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
 * The Original Code is UAltBugFix.pas
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


unit UAltBugFix;


interface


uses
  // Delphi
  Controls;


type
  {
  IAltBugFix:
    Interface to object used to fix Delphi's Alt Key bug.
  }
  IAltBugFix = interface(IInterface)
    ['{469A8DBC-CD1F-4C63-B850-1F70E5E2D958}']
    procedure RegisterCtrl(const Ctrl: TWinControl);
      {Registers a control to have Alt bug fixed.
        @param Ctrl [in] Control to be registered.
      }
    procedure UnRegisterCtrl(const Ctrl: TWinControl);
      {Unregisters a control and prevents Alt bug being fixed in control.
        @param Ctrl [in] Control to be unregistered.
      }
  end;


function AltBugFix: IAltBugFix;
  {Gets reference to relevant singleton implementation of IAltBugFix.
    @return Required implementation depending on OS.
  }


implementation


{
  Implementation notes
  --------------------

  When each form in the application is displayed it registers itself by calling
  IAltBugFix.RegisterCtrl and unregisters itself by calling
  IAltBugFix.UnRegisterCtrl when it is hidden. When customised common Windows
  dialogs are displayed the panel holding the custom Delphi controls is
  registered when the dialog is shown and unregistered when the dialog closes.

  Each registered form or control is subclassed by replacing its window
  procedure with a hook that listens for the WM_UPDATEUISTATE messages, which is
  the message triggering the error. When a control gets a WM_UPDATEUISTATE it
  sets a flag saying the control needs to be redrawn.

  The control is periodically checked to see if it needs a repaint, and if so
  this is done once. Any controls that are containers for other controls are
  recursively processed so that any affected child controls are also repainted.

  Registered controls are updated when the application enters the idle state.

  The code adjusts to underlying operating systems and to whether themes are
  enabled. The following table shows the different possibilities.

  +-----------------------+------------------------------+-------------------+
  | OS                    | Themes enabled               | Themes disabled   |
  +-----------------------+------------------------------+-------------------+
  | Windows Vista &       | Repaints button controls     | No updating (bug  |
  | Windows Server 2008 & | (TButton, TCheckBox,         | only occurs when  |
  | later                 | TRadioButton) and            | themes enabled)   |
  |                       | TStaticText controls when    |                   |
  |                       | WM_UPDATEUISTATE is detected |                   |
  +-----------------------+------------------------------+-------------------+
  | Windows XP &          | Repaints only TStaticText    | No updating       |
  | Windows Server 2003   | controls.                    |                   |
  +-----------------------+------------------------------+-------------------+
  | Any other OS          | No updating: themes not supported on these OSs   |
  |                       | therefore bug does not occur                     |
  +-----------------------+--------------------------------------------------+
}


uses
  // Delphi
  SysUtils, Contnrs, Messages, StdCtrls, ComCtrls, AppEvnts, SyncObjs,
  Forms, Themes, Windows,
  // Project
  UPlatform;


type

  {
  TCtrlWrapperClass:
    Class reference for control wrapper classes.
  }
  TCtrlWrapperClass = class of TCtrlWrapper;

  {
  TAltBugFix:
    Abstract base class for classes that implement IAltBugFix and provide a fix
    for Delphi's Alt key bug for all registered controls.
  }
  TAltBugFix = class(TInterfacedObject,
    IAltBugFix
  )
  private
    fUpdateList: TObjectList;
      {List of controls that will be monitored when application is idle}
    fAppEvents: TApplicationEvents;
      {Application events object used to trigger bug fix for controls in
      fIdleUpdateList when app is idle}
    fLock: TSimpleEvent;
      {Simple singalling event object used to prevent controls being registered
      and unregistered when bug fix code is running}
    fThemesEnabled: Boolean;
      {Flag indicating if themes are enabled (bug fixing required) or disabled
      (no bug fixes required)}
    function FindCtrl(const Ctrl: TWinControl;
      const List: TObjectList): Integer;
      {Finds location of wrapper class containing a control in a list.
        @param Ctrl [in] Control to be found.
        @param List [in] List containing wrapped control.
        @return Index of control wrapper in list or -1 if there is no such
          object.
      }
    procedure Idler(Sender: TObject; var Done: Boolean);
      {Handler for application's OnIdle event. Updates controls in idle list.
        @param Sender [in] Not used.
        @param Done [in/out] Not used.
      }
    procedure UpdateControls;
      {Updates (repaints) controls in update list as necessary.
      }
    procedure DisableIdler;
      {Disables handling of application's OnIdle event.
      }
    procedure UpdateIdler;
      {Updates application's OnIdle event depending on registered controls and
      whether themes enabled.
      }
    procedure ThemeChangeListener(Sender: TObject);
      {Handles theme services change event. Updates internal flag recording
      whether themes are available or not and determines whether idle processing
      is switched on or off.
        @param Sender [in] Not used.
      }
  protected
    function CtrlWrapperClass: TCtrlWrapperClass; virtual; abstract;
      {Gets class type of wrapper class used by object.
        @return Required class type.
      }
    { IAltBugFix methods }
    procedure RegisterCtrl(const Ctrl: TWinControl);
      {Registers a control to have Alt bug fixed.
        @param Ctrl [in] Control to be registered.
      }
    procedure UnRegisterCtrl(const Ctrl: TWinControl);
      {Unregisters a control and prevents Alt bug being fixed in control.
        @param Ctrl [in] Control to be unregistered.
      }
  public
    constructor Create;
      {Class constructor. Sets up object.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object.
      }
  end;

  {
  TAltBugFixXP:
    Class that implements IAltBugFix and provides a fix for Delphi's Alt key bug
    for all registered controls. Fix is appropriate for the bug's manifestation
    on Windows XP.
  }
  TAltBugFixXP = class(TAltBugFix)
  protected
    function CtrlWrapperClass: TCtrlWrapperClass; override;
      {Gets class type of wrapper class used by object.
        @return Required class type.
      }
  end;

  {
  TAltBugFixVista:
    Class that implements IAltBugFix and provides a fix for Delphi's Alt key bug
    for all registered controls. Fix is appropriate for the bug's manifestation
    on Windows Vista.
  }
  TAltBugFixVista = class(TAltBugFix)
  protected
    function CtrlWrapperClass: TCtrlWrapperClass; override;
      {Gets class type of wrapper class used by object.
        @return Required class type.
      }
  end;

  {
  TNulAltBugFix
    Nul implementation of IAltBugFix that does nothing. Used on OSs earlier than
    Windows XP where bug fix is not required.
  }
  TNulAltBugFix = class(TInterfacedObject,
    IAltBugFix
  )
  protected
    { IAltBugFix methods }
    procedure RegisterCtrl(const Ctrl: TWinControl);
      {Register a control to have Alt bug fixed. Does nothing in this
      implementation.
        @param Ctrl [in] Control to be registered. Ignored.
      }
    procedure UnRegisterCtrl(const Ctrl: TWinControl);
      {Unregister a control and prevents Alt bug being fixed in control. Does
      nothing in this implementation.
        @param Ctrl [in] Control to be unregistered. Ignored.
      }
  end;

  {
  TCtrlWrapper:
    Abstract base class for classes that wrap a TWinControl object and force it
    to repaint if Alt key is pressed, if necessary. Subclasses the wrapped
    control's window procedure to detect Alt key presses.
  }
  TCtrlWrapper = class(TObject)
  private
    fCtrl: TWinControl;
      {Reference to wrapped control}
    fOldWndProc: TWndMethod;
      {Reference to wrapped control's original window procedure}
    fRepaintNeeded: Boolean;
      {Flag indicating if wrapped control needs to be repainted}
    procedure WndProc(var Msg: TMessage);
      {Subclasses window procedure for wrapped control.
        @param Msg [in/out] Message to be handled. Msg.Result may be modified by
          old window procedure.
      }
  protected
    function RepaintRequired(const Ctrl: TWinControl): Boolean;
      virtual; abstract;
      {Checks whether a control needs to be repainted.
        @param Ctrl [in] Control to be checked.
        @return True if control needs to be repainted, False if not.
      }
  public
    constructor Create(const Ctrl: TWinControl);
      {Class constructor. Sets up object that wraps a control and sub-classes
      control's window procedure.
        @param Ctrl [in] Control to be wrapped and sub-classed.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object and restores control's old window
      procedure.
      }
    procedure Repaint;
      {Repaints the control and all its contained controls if required.
      }
    property Ctrl: TWinControl read fCtrl;
      {Reference to wrapped control}
  end;

  {
  TXPCtrlWrapper:
    Classes that wraps a TWinControl object and forces it to repaint if Alt key
    is pressed if necessary. Uses characterisation of Delphi's Alt key bug on
    Windows XP when determining which controls to repaint.
  }
  TXPCtrlWrapper = class(TCtrlWrapper)
  protected
    function RepaintRequired(const Ctrl: TWinControl): Boolean; override;
      {Checks whether a control needs to be repainted.
        @param Ctrl [in] Control to be checked.
        @return True if control needs to be repainted, False if not.
      }
  end;

  {
  TVistaCtrlWrapper:
    Classes that wraps a TWinControl object and forces it to repaint if Alt key
    is pressed if necessary. Uses characterisation of Delphi's Alt key bug on
    Windows Vista when determining which controls to repaint.
  }
  TVistaCtrlWrapper = class(TCtrlWrapper)
  protected
    function RepaintRequired(const Ctrl: TWinControl): Boolean; override;
      {Checks whether a control needs to be repainted.
        @param Ctrl [in] Control to be checked.
        @return True if control needs to be repainted, False if not.
      }
  end;

var
  // Private variable that stores reference to requied bug fix object instance
  pvtAltBugFix: IAltBugFix = nil;

function AltBugFix: IAltBugFix;
  {Gets reference to relevant singleton implementation of IAltBugFix.
    @return Required implementation depending on OS.
  }
begin
  if not Assigned(pvtAltBugFix) then
  begin
    // This is first call to this function and singleton object not yet created.
    // Implementation depends on underlying OS: there are implementations that
    // handle different bug fix requirements on XP and Vista and a nul
    // implementation for earlier OSs for which no bug fix is required.
    if IsVistaOrLater then
      pvtAltBugFix := TAltBugFixVista.Create
    else if IsXPOrLater then
      pvtAltBugFix := TAltBugFixXP.Create
    else
      pvtAltBugFix := TNulAltBugFix.Create;
  end;
  Result := pvtAltBugFix;
end;

const
  // Timeout used when waiting for an event to signal
  cLockTimeout = 10000; // 10 secs

{ TAltBugFix }

constructor TAltBugFix.Create;
  {Class constructor. Sets up object.
  }
begin
  inherited Create;

  // Record if themes enabled and provide listener for if themes change
  fThemesEnabled := ThemeServices.ThemesEnabled;
  ThemeServices.OnThemeChange := ThemeChangeListener;

  // Create objects used to maintain and refresh list of forms that are
  // processed during application's idle processing.
  fUpdateList := TObjectList.Create(True);
  fAppEvents := TApplicationEvents.Create(nil);

  // Create lock for protected sections
  fLock := TSimpleEvent.Create;
  fLock.SetEvent;
end;

destructor TAltBugFix.Destroy;
  {Class destructor. Tears down object.
  }
begin
  // Remove theme change handler
  ThemeServices.OnThemeChange := nil;

  // Disable application OnHint handler to prevent further updates
  DisableIdler;

  // Wait for any asynchronously running update code to complete
  fLock.WaitFor(cLockTimeout);

  // Free all owned objects
  FreeAndNil(fUpdateList);
  FreeAndNil(fAppEvents);
  FreeAndNil(fLock);

  inherited;
end;

procedure TAltBugFix.DisableIdler;
  {Disables handling of application's OnIdle event.
  }
begin
  fAppEvents.OnIdle := nil;
end;

function TAltBugFix.FindCtrl(const Ctrl: TWinControl;
  const List: TObjectList): Integer;
  {Finds location of wrapper class containing a control in a list.
    @param Ctrl [in] Control to be found.
    @param List [in] List containing wrapped control.
    @return Index of control wrapper in list or -1 if there is no such object.
  }
var
  Idx: Integer; // loops through all items in list
begin
  Result := -1;
  for Idx := 0 to Pred(List.Count) do
  begin
    if (List[Idx] as TCtrlWrapper).Ctrl = Ctrl then
    begin
      Result := Idx;
      Break;
    end;
  end;
end;

procedure TAltBugFix.Idler(Sender: TObject; var Done: Boolean);
  {Handler for application's OnIdle event. Updates controls in idle list.
    @param Sender [in] Not used.
    @param Done [in/out] Not used.
  }
begin
  UpdateControls;
end;

procedure TAltBugFix.RegisterCtrl(const Ctrl: TWinControl);
  {Registers a control to have Alt bug fixed.
    @param Ctrl [in] Control to be registered.
  }
begin
  // We unhook OnIdle event to prevent controls being updated while list is
  // being modified
  DisableIdler;
  try
    // Wait for any current control update to complete
    fLock.WaitFor(cLockTimeout);
    // Control to be updated when application enters idle state
    if FindCtrl(Ctrl, fUpdateList) = -1 then
      fUpdateList.Add(CtrlWrapperClass.Create(Ctrl));
  finally
    // Update application's OnIdle event
    UpdateIdler
  end;
end;

procedure TAltBugFix.ThemeChangeListener(Sender: TObject);
  {Handles theme services change event. Updates internal flag recording whether
  themes are available or not and determines whether idle processing is switched
  on or off.
    @param Sender [in] Not used.
  }
begin
  fThemesEnabled := ThemeServices.ThemesEnabled;
  UpdateIdler;
end;

procedure TAltBugFix.UnRegisterCtrl(const Ctrl: TWinControl);
  {Unregisters a control and prevents Alt bug being fixed in control.
    @param Ctrl [in] Control to be unregistered.
  }
var
  Idx: Integer; // index of Ctrl in appropriate list (-1 if not found)
begin
  // We unhook OnIdle event to prevent controls being updated while list is
  // being modified
  DisableIdler;
  try
    // Wait for any current control update to complete
    fLock.WaitFor(cLockTimeout);
    // Delete control from appropriate list
    // first look in idle list
    Idx := FindCtrl(Ctrl, fUpdateList);
    if Idx >= 0 then
      fUpdateList.Delete(Idx);
  finally
    // Update application's OnIdle event
    UpdateIdler;
  end;
end;

procedure TAltBugFix.UpdateControls;
  {Updates (repaints) controls in update list as necessary.
  }
var
  Idx: Integer; // loops through all control wrappers in list
begin
  if not fThemesEnabled then
    Exit;
  // Close lock: this is used to prevent List from being modified asynchronously
  // while items in List are being processed.
  fLock.ResetEvent;
  try
    // Get each control wrapper to repaint its control (and contained controls)
    // if necessary
    for Idx := 0 to Pred(fUpdateList.Count) do
      (fUpdateList[Idx] as TCtrlWrapper).Repaint;
  finally
    // Open lock: this permits modification of List
    fLock.SetEvent;
  end;
end;

procedure TAltBugFix.UpdateIdler;
  {Updates application's OnIdle event depending on registered controls and
  whether themes enabled.
  }
begin
  // We only handle application's OnIdle event there are controls registered in
  // idle update list and themes are enabled
  if fThemesEnabled and (fUpdateList.Count > 0) then
    fAppEvents.OnIdle := Idler
  else
    fAppEvents.OnIdle := nil;
end;

{ TAltBugFixXP }

function TAltBugFixXP.CtrlWrapperClass: TCtrlWrapperClass;
  {Gets class type of wrapper class used by object.
    @return Required class type.
  }
begin
  Result := TXPCtrlWrapper;
end;

{ TAltBugFixVista }

function TAltBugFixVista.CtrlWrapperClass: TCtrlWrapperClass;
  {Gets class type of wrapper class used by object.
    @return Required class type.
  }
begin
  Result := TVistaCtrlWrapper;
end;

{ TNulAltBugFix }

procedure TNulAltBugFix.RegisterCtrl(const Ctrl: TWinControl);
  {Register a control to have Alt bug fixed. Does nothing in this
  implementation.
    @param Ctrl [in] Control to be registered. Ignored.
  }
begin
  // Do nothing
end;

procedure TNulAltBugFix.UnRegisterCtrl(const Ctrl: TWinControl);
  {Unregister a control and prevents Alt bug being fixed in control. Does
  nothing in this implementation.
    @param Ctrl [in] Control to be unregistered. Ignored.
  }
begin
  // Do nothing
end;

{ TCtrlWrapper }

constructor TCtrlWrapper.Create(const Ctrl: TWinControl);
  {Class constructor. Sets up object that wraps a control and sub-classes
  control's window procedure.
    @param Ctrl [in] Control to be wrapped and sub-classed.
  }
begin
  Assert(Assigned(Ctrl),                                   // ** do not localise
    'TCtrlWrapper.Create: Ctrl is nil');
  inherited Create;
  fCtrl := Ctrl;
  // Subclass Ctrl by providing new window procedure
  fOldWndProc := Ctrl.WindowProc;
  Ctrl.WindowProc := WndProc;
end;

destructor TCtrlWrapper.Destroy;
  {Class destructor. Tears down object and restores control's old window
  procedure.
  }
begin
  fCtrl.WindowProc := fOldWndProc;
  inherited;
end;

procedure TCtrlWrapper.Repaint;
  {Repaints the control and all its contained controls if required.
  }

  procedure RepaintCtrl(const Ctrl: TControl);
    {Repaints a control if necessary. Called recursively if control has
    contained controls.
      @param Ctrl [in] Control to be assessed for repainting.
    }
  var
    WinCtrl: TWinControl; // reference to Ctrl as a TWinControl
    TabSheet: TTabSheet;  // reference to Ctrl as a TTabSheet
    CtrlIdx: Integer;     // loops through all Ctrl's contained controls
  begin
    // Ctrl must be a TWinControl
    if not (Ctrl is TWinControl) then
      Exit;
    WinCtrl := Ctrl as TWinControl;

    // Repaint control if required
    if RepaintRequired(WinCtrl) then
      WinCtrl.Repaint;

    // Recurse through controls if this is a container control
    for CtrlIdx := 0 to Pred(WinCtrl.ControlCount) do
    begin
      // skip repainting of controls on inactive pages in page control
      if (WinCtrl is TTabSheet) then
      begin
        TabSheet := WinCtrl as TTabSheet;
        if TabSheet.PageIndex <> TabSheet.PageControl.ActivePageIndex then
          Continue;
      end;
      // recurse to paint a contained control
      RepaintCtrl(WinCtrl.Controls[CtrlIdx]);
    end;
  end;

begin
  // We only repaint control if repaint is flagged as required. Repainting is
  // flagged when window procedure detects WM_UPDATEUISTATE message.
  if fRepaintNeeded then
  begin
    fRepaintNeeded := False;
    RepaintCtrl(fCtrl);
  end;
end;

procedure TCtrlWrapper.WndProc(var Msg: TMessage);
  {Subclasses window procedure for wrapped control.
    @param Msg [in/out] Message to be handled. Msg.Result may be modified by
      old window procedure.
  }
begin
  // Pass message to original window procedure for default handling
  fOldWndProc(Msg);
  if (Msg.Msg = WM_UPDATEUISTATE) then
    // We need to repaint control when WM_UPDATEUISTATE is received - this
    // message received when app needs to change state of accelerator characters
    // and this change of state is what causes this Delphi repainting bug
    fRepaintNeeded := True;
end;

{ TXPCtrlWrapper }

function TXPCtrlWrapper.RepaintRequired(const Ctrl: TWinControl): Boolean;
  {Checks whether a control needs to be repainted.
    @param Ctrl [in] Control to be checked.
    @return True if control needs to be repainted, False if not.
  }
begin
  // XP has problems only with static text controls
  Result := Ctrl is TStaticText;
end;

{ TVistaCtrlWrapper }

function TVistaCtrlWrapper.RepaintRequired(
  const Ctrl: TWinControl): Boolean;
  {Checks whether a control needs to be repainted.
    @param Ctrl [in] Control to be checked.
    @return True if control needs to be repainted, False if not.
  }
begin
  // Vista has problems with button and static text controls
  // Strictly speaking we should exclude TBitBtn here, but CodeSnip doesn't use
  // TBitBtns, so we haven't mentioned the class
  Result := (Ctrl is TButtonControl) or (Ctrl is TStaticText);
end;

initialization

finalization

pvtAltBugFix := nil;

end.

