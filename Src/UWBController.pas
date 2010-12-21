{
 * UWBController.pas
 *
 * Implements a class and supporting types  used to control performance and
 * appearance of a web browser control.
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
 * The Original Code is UWBController.pas
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


unit UWBController;


interface


uses
  // Delphi
  SysUtils, Classes, ActiveX, Windows, SHDocVw,
  // Project
  IntfUIHandlers, UNulUIHandler, UOleClientSite;


type

  {
  TWBScrollbarStyle:
    Styles for browser's scroll bars.
  }
  TWBScrollbarStyle = (
    sbsNormal,    // display scroll bars in normal (default) style
    sbsFlat,      // display flat scroll bars (in classic Windows UI)
    sbsHide       // hide the scroll bars
  );

  {
  TWBUpdateCSSEvent:
    Event called when browser control needs to get default CSS. Handler can
    modify or set default CSS.
      @param Sender [in] Reference to browser UI manager triggering event.
      @param CSS [in/out] CSS code. Current value of CSS property passed in.
        Handler can modify or replace this CSS code.
  }
  TWBUpdateCSSEvent = procedure(Sender: TObject; var CSS: string) of object;

  {
  TWBNavigateEvent:
    Type of event triggered just before browser control navigates to a new
    document. Handle this event to intervene in, cancel or get information about
    the navigation.
      @param Sender [in] Object triggering event.
      @param URL [in] URL to be navigated to.
      @param Cancel [in/out] False when called. Set true to prevent the browser
        navigating to the URL.
  }
  TWBNavigateEvent = procedure(Sender: TObject; const URL: string;
    var Cancel: Boolean) of object;

  {
  TWBTranslateEvent:
    Type of event triggered when a key is pressed in the web browser control.
    The program decides whether to handle (translate) the keypress itself or
    allow the web browser to handle it.
      @param Sender [in] Object triggering event.
      @param Msg [in[ Windows message record identifying the message that
        triggered the event. This may be zeroed if there was no such message.
      @param CmdID [in] Browser command that normally occurs in response to the
        event. This value may be zero if there is no related command.
      @param Handled [in/out] False when the event handler is called. Set to
        True if the handler program handles (translates) the keypress and leave
        False to let the web browser handle it. Keypresses can be supressed by
        setting Handled to true and doing nothing with the key press.
  }
  TWBTranslateEvent = procedure(Sender: TObject;
    const Msg: TMSG; const CmdID: DWORD; var Handled: Boolean) of object;

  {
  TWBMenuPopupEvent:
    Extended version of event called when browser wishes to display a popup
    menu. A popup menu should only be displayed in this event handler if Handled
    is true and the web browser's PopupMenu property is nil, otherwise two menus
    will be displayed.
      @param Sender [in] Object triggering event.
      @param PopupPos [in] Position to display the menu.
      @param MenuID [in] Type of menu to be displayed - this is one of the
        CONTEXT_MENU_* values.
      @param Obj [in] IDispatch interface to the selected object in the current
        document when the menu was summoned. Cast this to IHTMLElement to get
        information about the selected tag.
  }
  TWBMenuPopupEvent = procedure(Sender: TObject; const PopupPos: TPoint;
    const MenuID: DWORD; const Obj: IDispatch) of object;

  {
  TWBController:
    Class of object used to control performance and appearance of a web browser
    control.
  }
  TWBController = class(TNulUIHandler,
    IInterface,
    IOleClientSite,     // notifies web browser that we provide an OLE container
    IDocHostUIHandler   // accessed web browser to customise UI
  )
  private
    fNulDropTarget: IDropTarget;
      {Drop target handler that inhibits drag-drop}
    fWebBrowser: TWebBrowser;
      {Reference to controlled web browser control}
    fOnNavigate: TWBNavigateEvent;
      {Handler for OnNavigate event}
    fOleClientSite: TOleClientSite;
      {Object's IOleClientSite implementation}
    fOnUpdateCSS: TWBUpdateCSSEvent;
      {Handler for OnUpdateCSS event}
    fOnMenuPopup: TWBMenuPopupEvent;
      {Handler for OnMenuPopup event}
    fOnTranslateAccel: TWBTranslateEvent;
      {Handler for OnTranslateAccel event}
    procedure SetBrowserOleClientSite(const Site: IOleClientSite);
      {Registers an object as web browser's OLE container.
        @param Site [in] Reference to object providing OLE container. May be
          Self to register this object as OLE container or nil to unregister.
        @except EWBController raised if we can't find browser controls's
          IOleObject interface.
      }
    function IsValidDocument: Boolean;
      {Checks if current browser document is a valid HTML document.
        @return True if document is valid, False otherwise.
      }
    function GetSelectedText: string;
      {Gets selected text from current HTML document in browser.
        @return Selected text or '' if no text selected, or document is not
         valid.
      }
    function IsCommandEnabled(const CmdId: OLECMDID): Boolean;
      {Checks if a command is enabled on web browser control.
        @param CmdId [in] ID of command being queried.
        @return True if command enabled, False otherwise.
      }
    procedure ExecCommand(const CmdId: OLECMDID);
      {Executes a command on the web browser.
        @param CmdID [in] ID of command to the executed.
      }
  protected
    procedure WaitForDocToLoad;
      {Waits for a document to complete loading.
        @except EWBController raised if there is no document or it is not a
          valid HTML document.
      }
    procedure InternalLoadDocumentFromStream(const Stream: TStream);
      {Updates the web browser's current document from HTML read from stream.
        @param Stream [in] Stream containing valid HTML source code.
        @except EWbController raised document can't be loaded.
      }
    procedure NavigateHandler(Sender: TObject; const pDisp: IDispatch;
      var URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
      {Handles web browser navigation events by triggering own OnNavigate event.
        @param Sender [in] Not used.
        @param pDisp [in] Not used.
        @param URL [in/out] URL to access, passed to OnNavigate event handler.
          Left unchanged.
        @param Flags [in/out] Not used.
        @param TargetFrameName [in/out] Not used.
        @param PostData [in/out] Not used.
        @param Headers [in/out] Not used.
        @param Cancel [in/out] False when passed in. OnNavigate event handler
          may set to true to cancel navigation.
      }
    { IOleClientSite }
    property OleClientSite: TOleClientSite
      read fOleClientSite implements IOleClientSite;
      {References aggregated object implementing IOleClientSite interface}
    { IDocHostUIHandler }
    function GetDropTarget(const pDropTarget: IDropTarget;
      out ppDropTarget: IDropTarget): HResult; stdcall;
      {Notifies browser control of our nul drop target object that inhibits drag
      drop operations.
        @param pDropTarget [in] Not used.
        @param ppDropTarget [out] Set to nul drag drop handler object.
        @return S_OK to indicate DropTarget is assigned.
      }
    function GetHostInfo(var pInfo: TDocHostUIInfo): HResult; stdcall;
      {Called by browser to get UI capabilities. We configure the required UI
      appearance per relevant property values and defaults.
        @param pInfo [in/out] Reference to structure that we fill in to
          configure appearance of browser.
        @return S_OK to show we handled OK.
      }
    function ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown; const pdispReserved: IDispatch): HResult;
      stdcall;
      {Called by browser when about to display a context menu. We inhibit
      browser's default menu and trigger event to enable use to display a
      suitable context menu instead.
        @param dwID [in] Specifies identifier of the shortcut menu to be
          displayed. Passed to event handler.
        @param ppt [in] Screen coordinates where to display menu. Passed to
          event handler.
        @param pcmdtReserved [in] Not used.
        @param pdispReserved [in] IDispatch interface of HTML object under
          mouse. Passed to event handler.
        @return S_OK to prevent IE displaying its menu.
      }
    function TranslateAccelerator(const lpMsg: PMSG; const pguidCmdGroup: PGUID;
      const nCmdID: DWORD): HResult; stdcall;
      {Called by browser when a key press is received. We trigger
      OnTranslateAccel event to filter out key presses not to be handled by
      browser.
        @param lpMsg [in] Pointer to structure that specifies message to be
          translated.
        @param pguidCmdGroup [in] Not used.
        @param nCmdID [in] Command identifier.
        @return S_OK to prevent IE handling message or S_FALSE to allow it.
      }
  public
    constructor Create(const WebBrowser: TWebBrowser);
      {Class constructor. Sets up object as container for a browser control.
        @param WebBrowser [in] Contained browser control.
      }
    destructor Destroy; override;
      {Class destructor. Unregisters browser control container and tears down
      object.
      }
    procedure NavigateToURL(const URL: string);
      {Navigates to a document at a specified URL.
        @param URL [in] Full URL of the document.
        @except EWBController raised if new document is not valid.
      }
    procedure LoadFromString(const HTML: string);
      {Loads and displays valid HTML source from a string.
        @param HTML [in] String containing the HTML source.
        @except EWbController raised document can't be loaded.
      }
    procedure EmptyDocument;
      {Creates an empty document. This method guarantees that the browser
      contains a valid document object. The browser displays a blank page.
        @except EWBController raised if blank page can't be loaded.
      }
    function CanCopy: Boolean;
      {Checks if text can be copied from browser control to clipboard.
        @return True if copying permitted, False otherwise.
      }
    procedure CopyToClipboard;
      {Copies selected text from browser control to clipboard if operation
      permitted.
      }
    function CanSelectAll: Boolean;
      {Checks if all browser control's text can be selected.
        @return True if text can be selected, False otherwise.
      }
    procedure SelectAll;
      {Selects all text in browser control if operation is permitted.
      }
    procedure ClearSelection;
      {Clears any selected text in browser control.
      }
    property OnUpdateCSS: TWBUpdateCSSEvent
      read fOnUpdateCSS write fOnUpdateCSS;
      {Event triggered when browser needs default CSS. Provides opportunity to
      modify or replace code per CSS property}
    property OnNavigate: TWBNavigateEvent
      read fOnNavigate write fOnNavigate;
      {Event triggered when browser control is about to navigate to a new
      document. Handle this event to intervene in navigation process}
    property OnTranslateAccel: TWBTranslateEvent
      read fOnTranslateAccel write fOnTranslateAccel;
      {Event triggered when browser control receives a key press. This enables
      the program to determine whether the key press is handled by the browser
      or by the program. See the documentation of TWBTranslateEvent for more
      details}
    property OnMenuPopup: TWBMenuPopupEvent
      read fOnMenuPopup write fOnMenuPopup;
      {Event triggered when browser control wants to display a context menu.
      Enables the program to display a suitable popup menu}
  end;

  {
  EWBController:
    Class of exception raised by TWBController objects.
  }
  EWBController = class(Exception);


implementation


uses
  // Delphi
  StrUtils, Themes, Forms, MSHTML,
  // Project
  UNulDropTarget;


function TaskAllocWideString(const S: string): PWChar;
  {Allocates memory for a wide string using the Shell's task allocator and
  copies a given string into the memory as a wide string. Caller is responsible
  for freeing the buffer and must use the shell's allocator to do this.
    @param S [in] String to convert.
    @return Pointer to buffer containing wide string.
    @except EOutOfMemory raised in can't allocate a suitable buffer.
  }
var
  StrLen: Integer;  // length of string in bytes
begin
  // Store length of string, allowing for terminal #0
  StrLen := Length(S) + 1;
  // Allocate buffer for wide string using task allocator
  Result := CoTaskMemAlloc(StrLen * SizeOf(WideChar));
  if not Assigned(Result) then
    raise EOutOfMemory.Create('TaskAllocWideString: can''t allocate buffer.');
  // Convert string to wide string and store in buffer
  StringToWideChar(S, Result, StrLen);
end;


{ TWBController }

resourcestring
  // Error messages
  sCantLoadDoc = 'Failed to load HTML from a stream';
  sOleObjectError = 'Browser''s Default interface does not support IOleObject';
  sBadLoadError = 'Failed to load a document into browser control';
  sBadDocError = 'Document in browser control is not a valid HTML document';

function TWBController.CanCopy: Boolean;
  {Checks if text can be copied from browser control to clipboard.
    @return True if copying permitted, False otherwise.
  }
begin
  Result := IsCommandEnabled(OLECMDID_COPY) and (GetSelectedText <> '');
end;

function TWBController.CanSelectAll: Boolean;
  {Checks if all browser control's text can be selected.
    @return True if text can be selected, False otherwise.
  }
begin
  Result := IsCommandEnabled(OLECMDID_SELECTALL);
end;

procedure TWBController.ClearSelection;
  {Clears any selected text in browser control.
  }
begin
  if IsCommandEnabled(OLECMDID_CLEARSELECTION) then
    ExecCommand(OLECMDID_CLEARSELECTION);
end;

procedure TWBController.CopyToClipboard;
  {Copies selected text from browser control to clipboard if operation
  permitted.
  }
begin
  if CanCopy then
    // Get browser control to copy its content to clipboard
    ExecCommand(OLECMDID_COPY);
end;

constructor TWBController.Create(const WebBrowser: TWebBrowser);
  {Class constructor. Sets up object as container for a browser control.
    @param WebBrowser [in] Contained browser control.
  }
begin
  Assert(Assigned(WebBrowser), 'TWBController.Create: WebBrowser is nil');
  inherited Create;
  fWebBrowser := WebBrowser;
  fNulDropTarget := TNulDropTarget.Create;
  fOleClientSite := TOleClientSite.Create(Self);
  SetBrowserOleClientSite(Self);  // register as browser's OLE container
  fWebBrowser.OnBeforeNavigate2 := NavigateHandler;
end;

destructor TWBController.Destroy;
  {Class destructor. Unregisters browser control container and tears down
  object.
  }
begin
  SetBrowserOleClientSite(nil); // unregister as browser's OLE container
  FreeAndNil(fOleClientSite);
  fNulDropTarget := nil;
  inherited;
end;

procedure TWBController.EmptyDocument;
  {Creates an empty document. This method guarantees that the browser
  contains a valid document object. The browser displays a blank page.
    @except EWBController raised if blank page can't be loaded.
  }
begin
  // Load the special blank document
  NavigateToURL('about:blank');
end;

procedure TWBController.ExecCommand(const CmdId: OLECMDID);
  {Executes a command on the web browser.
    @param CmdID [in] ID of command to the executed.
  }
begin
  fWebBrowser.ExecWB(CmdId, OLECMDEXECOPT_DONTPROMPTUSER);
end;

function TWBController.GetDropTarget(const pDropTarget: IDropTarget;
  out ppDropTarget: IDropTarget): HResult;
  {Notifies browser control of our nul drop target object that inhibits drag
  drop operations.
    @param pDropTarget [in] Not used.
    @param ppDropTarget [out] Set to nul drag drop handler object.
    @return S_OK to indicate DropTarget is assigned.
  }
begin
  // We always switch off drag and drop
  ppDropTarget := fNulDropTarget;
  Result := S_OK;
end;

function TWBController.GetHostInfo(var pInfo: TDocHostUIInfo): HResult;
  {Called by browser to get UI capabilities. We configure the required UI
  appearance per relevant property values and defaults.
    @param pInfo [in/out] Reference to structure that we fill in to configure
      appearance of browser.
    @return S_OK to show we handled OK.
  }
var
  CSS: string;  // CSS to pass to browser
begin
  // Update flags depending on property values
  pInfo.dwFlags := 0;
  // Never show 3D border
  pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_NO3DBORDER;
  // Set up according to if XP themse available / in use
  if ThemeServices.ThemesEnabled then
    pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_THEME
  else if ThemeServices.ThemesAvailable then
    pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_NOTHEME;
  // Build dynamic style sheet if required
  CSS := '';
  if Assigned(fOnUpdateCSS) then
    fOnUpdateCSS(Self, CSS);
  if CSS <> '' then
    pInfo.pchHostCss := TaskAllocWideString(CSS);
  Result := S_OK;
end;

function TWBController.GetSelectedText: string;
  {Gets selected text from current HTML document in browser.
    @return Selected text or '' if no text selected, or document is not valid.
  }
var
  Doc: IDispatch;             // current document in browser control
  Sel: IHTMLSelectionObject;  // object encapsulating the current selection
  Range: IHTMLTxtRange;       // object that encapsulates a text range
begin
  Doc := fWebBrowser.Document;
  if IsValidDocument and
    // first we get selection ...
    Supports((Doc as IHTMLDocument2).selection, IHTMLSelectionObject, Sel) and
    // ... then check it contains text ...
    (Sel.type_ = 'Text') and
    // ... then create a text range on it and read the text
    Supports(Sel.createRange, IHTMLTxtRange, Range) then
    Result := Range.text
  else
    Result := '';
end;

procedure TWBController.InternalLoadDocumentFromStream(
  const Stream: TStream);
  {Updates the web browser's current document from HTML read from stream.
    @param Stream [in] Stream containing valid HTML source code.
    @except EWbController raised document can't be loaded.
  }
var
  PersistStreamInit: IPersistStreamInit;  // object used to load stream into doc
  StreamAdapter: IStream;                 // IStream interface to stream
begin
  Assert(Assigned(fWebBrowser.Document));
  // Get IPersistStreamInit interface on document object
  if fWebBrowser.Document.QueryInterface(
    IPersistStreamInit, PersistStreamInit
  ) = S_OK then
  begin
    // Clear document
    if PersistStreamInit.InitNew = S_OK then
    begin
      // Load data from Stream into WebBrowser
      StreamAdapter:= TStreamAdapter.Create(Stream);
      if Failed(PersistStreamInit.Load(StreamAdapter)) then
        raise EWBController.Create(sCantLoadDoc);
      // Wait for document to finish loading
      WaitForDocToLoad;
    end;
  end;
end;

function TWBController.IsCommandEnabled(const CmdId: OLECMDID): Boolean;
  {Checks if a command is enabled on web browser control.
    @param CmdId [in] ID of command being queried.
    @return True if command enabled, False otherwise.
  }
begin
  Result := (fWebBrowser.QueryStatusWB(CmdId) and OLECMDF_ENABLED) <> 0;
end;

function TWBController.IsValidDocument: Boolean;
  {Checks if current browser document is a valid HTML document.
    @return True if document is valid, False otherwise.
  }
begin
  // Document is considered valid if it supports IHTMLDocument2
  Result := Supports(fWebBrowser.Document, IHTMLDocument2);
end;

procedure TWBController.LoadFromString(const HTML: string);
  {Loads and displays valid HTML source from a string.
    @param HTML [in] String containing the HTML source.
    @except EWbController raised document can't be loaded.
  }
var
  StringStream: TStringStream;  // stream onto string
begin
  StringStream := TStringStream.Create(HTML);
  try
    EmptyDocument;
    InternalLoadDocumentFromStream(StringStream);
  finally
    StringStream.Free;
  end;
end;

procedure TWBController.NavigateHandler(Sender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
  {Handles web browser navigation events by triggering own OnNavigate event.
    @param Sender [in] Not used.
    @param pDisp [in] Not used.
    @param URL [in/out] URL to access, passed to OnNavigate event handler. Left
      unchanged.
    @param Flags [in/out] Not used.
    @param TargetFrameName [in/out] Not used.
    @param PostData [in/out] Not used.
    @param Headers [in/out] Not used.
    @param Cancel [in/out] False when passed in. OnNavigate event handler may
      set to true to cancel navigation.
  }
var
  DoCancel: Boolean;  // re-typing of Cancel parameter
begin
  if Assigned(fOnNavigate) then
  begin
    DoCancel := Cancel;
    fOnNavigate(Sender, URL, DoCancel);
    Cancel := DoCancel;
  end;
end;

procedure TWBController.NavigateToURL(const URL: string);
  {Navigates to a document at a specified URL.
    @param URL [in] Full URL of the document.
    @except EWBController raised if new document is not valid.
  }
var
  Flags: OleVariant;    // flags that determine action
begin
  // Don't record in history
  Flags := navNoHistory;
  if AnsiStartsText('res://', URL) or AnsiStartsText('file://', URL)
    or AnsiStartsText('about:', URL) or AnsiStartsText('javascript:', URL)
    or AnsiStartsText('mailto:', URL) then
    // don't use cache for local files
    Flags := Flags or navNoReadFromCache or navNoWriteToCache;
  // Do the navigation and wait for it to complete loading
  fWebBrowser.Navigate(WideString(URL), Flags);
  WaitForDocToLoad;
end;

procedure TWBController.SelectAll;
  {Selects all text in browser control if operation is permitted.
  }
begin
  if CanSelectAll then
    // Get web browser to select all its text
    ExecCommand(OLECMDID_SELECTALL);
end;

procedure TWBController.SetBrowserOleClientSite(
  const Site: IOleClientSite);
  {Registers an object as web browser's OLE container.
    @param Site [in] Reference to object providing OLE container. May be Self to
      register this object as OLE container or nil to unregister.
    @except EWBController raised if we can't find browser controls's IOleObject
      interface.
  }
var
  OleObj: IOleObject; // web browser's IOleObject interface
begin
  // Get web browser's IOleObject interface
  if not Supports(fWebBrowser.DefaultInterface, IOleObject, OleObj) then
    raise EWBController.Create(sOleObjectError);
  // Register's given client site as web browser's OLE container
  OleObj.SetClientSite(Site);
end;

function TWBController.ShowContextMenu(const dwID: DWORD;
  const ppt: PPOINT; const pcmdtReserved: IInterface;
  const pdispReserved: IDispatch): HResult;
  {Called by browser when about to display a context menu. We inhibit browser's
  default menu and trigger event to enable use to display a suitable context
  menu instead.
    @param dwID [in] Specifies identifier of the shortcut menu to be displayed.
      Passed to event handler.
    @param ppt [in] Screen coordinates where to display menu. Passed to event
      handler.
    @param pcmdtReserved [in] Not used.
    @param pdispReserved [in] IDispatch interface of HTML object under mouse.
      Passed to event handler.
    @return S_OK to prevent IE displaying its menu.
  }
begin
  if Assigned(fOnMenuPopup) then
    fOnMenuPopup(Self, ppt^, dwID, pDispReserved);
  // Inhibit IE's context menu
  Result := S_OK;
end;

function TWBController.TranslateAccelerator(const lpMsg: PMSG;
  const pguidCmdGroup: PGUID; const nCmdID: DWORD): HResult;
  {Called by browser when a key press is received. We trigger OnTranslateAccel
  event to filter out key presses not to be handled by browser.
    @param lpMsg [in] Pointer to structure that specifies message to be
      translated.
    @param pguidCmdGroup [in] Not used.
    @param nCmdID [in] Command identifier.
    @return S_OK to prevent IE handling message or S_FALSE to allow it.
  }
var
  Handled: Boolean; // flag set true by event handler if it handles key
  Msg: TMsg;        // Windows message record for given message
begin
  // Assume not handled by event handler
  Handled := False;
  // Call event handler if set
  if Assigned(fOnTranslateAccel) then
  begin
    // create copy of message: set all fields zero if lpMsg is nil
    if Assigned(lpMsg) then
      Msg := lpMsg^
    else
      FillChar(Msg, SizeOf(Msg), 0);
    // trigger event handler
    fOnTranslateAccel(Self, Msg, nCmdID, Handled);
  end;
  // If event handler handled accelerator then return S_OK to stop web browser
  // handling it otherwise return S_FALSE so browser will handle it
  if Handled then
    Result := S_OK
  else
    Result := S_FALSE;
end;

procedure TWBController.WaitForDocToLoad;
  {Waits for a document to complete loading.
    @except EWBController raised if there is no document or it is not a valid
      HTML document.
  }
begin
  // NOTE: do not call this method in a FormCreate event handler since the
  // browser will never reach this state - use a FormShow event handler instead
  while fWebBrowser.ReadyState <> READYSTATE_COMPLETE do
    Application.ProcessMessages;
  if not Assigned(fWebBrowser.Document) then
    raise EWBController.Create(sBadLoadError);
  if not IsValidDocument then
    raise EWBController.Create(sBadDocError);
end;


initialization

// Intiailise OLE
OleInitialize(nil);


finalization

// Unintialise OLE
OleUninitialize;

end.

