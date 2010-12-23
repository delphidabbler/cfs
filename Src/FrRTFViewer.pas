{
 * FrRTFViewer.pas
 *
 * Implements a viewer frame that displays rich text format documents.
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
 * The Original Code is FrRTFViewer.pas.
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


unit FrRTFViewer;


interface


uses
  // Delphi
  SysUtils, Forms, StdActns, Classes, ActnList, Menus, Controls, StdCtrls,
  ComCtrls;


type

  {
  TRTFViewerFrame:
    Viewer frame that displays rich text format documents using provided ASCII
    encoded RTF source. Supports selecting and copying of selections to
    clipboard as text and rich text.
  }
  TRTFViewerFrame = class(TFrame)
    reView: TRichEdit;
    mnuView: TPopupMenu;
    miCopy: TMenuItem;
    miSelectAll: TMenuItem;
    alView: TActionList;
    actCopy: TEditCopy;
    actSelectAll: TEditSelectAll;
  private
    procedure SetMargins;
      {Sets left and right margins in rich edit control.
      }
  public
    procedure Display(const RTF: TBytes);
      {Displays RTF in rich edit control.
        @param RTF [in] Byte array containing ASCII encoded RTF code to be
          displayed.
      }
  end;


implementation


uses
  // Delphi
  Messages, Windows;


{$R *.dfm}

{ TRTFViewerFrame }

procedure TRTFViewerFrame.Display(const RTF: TBytes);
  {Displays RTF in rich edit control.
    @param RTF [in] Byte array containing ASCII encoded RTF code to be
      displayed.
  }
var
  Stm: TBytesStream;  // used to load RTF bytes into rich edit control
begin
  reView.MaxLength := Length(RTF);  // ensures control has large enough capacity
  reView.PlainText := False;
  Stm := TBytesStream.Create(RTF);
  try
    reView.Lines.LoadFromStream(Stm, TEncoding.ASCII);
  finally
    Stm.Free;
  end;
  SetMargins;
end;

procedure TRTFViewerFrame.SetMargins;
  {Sets left and right margins in rich edit control.
  }
var
  Rect: TRect;  // client rectangle of richedit control used to set margins
begin
  // get client rect
  Rect := reView.ClientRect;
  // adjust for new margins
  Rect.Left := Rect.Left + 4;
  Rect.Right := Rect.Right - 4;
  // set the margins
  reView.Perform(EM_SETRECT, 0, LParam(@Rect));
end;

end.

