{
 * UFileLists.pas
 *
 * Implements classes that encapsulates lists of files and that provide
 * information about a file. Also implements classes that can populate a file
 * list object from both HDROP handles and Shell ID List arrays.
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
 * The Original Code is UFileLists.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2008-2011 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): None
 *
 * ***** END LICENSE BLOCK *****
}


unit UFileLists;


interface


uses
  // Delphi
  Classes, ShlObj;


type
  {
  TFileInfo:
    Class that encapsulates information about a file.
  }
  TFileInfo = class(TObject)
  private
    fAttrs: Integer;
      {Value of Attrs property}
    fName: string;
      {Value of Name property}
    fModified: TDateTime;
      {Value of Modified property}
  public
    constructor Create(const FileName: string); overload;
      {Class constructor. Creates an info object for a file.
        @param FileName [in] Name of file.
      }
    constructor Create(const FileInfo: TFileInfo); overload;
      {Class constructor. Creates a copy of another file info object.
        @param FileInfo [in] File info object to be copied.
      }
    function IsDirectory: Boolean;
      {Checks if file is a directory.
        @return True if file is a directory, false if not (is ordinary file).
      }
    function AttrsAsString: string;
      {String representation of file's attributes.
        @return Required string representation.
      }
    property Attrs: Integer read fAttrs;
      {File's attributes. Not valid for directories}
    property Modified: TDateTime read fModified;
      {Data file was last modified. Not valid for directories}
    property Name: string read fName;
      {Name of file or directory}
  end;

  {
  TFileListAdd:
    Type of method passed to TFileListProvider object that the object uses to
    add a file to an external object.
      @param FileName [in] Name of file to be added to list.
  }
  TFileListAdd = procedure(const FileName: string) of object;

  {
  TFileListProvider:
    Abstract base class of objects that can provide a list of files to a
    TFileList object. A TFileListProvider object is passed TFileList's
    constructor which in turn calls the provider's BuildList method.
  }
  TFileListProvider = class(TObject)
  public
    procedure BuildList(const AddProc: TFileListAdd); virtual; abstract;
      {Builds a list of files and adds the list items to an external object.
        @param AddProc [in] Method to call to add each file in list to another
          object.
      }
  end;

  {
  TFileList:
    Base class that encapsulates a list of files and directories. Gets its list
    of files from a file provider object passed to constructor.
  }
  TFileList = class(TObject)
  private
    fFiles: TStringList;
      {List of normal files}
    fDirs: TStringList;
      {List of directories}
    procedure ClearList(const List: TStringList);
      {Clears a file or directory list and frees contained file info objects.
        @param List [in] List to be cleared.
      }
    function GetFileCount: Integer;
      {Read accessor for FileCount property.
        @return Number of files in files list.
      }
    function GetFile(Idx: Integer): TFileInfo;
      {Read accessor for Files[] property.
        @return Reference to indexed file info object.
      }
    function GetDirectoryCount: Integer;
      {Read accessor for DirectoryCount property.
        @return Numnber of directories in directories list.
      }
    function GetDirectory(Idx: Integer): TFileInfo;
      {Read accessor for Directories[] property.
        @return Reference to indexed file info object.
      }
  protected
    procedure AddFile(const Name: string);
      {Adds a named file to either the files or directories list.
        @param Name [in] Name of file to be added.
      }
  public
    constructor Create(const Provider: TFileListProvider);
      {Class constructor. Sets up object and populates the file lists using a
      provided list provider object.
        @param Provider [in] Object used to populate list.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object.
      }
    property FileCount: Integer read GetFileCount;
      {Number of files in Files[] property list}
    property Files[Idx: Integer]: TFileInfo read GetFile;
      {List of files}
    property DirectoryCount: Integer read GetDirectoryCount;
      {Number of directories in Directories[] list}
    property Directories[Idx: Integer]: TFileInfo read GetDirectory;
      {List of directories}
  end;

  {
  TDropFileListProvider:
    Class that can access a list of files referenced by a HDROP handle and adds
    the files to an external object using a provided method.
  }
  TDropFileListProvider = class(TFileListProvider)
  private
    fHDrop: THandle;
      {Handle of list of files}
  public
    procedure BuildList(const AddProc: TFileListAdd); override;
      {Extracts list of files from HDROP handle and adds to external object.
        @param AddProc [in] Method to call to add file to object.
      }
    constructor Create(const HDrop: THandle);
      {Class constructor. Sets up object to work with a HDROP handle.
        @param HDrop [in] HDROP handle that provides access to list of files.
      }
  end;

  {
  TIDFileListProvider:
    Class that can access a list of files referenced by a Shell IDList Array
    structure and adds the files to an external object using a provided method.
  }
  TIDFileListProvider = class(TFileListProvider)
  private
    fIDA: PIDA;
      {References Shell ID List array that provides list of files}
  public
    procedure BuildList(const AddProc: TFileListAdd); override;
      {Extracts list of files from Shell IDList array and adds to external
      object.
        @param AddProc [in] Method to call to add file to object.
      }
    constructor Create(const IDA: PIDA);
      {Class constructor. Sets up object to work with a Shell IDList Array.
        @param IDA [in] Pointer to structure that provides access IDList array.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, Windows, ShellAPI,
  // 3rd Party
  IDLUtils,
  // Project
  UUtils;


{ TFileList }

procedure TFileList.AddFile(const Name: string);
  {Adds a named file to either the files or directories list.
    @param Name [in] Name of file to be added.
  }
var
  FileInfo: TFileInfo;  // file info object for file
begin
  FileInfo := TFileInfo.Create(Name);
  if FileInfo.IsDirectory then
    fDirs.AddObject(Name, FileInfo)
  else
    fFiles.AddObject(Name, FileInfo);
end;

procedure TFileList.ClearList(const List: TStringList);
  {Clears a file or directory list and frees contained file info objects.
    @param List [in] List to be cleared.
  }
var
  Idx: Integer; // loops through all items in list
begin
  for Idx := Pred(List.Count) downto 0 do
    List.Objects[Idx].Free;
  List.Clear;
end;

constructor TFileList.Create(const Provider: TFileListProvider);
  {Class constructor. Sets up object and populates the file lists using a
  provided list provider object.
    @param Provider [in] Object used to populate list.
  }
begin
  // Create lists
  fFiles := TStringList.Create;
  fDirs := TStringList.Create;
  // Get provider to populate list
  Provider.BuildList(AddFile);
  // Sort the list
  fFiles.Sorted := True;
  fDirs.Sorted := True;
end;

destructor TFileList.Destroy;
  {Class destructor. Tears down object.
  }
begin
  ClearList(fDirs);
  FreeAndNil(fDirs);
  ClearList(fFiles);
  FreeAndNil(fFiles);
  inherited;
end;

function TFileList.GetDirectory(Idx: Integer): TFileInfo;
  {Read accessor for Directories[] property.
    @return Reference to indexed file info object.
  }
begin
  Result := fDirs.Objects[Idx] as TFileInfo;
end;

function TFileList.GetDirectoryCount: Integer;
  {Read accessor for DirectoryCount property.
    @return Numnber of directories in directories list.
  }
begin
  Result := fDirs.Count;
end;

function TFileList.GetFile(Idx: Integer): TFileInfo;
  {Read accessor for Files[] property.
    @return Reference to indexed file info object.
  }
begin
  Result := fFiles.Objects[Idx] as TFileInfo;
end;

function TFileList.GetFileCount: Integer;
  {Read accessor for FileCount property.
    @return Number of files in files list.
  }
begin
  Result := fFiles.Count;
end;

{ TFileInfo }

function TFileInfo.AttrsAsString: string;
  {String representation of file's attributes.
    @return Required string representation.
  }
begin
  if IsDirectory then
    Result := ''
  else
    Result := UUtils.AttrsToStr(fAttrs);
end;

constructor TFileInfo.Create(const FileName: string);
  {Class constructor. Creates an info object for a file.
    @param FileName [in] Name of file.
  }
begin
  inherited Create;
  fName := FileName;
  fAttrs := FileGetAttr(FileName);
  if not IsDirectory then
    fModified := FileDateToDateTime(UUtils.FileAge(FileName))
  else
    fModified := 0.0;
end;

constructor TFileInfo.Create(const FileInfo: TFileInfo);
  {Class constructor. Creates a copy of another file info object.
    @param FileInfo [in] File info object to be copied.
  }
begin
  inherited Create;
  fName := FileInfo.fName;
  fAttrs := FileInfo.fAttrs;
  fModified := FileInfo.fModified;
end;

function TFileInfo.IsDirectory: Boolean;
  {Checks if file is a directory.
    @return True if file is a directory, false if not (is ordinary file).
  }
begin
  Result := (fAttrs and faDirectory) <> 0;
end;

{ TDropFileListProvider }

procedure TDropFileListProvider.BuildList(const AddProc: TFileListAdd);
  {Extracts list of files from HDROP handle and adds to external object.
    @param AddProc [in] Method to call to add file to object.
  }
var
  FileCount: Integer;   // number of referenced files
  Idx: Integer;         // loops thru list of files
  NameLen: Integer;     // length of a file name
  FileName: string;     // a file name
begin
  if fHDrop = 0 then
    Exit;
  // Scan through files specified by HDROP handle, adding to lists
  FileCount := DragQueryFile(fHDrop, Cardinal(-1), nil, 0);
  try
    for Idx := 0 to Pred(FileCount) do
    begin
      NameLen := DragQueryFile(fHDrop, Idx, nil, 0);
      SetLength(FileName, NameLen);
      DragQueryFile(fHDrop, Idx, PChar(FileName), NameLen + 1);
      AddProc(FileName);
    end;
  finally
    DragFinish(fHDrop);
  end;
end;

constructor TDropFileListProvider.Create(const HDrop: THandle);
  {Class constructor. Sets up object to work with a HDROP handle.
    @param HDrop [in] HDROP handle that provides access to list of files.
  }
begin
  inherited Create;
  fHDrop := HDrop;  // store handle for use by BuildList
end;

{ TIDFileListProvider }

{
  About the "Shell IDList Array" format from WinHelp:
    The global memory object contains an array of item identifier lists.
    The memory object consists of a CIDA structure that contains offsets to any
    number of item identifier lists (ITEMIDLIST structures). The first structure
    in the array corresponds to a folder, and subsequent structures correspond
    to file objects within the folder.

  This class takes a pointer to the CIDA structure and parses the files from it.
}

procedure TIDFileListProvider.BuildList(const AddProc: TFileListAdd);
  {Extracts list of files from Shell IDList array and adds to external
  object.
    @param AddProc [in] Method to call to add file to object.
  }

  // ---------------------------------------------------------------------------
  procedure AddNameFromPIDL(const Root, Relative: PItemIDList);
    {Adds file name to list specified by a pidl.
      @param Root [in] PIDL to root folder (may be nil if Relative fully
        specifies a file name.
      @param Relative [in] PIDL of file relative to Root.
    }
  var
    FileName: string;         // fully specified name of file
    SHFileInfo: TSHFileInfo;  // structure used to get file name from PIDL
    PIDL: PItemIDList;        // fully specifies file name
  begin
    // Append Relative pidl to Root pidl to get fully specified file path
    PIDL := ConcatPIDLs(Root, Relative);
    if Assigned(PIDL) then
    begin
      // Get file name
      SetLength(FileName, MAX_PATH);
      // we first try to get path from ID list: fails if pidl specifies virtual
      // file or folder that is not part of file system
      if SHGetPathFromIDList (PIDL, PChar(FileName)) then
        SetLength(FileName, StrLen(PChar(FileName))) // fixes length of FileName
      else
      begin
        // if first attempt fails we try an alternative and get the display name
        // of the PIDL
        SHGetFileInfo(
          PChar(PIDL),
          0,
          SHFileInfo,
          SizeOf(TSHFileInfo),
          SHGFI_PIDL or SHGFI_DISPLAYNAME
        );
        FileName := SHFileInfo.szDisplayName
      end;
      // Add file to lists
      AddProc(FileName);
      // Free the pidl
      IDLUtils.ShellMalloc.Free(PIDL);
    end
  end;
  // ---------------------------------------------------------------------------

var
  PIDL: PItemIDList;  // pointer to ID list of top level folder
  I: Integer;         // loops through list of files following top level folder
begin
  // NOTE: This method, including AddNameFromPIDL, is adapted from on code by
  // Grahame Marsh accompanying an article on OLE drag and drop from UNDU.

  // Get top level folder
  PIDL := PItemIDList(UINT(fIDA) + fIDA^.aoffset[0]);
  AddNameFromPIDL(nil, PIDL);   // PIDL fully specifies folder
  // Get folder contents:
  // pidls for each file stored at offsets after structure. Each pidl is
  // relative and therefore need appending to top level folder's PIDL to get
  // full file spec.
  for I := 1 to fIDA^.cidl do
    AddNameFromPIDL(PIDL, PItemIDList(UINT(fIDA) + fIDA^.aoffset[I]));
end;

constructor TIDFileListProvider.Create(const IDA: PIDA);
  {Class constructor. Sets up object to work with a Shell IDList Array.
    @param IDA [in] Pointer to structure that provides access IDList array.
  }
begin
  inherited Create;
  fIDA := IDA;
end;

end.

