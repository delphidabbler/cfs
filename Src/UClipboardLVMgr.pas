{
 * UClipboardLVMgr.pas
 *
 * Implements class that manages display of clipboard information in a list view
 * control.
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
 * The Original Code is UClipboardLVMgr.pas.
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


unit UClipboardLVMgr;


interface


uses
  // Delphi
  Classes, Controls, ComCtrls, Windows;


type

  {
  TLVSortDirection:
    Enumeration used to specify sort direction of a list view column.
  }
  TLVSortDirection = (
    sdUnsorted,     // column not sorted
    sdAscending,    // column sorted in ascending order
    sdDescending    // column sorted in descending order
  );

  {
  TLVSortInfo:
    Record that provides information about which is current sort column and
    last sort order of each column. The Direction array needs to be initialised
    to number of columns in list view.
  }
  TLVSortInfo = record
    SortColumn: Integer;                  // index of sort column
    Direction: array of TLVSortDirection; // sort direction of columns
  end;

  {
  TClipboardLVMgr:
    Class that manages display of clipboard information in a list view control.
  }
  TClipboardLVMgr = class(TObject)
  private
    fLV: TListView;
      {Reference to list view control being managed}
    fEmptyPane: TWinControl;
      {Reference to panel to display when clipboard is empty}
    fUpdating: Boolean;
      {Flag true while list view is being updated}
    fSortInfo: TLVSortInfo;
      {Provides information about sorting of list columns and currently sorted
      column}
    fOnDblClick: TNotifyEvent;
      {Stores any OnDblClick event handler}
    procedure DrawItem(Sender: TCustomListView; Item: TListItem; Rect: TRect;
      State: TOwnerDrawState);
      {Handles list view's OnDrawItem event. Owner draws a line of the list
      view.
        @param Sender [in] Not used.
        @param Item [in] List item to be displayed.
        @param Rect [in] Rectangle in which to display list item.
        @param State [in] State of list item (selected, focussed etc).
      }
    procedure Compare(Sender: TObject; Item1, Item2: TListItem; Data: Integer;
      var Compare: Integer);
      {ListView OnCompare event handler. Compares two list items in a way that
      depends of column being sorted.
        @param Sender [in] Not used.
        @param Item1 [in] References 1st list item to be compared.
        @param Item2 [in] References 2nd list item to be compared.
        @param Data [in] Not used.
        @param Compare [in/out] Set to result of comparison.
      }
    procedure ColumnClick(Sender: TObject; Column: TListColumn);
      {List View column header click event handler. Sort list view according to
      which column was clicked.
        @param Sender [in] Not used.
        @param Column [in] Column whose header was clicked.
      }
    procedure DblClick(Sender: TObject);
      {Handles list view's OnDblClick event by triggering this objects own
      OnDblClick event.
        @param Sender [in] Not used.
      }
  public
    constructor Create(const LV: TListView; const EmptyPane: TWinControl);
      {Class constructor. Sets up object and configures list view control.
        @param LV [in] List view being managed.
        @param EmptyPane [in] Panel to be displayed when clipboard is empty.
      }
    procedure Update;
      {Updates display according to current state of clipboard.
      }
    function SelectedFormat: Word;
      {Gets format associated with selected list item.
        @return Required clipboard format or 0 if no selection or selection has
          no associated format.
      }
    property OnDblClick: TNotifyEvent read fOnDblClick write fOnDblClick;
      {Event triggered when list view is double-clicked}
  end;


implementation


uses
  // Delphi
  SysUtils, Clipbrd, CommCtrl, Graphics,
  // Project
  UCBUtils, UUtils;


{ TClipboardLVMgr }

procedure TClipboardLVMgr.ColumnClick(Sender: TObject;
  Column: TListColumn);
  {List View column header click event handler. Sort list view according to
  which column was clicked.
    @param Sender [in] Not used.
    @param Column [in] Column whose header was clicked.
  }
var
  CurOrder: TLVSortDirection; // current sort direction of clicked column
  I: Integer;                 // loops thru sort column index
begin
  // Record current sort order for required column
  CurOrder := fSortInfo.Direction[Column.Index];
  fSortInfo.SortColumn := Column.Index;
  // Clear all sort records to unsorted
  for I := Low(fSortInfo.Direction) to High(fSortInfo.Direction) do
    fSortInfo.Direction[I] := sdUnsorted;
  // Update sort info for clicked column depending on current sort order
  case CurOrder of
    sdUnsorted:   fSortInfo.Direction[fSortInfo.SortColumn] := sdAscending;
    sdAscending:  fSortInfo.Direction[fSortInfo.SortColumn] := sdDescending;
    sdDescending: fSortInfo.Direction[fSortInfo.SortColumn] := sdAscending;
  end;
  // Perform the sort
  fLV.AlphaSort;
end;

procedure TClipboardLVMgr.Compare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
  {ListView OnCompare event handler. Compares two list items in a way that
  depends of column being sorted.
    @param Sender [in] Not used.
    @param Item1 [in] References 1st list item to be compared.
    @param Item2 [in] References 2nd list item to be compared.
    @param Data [in] Not used.
    @param Compare [in/out] Set to result of comparison.
  }

  // ---------------------------------------------------------------------------
  function DelimNumToInt(const Num: string): Integer;
    {Converts a number string that may contain thousands separators to a number.
      @param Num [in] String to be converted.
      @return Required numeric value or -1 if Num is not a valid number/
    }
  var
    IdxNum: Integer;    // loops thru thousand separated number
    IdxPure: Integer;   // loops thru number string without separated
    PureNum: string;    // contains number without thousand separators
  begin
    // assume number is OK: strip out thousands separators
    SetLength(PureNum, Length(Num));
    IdxPure := 1;
    for IdxNum := 1 to Length(Num) do
    begin
      if Num[IdxNum] <> ThousandSeparator then
      begin
        PureNum[IdxPure] := Num[IdxNum];
        Inc(IdxPure);
      end;
    end;
    SetLength(PureNum, IdxPure - 1);
    // convert "pure" string to number
    Result := StrToIntDef(PureNum, -1);
  end;
  // ---------------------------------------------------------------------------

begin
  // We don't do comparison while list view is updating
  if fUpdating then
    Exit;
  // Perform sort depending on column
  case fSortInfo.SortColumn of
    0:
      // sorting caption as text
      Compare := AnsiCompareText(Item1.Caption, Item2.Caption);
    1:
      // sorting first subitem as text
      Compare := AnsiCompareText(Item1.SubItems[0], Item2.SubItems[0]);
    2:
      // sorting second subitem as thousands separated numbers
      Compare := DelimNumToInt(Item1.SubItems[1])
        - DelimNumToInt(Item2.SubItems[1])
  end;
  // If we need a descendign sort we simply reverse sign of comparison
  if fSortInfo.Direction[fSortInfo.SortColumn] = sdDescending then
    Compare := -Compare;
end;

constructor TClipboardLVMgr.Create(const LV: TListView;
  const EmptyPane: TWinControl);
  {Class constructor. Sets up object and configures list view control.
    @param LV [in] List view being managed.
    @param EmptyPane [in] Panel to be displayed when clipboard is empty.
  }
var
  I: Integer; // loops through all sort direction elements
begin
  inherited Create;
  // record list view and empty pane
  fLV := LV;
  fEmptyPane := EmptyPane;
  // set list view required properties
  fLV.OwnerDraw := True;
  fLV.SortType := stText;
  // assign required list view event handlers
  fLV.OnDrawItem := DrawItem;
  fLV.OnCompare := Compare;
  fLV.ColumnClick := True;
  fLV.OnColumnClick := ColumnClick;
  fLV.OnDblClick := DblClick;
  // size the sort info direction array to number of list view columns and
  // initialise the record
  SetLength(fSortInfo.Direction, fLV.Columns.Count);
  fSortInfo.SortColumn := 0;
  for I := Low(fSortInfo.Direction) to High(fSortInfo.Direction) do
    fSortInfo.Direction[I] := sdUnsorted;
  fSortInfo.Direction[fSortInfo.SortColumn] := sdAscending;
end;

procedure TClipboardLVMgr.DblClick(Sender: TObject);
  {Handles list view's OnDblClick event by triggering this objects own
  OnDblClick event.
    @param Sender [in] Not used.
  }
begin
  if Assigned(fOnDblClick) then
    fOnDblClick(Self);
end;

procedure TClipboardLVMgr.DrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
  {Handles list view's OnDrawItem event. Owner draws a line of the list view.
    @param Sender [in] Not used.
    @param Item [in] List item to be displayed.
    @param Rect [in] Rectangle in which to display list item.
    @param State [in] State of list item (selected, focussed etc).
  }

  // ---------------------------------------------------------------------------
  procedure DisplayItem(const Col: Integer; var Left: Integer);
    {Displays caption or sub-item relating to a list view column appropriately
    aligned.
      @param Col [in] Index of column to be displayed. (0 => caption, N>=1 =>
        subitem n-1.
      @param Left [in/out] Left co-ordinate of column to be displayed passed in.
        Left is updated to co-ordinate of next column.
    }
  const
    // Maps TAlignment value to appropriate DrawText constant.
    cAlignMap: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
  var
    ColRect: TRect;   // rectangle defining display for text in list view column
    Width: Integer;   // width of a column
    Text: string;     // text to be displayed in column
  begin
    // Calculate rectangle in which to display (sub-)item's text
    Width := ListView_GetColumnWidth(fLV.Handle, Col);
    ColRect := Rect;
    ColRect.Left := Left + 8;
    ColRect.Right := Left + Width - 8;
    // Determine text to be displayed
    if Col = 0 then
      Text := Item.Caption
    else
      Text := Item.SubItems[Col - 1];
    // Draw text with end ellipsis if text too long
    DrawTextEx(
      fLV.Canvas.Handle,
      PChar(Text),
      -1,
      ColRect,
      DT_VCENTER or DT_END_ELLIPSIS or cAlignMap[fLV.Columns[Col].Alignment],
      nil
    );
    // Determine left edge of next column
    Left := Left + Width;
  end;

  procedure SetColours(const BG, FG: TColor);
    {Sets canvas' background and foreground colours.
      @param BG [in] Background colour.
      @param FG [in] Foreground colour.
    }
  begin
    fLV.Canvas.Brush.Color := BG;
    fLV.Canvas.Font.Color := FG;
  end;
  // ---------------------------------------------------------------------------

var
  Idx: Integer;         // loops through columns to be displayed
  NextLeft: Integer;    // set to left hand co-ord of each column
begin
  with fLV do
  begin
    // Set background / foreground colours depending on selection state
    if (odSelected in State) then
      if Focused then
        SetColours(clHighlight, clHighlightText)  // selected / focussed
      else
        SetColours(clBtnFace, clBtnText)          // selected / unfocussed
    else
      SetColours(Color, Font.Color);              // unselected
    // Draw background
    Canvas.FillRect(Rect);
    // Draw each column entry
    NextLeft := 0;
    for Idx := 0 to Pred(Columns.Count) do
      DisplayItem(Idx, NextLeft);
    if (odSelected in State) and Focused then
      // selected and focussed: need focus rectangle
      Canvas.DrawFocusRect(Rect);
  end;
end;

function TClipboardLVMgr.SelectedFormat: Word;
  {Gets format associated with selected list item.
    @return Required clipboard format or 0 if no selection or selection has no
      associated format.
  }
begin
  if Assigned(fLV.Selected) then
    Result := Word(fLV.Selected.Data)
  else
    Result := 0;
end;

procedure TClipboardLVMgr.Update;
  {Updates display according to current state of clipboard.
  }

  // ---------------------------------------------------------------------------
  procedure AcquireClipboard;
    {Waits until clipboard is available and opens it.
      @except Exception raised if maximum number of attempts to open clipboard
        fails.
    }
  resourcestring
    sTimeOut = 'Timed out waiting for clipboard'; // timeout error message
  const
    cMaxAttempts = 20;  // max number of attempts to open clipboard
  var
    Attempts: Integer;  // number of attempts made to open clipboard
  begin
    // Attempt to open clipboard
    Attempts := 0;
    while not UCBUtils.CanOpenClipboard and (Attempts <= cMaxAttempts) do
    begin
      Pause(50);
      Inc(Attempts);
    end;
    // Check if we failed
    if Attempts > cMaxAttempts then
      raise Exception.Create(sTimeOut);
    // Open the clipboard
    Clipboard.Open;
  end;

  procedure ReleaseClipboard;
    {Closes clipboard.
    }
  begin
    Clipboard.Close;
  end;

  procedure DisplayCBContent;
    {Displays information about formats on clipboard.
    }
  var
    I: Integer;     // loops through all available clipboard formats
    LI: TListItem;  // new list item add to list view
    Fmt: Word;      // a format ID
  begin
    // Ensure list view is displayed and is cleared
    fEmptyPane.Visible := False;
    fLV.Items.Clear;
    fLV.Visible := True;
    // Loop through all formats, getting handle. Sometimes all handles must have
    // been read once before GlobalSize will return correct size! So we do this
    // dummy scan through all formats, grabbing handles.
    for I := 0 to ClipBoard.FormatCount - 1 do
    begin
      Fmt := ClipBoard.Formats[I];
      Clipboard.GetAsHandle(Fmt);
    end;
    // Loop thru all formats, displaying information about each one to list view
    for I := 0 to ClipBoard.FormatCount - 1 do
    begin
      LI := fLV.Items.Add;
      Fmt := ClipBoard.Formats[I];
      LI.Caption := IntToHex(Fmt, 4);
      LI.SubItems.Add(UCBUtils.CBCodeToString(Fmt));
      if UCBUtils.IsDataInGlobalMemFormat(Fmt) then
        // add size for data in global memory format
        LI.SubItems.Add(
          IntToFixed(GlobalSize(Clipboard.GetAsHandle(Fmt)), True)
        )
      else
        // can't display size for non-global memory formats
        LI.SubItems.Add('-');
      LI.Data := Pointer(Fmt);
    end;
  end;

  procedure DisplayEmptyCB;
    {Displays message noting clipboard is empty.
    }
  begin
    // Display the panel containing the "empty" message
    fLV.Visible := False;
    fEmptyPane.Visible := True;
  end;
  // ---------------------------------------------------------------------------

begin
  // Get out if already updating
  if fUpdating then
    Exit;
  fUpdating := True;
  // Acquire clipboard: tries several times and raises exception if fails
  AcquireClipboard;
  try
    if ClipBoard.FormatCount = 0 then
      DisplayEmptyCB      // no content
    else
      DisplayCBContent;   // display content
  finally
    ReleaseClipboard;
    fUpdating := False;
  end;
  fLV.AlphaSort;  // must call after finished updating
end;

end.

