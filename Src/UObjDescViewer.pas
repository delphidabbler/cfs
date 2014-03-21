{
 * UObjDescViewer.pas
 *
 * Implements viewer for object descriptors and link source descriptors.
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
 * The Original Code is UObjDescViewer.pas.
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


unit UObjDescViewer;


interface


uses
  // Delphi
  Forms,
  // Project
  IntfViewers, UGlobalMemViewer, UObjDescAdapter;


type

  {
  TObjDescViewer:
    Viewer for object descriptors and link source descriptors.
  }
  TObjDescViewer = class(TGlobalMemViewer,
    IViewer
  )
  private
    fObjDesc: TObjDescAdapter;
      {Interprets object and link descriptors from clipboard data}
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
  SysUtils, ActiveX,
  // Project
  FrObjDescViewer, UClipFmt, UDataBuffer, UViewers;


{ TObjDescViewer }

destructor TObjDescViewer.Destroy;
  {Class destructor. Ensures any remaining rendered data is released.
  }
begin
  ReleaseClipData;
  inherited;
end;

function TObjDescViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True. This is always a primary viewer.
  }
begin
  Result := True;
end;

function TObjDescViewer.MenuText(const FmtID: Word): string;
  {Gets text to display in viewer menu.
    @param FmtID [in] ID of required clipboard format.
    @return Required menu text.
  }
resourcestring
  sMenuText = 'View Descriptor';  // we use this menu text for both formats
begin
  Result := sMenuText;
end;

procedure TObjDescViewer.ReleaseClipData;
  {Frees the data rendered when RenderClipData was last called.
  }
begin
  FreeAndNil(fObjDesc);
end;

procedure TObjDescViewer.RenderClipData(const FmtID: Word);
  {Reads data for a specified format from the clipboard and renders it into
  a format suitable for display.
    @param FmtID [in] ID of clipboard format to be rendered.
  }
var
  OD: PObjectDescriptor;  // pointer to object/link src descriptor info
  Data: IDataBuffer;      // buffer containing copy of clipboard data
begin
  ReleaseClipData;                      // release any existing rendered data
  Data := CopyClipboardMemData(FmtID);  // get copy of clipboard data
  OD := Data.Lock;
  try
    // hand off data to TObjDescAdapter to extract required info from data
    fObjDesc := TObjDescAdapter.Create(OD^);
  finally
    Data.Unlock;
  end;
end;

procedure TObjDescViewer.RenderView(const Frame: TFrame);
  {Displays the rendered clipboard data in viewer frame.
    @param Frame [in] Frame in which to display the data.
  }
begin
  // frame uses information provided by TObjDescAdapter object
  (Frame as TObjDescViewerFrame).Display(fObjDesc);
end;

function TObjDescViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  Result := (FmtID = CF_OBJECTDESCRIPTOR) or (FmtID = CF_LINKSRCDESCRIPTOR);
end;

function TObjDescViewer.UIFrameClass: TFrameClass;
  {Gets the class type of the viewer frame.
    @return Required frame class.
  }
begin
  Result := TObjDescViewerFrame;
end;


initialization

// Register viewer
ViewerRegistrar.RegisterViewer(TObjDescViewer.Create);

end.

