{
 * USettings.pas
 *
 * Implements global singleton object used to provide access to persistent
 * storage where program preferences and persistent information are stored.
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
 * The Original Code is USettings.pas.
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


unit USettings;


interface


type

  {
  ISettingsSection:
    Interface supported by objects that can read and write data in a named
    section of settings persistent storage.
  }
  ISettingsSection = interface(IInterface)
    ['{917AA54B-8CDC-427F-A248-439BEE33C125}']
    function ReadBool(const Name: string; const Def: Boolean): Boolean;
      {Reads boolean value from section.
        @param Name [in] Name of value to read.
        @param Def [in] Default value to be used if value can't be read.
        @return Value associated with Name or Def if value can't be read.
      }
    procedure ReadBin(const Name: string; var Buf; const Size: Integer);
      {Reads binary data from section.
        @param Name [in] Name of value to be read.
        @param Buf [in/out] Default data passed in. Buffer set to read data if
          named value exists. Buf is not changed if value does not exist.
      }
    procedure WriteBool(const Name: string; const Value: Boolean);
      {Writes a boolean value to section.
        @param Name [in] Name of value to be written.
        @param Value [in] Value to be written.
      }
    procedure WriteBin(const Name: string; const Buf; const Size: Integer);
      {Writes binary data to section.
        @param Name [in] Name of value to be written.
        @param Buf [in] Buffer from which data to be written.
        @param Size [in] Size of data from buffer to write.
      }
  end;

  {
  ISettings:
    Interface to global settings object. Used to gain access to a named section.
  }
  ISettings = interface(IInterface)
    ['{7AC55C9D-BFDC-43EA-8E7B-F859FDE89B3D}']
    function OpenSection(const Name: string): ISettingsSection;
      {Opens a section of persistent storage for reading and writing.
        @param Name [in] Name of required section.
        @return Reference to requested section object.
      }
  end;


function Settings: ISettings;
  {Provides reference to global settings singleton object
    @return Reference to global object.
  }


implementation


uses
  // Delphi
  SysUtils, Registry,
  // Project
  UGlobals;


var
  // Internal reference to global settings object
  pvtSettings: ISettings = nil;


function Settings: ISettings;
  {Provides reference to global settings singleton object
    @return Reference to global object.
  }
begin
  Result := pvtSettings;
end;

type
  {
  TSettings:
    Class that enables setting data to be written to and read from persistent
    storage. This implementation uses the registry as storage.
  }
  TSettings = class(TInterfacedObject, ISettings)
  protected
    { ISettings }
    function OpenSection(const Name: string): ISettingsSection;
      {Opens a section of persistent storage for reading and writing. The
      section is a registry subkey.
        @param Name [in] Name of required section.
        @return Reference to requested section object.
      }
  end;

  {
  TSection:
    Class that provides read and write access to a section of the persistent
    "Settings" storage. This implementation uses the registry as storage.
  }
  TSection = class(TInterfacedObject, ISettingsSection)
  private
    fSubKey: string;
      {Subkey of registry that contains section's data}
    fRegistry: TRegistry;
      {Reference to registry object used to read and write data}
  protected
    { ISettingsSection }
    function ReadBool(const Name: string; const Def: Boolean): Boolean;
      {Reads boolean value from section's registry subkey.
        @param Name [in] Name of value to read.
        @param Def [in] Default value to be used if value can't be read.
        @return Value associated with Name or Def if value can't be read.
      }
    procedure ReadBin(const Name: string; var Buf; const Size: Integer);
      {Reads binary data from section's registry subkey.
        @param Name [in] Name of value to be read.
        @param Buf [in/out] Default data passed in. Buffer set to read data if
          named value exists. Buf is not changed if value does not exist.
      }
    procedure WriteBool(const Name: string; const Value: Boolean);
      {Writes a boolean value to section's regsitry subkey.
        @param Name [in] Name of value to be written.
        @param Value [in] Value to be written.
      }
    procedure WriteBin(const Name: string; const Buf; const Size: Integer);
      {Writes binary data to section's registry subkey.
        @param Name [in] Name of value to be written.
        @param Buf [in] Buffer from which data to be written.
        @param Size [in] Size of data from buffer to write.
      }
  public
    constructor Create(const SectionName: string);
      {Class constructor. Sets up object to operate on section (registry key).
        @param SectionName [in] Name of section.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object.
      }
  end;


{ TSection }

constructor TSection.Create(const SectionName: string);
  {Class constructor. Sets up object to operate on section (registry key).
    @param SectionName [in] Name of section.
  }
begin
  inherited Create;
  // Create registry access object
  fRegistry := TRegistry.Create;
  // Record root and construct subkey of registry used for the section
  fRegistry.RootKey := cRegRootKey;
  fSubKey := cRegKey + '\' + SectionName;
end;

destructor TSection.Destroy;
  {Class destructor. Tears down object.
  }
begin
  FreeAndNil(fRegistry);
  inherited;
end;

procedure TSection.ReadBin(const Name: string; var Buf; const Size: Integer);
  {Reads binary data from section's registry subkey.
    @param Name [in] Name of value to be read.
    @param Buf [in/out] Default data passed in. Buffer set to read data if named
      value exists. Buf is not changed if value does not exist.
  }
begin
  if fRegistry.OpenKeyReadOnly(fSubKey) and fRegistry.ValueExists(Name) then
    fRegistry.ReadBinaryData(Name, Buf, Size);
end;

function TSection.ReadBool(const Name: string; const Def: Boolean): Boolean;
  {Reads boolean value from section's registry subkey.
    @param Name [in] Name of value to read.
    @param Def [in] Default value to be used if value can't be read.
    @return Value associated with Name or Def if value can't be read.
  }
begin
  Result := Def;
  if fRegistry.OpenKeyReadOnly(fSubKey) and fRegistry.ValueExists(Name) then
    Result := fRegistry.ReadBool(Name)
end;

procedure TSection.WriteBin(const Name: string; const Buf; const Size: Integer);
  {Writes binary data to section's registry subkey.
    @param Name [in] Name of value to be written.
    @param Buf [in] Buffer from which data to be written.
    @param Size [in] Size of data from buffer to write.
  }
var
  WriteBuf: PByte;  // temp write buffer
begin
  if fRegistry.OpenKey(fSubKey, True) then
  begin
    // We have to copy data since we (have to) use const Buf, but
    // WriteBinaryData takes a var parameter
    GetMem(WriteBuf, Size);
    try
      Move(Buf, WriteBuf^, Size);
      fRegistry.WriteBinaryData(Name, WriteBuf^, Size);
    finally
      FreeMem(WriteBuf, Size);
    end;
    fRegistry.CloseKey;
  end;
end;

procedure TSection.WriteBool(const Name: string; const Value: Boolean);
  {Writes a boolean value to section's regsitry subkey.
    @param Name [in] Name of value to be written.
    @param Value [in] Value to be written.
  }
begin
  if fRegistry.OpenKey(fSubKey, True) then
  begin
    fRegistry.WriteBool(Name, Value);
    fRegistry.CloseKey;
  end;
end;

{ TSettings }

function TSettings.OpenSection(const Name: string): ISettingsSection;
  {Opens a section of persistent storage for reading and writing. The section is
  a registry subkey.
    @param Name [in] Name of required section.
    @return Reference to requested section object.
  }
begin
  Result := TSection.Create(Name);
end;


initialization

// Create global settings object
pvtSettings := TSettings.Create;


finalization

// Release settings object
pvtSettings := nil;

end.

