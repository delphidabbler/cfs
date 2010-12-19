{
 * FrFileListViewer.pas
 *
 * Implements a viewer frame that displays a list of files provided in a
 * TFileList object.
 *
 * v1.0 of 10 Mar 2008  - Original version.
 * v1.1 of 04 May 2008  - Changed caption of 1st list view to "Files / Folders"
 *                        from "Dropped Files".
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
 * The Original Code is FrFileListViewer.pas.
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


unit FrFileListViewer;


interface


uses
  // Delphi
  Classes, ActnList, Menus, ImgList, Controls, ComCtrls, Forms,
  // Project
  UFileLists;


type
  {
  TFileListViewerFrame:
    Viewer frame that displays a list of files provided in a TFileList object.
    Supports copying of file list to clipboard as text and execution of selected
    files.
  }
  TFileListViewerFrame = class(TFrame)
    lvView: TListView;
    ilView: TImageList;
    mnuView: TPopupMenu;
    miExec: TMenuItem;
    alView: TActionList;
    actExec: TAction;
    actCopy: TAction;
    miCopy: TMenuItem;
    procedure lvViewDblClick(Sender: TObject);
    procedure lvViewDeletion(Sender: TObject; Item: TListItem);
    procedure actExecExecute(Sender: TObject);
    procedure actExecUpdate(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
  private
    function GetSelectedFileInfo: TFileInfo;
      {Gets information about file associated with selected list item.
        @return File information or nil if no list item selected or no file
          associated with list item.
      }
    procedure ExecSelectedFile;
      {Attempts to execute selected file. Directories open in Explorer and files
      are opened if the have an associated application.
      }
  public
    procedure Display(const FileList: TFileList);
      {Displays information about files in file list in list view.
        @param FileList [in] Object encapsulating file list.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, Clipbrd,
  // Project
  UMessageBox, UProcessUtils;


{$R *.dfm}


const
  // Index of images used in list view
  cDirImgIdx = 0;     // folder image
  cFileImgIdx = 1;    // file image


{ TFileListViewerFrame }

procedure TFileListViewerFrame.actCopyExecute(Sender: TObject);
  {Copies the names of the displayed files to the clipboard as text.
    @param Sender [in] Not used.
  }
var
  Items: TStringList; // list to store file names
  Idx: Integer;       // loops through all list view items
begin
  Items := TStringList.Create;
  try
    // Build list of files (file names are stored in list view captions)
    for Idx := 0 to Pred(lvView.Items.Count) do
      Items.Add(lvView.Items[Idx].Caption);
    // Store list of files as CRLF separated file names on clipboard as text
    Clipboard.Open;
    try
      Clipboard.AsText := Items.Text;
    finally
      Clipboard.Close;
    end;
  finally
    FreeAndNil(Items);
  end;
end;

procedure TFileListViewerFrame.actCopyUpdate(Sender: TObject);
  {Enables / disables Copy action depending on if any files are displayed.
    @param Sender [in] Not used.
  }
begin
  actCopy.Enabled := lvView.Items.Count > 0;
end;

procedure TFileListViewerFrame.actExecExecute(Sender: TObject);
  {Attempts to execute the currently selected file.
    @param Sender [in] Not used.
  }
begin
  ExecSelectedFile;
end;

procedure TFileListViewerFrame.actExecUpdate(Sender: TObject);
  {Updates Execute action according to selection in list view.
    @param Sender [in] Not used.
  }
resourcestring
  sOpen = 'Open';         // caption used when file is selected
  sExplore = 'Explore';   // caption used when a directory is selected
var
  SelectedFile: TFileInfo;  // info about file related to selected list item
begin
  // We set caption (used in menu) depending on whether file or directory is
  // selected. If not item is selected the action is hidden.
  SelectedFile := GetSelectedFileInfo;
  if Assigned(SelectedFile) then
  begin
    actExec.Visible := True;
    if SelectedFile.IsDirectory then
      actExec.Caption := sExplore
    else
      actExec.Caption := sOpen;
  end
  else
    actExec.Visible := False;
end;

procedure TFileListViewerFrame.Display(const FileList: TFileList);
  {Displays information about files in file list in list view.
    @param FileList [in] Object encapsulating file list.
  }

  procedure AddItem(const FileInfo: TFileInfo);
    {Adds information about a file to the list view.
      @param FileInfo [in] Info about file to add to list.
    }
  var
    LI: TListItem;  // new list item
  begin
    LI := lvView.Items.Add;
    // place file name in caption
    LI.Caption := FileInfo.Name;
    if FileInfo.IsDirectory then
      // a directory: use folder glyph and add no other info
      LI.ImageIndex := cDirImgIdx
    else
    begin
      // a file: use file glyph and add modification date and attributes
      LI.SubItems.Add(DateTimeToStr(FileInfo.Modified));
      LI.SubItems.Add(FileInfo.AttrsAsString);
      LI.ImageIndex := cFileImgIdx;
    end;
    // store a new copy of file info object in list item: new copy needed since
    // file list (and its file info items) may be deleted after this method
    // returns
    LI.Data := TFileInfo.Create(FileInfo);
  end;

var
  Idx: Integer; // loops thru all files in list
begin
  lvView.Items.BeginUpdate;
  try
    // Clear any previous entries
    lvView.Clear;
    // Add directories first
    for Idx := 0 to Pred(FileList.DirectoryCount) do
      AddItem(FileList.Directories[Idx]);
    // Add files
    for Idx := 0 to Pred(FileList.FileCount) do
      AddItem(FileList.Files[Idx]);
  finally
    lvView.Items.EndUpdate;
  end;
end;

procedure TFileListViewerFrame.ExecSelectedFile;
  {Attempts to execute selected file. Directories open in Explorer and files are
  opened if the have an associated application.
  }
resourcestring
  // Error messages
  sCantExplore = 'Can''t explore this folder:'#10#10'%s';
  sCantOpen = 'Don''t know how to open this file:'#10#10'%s';
var
  FileInfo: TFileInfo;  // info about selected file
begin
  // Get info about file from selected list item
  FileInfo := GetSelectedFileInfo;
  if Assigned(FileInfo) then
  begin
    // We have a selected file
    if FileInfo.IsDirectory then
    begin
      if not ExploreFolder(FileInfo.Name) then
        TMessageBox.Error(Self, Format(sCantExplore, [FileInfo.Name]));
    end
    else
    begin
      if not OpenFile(FileInfo.Name) then
        TMessageBox.Error(Self, Format(sCantOpen, [FileInfo.Name]));
    end;
  end;
end;

function TFileListViewerFrame.GetSelectedFileInfo: TFileInfo;
  {Gets information about file associated with selected list item.
    @return File information or nil if no list item selected or no file
      associated with list item.
  }
begin
  if Assigned(lvView.Selected) and Assigned(lvView.Selected.Data) then
    Result := TFileInfo(lvView.Selected.Data)
  else
    Result := nil;
end;

procedure TFileListViewerFrame.lvViewDblClick(Sender: TObject);
  {Handles double clicks on a list item by attempting to execute file.
    @param Sender [in] Not used.
  }
begin
  ExecSelectedFile;
end;

procedure TFileListViewerFrame.lvViewDeletion(Sender: TObject;
  Item: TListItem);
  {Called when a list view item is being deleted. We delete the owned file info
  object associated with the list item.
    @param Sender [in] Not used.
    @param Item [in] List item being deleted.
  }
begin
  if Assigned(Item) and Assigned(Item.Data) then
    TFileInfo(Item.Data).Free;
end;

end.

