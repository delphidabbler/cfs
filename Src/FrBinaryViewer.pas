{
 * FrBinaryViewer.pas
 *
 * Implements a viewer frame that displays a hex view of binary data in a memo
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
 * The Original Code is FrBinaryViewer.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2008-2011 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): None
 *
 * ***** END LICENSE BLOCK *****
}


unit FrBinaryViewer;


interface


uses
  // Delphi
  Forms, Classes, ActnList, Controls, ExtCtrls, Messages;


type

  {
  TBinaryViewerFrame:
    Viewer frame that displays a hex view of binary data in a memo control.
  }
  TBinaryViewerFrame = class(TFrame)
    actDocEnd: TAction;
    actDocHome: TAction;
    actDown: TAction;
    actLeft: TAction;
    actLineEnd: TAction;
    actLineHome: TAction;
    actPgDn: TAction;
    actPgUp: TAction;
    actRight: TAction;
    actUp: TAction;
    alView: TActionList;
    pbView: TPaintBox;
    sbView: TScrollBox;
    procedure pbViewPaint(Sender: TObject);
    procedure sbViewResize(Sender: TObject);
    procedure actDocEndExecute(Sender: TObject);
    procedure actDocHomeExecute(Sender: TObject);
    procedure actDownExecute(Sender: TObject);
    procedure actLeftExecute(Sender: TObject);
    procedure actLineEndExecute(Sender: TObject);
    procedure actLineHomeExecute(Sender: TObject);
    procedure actPgDnExecute(Sender: TObject);
    procedure actPgUpExecute(Sender: TObject);
    procedure actRightExecute(Sender: TObject);
    procedure actUpExecute(Sender: TObject);
  private
    fData: TStream;
      {Stores binary data to be displayed}
    fLineHeight: Integer;
      {Height of a line in the hex viewer. Depends on font used}
    fLineWidth: Integer;
      {Width of a line in the hex viewer. Depends on font used}
    procedure UpdateCtrlSize;
      {Updates size of control on which hex view in painted.
      }
    procedure SetLineExtent;
      {Records width and height of line in hex viewer in current font.
      }
    function LineCount: Integer;
      {Calculates number of hex viewer lines required to display data.
        @return Number of required lines.
      }
    procedure PaintLine(const X, Y: Integer; const Line: Integer);
      {Paints textual representation of a line of hex.
        @param X [in] X co-ordinate where text to be displayed.
        @param Y [in] Y co-ordinate where text to be displayed.
        @param Line [in] Zero based line of data to display.
      }
    procedure CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
      {Handles font changed message. Records new font and recalculates length
      and height of a line and width and height of whole document.
        @param Msg [in/out] Not used.
      }
  public
    constructor Create(AOwner: TComponent); override;
      {Class constructor. Initialises object and creates data store.
        @param AOwner [in] Passed on to inherited constructor.
      }
    destructor Destroy; override;
      {Class destructor. Releases data store.
      }
    procedure Display(const Data: TStream);
      {Displays a hex view of the data in the frame.
        @param Data [in] Stream containing the binary data.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, Windows;


{$R *.dfm}


type
  {
  THexLineArray:
    Array of bytes that can be displayed on one line of the hex viewer.
  }
  THexLineArray = array[0..15] of Byte;


const
  // Format string used to generate a line of text in the hex viewer
  cLineFmtStr = '%0.8X  %-48s  %-16s';
  //               ^       ^      ^
  //               |       |      text representation
  //               |       hex representation
  //               offset into data (in hex)


{ TBinaryViewerFrame }

procedure TBinaryViewerFrame.actDocEndExecute(Sender: TObject);
  {Handles action triggered when Ctrl+End keys pressed. Moves to end of binary
  document.
    @param Sender [in] Not used.
  }
begin
  sbView.VertScrollBar.Position := pbView.ClientHeight;
  sbView.HorzScrollBar.Position := fLineWidth;
end;

procedure TBinaryViewerFrame.actDocHomeExecute(Sender: TObject);
  {Handles action triggered when Ctrl+Home keys pressed. Moves to start of
  binary document.
    @param Sender [in] Not used.
  }
begin
  sbView.VertScrollBar.Position := 0;
  sbView.HorzScrollBar.Position := 0;
end;

procedure TBinaryViewerFrame.actDownExecute(Sender: TObject);
  {Handles action triggered when Down key pressed. Scrolls down one line.
    @param Sender [in] Not used.
  }
begin
  sbView.VertScrollBar.Position := sbView.VertScrollBar.Position + fLineHeight;
end;

procedure TBinaryViewerFrame.actLeftExecute(Sender: TObject);
  {Handles action triggered when Left key pressed. Scrolls left one character.
    @param Sender [in] Not used.
  }
begin
  sbView.HorzScrollBar.Position := sbView.HorzScrollBar.Position - 1;
end;

procedure TBinaryViewerFrame.actLineEndExecute(Sender: TObject);
  {Handles action triggered when End key pressed. Scrolls right to display end
  of line.
    @param Sender [in] Not used.
  }
begin
  sbView.HorzScrollBar.Position := fLineWidth;
end;

procedure TBinaryViewerFrame.actLineHomeExecute(Sender: TObject);
  {Handles action triggered when Home key pressed. Scrolls left to display start
  of line.
    @param Sender [in] Not used.
  }
begin
  sbView.HorzScrollBar.Position := 0;
end;

procedure TBinaryViewerFrame.actPgDnExecute(Sender: TObject);
  {Handles action triggered when Page Dn key pressed. Scrolls down one screen.
    @param Sender [in] Not used.
  }
begin
  sbView.VertScrollBar.Position := sbView.VertScrollBar.Position +
    sbView.ClientHeight;
end;

procedure TBinaryViewerFrame.actPgUpExecute(Sender: TObject);
  {Handles action triggered when Page Up key pressed. Scrolls up one screen.
    @param Sender [in] Not used.
  }
begin
  sbView.VertScrollBar.Position := sbView.VertScrollBar.Position -
    sbView.ClientHeight;
end;

procedure TBinaryViewerFrame.actRightExecute(Sender: TObject);
  {Handles action triggered when Right key pressed. Scrolls right one character.
    @param Sender [in] Not used.
  }
begin
  sbView.HorzScrollBar.Position := sbView.HorzScrollBar.Position + 1;
end;

procedure TBinaryViewerFrame.actUpExecute(Sender: TObject);
  {Handles action triggered when Up key pressed. Scrolls up one line.
    @param Sender [in] Not used.
  }
begin
  sbView.VertScrollBar.Position := sbView.VertScrollBar.Position - fLineHeight;
end;

procedure TBinaryViewerFrame.CMFontChanged(var Msg: TMessage);
  {Handles font changed message. Records new font and recalculates length and
  height of a line and width and height of whole document.
    @param Msg [in/out] Not used.
  }
begin
  pbView.Canvas.Font := pbView.Font;
  SetLineExtent;
  UpdateCtrlSize;
end;

constructor TBinaryViewerFrame.Create(AOwner: TComponent);
  {Class constructor. Initialises object and creates data store.
    @param AOwner [in] Passed on to inherited constructor.
  }
begin
  inherited;
  pbView.Canvas.Font := pbView.Font;
  fData := TMemoryStream.Create;
  SetLineExtent;
end;

destructor TBinaryViewerFrame.Destroy;
  {Class destructor. Releases data store.
  }
begin
  FreeAndNil(fData);
  inherited;
end;

procedure TBinaryViewerFrame.Display(const Data: TStream);
  {Displays hex view of data in the frame.
    @param Data [in] Stream containing the binary data.
  }
begin
  fData.Size := 0;
  fData.CopyFrom(Data, 0);
  fData.Position := 0;
  UpdateCtrlSize;
end;

function TBinaryViewerFrame.LineCount: Integer;
  {Calculates number of hex viewer lines required to display data.
    @return Number of required lines.
  }
begin
  if Assigned(fData) then
  begin
    Result := fData.Size div SizeOf(THexLineArray);
    if fData.Size mod SizeOf(THexLineArray) <> 0 then
      Inc(Result);
  end
  else
    Result := 0;
end;

procedure TBinaryViewerFrame.PaintLine(const X, Y: Integer;
  const Line: Integer);
  {Paints textual representation of a line of hex.
    @param X [in] X co-ordinate where text to be displayed.
    @param Y [in] Y co-ordinate where text to be displayed.
    @param Line [in] Zero based line of data to display.
  }

  // ---------------------------------------------------------------------------
  function MapChar(const Ch: Byte): Char;
    {Maps a byte onto a printable character.
      @param Ch [in] Byte to be displayed.
      @return Character used to represent bytes ('.' if byte not printable).
    }
  begin
    if Ch in [32..126] then
      Result := Char(Ch)
    else
      Result := '.';
  end;
  // ---------------------------------------------------------------------------

var
  HexStr: string;         // hex representation of a byte
  CharStr: string;        // character representation of a byte
  Idx: Integer;           // loops through each byte in line
  Offset: Integer;        // offset of line in buffer
  ByteCount: Integer;     // number of bytes to display
  Buffer: THexLineArray;  // buffer to contain line to display
  LineStr: string;        // line of text to display
begin
  // Get display data from data stream
  Offset := Line * SizeOf(THexLineArray);
  fData.Position := Offset;
  ByteCount := fData.Read(Buffer, SizeOf(THexLineArray));

  // Create hex and character areas of line
  HexStr := '';
  CharStr := '';
  for Idx := 0 to Pred(ByteCount) do
  begin
    HexStr := HexStr + IntToHex(Buffer[Idx], 2) + ' ';
    CharStr := CharStr + MapChar(Buffer[Idx]);
  end;

  // Put the line together: offset / hex / characters
  LineStr := Format(cLineFmtStr, [Offset, HexStr, CharStr]);
  pbView.Canvas.TextOut(X, Y, LineStr);
end;

procedure TBinaryViewerFrame.pbViewPaint(Sender: TObject);
  {Handles OnPaint event of paint box. Used to display hex viewer. Only the
  visible (or partially visible) lines are displayed.
    @param Sender [in] Not Used.
  }
var
  FirstVisibleLine: Integer;  // index of first (part) visible line in viewer
  LastVisibleLine: Integer;   // index of last (part) visible line in viewer
  LineIdx: Integer;           // index of each line to be displayed
  VScrollPos: Integer;        // position of scroll box's veritcal scroll bar
begin
  VScrollPos := sbView.VertScrollBar.Position;
  FirstVisibleLine := (VScrollPos div fLineHeight) - 1;
  LastVisibleLine := ((VScrollPos + sbView.ClientHeight) div fLineHeight) - 1;
  for LineIdx := FirstVisibleLine to LastVisibleLine do
    PaintLine(0, LineIdx * fLineHeight, LineIdx);
end;

procedure TBinaryViewerFrame.sbViewResize(Sender: TObject);
  {Handles frame resizing. Updates size of control on which hex viewer is
  displayed.
    @param Sender [in] Not used.
  }
begin
  UpdateCtrlSize;
end;

procedure TBinaryViewerFrame.SetLineExtent;
  {Records width and height of line in hex viewer in current font.
  }
var
  TM: TTextMetric;  // text metrics for current font in display control
begin
  GetTextMetrics(pbView.Canvas.Handle, TM);
  fLineHeight := pbView.Canvas.TextHeight('Xy') + TM.tmExternalLeading;
  fLineWidth := pbView.Canvas.TextWidth(Format(cLineFmtStr, [0, '', '']));
end;

procedure TBinaryViewerFrame.UpdateCtrlSize;
  {Updates size of control on which hex view in painted.
  }
begin
  pbView.ClientHeight := LineCount * fLineHeight;
  pbView.ClientWidth := fLineWidth;
end;

end.

