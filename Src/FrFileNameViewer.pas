{
 * FrFileNameViewer.pas
 *
 * Implements a viewer frame that can display file and folder names specified as
 * text.
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
 * The Original Code is FrFileNameViewer.pas.
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


unit FrFileNameViewer;


interface


uses
  // Delphi
  Menus, StdActns, Classes, ActnList, StdCtrls, Controls, ExtCtrls,
  // Project
  FrShellNameViewer;


type
  {
  TFileNameViewerFrame:
    Viewer frame that can display file names specified as text. Executes
    applications and file with associated applications. Displays folders in
    Explorer. Supports selection of file name and copying of file name to
    clipboard as text.
  }
  TFileNameViewerFrame = class(TShellNameViewerFrame)
    procedure actExecUpdate(Sender: TObject);
    procedure actExecExecute(Sender: TObject);
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  UFileLists, UMessageBox, UProcessUtils;


{$R *.dfm}

procedure TFileNameViewerFrame.actExecExecute(Sender: TObject);
  {Attempts the open the named file, or display contents in explorer if it is a
  folder.
    @param Sender [in] Not used.
  }
resourcestring
  // Error messages
  sCantExplore = 'Can''t explore this folder:'#10#10'%s';
  sCantOpen = 'Don''t know how to open this file:'#10#10'%s';
var
  FI: TFileInfo;  // object providing info about the file
begin
  if actExec.Enabled then
  begin
    // get file info
    FI := TFileInfo.Create(edName.Text);
    try
      if FI.IsDirectory then
      begin
        // directory: open explorer
        if not ExploreFolder(FI.Name) then
          TMessageBox.Error(Self, Format(sCantExplore, [FI.Name]));
      end
      else
      begin
        // file: try to open
        if not OpenFile(FI.Name) then
          TMessageBox.Error(Self, Format(sCantOpen, [FI.Name]));
      end;
    finally
      FreeAndNil(FI);
    end;
  end;
end;

procedure TFileNameViewerFrame.actExecUpdate(Sender: TObject);
  {Sets the caption of the execute action depending on if file is true file or
  directory.
    @param Sender [in] Not used.
  }
resourcestring
  // Alternative action captions
  sOpen = '&Open';
  sExplore = '&Explore';
var
  FI: TFileInfo;
begin
  inherited;  // this sets Enabled property
  if actExec.Enabled then
  begin
    // get file info
    FI := TFileInfo.Create(edName.Text);
    try
      if FI.IsDirectory then
        actExec.Caption := sExplore
      else
        actExec.Caption := sOpen;
    finally
      FreeAndNil(FI);
    end;
  end;
end;

end.

