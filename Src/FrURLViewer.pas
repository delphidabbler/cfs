{
 * FrURLViewer.pas
 *
 * Implements a viewer frame that can display URLs specified as text.
 *
 * v1.0 of 19 Mar 2008  - Original version.
 * v1.1 of 19 Jun 2008  - Added keywboard accelerator to Go to URL button.
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
 * The Original Code is FrURLViewer.pas.
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


unit FrURLViewer;


interface


uses
  // Delphi
  Menus, StdActns, Classes, ActnList, StdCtrls, Controls, ExtCtrls,
  // Project
  FrShellNameViewer;


type
  {
  TURLViewerFrame:
    Viewer frame that can display URLs specified as text. URLs are displayed in
    default browser or application. Suppoorts election of URL and copying of URL
    to clipboard as text.
  }
  TURLViewerFrame = class(TShellNameViewerFrame)
    procedure actExecExecute(Sender: TObject);
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  UMessageBox, UProcessUtils;


{$R *.dfm}

procedure TURLViewerFrame.actExecExecute(Sender: TObject);
  {Handles Execute action by attempting to display URL in default browser.
  Displays error on failure
    @param Sender [in] Not used.
  }
resourcestring
  // Error message
  sCantOpen = 'Can''t open URL'#10#10'%s';
begin
  if not OpenFile(edName.Text) then
    TMessageBox.Error(Self, Format(sCantOpen, [edName.Text]));
end;

end.

