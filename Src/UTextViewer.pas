{
 * UTextViewer.pas
 *
 * Viewer object that displays plain text clipboard formats, including Ansi,
 * Unicode and OEM text. Also used as a secondary viewer for plain text
 * formatted code, such as HTML or RTF.
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
 * The Original Code is UTextViewer.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2008-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): None
 *
 * ***** END LICENSE BLOCK *****
}


unit UTextViewer;


interface


uses
  // Delphi
  Forms,
  // Project
  IntfViewers, UBaseTextViewer;


type

  {
  TTextViewer:
    Viewer object that displays plain text clipboard formats, including Ansi,
    Unicode and OEM text. Also used as a secondary viewer for plain text
    formatted code, such as HTML or RTF.
  }
  TTextViewer = class(TBaseTextViewer,
    IViewer
  )
  private
    fIsOEM: Boolean;
      {Flag set true if OEM text is being displayed, False if not}
    fText: string;
      {Text read from clipboard}
    function IsSecondaryViewer(const FmtID: Word): Boolean;
      {Checks if the viewer is a "secondary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if the viewer is a secondary viewer for the FmtID, False if
          not.
      }
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
        @return True if the viewer is a primary viewer, False if not.
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
  end;


implementation


uses
  // Project
  FrTextViewer, UClipFmt, UViewers;


function TTextViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if the viewer is a primary viewer, False if not.
  }
begin
  // Text viewer is primary viewer for plain text formats in either Ansi, OEM
  // or Unicode formats. The latter are converted to Ansi. The viewer is also
  // the primary viewer for specially formatted formats that are intended to be
  // viewed as source - CF_RTFASTEXT for example.
  Result := (FmtID = CF_TEXT)
    or (FmtID = CF_UNICODETEXT)
    or (FmtID = CF_OEMTEXT)
    or (FmtID = CF_RTFASTEXT)
    or (FmtID = CF_MIME_PLAINTEXT);
end;

function TTextViewer.IsSecondaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is a "secondary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if the viewer is a secondary viewer for the FmtID, False if
      not.
  }
begin
  // Text viewer is a 2ndary view for formats known to be stored as plain text
  // but which have a special format (e.g. HTML) that is better rendered by a
  // dedicated primary viewer. The text viewer is provided to enable the
  // underlying source to be viewed.
  Result := (FmtID = CF_RTF)
    or (FmtID = CF_RTFNOOBJS)
    or (FmtID = CF_FILENAMEA)
    or (FmtID = CF_FILENAMEW)
    or (FmtID = CF_INETURLA)
    or (FmtID = CF_INETURLW)
    or (FmtID = CF_HTML)
    or (FmtID = CF_HYPERTEXT)
    or (FmtID = CF_MIME_HTML)
    or (FmtID = CF_MIME_MOZHTMLCONTEXT);
end;

function TTextViewer.MenuText(const FmtID: Word): string;
  {Gets text to display in viewer menu.
    @param FmtID [in] ID of required clipboard format.
    @return Required menu text.
  }
resourcestring
  sPrimaryMenuText = 'View Text';       // text when primary viewer
  sSecondaryMenuText = 'View As Text';  // text when 2ndary viewer
begin
  if IsPrimaryViewer(FmtID) then
    Result := sPrimaryMenuText
  else
    Result := sSecondaryMenuText;
end;

procedure TTextViewer.ReleaseClipData;
  {Frees the data rendered when RenderClipData was last called.
  }
begin
  // All we do is delete the text
  fText := '';
end;

procedure TTextViewer.RenderClipData(const FmtID: Word);
  {Reads data for a specified format from the clipboard and renders it into a
  format suitable for display.
    @param FmtID [in] ID of clipboard format to be rendered.
  }
begin
  fText := inherited CopyClipboardText(FmtID);
  fIsOEM := FmtID = CF_OEMTEXT;
end;

procedure TTextViewer.RenderView(const Frame: TFrame);
  {Displays the rendered clipboard data in viewer frame.
    @param Frame [in] Frame in which to display the data.
  }
begin
  // We pass the text and OEM flag to frame
  (Frame as TTextViewerFrame).Display(fText, fIsOEM);
end;

function TTextViewer.SupportsFormat(const FmtID: Word): Boolean;
  {Checks whether viewer supports a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if format is supported, False if not.
  }
begin
  // Formats supported are those for which text viewer is either a primary or
  // secondary viewer
  Result := IsPrimaryViewer(FmtID) or IsSecondaryViewer(FmtID);
end;

function TTextViewer.UIFrameClass: TFrameClass;
  {Gets the class type of the viewer frame.
    @return Required frame class.
  }
begin
  Result := TTextViewerFrame;
end;

initialization

// Register viewer
ViewerRegistrar.RegisterViewer(TTextViewer.Create);

end.

