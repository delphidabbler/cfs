{
 * FrHTMLViewer.pas
 *
 * Implements a viewer frame that displays complete and partial HTML documents.
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
 * The Original Code is FrHTMLViewer.pas.
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


unit FrHTMLViewer;


interface


uses
  // Delphi
  Classes, ActnList, Menus, OleCtrls, SHDocVw, Controls, ExtCtrls, Forms,
  Windows,
  // Project
  UWBController;


type

  {
  THTMLViewerFrame:
    Viewer frame that displays complete and partial HTML documents using
    provided HTML source. Uses a default style sheet loaded from resources.
    Supports selecting and copying of selections to clipboard as text, HTML and
    rich text.
  }
  THTMLViewerFrame = class(TFrame)
    pnlHost: TPanel;
    wbView: TWebBrowser;
    mnuView: TPopupMenu;
    miCopy: TMenuItem;
    miSelectAll: TMenuItem;
    alView: TActionList;
    actCopy: TAction;
    actSelectAll: TAction;
    procedure actCopyExecute(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actSelectAllUpdate(Sender: TObject);
  private
    fLoading: Boolean;
      {Flag true when document is being loaded into browser control}
    fWBController: TWBController;
      {Object used to control behaviour of browser control}
    procedure TranslateAccelHandler(Sender: TObject; const Msg: TMSG;
      const CmdID: DWORD; var Handled: Boolean);
      {Handles browser controller's OnTranslateAccel event. Prevents browser
      from responding to function keys and to Ctrl, Ctrl+Shift and
      Ctrl+Shift+Alt with alphanumeric keys. Such key presses are instead passed
      to frame window in case they need to be handled there.
        @param Sender [in] Not used.
        @param Msg [in] Identifies windows system and normal key up/down events.
        @param CmdID [in] Not used.
        @param Handled [in/out] Set to true if key is handled by event handler
          to prevent browser control from handling further.
      }
    procedure PopupMenuHandler(Sender: TObject; const PopupPos: TPoint;
      const MenuID: DWORD; const Obj: IDispatch);
      {Handles browser controller's OnMenuPopup event. Displays associated
      pop-up menu.
        @param Sender [in] Not used.
        @param PopupPos [in] Specifies location to display menu.
        @param MenuID [in] Not used.
        @param Obj [in] Not used.
      }
    procedure UpdateCSSHandler(Sender: TObject; var CSS: string);
      {Handles browser controller's OnUpdateCSS event. Causes browser to use
      default style sheet included in program's resources.
        @param Sender [in] Not used.
        @param CSS [in/out] Default CSS. Set to required code.
      }
    procedure NavigationHandler(Sender: TObject; const URL: string;
      var Cancel: Boolean);
      {Handles browser controller's OnNavigate event. Unsures any clocked links
      are displayed in external browser rather than in place.
        @param Sender [in] Not used.
        @param URL [in] URL to be navigated to.
        @param Cancel [in/out] Set to True to prevent in-place navigation and
          left as False to permit navigation.
      }
  public
    constructor Create(AOwner: TComponent); override;
      {Class constructor. Initialises controller for web browser control.
        @param AOwner [in] Control that owns frame.
      }
    destructor Destroy; override;
      {Class destructor. Finalises frame and tears down object.
      }
    procedure Display(const HTML: string);
      {Displays HTML in browser control.
        @param HTML [in] HTML source code to be displayed.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, StrUtils, Messages,
  // Project
  UMessageBox, UProcessUtils;


{$R *.dfm}


{ TBaseHTMLViewerFrame }

procedure THTMLViewerFrame.actCopyExecute(Sender: TObject);
  {Copies text selected in browser control to clipboard.
    @param Sender [in] Not used.
  }
begin
  fWBController.CopyToClipboard;
end;

procedure THTMLViewerFrame.actCopyUpdate(Sender: TObject);
  {Enables Copy action only if browser control supports the command in current
  context.
    @param Sender [in] Not used.
  }
begin
  actCopy.Enabled := fWBController.CanCopy;
end;

procedure THTMLViewerFrame.actSelectAllExecute(Sender: TObject);
  {Selects all content of browser control.
    @param Sender [in] Not used.
  }
begin
  fWBController.SelectAll;
end;

procedure THTMLViewerFrame.actSelectAllUpdate(Sender: TObject);
  {Enables Select All action only if browser supports the command in current
  context.
    @param Sender [in] Not used.
  }
begin
  actSelectAll.Enabled := fWBController.CanSelectAll;
end;

constructor THTMLViewerFrame.Create(AOwner: TComponent);
  {Class constructor. Initialises controller for web browser control.
    @param AOwner [in] Control that owns frame.
  }
begin
  inherited Create(AOwner);
  // Set up and initialise browser using controller object
  fWBController := TWBController.Create(wbView);
  fWBController.OnTranslateAccel := TranslateAccelHandler;
  fWBController.OnMenuPopup := PopupMenuHandler;
  fWBController.OnNavigate := NavigationHandler;
  fWBController.OnUpdateCSS := UpdateCSSHandler;
  fWBController.Silent := True; // inhibit JScript error dialogues
end;

destructor THTMLViewerFrame.Destroy;
  {Class destructor. Finalises frame and tears down object.
  }
begin
  Parent := nil;  // needed to fix access violation bug
  FreeAndNil(fWBController);
  inherited;
end;

procedure THTMLViewerFrame.Display(const HTML: string);
  {Displays HTML in browser control.
    @param HTML [in] HTML source code to be displayed.
  }
begin
  // Note: we don't check if HTML is a complete document. Browser control will
  // display sections of HTML code with no <html>..</html> tags, no <head>
  // section, no doc type and no <body>..</body> tags.
  fLoading := True;
  try
    fWBController.LoadFromString(HTML);
  finally
    fLoading := False;
  end;
end;

procedure THTMLViewerFrame.NavigationHandler(Sender: TObject;
  const URL: string; var Cancel: Boolean);
  {Handles browser controller's OnNavigate event. Unsures any clocked links are
  displayed in external browser rather than in place.
    @param Sender [in] Not used.
    @param URL [in] URL to be navigated to.
    @param Cancel [in/out] Set to True to prevent in-place navigation and left
      as False to permit navigation.
  }
resourcestring
  // Error message
  sCantDisplay = 'Can''t display URL:'#10#10'%s';
begin
  // Don't inhibit navigation when we're loading a document: can cause script
  // errors and then GPFs if we do!! Downside is that browser may simply display
  // navigated to URL if navigation fails
  if fLoading then
    Exit;
  // We cancel all navigations that don't navigate to 'about:blank'.
  // 'about:blank' is required to load a blank document for use to load HTML
  // from strings
  if not AnsiSameText('about:blank', URL) then
  begin
    // All other URLs except those that start with 'about:' displayed externally
    Cancel := True;
    if (AnsiStartsText('about:', URL) or not OpenFile(URL)) then
      TMessageBox.Error(Self, Format(sCantDisplay, [URL]));
  end;
end;

procedure THTMLViewerFrame.PopupMenuHandler(Sender: TObject;
  const PopupPos: TPoint; const MenuID: DWORD; const Obj: IDispatch);
  {Handles browser controller's OnMenuPopup event. Displays associated pop-up
  menu.
    @param Sender [in] Not used.
    @param PopupPos [in] Specifies location to display menu.
    @param MenuID [in] Not used.
    @param Obj [in] Not used.
  }
begin
  mnuView.Popup(PopupPos.X, PopupPos.Y);
end;

procedure THTMLViewerFrame.TranslateAccelHandler(Sender: TObject;
  const Msg: TMSG; const CmdID: DWORD; var Handled: Boolean);
  {Handles browser controller's OnTranslateAccel event. Prevents browser from
  responding to function keys and to Ctrl, Ctrl+Shift and Ctrl+Shift+Alt
  with alphanumeric keys. Such key presses are instead passed to frame window in
  case they need to be handled there.
    @param Sender [in] Not used.
    @param Msg [in] Identifies windows system and normal key up/down events.
    @param CmdID [in] Not used.
    @param Handled [in/out] Set to true if key is handled by event handler to
      prevent browser control from handling further.
  }

  // ---------------------------------------------------------------------------
  procedure PostKeyPress(const DownMsg, UpMsg: UINT);
    {Posts a key down and key up message to frame's window using wParam and
    lParam values of message passed to outer method.
      @param DownMsg [in] Key down message (WM_KEYDOWN or WM_SYSKEYDOWN).
      @param UpMsg [in] Key up message (WM_KEYUP or WM_SYSKEYUP).
    }
  begin
    PostMessage(Handle, DownMsg, Msg.wParam, Msg.lParam);
    PostMessage(Handle, UpMsg, Msg.wParam, Msg.lParam);
  end;
  // ---------------------------------------------------------------------------

var
  ShiftState: TShiftState;  // state of key modifiers
  PostMsg: Boolean;         // whether to post message to parent
begin
  PostMsg := False;
  // We only handle key down messages
  if ((Msg.message = WM_KEYDOWN) or (Msg.message = WM_SYSKEYDOWN)) then
  begin
    // Record state of modifier keys
    ShiftState := Forms.KeyDataToShiftState(Msg.lParam);

    // Process key pressed (wParam field of Msg)
    case Msg.wParam of
      Ord('A')..Ord('Z'), Ord('0')..Ord('9'):
        // We pass Ctrl key with any alphanumeric keys to self. This enables
        // any shortcut keys to be handled by associated action in frame.
        if (ShiftState = [ssCtrl])
          or (ShiftState = [ssCtrl, ssShift])
          or (ShiftState = [ssCtrl, ssShift, ssAlt]) then
          PostMsg := True;
      VK_F1..VK_F24:
        // We post all function keys with any modifier to self to allow here.
        // It is particularly important to pass on F5 to prevent browser from
        // refreshing and F1 to enable help.
        // NOTE: we assume all function keys have contiguous codes
        PostMsg := True;
    end;
    if PostMsg then
    begin
      // Any message for which posting is required is posted to window that owns
      // frame, and is therefore passed to main application.
      case Msg.message of
        WM_KEYDOWN:     PostKeyPress(WM_KEYDOWN, WM_KEYUP);
        WM_SYSKEYDOWN:  PostKeyPress(WM_SYSKEYDOWN, WM_SYSKEYUP);
      end;
      // We consider all posted messages as handled to prevent browser
      // processing them further
      Handled := True;
    end;
  end;
end;

procedure THTMLViewerFrame.UpdateCSSHandler(Sender: TObject;
  var CSS: string);
  {Handles browser controller's OnUpdateCSS event. Causes browser to use default
  style sheet included in program's resources.
    @param Sender [in] Not used.
    @param CSS [in/out] Default CSS. Set to required code.
  }
var
  Stm: TResourceStream; // stream onto CSS code in resources
begin
  Stm := TResourceStream.Create(HInstance, 'CSS', RT_RCDATA);
  try
    SetLength(CSS, Stm.Size);
    Stm.ReadBuffer(PChar(CSS)^, Length(CSS));
  finally
    FreeAndNil(Stm);
  end;
end;

end.

