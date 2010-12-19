{
 * UMessageBox.pas
 *
 * Implements a static class that can display message dialog boxes at an
 * appropriate position on screen.
 *
 * v1.0 of 10 Mar 2008  - Original version.
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
 * The Original Code is UMessageBox.pas.
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


unit UMessageBox;


interface


uses
  // Project
  SysUtils, Forms, Controls, Dialogs;


type

  {
  TMessageBox:
    Static class that can display message dialog boxes at an appropriate
    position on screen.
  }
  TMessageBox = class(TObject)
  private
    class function GetParentForm(Ctrl: TWinControl): TForm;
      {Gets parent form of a control. If control is already a form it is
      returned.
        @param Ctrl [in] Control for which we need parent.
        @return Parent form or Ctrl if Ctrl is a form. Nil returned if Ctrl has
          no parent.
      }
    class function Display(AlignTo: TWinControl; const Msg: string;
      const MsgType: TMsgDlgType; const Buttons: TMsgDlgButtons): Word;
      {Displays a message in a customised dialog box located over a form.
        @param AlignTo [in] Control that dialog box is aligned over. If AlignTo
          is not a form its parent form is used. If AlignTo is nil or has no
          parent then the current active form is used.
        @param Msg [in] Message displayed in dialog.
        @param MsgType [in] Type of dialog box. Must not be mtCustom.
        @param Buttons [in] Set of buttons to display in dialog box.
        @return Value indicating which button was pressed to close dialog box.
      }
  public
    class procedure Error(AlignTo: TWinControl; const Msg: string);
      {Displays a message in an error dialog box located relative to owner form.
        @param AlignTo [in] Control whose parent form the dialog box is aligned
          over. If AlignTo is nil or has no parent form then current active form
          is used.
        @param Msg [in] Message displayed in dialog.
      }
    class procedure ExceptionHandler(Sender: TObject; E: Exception);
      {Handles application exceptions by displaying an error dialog box located
      over currently active form.
        @param Sender [in] Not used.
        @param E [in] Exception. Message is displayed in dialog.
      }
  end;


implementation


uses
  // Delphi
  Windows;


{ TMessageBox }

class function TMessageBox.Display(AlignTo: TWinControl;
  const Msg: string; const MsgType: TMsgDlgType;
  const Buttons: TMsgDlgButtons): Word;
  {Displays a message in a customised dialog box located over a form.
    @param AlignTo [in] Control that dialog box is aligned over. If AlignTo is
      not a form its parent form is used. If AlignTo is nil or has no parent
      then the current active form is used.
    @param Msg [in] Message displayed in dialog.
    @param MsgType [in] Type of dialog box. Must not be mtCustom.
    @param Buttons [in] Set of buttons to display in dialog box.
    @return Value indicating which button was pressed to close dialog box.
  }
var
  Dlg: TForm;               // dialog box instance
  AlignerRect: TRect;       // rectangle to align form to
  WorkArea: TRect;          // workspace rectangle
begin
  Assert(MsgType <> mtCustom,                              // ** do not localise
    'TMessageBox.Display: MsgType is mtCustom');
  // Create a dialog box of required type
  Dlg := CreateMessageDialog(Msg, MsgType, Buttons);
  try
    // Align form
    WorkArea := Screen.WorkAreaRect;
    // find form to align to
    AlignTo := GetParentForm(AlignTo);
    if not Assigned(AlignTo) then
      AlignTo := Screen.ActiveForm;
    if not Assigned(AlignTo) then
      AlignerRect := WorkArea
    else
      AlignerRect := AlignTo.BoundsRect;
    // do alignment
    Dlg.Left := AlignerRect.Left
      + (AlignerRect.Right - AlignerRect.Left - Dlg.Width) div 2;
    Dlg.Top := AlignerRect.Top
      + (AlignerRect.Bottom - AlignerRect.Top - Dlg.Height) div 2;
    // keep with workspace
    if Dlg.Left < WorkArea.Left then
      Dlg.Left := WorkArea.Left;
    if Dlg.Top < WorkArea.Top then
      Dlg.Top := WorkArea.Top;
    if Dlg.Left + Dlg.Width > WorkArea.Right then
      Dlg.Left := WorkArea.Right - Dlg.Width;
    if Dlg.Top + Dlg.Height > WorkArea.Bottom then
      Dlg.Top := WorkArea.Bottom - Dlg.Height;

    // Display the dialog and return result
    Result := Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

class procedure TMessageBox.Error(AlignTo: TWinControl; const Msg: string);
  {Displays a message in an error dialog box located relative to owner form.
    @param AlignTo [in] Control whose parent form the dialog box is aligned
      over. If AlignTo is nil or has no parent form then current active form is
      used.
    @param Msg [in] Message displayed in dialog.
  }
begin
  Display(AlignTo, Msg, mtError, [mbOK]);
end;

class procedure TMessageBox.ExceptionHandler(Sender: TObject;
  E: Exception);
  {Handles application exceptions by displaying an error dialog box located over
  currently active form.
    @param Sender [in] Not used.
    @param E [in] Exception. Message is displayed in dialog.
  }
resourcestring
  // Exception message
  sException = 'An unhandled exception has been detected:'#10#10'"%s"';
begin
  Error(nil, Format(sException, [E.Message]));
end;

class function TMessageBox.GetParentForm(Ctrl: TWinControl): TForm;
  {Gets parent form of a control. If control is already a form it is returned.
    @param Ctrl [in] Control for which we need parent.
    @return Parent form or Ctrl if Ctrl is a form. Nil returned if Ctrl has no
      parent.
  }
begin
  while Assigned(Ctrl) and not (Ctrl is TForm) do
    Ctrl := Ctrl.Parent;
  if Assigned(Ctrl) then
    Result := Ctrl as TForm
  else
    Result := nil;
end;

end.
