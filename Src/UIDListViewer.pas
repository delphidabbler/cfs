{
 * UIDListViewer.pas
 *
 * Implements viewer object for shell ID lists.
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
 * The Original Code is UIDListViewer.pas.
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


unit UIDListViewer;


interface


uses
  // Delphi
  Forms,
  // Project
  IntfViewers, UFileLists, UGlobalMemViewer;


type

  {
  TIDListViewer:
    Viewer for shell ID lists.
  }
  TIDListViewer = class(TGlobalMemViewer,
    IViewer
  )
  private
    fFileList: TFileList;
      {Stores list of files extracted from ID list}
  protected
    { IViewer }
    function SupportsFormat(const FmtID: Word): Boolean;
      {Checks whether viewer supports a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if format is supported, False if not.
      }
    function IsPrimaryViewer(const FmtID: Word): Boolean;
      {Checks if the viewer is the "primary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True. This is always a primary viewer.
      }
    function MenuText(const FmtID: Word): string;
      {Gets text to display in viewer menu.
        @param FmtID [in] ID of required clipboard format.
        @return Required menu text.
      }
    procedure RenderClipData(const FmtID: Word);
      {Reads data for a specified format from the clipboard and renders it into
      a format suitable for display.
        @param FmtID [in] ID of clipboard format to be rendered.
      }
    procedure ReleaseClipData;
      {Frees the data rendered when RenderClipData was last called.
      }
    procedure RenderView(const Frame: TFrame);
      {Displays the rendered clipboard data in viewer frame.
        @param Frame [in] Frame in which to display the data.
      }
    function UIFrameClass: TFrameClass;
      {Gets the class type of the viewer frame.
        @return Required frame class.
      }
  public
    destructor Destroy; override;
      {Class destructor. Ensures any remaining rendered data is released.
      }
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  FrFileListViewer, UClipFmt, UDataBuffer, UViewers;


{ TIDListViewer }

destructor TIDListViewer.Destroy;
  {Class destructor. Ensures any remaining rendered data is released.
  }
begin
  ReleaseClipData;
  inherited;
end;

function TIDListViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True. This is always a primary viewer.
  }
begin
  Result := True;
end;

function TIDListViewer.MenuText(const FmtID: Word): string;
  {Gets text to display in viewer menu.
    @param FmtID [in] ID of required clipboard format.
    @return Required menu text.
  }
resourcestring
  sMenuDesc = 'View ID List';   // always use this menu id
begin
  Result := sMenuDesc;
end;

procedure TIDListViewer.ReleaseClipData;
  {Frees the data rendered when RenderClipData was last called.
  }
begin
  FreeAndNil(fFileList);
end;

procedure TIDListViewer.RenderClipData(const FmtID: Word);
  {Reads data for a specified format from the clipboard and renders it into a
  format suitable for display.
    @param FmtID [in] ID of clipboard format to be rendered.
  }
var
  Data: IDataBuffer;                  // stores copy of clipboard data
  FileProvider: TIDFileListProvider;  // gets files from IDList array
begin
  ReleaseClipData;                      // clear any existing data
  Data := CopyClipboardMemData(FmtID);  // get copy of clipboard data
  try
    // populate a TFileList with files from IDList array
    FileProvider := TIDFileListProvider.Create(Data.Lock);
    try
      fFileList := TFileList.Create(FileProvider);
    finally
      FreeAndNil(FileProvider);
    end;
  finally
    Data.Unlock;
  end;
end;

procedure TIDListViewer.RenderView(const Frame: TFrame);
  {Displays the rendered clipboard data in viewer frame.
    @param Frame [in] Frame in which to display the data.
  }
begin
  // frame uses file list to create its display
  (Frame as TFileListViewerFrame).Display(fFileList);
end;

function TIDListViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  Result := FmtID = CF_IDLIST;
end;

function TIDListViewer.UIFrameClass: TFrameClass;
  {Gets the class type of the viewer frame.
    @return Required frame class.
  }
begin
  Result := TFileListViewerFrame;
end;


initialization

// Register viewer
ViewerRegistrar.RegisterViewer(TIDListViewer.Create);

end.

