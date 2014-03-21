{
 * UHDROPViewer.pas
 *
 * Implements a viewer for the HDROP clipboard format.
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
 * The Original Code is UHDROPViewer.pas.
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


unit UHDROPViewer;


interface


uses
  // Delphi
  Forms,
  // Project
  IntfViewers, UFileLists, UGlobalMemViewer;


type

  {
  THDROPViewer:
    Viewer for the HDROP clipboard format.
  }
  THDROPViewer = class(TGlobalMemViewer,
    IViewer
  )
  private
    fFileList: TFileList;
      {Stores list of files extracted from HDROP handle}
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


{ THDROPViewer }

destructor THDROPViewer.Destroy;
  {Class destructor. Ensures any remaining rendered data is released.
  }
begin
  ReleaseClipData;  // in case user forgets to call
  inherited;
end;

function THDROPViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True. This is always a primary viewer.
  }
begin
  Result := True;
end;

function THDROPViewer.MenuText(const FmtID: Word): string;
  {Gets text to display in viewer menu.
    @param FmtID [in] ID of required clipboard format.
    @return Required menu text.
  }
resourcestring
  sMenuText = 'View Files'; // always use this menu text
begin
  Result := sMenuText;
end;

procedure THDROPViewer.ReleaseClipData;
  {Frees the data rendered when RenderClipData was last called.
  }
begin
  FreeAndNil(fFileList);
end;

procedure THDROPViewer.RenderClipData(const FmtID: Word);
  {Reads data for a specified format from the clipboard and renders it into
  a format suitable for display.
    @param FmtID [in] ID of clipboard format to be rendered.
  }
var
  Data: IDataBuffer;                    // buffer storing copy of clipboard data
  FileProvider: TDropFileListProvider;  // object that gets files from HDROP
begin
  ReleaseClipData;                      // clear any existing data
  Data := CopyClipboardMemData(FmtID);  // get copy of clipboard data
  // populate a TFileList with files from HDROP handle
  FileProvider := TDropFileListProvider.Create(Data.Handle);
  try
    fFileList := TFileList.Create(FileProvider);
  finally
    FreeAndNil(FileProvider);
  end;
end;

procedure THDROPViewer.RenderView(const Frame: TFrame);
  {Displays the rendered clipboard data in viewer frame.
    @param Frame [in] Frame in which to display the data.
  }
begin
  // pass the file list to the frame
  (Frame as TFileListViewerFrame).Display(fFileList);
end;

function THDROPViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  Result := FmtID = CF_HDROP;
end;

function THDROPViewer.UIFrameClass: TFrameClass;
  {Gets the class type of the viewer frame.
    @return Required frame class.
  }
begin
  Result := TFileListViewerFrame;
end;


initialization

// Register viewer
ViewerRegistrar.RegisterViewer(THDROPViewer.Create);

end.

