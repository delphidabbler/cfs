{
 * UObjDescAdapter.pas
 *
 * Implements a cthat provides an alternative interface to Object descriptors
 * and Link Source descriptors.
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
 * The Original Code is UObjDescAdapter.pas.
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


unit UObjDescAdapter;


interface


uses
  // Delphi
  ActiveX, Windows;


type

  {
  TObjDescAdapter:
    Class that provides an alternative interface to Object descriptors and Link
    Source descriptors that provide information user interface information
    during data transfer operations, as used in the Paste Special dialog box.
  }
  TObjDescAdapter = class(TObject)
  private
    fStatus: DWORD;
      {Value of status property}
    fDrawAspect: DWORD;
      {Value of DrawAspect property}
    fFullUserTypeName: string;
      {Value of FullUserTypeName property}
    fSrcOfCopy: string;
      {Value of SrcOfCopy property}
    fCLSID: TGUID;
      {Value of CLSID property}
    fExtent: TSize;
      {Value of Extent property}
    function GetStringFromOffset(const OD: TObjectDescriptor;
      const Offset: Integer): string;
      {Fetches Unicode string located at a specified byte offset from the start
      of a TObjectDescriptor record.
        @param OD [in] Object descriptor record beyond which string is located.
        @param Offset [in] Offset from start of OD at which string is located.
      }
  public
    constructor Create(const OD: TObjectDescriptor);
      {Class constructor. Populates fields from an object descriptor or link
      source descriptor.
        @param OD [in] Record providing information about descriptor.
      }
    property CLSID: TGUID read fCLSID;
      {CLSID of the object being transferred. May be CLSID_NULL}
    property DrawAspect: DWORD read fDrawAspect;
      {Display aspect of the object. May be 0 if source application did not
      draw the object}
    property Extent: TSize read fExtent;
      {Specifies the extent of the object without cropping or scaling. May be
      (0,0) if source application did not draw the object}
    property Status: DWORD read fStatus;
      {Status flags for the object defined by OLEMISC structure}
    property FullUserTypeName: string read fFullUserTypeName;
      {Full user type name of the object. May be ''}
    property SrcOfCopy: string read fSrcOfCopy;
      {Specifies the source of the transfer. May be '' for an unknown source}
  end;


implementation


{ TObjDescAdapter }

constructor TObjDescAdapter.Create(const OD: TObjectDescriptor);
  {Class constructor. Populates fields from an object descriptor or link source
  descriptor.
    @param OD [in] Record providing information about descriptor.
  }
resourcestring
  sUnknownSource = 'Unknown Source';    // value used when source is unknown
begin
  // Set property values
  // OD.pointl field ignored since only relevant to drag-drop
  fCLSID := OD.clsid;
  fDrawAspect := OD.dwDrawAspect;
  fExtent.cx := OD.size.X;
  fExtent.cy := OD.size.Y;
  fStatus := OD.dwStatus;
  if OD.dwFullUserTypeName <> 0 then
    // we have user type name: get it
    fFullUserTypeName := GetStringFromOffset(OD, OD.dwFullUserTypeName);
  if OD.dwSrcOfCopy <> 0 then
    // we have source of copy: get it
    fSrcOfCopy := GetStringFromOffset(OD, OD.dwSrcOfCopy);
end;

function TObjDescAdapter.GetStringFromOffset(const OD: TObjectDescriptor;
  const Offset: Integer): string;
  {Fetches Unicode string located at a specified byte offset from the start of a
  TObjectDescriptor record.
    @param OD [in] Object descriptor record beyond which string is located.
    @param Offset [in] Offset from start of OD at which string is located.
  }
begin
  Result := PWideChar(Pointer(Integer(@OD) + Offset));
end;

end.

