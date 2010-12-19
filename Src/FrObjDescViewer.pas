{
 * FrObjDescViewer.pas
 *
 * Implements a viewer frame that information about displays object and link
 * source descriptors.
 *
 * v1.0 of 10 Mar 2008  - Original version.
 * v1.1 of 04 May 2008  - Added code to refresh scroll box to ensure contained
 *                        labels display correctly.
 *                      - Slightly increased size of some display edit controls.
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
 * The Original Code is FrObjDescViewer.pas.
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


unit FrObjDescViewer;


interface


uses
  // Delphi
  Menus, StdActns, Classes, ActnList, StdCtrls, Controls, ExtCtrls, Forms,
  // Project
  UObjDescAdapter;


type

  {
  TObjDescViewerFrame:
    Viewer frame that displays information about object and link source
    descriptors in read-only edit controls. Supports selecting and copying of
    text in edit controls as text.
  }
  TObjDescViewerFrame = class(TFrame)
    actCopy: TEditCopy;
    actSelectAll: TEditSelectAll;
    alView: TActionList;
    edCLSID: TEdit;
    edDrawAspect: TEdit;
    edFullUserTypeName: TEdit;
    edSize: TEdit;
    edSrcOfCopy: TEdit;
    edStatus: TEdit;
    lblClassID: TLabel;
    lblDrawAspect: TLabel;
    lblFullUserTypeName: TLabel;
    lblSize: TLabel;
    lblSrcOfCopy: TLabel;
    lblStatus: TLabel;
    miCopy: TMenuItem;
    miSelectAll: TMenuItem;
    mnuView: TPopupMenu;
    pnlView: TPanel;
    sbView: TScrollBox;
  public
    procedure Display(const ObjDesc: TObjDescAdapter);
      {Displays information about an object or link source descriptor.
        @param ObjDesc [in] Object that contains information about the
          descriptor.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, ActiveX;


{$R *.dfm}


{ TObjDescViewerFrame }

procedure TObjDescViewerFrame.Display(const ObjDesc: TObjDescAdapter);
  {Displays information about an object or link source descriptor.
    @param ObjDesc [in] Object that contains information about the descriptor.
  }
resourcestring
  // Display text
  sBadDrawAspect = 'Unknown';
  sNonSourceAspect = 'Source did not draw';
  sNotSpecified = 'Not specified';
  sExtent = 'Width: %0:d, Height: %1:d';
begin
  // We need to refresh scroll box to ensure labels display properly
  sbView.Refresh;
  // Store required object descriptions in edit controls
  edCLSID.Text := GUIDToString(ObjDesc.CLSID);
  case ObjDesc.DrawAspect of
    0: edDrawAspect.Text := sNonSourceAspect;
    DVASPECT_CONTENT: edDrawAspect.Text := 'DVASPECT_CONTENT';
    DVASPECT_THUMBNAIL: edDrawAspect.Text := 'DVASPECT_THUMBNAIL';
    DVASPECT_ICON: edDrawAspect.Text := 'DVASPECT_ICON';
    DVASPECT_DOCPRINT: edDrawAspect.Text := 'DVASPECT_DOCPRINT';
    else edDrawAspect.Text := sBadDrawAspect;
  end;
  if (ObjDesc.Extent.cx = 0) and (ObjDesc.Extent.cy = 0) then
    edSize.Text := sNotSpecified
  else
    edSize.Text := Format(sExtent, [ObjDesc.Extent.cx, ObjDesc.Extent.cy]);
  edStatus.Text := Format('%0.4X', [ObjDesc.Status]);
  edFullUserTypeName.Text := ObjDesc.FullUserTypeName;
  edSrcOfCopy.Text := ObjDesc.SrcOfCopy;
end;

end.

