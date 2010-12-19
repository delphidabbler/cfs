{
 * UFileGroupDescViewer.pas
 *
 * Implements a viewer for shell file group descriptors.
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
 * The Original Code is UFileGroupDescViewer.pas.
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


unit UFileGroupDescViewer;


interface


uses
  // Delphi
  Forms,
  // Project
  IntfViewers, UFileGroupDescAdapter, UGlobalMemViewer;


type

  {
  TFileGroupDescViewer:
    Viewer for shell file group descriptors.
  }
  TFileGroupDescViewer = class(TGlobalMemViewer,
    IViewer
  )
  private
    fGroupDesc: TFileGroupDescAdapter;
      {Provides information about a file group descriptor and its contained
      file descriptors}
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
      {Class destructor. Ensure that any remaining rendered data is released.
      }
  end;


implementation


uses
  // Delphi
  ShlObj, SysUtils,
  // Project
  FrFileGroupDescViewer, UClipFmt, UDataBuffer, UViewers;


{ TFileGroupDescViewer }

destructor TFileGroupDescViewer.Destroy;
  {Class destructor. Ensure that any remaining rendered data is released.
  }
begin
  ReleaseClipData;
  inherited;
end;

function TFileGroupDescViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True. This is always a primary viewer.
  }
begin
  Result := True;
end;

function TFileGroupDescViewer.MenuText(const FmtID: Word): string;
  {Gets text to display in viewer menu.
    @param FmtID [in] ID of required clipboard format.
    @return Required menu text.
  }
resourcestring
  sMenuText = 'View Descriptor';  // always use this menu text
begin
  Result := sMenuText;
end;

procedure TFileGroupDescViewer.ReleaseClipData;
  {Frees the data rendered when RenderClipData was last called.
  }
begin
  FreeAndNil(fGroupDesc);
end;

procedure TFileGroupDescViewer.RenderClipData(const FmtID: Word);
  {Reads data for a specified format from the clipboard and renders it into
  a format suitable for display.
    @param FmtID [in] ID of clipboard format to be rendered.
  }
var
  PDesc: Pointer;     // pointer to descriptor data
  Data: IDataBuffer;  // buffer used to copy clipboard data
begin
  ReleaseClipData;    // ensure any previous rendered data is released
  Data := CopyClipboardMemData(FmtID);  // get copy of clipboard data
  PDesc := Data.Lock;
  try
    // hand off both ansi and wide forms of data to TFileGroupDescAdapter to
    // interpret
    if FmtID = CF_FILEDESCRIPTORA then
      fGroupDesc := TFileGroupDescAdapter.Create(PFileGroupDescriptorA(PDesc)^)
    else // CF_FILEDESCRIPTORW
      fGroupDesc := TFileGroupDescAdapter.Create(PFileGroupDescriptorW(PDesc)^);
  finally
    Data.Unlock;
  end;
end;

procedure TFileGroupDescViewer.RenderView(const Frame: TFrame);
  {Displays the rendered clipboard data in viewer frame.
    @param Frame [in] Frame in which to display the data.
  }
begin
  // frame uses information in group descriptor adapter object
  (Frame as TFileGroupDescViewerFrame).Display(fGroupDesc);
end;

function TFileGroupDescViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  // We support ansi and unicode versions of file descriptors
  Result := (FmtID = CF_FILEDESCRIPTORA) or (FmtID = CF_FILEDESCRIPTORW);
end;

function TFileGroupDescViewer.UIFrameClass: TFrameClass;
  {Gets the class type of the viewer frame.
    @return Required frame class.
  }
begin
  Result := TFileGroupDescViewerFrame;
end;


initialization

// Register viewer
ViewerRegistrar.RegisterViewer(TFileGroupDescViewer.Create);

end.

