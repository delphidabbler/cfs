{
 * FmBaseDlg.pas
 *
 * Implements a form that provides the ancestor of all forms that act as dialog
 * boxes in the application. Ensures that dialog boxes have the owner form as a
 * parent window.
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
 * The Original Code is FmBaseDlg.pas
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


unit FmBaseDlg;


interface


uses
  // Project
  FmBase;


type
  {
  TBaseDlgForm:
    Base class for forms that provides the ancestor of all forms that act as
    dialog boxes in the application. Ensures that dialog boxes have the owner
    form as a parent window.
  }
  TBaseDlgForm = class(TBaseForm)
    procedure FormCreate(Sender: TObject);
  private
    procedure SetParentToOwner;
      {Sets handle of form's owner as parent of this form's window. If owner has
      no handle, or is nil either active form or application's main form is used
      as parent.
      }
  end;


implementation


uses
  // Delphi
  Controls, Forms, Windows;


{$R *.dfm}

procedure TBaseDlgForm.FormCreate(Sender: TObject);
  {Handles form's OnCreate event. Ensures that any owner form's handle is this
  form's parent.
    @param Sender [in] Not used.
  }
begin
  inherited;
  SetParentToOwner;
end;

procedure TBaseDlgForm.SetParentToOwner;
  {Sets handle of form's owner as parent of this form's window. If owner has no
  handle, or is nil either active form or application's main form is used as
  parent.
  }
var
  ParentWnd: THandle; // window handle of parent control
begin
  // Get parent handle
  if Assigned(Owner) and (Owner is TWinControl) then
    ParentWnd := (Owner as TWinControl).Handle
  else if Assigned(Screen.ActiveCustomForm) then
    ParentWnd := Screen.ActiveCustomForm.Handle
  else if Assigned(Application.MainForm) then
    ParentWnd := Application.MainForm.Handle
  else
    ParentWnd := Application.Handle;
  Assert(ParentWnd <> 0,                                   // ** do not localise
    'TBaseDlgForm.SetParentToOwner: Can''t get parent window');
  // Set form's window handle
  SetWindowLong(Handle, GWL_HWNDPARENT, ParentWnd);
end;

end.

