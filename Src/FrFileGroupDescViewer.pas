{
 * FrFileGroupDescViewer.pas
 *
 * Implements a viewer frame that displays information about all file
 * descriptors contained in a file group descriptor
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
 * The Original Code is FrFileGroupDescViewer.pas.
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


unit FrFileGroupDescViewer;


interface


uses
  // Delphi
  Forms, Classes, ActnList, Menus, Controls, ComCtrls,
  // Project
  UFileGroupDescAdapter;


type

  {
  TFileGroupDescViewerFrame:
    Viewer frame that displays information about all file descriptors contained
    in a file group descriptor in a tree view. Supports copying names of all
    files in file group to clipboard as text.
  }
  TFileGroupDescViewerFrame = class(TFrame)
    tvView: TTreeView;
    mnuView: TPopupMenu;
    miCopy: TMenuItem;
    alView: TActionList;
    actCopy: TAction;
    procedure actCopyExecute(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
  public
    procedure Display(const fGroupDesc: TFileGroupDescAdapter);
      {Displays information about a file group descriptor's contained file
      descriptors in frame.
        @param fGroupDesc [in] Object containing information about the file
          group descriptor.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, Clipbrd;


{$R *.dfm}


{ TFileGroupDescViewerFrame }

procedure TFileGroupDescViewerFrame.actCopyExecute(Sender: TObject);
  {Copies list of file names from file descriptors to clipboard.
    @param Sender [in] Not used.
  }
var
  Items: TStringList;   // used to store list of file names
  Node: TTreeNode;      // references top level tree nodes (contain file names)
begin
  Items := TStringList.Create;
  try
    // Loops through all top level tree nodes
    Node := tvView.Items.GetFirstNode;
    while Assigned(Node) do
    begin
      Items.Add(Node.Text); // add file name contained in node to list
      Node := Node.GetNextSibling;
    end;
    // Copy all file names, separated by CRLF, to clipboard as text
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

procedure TFileGroupDescViewerFrame.actCopyUpdate(Sender: TObject);
  {Enables copy action if file group descriptor contains one or more file
  descriptors.
    @param Sender [in] Not used.
  }
begin
  actCopy.Enabled := tvView.Items.Count > 0;
end;

procedure TFileGroupDescViewerFrame.Display(
  const fGroupDesc: TFileGroupDescAdapter);
  {Displays information about a file group descriptor's contained file
  descriptors in frame.
    @param fGroupDesc [in] Object containing information about the file group
      descriptor.
  }
resourcestring
  // Display text
  sCLSID = 'CLSID: %s';
  sIconSize = 'Icon size: %d, %d';
  sCoords = 'Screen co-ords: %d, %d';
  sAttrs = 'Attributes: %s';
  sCreation = 'Creation date: %s';
  sLastAccess = 'Last access date: %s';
  sLastWrite = 'Last write date: %s';
  sFileSize = 'File size: %d bytes';
var
  Idx: Integer;               // loops thru file descriptors
  Node: TTreeNode;            // references a tree node
  FileDesc: TFileDescAdapter; // reference to a contained file descriptor
begin
  tvView.Items.BeginUpdate;
  try
    tvView.Items.Clear;
    // loop thru all file descriptors
    for Idx := 0 to Pred(fGroupDesc.FileDescCount) do
    begin
      // get descriptor and add node for it
      FileDesc := fGroupDesc.FileDescs[Idx];
      Node := tvView.Items.AddChild(nil, FileDesc.FileName);
      // add child nodes for each valid field
      if FileDesc.HaveCLSID then
        tvView.Items.AddChild(
          Node, Format(sCLSID, [GUIDToString(FileDesc.CLSID)])
        );
      if FileDesc.HaveIconInfo then
      begin
        tvView.Items.AddChild(
          Node, Format(sIconSize, [FileDesc.IconSize.cx, FileDesc.IconSize.cy])
        );
        tvView.Items.AddChild(
          Node, Format(sCoords, [FileDesc.Coords.X, FileDesc.Coords.Y])
        );
      end;
      if FileDesc.HaveAttrs then
        tvView.Items.AddChild(
          Node, Format(sAttrs, [FileDesc.AttrsAsString])
        );
      if FileDesc.HaveCreateTime then
        tvView.Items.AddChild(
          Node, Format(sCreation, [DateTimeToStr(FileDesc.CreateTime)])
        );
      if FileDesc.HaveLastAccessTime then
        tvView.Items.AddChild(
          Node, Format(sLastAccess, [DateTimeToStr(FileDesc.LastAccessTime)])
        );
      if FileDesc.HaveLastWriteTime then
        tvView.Items.AddChild(
          Node, Format(sLastWrite, [DateTimeToStr(FileDesc.LastWriteTime)])
        );
      if FileDesc.HaveFileSize then
        tvView.Items.AddChild(
          Node, Format(sFileSize, [FileDesc.FileSize])
        );
    end;
    tvView.FullExpand;
  finally
    tvView.Items.EndUpdate;
  end;
end;

end.

