{
 * UFileGroupDescAdapter.pas
 *
 * Implements classes that provide alternative interface to both ansi and
 * unicode versions of file group descriptors and contained file descriptors.
 *
 * v1.0 of 11 Mar 2008  - Original version.
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
 * The Original Code is UFileGroupDescAdapter.pas.
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


unit UFileGroupDescAdapter;


interface


uses
  // Delphi
  Contnrs, ShlObj, Windows;


type

  {
  TFileGroupDescAdapter:
    Class that provides an alternative interface to the contents of a file
    descriptor. Works with both ansi and wide versions of file descriptors.
  }
  TFileDescAdapter = class(TObject)
  private
    fFileName: string;
      {Name of file}
    fCLSID: TGUID;
      {File class identifier}
    fAttrs: DWORD;
      {File's attribute}
    fCoords: TPoint;
      {Screen co-ordinates of file}
    fIconSize: TSize;
      {File's icon size}
    fFileSize: Int64;
      {Size of file}
    fLastWriteTime: TDateTime;
      {Time of last access to file}
    fLastAccessTime: TDateTime;
      {Time file last accessed}
    fCreateTime: TDateTime;
      {Time file was created}
    fFlags: DWORD;
      {Flags indicating which other fields / properties are valid}
    function HaveFlag(const Flag: DWORD): Boolean;
      {Checks if a flag is included in fFlags.
        @param Flag [in] Flag to be tested.
        @return True if Flag is valid, False if not.
      }
    procedure ProcessHeader(const PHdr: Pointer);
      {Reads properties from portion of TFileGroupDescriptorA and
      TFileGroupDescriptorW that is common to each record.
        @param PHdr [in] Pointer to record to be processed.
      }
  public
    constructor Create(const FD: TFileDescriptorA); overload;
      {Class constructor. Constructs an adapter object for an ansi file
      descriptor.
        @param FGD [in] Ansi version of a file group descriptor.
      }
    constructor Create(const FD: TFileDescriptorW); overload;
      {Class constructor. Constructs an adapter object for an unicode file
      descriptor.
        @param FGD [in] Unicode version of a file group descriptor.
      }
    function HaveLastAccessTime: Boolean;
      {Checks if LastAccessTime property is valid.
        @return True if property is valid.
      }
    function HaveAttrs: Boolean;
      {Checks if Attrs property is valid.
        @return True if property is valid.
      }
    function HaveCLSID: Boolean;
      {Checks if CLSID property is valid.
        @return True if property is valid.
      }
    function HaveCreateTime: Boolean;
      {Checks if CreateTime property is valid.
        @return True if property is valid.
      }
    function HaveFileSize: Boolean;
      {Checks if FileSize property is valid.
        @return True if property is valid.
      }
    function HaveIconInfo: Boolean;
      {Checks if Coords and IconSize properties are valid.
        @return True if property is valid.
      }
    function HaveLastWriteTime: Boolean;
      {Checks if LastWriteTime property is valid.
        @return True if property is valid.
      }
    function AttrsAsString: string;
      {Gets file attributes as a string.
        @return String representation of file attributes or '' if Attrs property
          is not valid.
      }
    property FileName: string read fFileName;
      {Name of file. Undefined if HaveFileName returns false}
    property CLSID: TGUID read fCLSID;
      {File class identifier. Undefined if HaveCLSID returns false}
    property IconSize: TSize read fIconSize;
      {File's icon size. Undefined if HaveIconInfo returns false}
    property Coords: TPoint read fCoords;
      {Screen co-ordinates of file. Undefined if HaveIconInfo returns false}
    property Attrs: DWORD read fAttrs;
      {Attributes of file. Undefined if HaveAttrs returns false}
    property CreateTime: TDateTime read fCreateTime;
      {Time file was created. Undefined if HaveCreateTime returns false}
    property LastAccessTime: TDateTime read fLastAccessTime;
      {Time file last accessed. Undefined if HaveAccessTime returns false}
    property LastWriteTime: TDateTime read fLastWriteTime;
      {Time of last access to file. Undefined if HaveLastWriteTime returns
      false}
    property FileSize: Int64 read fFileSize;
      {Size of file. Undefined if HaveFileSize returns false}
  end;

  {
  TFileGroupDescAdapter:
    Class that provides an alternative interface to the contents of a file
    group descriptor. Works with both ansi and wide versions of group file
    descriptors.
  }
  TFileGroupDescAdapter = class(TObject)
  private
    fFileDescs: TObjectList;
      {Stores list of file descriptor objects}
    procedure Initialize;
      {Initialises object: does processing common to both constructors.
      }
    function GetFileDesc(Idx: Integer): TFileDescAdapter;
      {Gets a file descriptor object from list.
        @param Idx [in] Index of required file descriptor.
        @return Reference to file descriptor adpater object.
      }
    function GetFileDescCount: Integer;
      {Gets number of file descriptors in group.
        @return Count of file descriptors.
      }
  public
    constructor Create(const FGD: TFileGroupDescriptorA); overload;
      {Class constructor. Constructs an adapter object for an ansi file group
      descriptor.
        @param FGD [in] Ansi version of a file group descriptor.
      }
    constructor Create(const FGD: TFileGroupDescriptorW); overload;
      {Class constructor. Constructs an adapter object for an unicode file group
      descriptor.
        @param FGD [in] Unicode version of a file group descriptor.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object.
      }
    property FileDescs[Idx: Integer]: TFileDescAdapter read GetFileDesc;
      {Provides access to list of contained file descriptors}
    property FileDescCount: Integer read GetFileDescCount;
      {Number of contained file descriptors}
  end;


implementation


uses
  // Delphi
  SysUtils, ActiveX,
  // Project
  UUtils;


type
  {
  TFileDescriptorHeader, PFileDescriptorHeader:
    Record and associated pointer that maps onto common fields of
    TFileGroupDescriptorA and TFileGroupDescriptorW. We casts these records to
    this type to standardise code that accesses these records.
  }
  TFileDescriptorHeader = record
    dwFlags: DWORD;               // flags indicating which fields are valid
    clsid: TCLSID;                // file class identifier
    sizel: TSize;                 // width and height of file icon
    pointl: TPoint;               // screen co-ords of file object
    dwFileAttributes: DWORD;      // attributes of file
    ftCreationTime: TFileTime;    // time file was created
    ftLastAccessTime: TFileTime;  // time file last accessed
    ftLastWriteTime: TFileTime;   // time file last written to
    nFileSizeHigh: DWORD;         // high word of file size
    nFileSizeLow: DWORD;          // low word of file size
  end;
  PFileDescriptorHeader = ^TFileDescriptorHeader;


{ TFileGroupDescAdapter }

constructor TFileGroupDescAdapter.Create(const FGD: TFileGroupDescriptorA);
  {Class constructor. Constructs an adapter object for an ansi file group
  descriptor.
    @param FGD [in] Ansi version of a file group descriptor.
  }
var
  Idx: Integer; // loops through all file descriptors in group
begin
  inherited Create;
  Initialize;   // sets up object list
  // create file descriptor object for each ansi file descriptor in group
  for Idx := 0 to Pred(FGD.cItems) do
    fFileDescs.Add(TFileDescAdapter.Create(FGD.fgd[Idx]));
end;

constructor TFileGroupDescAdapter.Create(const FGD: TFileGroupDescriptorW);
  {Class constructor. Constructs an adapter object for an unicode file group
  descriptor.
    @param FGD [in] Unicode version of a file group descriptor.
  }
var
  Idx: Integer; // loops through all file descriptors in group
begin
  inherited Create;
  Initialize;   // sets up object list
  // create file descriptor object for each unicode file descriptor in group
  for Idx := 0 to Pred(FGD.cItems) do
    fFileDescs.Add(TFileDescAdapter.Create(FGD.fgd[Idx]));
end;

destructor TFileGroupDescAdapter.Destroy;
  {Class destructor. Tears down object.
  }
begin
  FreeAndNil(fFileDescs); // frees contained objects
  inherited;
end;

function TFileGroupDescAdapter.GetFileDesc(Idx: Integer): TFileDescAdapter;
  {Gets a file descriptor object from list.
    @param Idx [in] Index of required file descriptor.
    @return Reference to file descriptor adpater object.
  }
begin
  Result := fFileDescs[Idx] as TFileDescAdapter;
end;

function TFileGroupDescAdapter.GetFileDescCount: Integer;
  {Gets number of file descriptors in group.
    @return Count of file descriptors.
  }
begin
  Result := fFileDescs.Count;
end;

procedure TFileGroupDescAdapter.Initialize;
  {Initialises object: does processing common to both constructors.
  }
begin
  fFileDescs := TObjectList.Create(True);
end;

{ TFileDescAdapter }

// NOTE: we don't implement FD_LINKUI flag of TFileGroupDescriptorA.dwFlags

function TFileDescAdapter.AttrsAsString: string;
  {Gets file attributes as a string.
    @return String representation of file attributes or '' if Attrs property
      is not valid.
  }
begin
  Result := UUtils.AttrsToStr(fAttrs);
end;

constructor TFileDescAdapter.Create(const FD: TFileDescriptorA);
  {Class constructor. Constructs an adapter object for an ansi file descriptor.
    @param FGD [in] Ansi version of a file group descriptor.
  }
var
  FDH: TFileDescriptorHeader;
begin
  inherited Create;
  fFileName := FD.cFileName;
  FDH := PFileDescriptorHeader(@FD)^;
  ProcessHeader(@FD);
end;

constructor TFileDescAdapter.Create(const FD: TFileDescriptorW);
  {Class constructor. Constructs an adapter object for an unicode file
  descriptor.
    @param FGD [in] Unicode version of a file group descriptor.
  }
var
  FDH: TFileDescriptorHeader;
begin
  inherited Create;
  fFileName := FD.cFileName;
  FDH := PFileDescriptorHeader(@FD)^;
  ProcessHeader(@FD);
end;

function TFileDescAdapter.HaveAttrs: Boolean;
  {Checks if Attrs property is valid.
    @return True if property is valid.
  }
begin
  Result := HaveFlag(FD_ATTRIBUTES);
end;

function TFileDescAdapter.HaveCLSID: Boolean;
  {Checks if CLSID property is valid.
    @return True if property is valid.
  }
begin
  Result := HaveFlag(FD_CLSID);
end;

function TFileDescAdapter.HaveCreateTime: Boolean;
  {Checks if CreateTime property is valid.
    @return True if property is valid.
  }
begin
  Result := HaveFlag(FD_CREATETIME);
end;

function TFileDescAdapter.HaveFileSize: Boolean;
  {Checks if FileSize property is valid.
    @return True if property is valid.
  }
begin
  Result := HaveFlag(FD_FILESIZE);
end;

function TFileDescAdapter.HaveFlag(const Flag: DWORD): Boolean;
  {Checks if a flag is included in fFlags.
    @param Flag [in] Flag to be tested.
    @return True if Flag is valid, False if not.
  }
begin
  Result := fFlags and Flag <> 0;
end;

function TFileDescAdapter.HaveIconInfo: Boolean;
  {Checks if Coords and IconSize properties are valid.
    @return True if property is valid.
  }
begin
  Result := HaveFlag(FD_SIZEPOINT);
end;

function TFileDescAdapter.HaveLastAccessTime: Boolean;
  {Checks if LastAccessTime property is valid.
    @return True if property is valid.
  }
begin
  Result := HaveFlag(FD_ACCESSTIME);
end;

function TFileDescAdapter.HaveLastWriteTime: Boolean;
  {Checks if LastWriteTime property is valid.
    @return True if property is valid.
  }
begin
  Result := HaveFlag(FD_WRITESTIME);
end;

procedure TFileDescAdapter.ProcessHeader(const PHdr: Pointer);
  {Reads properties from portion of TFileGroupDescriptorA and
  TFileGroupDescriptorW that is common to each record.
    @param PHdr [in] Pointer to record to be processed.
  }
var
  FDH: TFileDescriptorHeader; // record that maps onto start of PHdr^
  Size: Int64;                // used to store file size
begin
  // Map common fields of PHdr^ onto FDH
  FDH := PFileDescriptorHeader(PHdr)^;

  // Get property validity flags
  fFlags := FDH.dwFlags;

  // Get property values
  if HaveCLSID then
    fCLSID := FDH.clsid;
  if HaveIconInfo then
  begin
    fIconSize := FDH.sizel;
    fCoords := FDH.pointl;
  end;
  if HaveAttrs then
    fAttrs := FDH.dwFileAttributes;
  if HaveCreateTime then
    fCreateTime := WinFileTimeToDateTime(FDH.ftCreationTime);
  if HaveLastAccessTime then
    fLastAccessTime := WinFileTimeToDateTime(FDH.ftLastAccessTime);
  if HaveLastWriteTime then
    fLastWriteTime := WinFileTimeToDateTime(FDH.ftLastWriteTime);
  if HaveFileSize then
  begin
    Int64Rec(Size).Lo := FDH.nFileSizeLow;
    Int64Rec(Size).Hi := FDH.nFileSizeHigh;
    fFileSize := Size;
  end;
end;

end.

