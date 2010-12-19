{
 * UDataBuffer.pas
 *
 * Implements data buffer in global memory that makes a copy of a supplied
 * buffer and maintains locks on the data. Also provides a TStream interface to
 * the buffer.
 *
 * v1.0 of 09 Mar 2008  - Original version.
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
 * The Original Code is UDataBuffer.pas
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


unit UDataBuffer;


interface


uses
  // Delphi
  Classes;

type

  {
  IDataBuffer:
    Interface to object that wraps a data buffer in global memory.
  }
  IDataBuffer = interface(IInterface)
    ['{EA13A024-1CAB-42EE-88D5-3CC42FE3415B}']
    function GetSize: Integer;
      {Gets size of data in buffer.
        @return Required size in bytes.
      }
    function GetHandle: THandle;
      {Provides access to data's global memory handle.
        @return Required handle.
      }
    function IsValid: Boolean;
      {Checks if object contains valid data.
        @return True if data valid, false otherwise.
      }
    function Lock: Pointer;
      {Locks the buffer handle and provides a pointer to the data. Unlock should
      be used to release the lock.
        @return Pointer to data.
      }
    procedure Unlock;
      {Unlocks the data buffer. Calls should match those to Lock.
      }
    property Size: Integer read GetSize;
      {Size of the data buffer}
    property Handle: THandle read GetHandle;
      {Global memory handle of buffer}
  end;

  {
  TDataBuffer:
    Implements data buffer in global memory. The buffer is a copy of the data
    passed in the constructor. Maintains a count of locks placed on the data
    and ensures all locks are freed before deletion.
  }
  TDataBuffer = class(TInterfacedObject,
    IDataBuffer
  )
  private
    fSize: Integer;
      {Size of data buffer}
    fHandle: THandle;
      {Handle to data buffer}
    fLockCount: Integer;
      {Count of number of locks on data currently in force}
  protected
    { IDataBuffer methods }
    function GetSize: Integer;
      {Gets size of data in buffer.
        @return Required size in bytes.
      }
    function GetHandle: THandle;
      {Provides access to data's global memory handle.
        @return Required handle.
      }
    function IsValid: Boolean;
      {Checks if object contains valid data.
        @return True if data valid, false otherwise.
      }
    function Lock: Pointer;
      {Locks the buffer handle and provides a pointer to the data. Unlock should
      be used to release the lock.
        @return Pointer to data.
      }
    procedure Unlock;
      {Unlocks the data buffer. Calls should match those to Lock.
      }
  public
    constructor Create(const Data: Pointer; const Size: Integer);
      {Class constructor. Create instance containing a copy of provided data.
        @param Data [in] Pointer to data to be copied stored to buffer.
        @param Size [in] Size of data.
      }
    destructor Destroy; override;
      {Class destructor. Clears any remaining locks before releasing the memory.
      }
    class function NulInstance: IDataBuffer;
      {Creates a new nul object. This is an empty data buffer that is invalid.
        @return Reference to new nul object.
      }
  end;

  {
  TDataBufferStream:
    Provides a read-only TStream interface to an IDataBuffer instance. The
    IDataBuffer object must remain valid throughout the life of this stream
    since the stream does not copy the memory. For this reason TDataBufferStream
    keeps hold of the IDataBuffer object until TDataBufferStream is freed. An
    exception is raised if an attempt is made to write to the stream.
  }
  TDataBufferStream = class(TCustomMemoryStream)
  private
    fData: IDataBuffer;
      {Reference to data buffer object}
  public
    constructor Create(const Data: IDataBuffer);
      {Class constructor. Creates a read only TStream instance that reads data from
      a provided buffer. The buffer it *not* copied and should remain valid for the
      life of this stream.
        @param Data [in] Reference to data object to be accessed.
      }
    destructor Destroy; override;
      {Class destructor. Unlocks the data buffer.
      }
    function Write(const Buffer; Count: Longint): Longint; override;
      {Prevents writing to this read only stream.
        @param Buffer [in] Reference to data to be written. Ignored.
        @param Count [in] Size of data to be written. Ignored.
        @except EStreamError raised on every call.
      }
  end;


implementation


uses
  // Delphi
  Windows;


{ TDataBuffer }

constructor TDataBuffer.Create(const Data: Pointer; const Size: Integer);
  {Class constructor. Create instance containing a copy of provided data.
    @param Data [in] Pointer to data to be copied stored to buffer.
    @param Size [in] Size of data.
  }
var
  MemPtr: Pointer;  // pointer to new memory
begin
  inherited Create;
  fHandle := 0;   // indicates invalid data
  // Check we have valid data of non-zero length
  if (Size > 0) and Assigned(Data) then
  begin
    // Allocate new memory and copy data to it
    fHandle := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, Size);
    if fHandle > 0 then
    begin
      MemPtr := GlobalLock(fHandle);
      if MemPtr <> nil then
      begin
        Move(Data^, MemPtr^, Size);
        GlobalUnlock(fHandle);
      end;
    end;
  end;
  fSize := Size;
  fLockCount := 0;
end;

destructor TDataBuffer.Destroy;
  {Class destructor. Clears any remaining locks before releasing the memory.
  }
begin
  while fLockCount > 0 do
    Unlock;
  GlobalFree(fHandle);
  inherited;
end;

function TDataBuffer.GetHandle: THandle;
  {Provides access to data's global memory handle.
    @return Required handle.
  }
begin
  Result := fHandle;
end;

function TDataBuffer.GetSize: Integer;
  {Gets size of data in buffer.
    @return Required size in bytes.
  }
begin
  Result := fSize;
end;

function TDataBuffer.IsValid: Boolean;
  {Checks if object contains valid data.
    @return True if data valid, false otherwise.
  }
begin
  Result := fHandle > 0;
end;

function TDataBuffer.Lock: Pointer;
  {Locks the buffer handle and provides a pointer to the data. Unlock should be
  used to release the lock.
    @return Pointer to data.
  }
begin
  Result := GlobalLock(fHandle);
  Inc(fLockCount);
end;

class function TDataBuffer.NulInstance: IDataBuffer;
  {Creates a new nul object. This is an empty data buffer that is invalid.
    @return Reference to new nul object.
  }
begin
  Result := TDataBuffer.Create(nil, 0);
end;

procedure TDataBuffer.Unlock;
  {Unlocks the data buffer. Calls should match those to Lock.
  }
begin
  if fLockCount > 0 then
  begin
    GlobalUnlock(fHandle);
    Dec(fLockCount);
  end;
end;

{ TDataBufferStream }

constructor TDataBufferStream.Create(const Data: IDataBuffer);
  {Class constructor. Creates a read only TStream instance that reads data from
  a provided buffer. A reference to the buffer is maintained throught the life
  of the stream. The buffer is *not* copied.
    @param Data [in] Reference to data object to be accessed.
  }
begin
  inherited Create;
  fData := Data;
  SetPointer(fData.Lock, fData.Size);
end;

destructor TDataBufferStream.Destroy;
  {Class destructor. Unlocks the data buffer.
  }
begin
  fData.Unlock;
  inherited;
end;

function TDataBufferStream.Write(const Buffer; Count: Integer): Longint;
  {Prevents writing to this read only stream.
    @param Buffer [in] Reference to data to be written. Ignored.
    @param Count [in] Size of data to be written. Ignored.
    @except EStreamError raised on every call.
  }
resourcestring
  sCantWrite = 'Can''t write to TMemoryStreamEx'; // error message
begin
  raise EStreamError.Create(sCantWrite);
end;

end.

