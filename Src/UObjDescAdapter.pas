{
 * UObjDescAdapter.pas
 *
 * Implements a that provides an alternative interface to Object descriptors
 * and Link Source descriptors.
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
 * The Original Code is UObjDescAdapter.pas.
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


unit UObjDescAdapter;


interface


uses
  // Delphi
  ActiveX, Windows;


type
  ///  <summary>
  ///  Class that provides an alternative interface to Object descriptors and
  ///  Link Source descriptors as represented by the TObjectDescriptor
  ///  (OBJECTDESCRIPTOR) structure.
  ///  </summary>
  ///  <remarks>
  ///  <para>These formats provide user interface information during data
  ///  transfer operations.</para>
  ///  <para>See http://tinyurl.com/34jbglt (MSDN).</para>
  ///  </remarks>
  TObjDescAdapter = class(TObject)
  private
    fStatus: DWORD;
      {Value of status property}
    fDrawAspect: DWORD;
      {Value of DrawAspect property}
    fFullUserTypeName: UnicodeString;
      {Value of FullUserTypeName property}
    fSrcOfCopy: UnicodeString;
      {Value of SrcOfCopy property}
    fCLSID: TGUID;
      {Value of CLSID property}
    fExtent: TSize;
      {Value of Extent property}
    function GetStringFromOffset(const OD: TObjectDescriptor;
      const Offset: Integer): UnicodeString;
      {Fetches Unicode string located at a specified byte offset from the start
      of a TObjectDescriptor record.
        @param OD [in] Object descriptor record beyond which string is located.
        @param Offset [in] Offset from start of OD at which string is located.
        @return Required Unicode string.
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
    property FullUserTypeName: UnicodeString read fFullUserTypeName;
      {Full user type name of the object. May be ''}
    property SrcOfCopy: UnicodeString read fSrcOfCopy;
      {Specifies the source of the transfer. May be '' for an unknown source}
  end;


implementation


{ TObjDescAdapter }

constructor TObjDescAdapter.Create(const OD: TObjectDescriptor);
  {Class constructor. Populates fields from an object descriptor or link source
  descriptor.
    @param OD [in] Record providing information about descriptor.
  }
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
  const Offset: Integer): UnicodeString;
  {Fetches Unicode string located at a specified byte offset from the start of a
  TObjectDescriptor record.
    @param OD [in] Object descriptor record beyond which string is located.
    @param Offset [in] Offset from start of OD at which string is located.
    @return Required Unicode string.
  }
begin
  Result := PWideChar(Pointer(Integer(@OD) + Offset));
end;

end.

