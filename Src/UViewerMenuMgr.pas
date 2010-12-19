{
 * UViewerMenuMgr.pas
 *
 * Implements a class that manages a popup menu that displays items used to
 * select a viewer in which to display a clipboard format.
 *
 * v1.0 of 14 Mar 2008  - Original version.
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
 * The Original Code is UViewerMenuMgr.pas.
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


unit UViewerMenuMgr;


interface


uses
  // Delphi
  Menus,
  // Project
  IntfViewers;


type

  {
  TViewerMenuItemEvent:
    Type of method passed to menu manager that is called when menu items are
    clicked.
      @param Viewer [in] Viewer object associated with clicked menu item.
      @param FmtID [in] Clipboard format that viewer displays.
  }
  TViewerMenuItemEvent = procedure(const Viewer: IViewer; const FmtID: Word)
    of object;

  {
  TViewerMenuMgr:
    Class that manages a popup menu that displays items used to select a viewer
    in which to display a clipboard format. Menu displays an item for each
    registered viewer, split into primary and secondary viewer sections.
  }
  TViewerMenuMgr = class(TObject)
  private
    fMenu: TPopupMenu;
      {Managed popup menu}
    fClickHandler: TViewerMenuItemEvent;
      {Event handler called when menu items clicked}
  public
    constructor Create(const Menu: TPopupMenu;
      const ClickHandler: TViewerMenuItemEvent);
      {Class constructor. Sets up manager for a specified menu and event
      handler.
        @param Menu [in] Popup menu to be managed.
        @param ClickHandler [in] Method called when managed menu items are
          clicked.
      }
    procedure UpdateMenu(const Fmt: Word);
      {Updates menu to menu items for viewer objects that support a clipboard
      format.
        @param Fmt [in] Clipboard format for which viewer menu needed.
      }
    procedure DoDefaultAction(const Fmt: Word);
      {Performs default menu action, if any.
        @param Fmt [in] Clipboard format for which default action required.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, Contnrs,
  // Project
  UViewers;


type

  {
  TViewerMenuItem:
    Custom menu item that has associated viewer object and clipboard format
    along with reference to a method to be called when menu is clicked. When
    menu is clicked the click handler method is passed the viewer and clipboard
    format.
  }
  TViewerMenuItem = class(TMenuItem)
  private
    fViewer: IViewer;
      {Viewer associated with menu item}
    fClickHandler: TViewerMenuItemEvent;
      {Method called when menu item clicked}
    fFormat: Word;
      {Clipboard format displayed by viewer}
  public
    constructor Create(const AOwner: TPopupMenu; const Viewer: IViewer;
      const Format: Word; const ClickHandler: TViewerMenuItemEvent);
      reintroduce;
      {Class constructor. Create menu item with reference to viewer, clipboard
      format and click event handler.
        @param AOwner [in] Menu that owns the menu item.
        @param Viewer [in] Viewer associated with menu item.
        @param Format [in] Clipboard format which viewer displays.
        @param ClickHandler [in] Method called when menu item clicked.
      }
    procedure Click; override;
      {Called when menu item is clicked. Call click handler method, passing
      viewer and clipboard format.
      }
  end;


{ TViewerMenuMgr }

constructor TViewerMenuMgr.Create(const Menu: TPopupMenu;
  const ClickHandler: TViewerMenuItemEvent);
  {Class constructor. Sets up manager for a specified menu and event handler.
    @param Menu [in] Popup menu to be managed.
    @param ClickHandler [in] Method called when managed menu items are clicked.
  }
begin
  Assert(Assigned(Menu));
  Assert(Assigned(ClickHandler));
  inherited Create;
  fMenu := Menu;
  fClickHandler := ClickHandler;
end;

procedure TViewerMenuMgr.DoDefaultAction(const Fmt: Word);
  {Performs default menu action, if any.
    @param Fmt [in] Clipboard format for which default action required.
  }
var
  Idx: Integer;   // loops through format's menu
  MI: TMenuItem;  // references a menu item in menu
begin
  // Update the menu for the format
  UpdateMenu(Fmt);
  // Find any default action and trigger it
  for Idx := 0 to Pred(fMenu.Items.Count) do
  begin
    MI := fMenu.Items[Idx];
    if MI.Default then
    begin
      MI.Click;
      Exit;
    end;
  end;
end;

procedure TViewerMenuMgr.UpdateMenu(const Fmt: Word);
  {Updates menu to menu items for viewer objects that support a clipboard
  format.
    @param Fmt [in] Clipboard format for which viewer menu needed.
  }
resourcestring
  // Menu item used (disabled) when there are no viewers
  sNoViewer = 'No viewers';
var
  VList: IViewerList;           // gets list of viewers that support clip format
  Idx: Integer;                 // loops through all viewers
  MI: TMenuItem;                // reference to a menu item
  PrimaryItems: TObjectList;    // menu items for primary viewers
  SecondaryItems: TObjectList;  // menu items for secondary viewers
begin
  // Clear the menu
  fMenu.Items.Clear;
  // Get list of matching viewers
  VList := Viewers.GetViewerList(Fmt);
  if VList.Count > 0 then
  begin
    // We have viewers: build menus
    // create lists of primary and secondary view menu items
    SecondaryItems := nil;
    PrimaryItems := TObjectList.Create(False);
    try
      SecondaryItems := TObjectList.Create(False);
      // loop through each viewer, adding a menu item to appropriate primary or
      // secondary list
      for Idx := 0 to Pred(VList.Count) do
      begin
        // we use special menu item clss that can reference viewer, clip format
        // and click handler
        MI := TViewerMenuItem.Create(fMenu, VList[Idx], Fmt, fClickHandler);
        if VList[Idx].IsPrimaryViewer(Fmt) then
          PrimaryItems.Add(MI)
        else
          SecondaryItems.Add(MI);
      end;
      // add primary menu items to menu
      for Idx := 0 to Pred(PrimaryItems.Count) do
        fMenu.Items.Add(PrimaryItems[Idx] as TViewerMenuItem);
      // add spacer if required
      if (PrimaryItems.Count > 0) and (SecondaryItems.Count > 0) then
        fMenu.Items.Add(Menus.NewLine);
      // add secondary menu items to menu
      for Idx := 0 to Pred(SecondaryItems.Count) do
        fMenu.Items.Add(SecondaryItems[Idx] as TViewerMenuItem);
      // set default viewer to fist viewer on menu, if any
      if fMenu.Items.Count > 0 then
        fMenu.Items[0].Default := True;
    finally
      FreeAndNil(SecondaryItems);
      FreeAndNil(PrimaryItems);
    end;
  end
  else
  begin
    // No viewers: put single explanatory disabled menu item in menu
    MI := Menus.NewItem(sNoViewer, 0, False, False, nil, 0, '');
    fMenu.Items.Add(MI);
  end;
end;

{ TViewerMenuItem }

procedure TViewerMenuItem.Click;
  {Called when menu item is clicked. Call click handler method, passing viewer
  and clipboard format.
  }
begin
  fClickHandler(fViewer, fFormat);
end;

constructor TViewerMenuItem.Create(const AOwner: TPopupMenu;
  const Viewer: IViewer; const Format: Word;
  const ClickHandler: TViewerMenuItemEvent);
  {Class constructor. Create menu item with reference to viewer, clipboard
  format and click event handler.
    @param AOwner [in] Menu that owns the menu item.
    @param Viewer [in] Viewer associated with menu item.
    @param Format [in] Clipboard format which viewer displays.
    @param ClickHandler [in] Method called when menu item clicked.
  }
begin
  Assert(Assigned(Viewer));
  Assert(Assigned(Clickhandler));
  inherited Create(AOwner);
  // record parameters
  fViewer := Viewer;
  fFormat := Format;
  fClickHandler := ClickHandler;
  // set caption to menu text provided by viewer
  Caption := fViewer.MenuText(fFormat);
end;

end.

