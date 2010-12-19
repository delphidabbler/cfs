{
 * FmBase.pas
 *
 * Implements a form that provides the ancestor of all forms in the application.
 * Provides default names for form window classes along with various operations
 * that are common to all forms in application.
 *
 * v1.0 of 19 Jun 2008  - Original version.
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
 * The Original Code is FmBase.pas
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
  SysUtils, StrUtils, Themes,
  // Project
  UAltBugFix;


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
  StrLCopy(Params.WinClassName, PChar(WindowClassName), 62);
end;

procedure TBaseForm.FormCreate(Sender: TObject);
  {Handles form's OnCreate event. Registers form with object that works around
  Delphi's Alt Key bug.
    @param Sender [in] Not used.
  }
begin
  AltBugFix.RegisterCtrl(Self);
end;

procedure TBaseForm.FormDestroy(Sender: TObject);
  {Handles form's OnDestroy event. Unregisters form with object that works
  around Delphi's Alt Key bug.
    @param Sender [in] Not used.
  }
begin
  AltBugFix.UnRegisterCtrl(Self);
end;

end.

