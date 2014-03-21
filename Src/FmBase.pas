{
 * FmBase.pas
 *
 * Implements a form that provides the ancestor of all forms in the application.
 * Provides default names for form window classes along with various operations
 * that are common to all forms in application.
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
 * The Original Code is FmBase.pas
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


unit FmBase;


interface


uses
  // Delphi
  Forms, Controls, Messages;


type
  {
  TBaseForm:
    Base class for all forms in application. Sets a unique window class name for
    all derived forms and provides various operations that are common to all
    forms in application.
  }
  TBaseForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure CMWinIniChange(var Msg: TMessage); message CM_WININICHANGE;
      {Handles CM_WININICHANGE message by updating themes.
        @param Msg [in/out] CM_WININICHANGE message. Unchanged.
      }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
      {Sets window class name.
        @param Params [in/out] Parameters used in underlying call to
          CreateWindowEx API function. Window class name member field is set.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, StrUtils, Themes;


{$R *.dfm}

procedure TBaseForm.CMWinIniChange(var Msg: TMessage);
  {Handles CM_WININICHANGE message by updating themes.
    @param Msg [in/out] CM_WININICHANGE message. Unchanged.
  }
begin
  ThemeServices.ApplyThemeChange;
  inherited;
end;

procedure TBaseForm.CreateParams(var Params: TCreateParams);
  {Sets window class name.
    @param Params [in/out] Parameters used in underlying call to
      CreateWindowEx API function. Window class name member field is set.
  }
var
  WindowClassName: string;  // name of window class
begin
  inherited;
  Assert(Name <> '',                                       // ** do not localise
    'TBaseForm.CreateParams: Name is empty string');
  WindowClassName := 'DelphiDabbler.CFS.' + Name;
  StrLCopy(
    Params.WinClassName,
    PChar(WindowClassName),
    SizeOf(Params.WinClassName) div SizeOf(Char) - 1
  );
end;

procedure TBaseForm.FormCreate(Sender: TObject);
  {Do-nothing handler of form's OnCreate event.
    @param Sender [in] Not used.
  }
begin
  // For reasons I don't understand this do-nothing event handler must be
  // present otherwise OnCreate handlers of descendant forms won't get called!!
end;

procedure TBaseForm.FormDestroy(Sender: TObject);
  {Do-nothing handler of form's OnDestroy event.
    @param Sender [in] Not used.
  }
begin
  // For reasons I don't understand this do-nothing event handler must be
  // present otherwise OnDestroy handlers of descendant forms won't get called!!
end;

end.

