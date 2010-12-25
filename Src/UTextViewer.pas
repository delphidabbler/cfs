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
  ///  <summary>
  ///  Abstract base classes for viewers that display plain text clipboard
  ///  formats.
  ///  </summary>
  TTextViewer = class abstract(TBaseTextViewer,
    IViewer
  )
  private
    fText: UnicodeString;
      {Text read from clipboard}
  protected
    function IsSecondaryViewer(const FmtID: Word): Boolean; virtual; abstract;
      {Checks if the viewer is a "secondary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if the viewer is a secondary viewer for the FmtID, False if
          not.
      }
    function GetText(const FmtID: Word): UnicodeString; virtual; abstract;
      {Gets the text to display in Unicode format.
        @param FmtID [in] ID of required clipboard format.
        @return Required string.
      }
    { IViewer }
    function SupportsFormat(const FmtID: Word): Boolean;
      {Checks whether viewer supports a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if format is supported, False if not.
      }
    function IsPrimaryViewer(const FmtID: Word): Boolean; virtual; abstract;
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

type
  ///  <summary>
  ///  Viewer for plain text stored on clipboard in Unicode format.
  ///  </summary>
  TUnicodeTextViewer = class sealed(TTextViewer)
  strict protected
    function GetText(const FmtID: Word): UnicodeString; override;
      {Gets the text to display in Unicode format.
        @param FmtID [in] ID of required clipboard format.
        @return Required string.
      }
    function IsSecondaryViewer(const FmtID: Word): Boolean; override;
      {Checks if the viewer is a "secondary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if the viewer is a secondary viewer for the FmtID, False if
          not.
      }
    function IsPrimaryViewer(const FmtID: Word): Boolean; override;
      {Checks if the viewer is the "primary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if the viewer is a primary viewer, False if not.
      }
  end;

type
  ///  <summary>
  ///  Viewer for plain text stored on clipboard in ANSI format using the system
  ///  default code page.
  ///  </summary>
  TAnsiTextViewer = class sealed(TTextViewer)
  strict protected
    function GetText(const FmtID: Word): UnicodeString; override;
      {Gets the text to display in Unicode format.
        @param FmtID [in] ID of required clipboard format.
        @return Required string.
      }
    function IsSecondaryViewer(const FmtID: Word): Boolean; override;
      {Checks if the viewer is a "secondary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if the viewer is a secondary viewer for the FmtID, False if
          not.
      }
    function IsPrimaryViewer(const FmtID: Word): Boolean; override;
      {Checks if the viewer is the "primary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if the viewer is a primary viewer, False if not.
      }
  end;

type
  ///  <summary>
  ///  Viewer for plain text stored on clipboard in UTF-8 format.
  ///  </summary>
  TUTF8TextViewer = class sealed(TTextViewer)
  strict protected
    function GetText(const FmtID: Word): UnicodeString; override;
      {Gets the text to display in Unicode format.
        @param FmtID [in] ID of required clipboard format.
        @return Required string.
      }
    function IsSecondaryViewer(const FmtID: Word): Boolean; override;
      {Checks if the viewer is a "secondary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if the viewer is a secondary viewer for the FmtID, False if
          not.
      }
    function IsPrimaryViewer(const FmtID: Word): Boolean; override;
      {Checks if the viewer is the "primary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if the viewer is a primary viewer, False if not.
      }
  end;

type
  ///  <summary>
  ///  Viewer for plain text stored on clipboard in ASCII format.
  ///  </summary>
  TASCIITextViewer = class sealed(TTextViewer)
  strict protected
    function GetText(const FmtID: Word): UnicodeString; override;
      {Gets the text to display in Unicode format.
        @param FmtID [in] ID of required clipboard format.
        @return Required string.
      }
    function IsSecondaryViewer(const FmtID: Word): Boolean; override;
      {Checks if the viewer is a "secondary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if the viewer is a secondary viewer for the FmtID, False if
          not.
      }
    function IsPrimaryViewer(const FmtID: Word): Boolean; override;
      {Checks if the viewer is the "primary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if the viewer is a primary viewer, False if not.
      }
  end;

type
  ///  <summary>
  ///  Viewer for plain text stored on clipboard as OEM (ANSI) text.
  ///  </summary>
  TOEMTextViewer = class sealed(TTextViewer)
  strict protected
    function GetText(const FmtID: Word): UnicodeString; override;
      {Gets the text to display in Unicode format.
        @param FmtID [in] ID of required clipboard format.
        @return Required string.
      }
    function IsSecondaryViewer(const FmtID: Word): Boolean; override;
      {Checks if the viewer is a "secondary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if the viewer is a secondary viewer for the FmtID, False if
          not.
      }
    function IsPrimaryViewer(const FmtID: Word): Boolean; override;
      {Checks if the viewer is the "primary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if the viewer is a primary viewer, False if not.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, Windows,
  // Project
  FrTextViewer, UClipFmt, UViewers;


{ TTextViewer }

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
  fText := GetText(FmtID);
end;

procedure TTextViewer.RenderView(const Frame: TFrame);
  {Displays the rendered clipboard data in viewer frame.
    @param Frame [in] Frame in which to display the data.
  }
begin
  // We pass the text and OEM flag to frame
  (Frame as TTextViewerFrame).Display(fText);
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

{ TUnicodeTextViewer }

function TUnicodeTextViewer.GetText(const FmtID: Word): UnicodeString;
  {Gets the text to display in Unicode format.
    @param FmtID [in] ID of required clipboard format.
    @return Required string.
  }
begin
  Result := TEncoding.Unicode.GetString(GetAsUnicodeBytes(FmtID));
end;

function TUnicodeTextViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if the viewer is a primary viewer, False if not.
  }
begin
  Result := FmtID = CF_UNICODETEXT;
end;

function TUnicodeTextViewer.IsSecondaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is a "secondary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if the viewer is a secondary viewer for the FmtID, False if
      not.
  }
begin
  Result := (FmtID = CF_FILENAMEW)
    or (FmtID = CF_INETURLW)
    or (FmtID = CF_MIME_HTML)
    or (FmtID = CF_MIME_MOZHTMLCONTEXT);
end;

{ TAnsiTextViewer }

function TAnsiTextViewer.GetText(const FmtID: Word): UnicodeString;
  {Gets the text to display in Unicode format.
    @param FmtID [in] ID of required clipboard format.
    @return Required string.
  }
begin
  Result := TEncoding.Default.GetString(GetAsAnsiBytes(FmtID));
end;

function TAnsiTextViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if the viewer is a primary viewer, False if not.
  }
begin
  Result := FmtID = CF_TEXT;
end;

function TAnsiTextViewer.IsSecondaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is a "secondary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if the viewer is a secondary viewer for the FmtID, False if
      not.
  }
begin
  Result := (FmtID = CF_FILENAMEA) or (FmtID = CF_HYPERTEXT);

end;

{ TUTF8TextViewer }

function TUTF8TextViewer.GetText(const FmtID: Word): UnicodeString;
  {Gets the text to display in Unicode format.
    @param FmtID [in] ID of required clipboard format.
    @return Required string.
  }
begin
  Result := TEncoding.UTF8.GetString(GetAsAnsiBytes(FmtID));
end;

function TUTF8TextViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if the viewer is a primary viewer, False if not.
  }
begin
  Result := False;
end;

function TUTF8TextViewer.IsSecondaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is a "secondary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if the viewer is a secondary viewer for the FmtID, False if
      not.
  }
begin
  Result := FmtID = CF_HTML;
end;

{ TASCIITextViewer }

function TASCIITextViewer.GetText(const FmtID: Word): UnicodeString;
  {Gets the text to display in Unicode format.
    @param FmtID [in] ID of required clipboard format.
    @return Required string.
  }
begin
  Result := TEncoding.ASCII.GetString(GetAsAnsiBytes(FmtID));
end;

function TASCIITextViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if the viewer is a primary viewer, False if not.
  }
begin
  Result := FmtID = CF_RTFASTEXT;
end;

function TASCIITextViewer.IsSecondaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is a "secondary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if the viewer is a secondary viewer for the FmtID, False if
      not.
  }
begin
  Result := (FmtID = CF_RTF)
    or (FmtID = CF_RTFNOOBJS)
    or (FmtID = CF_INETURLA);
end;

{ TOEMTextViewer }

function TOEMTextViewer.GetText(const FmtID: Word): UnicodeString;
  {Gets the text to display in Unicode format.
    @param FmtID [in] ID of required clipboard format.
    @return Required string.
  }
var
  Bytes: TBytes;  // bytes of OEM char string on clipboard
begin
  // Get bytes in OEM char set from clipboard
  Bytes := GetAsAnsiBytes(FmtID);
  // Convert from OEM char set to ANSI
  OEMToCharBuffA(PAnsiChar(Bytes), PAnsiChar(Bytes), Length(Bytes));
  // Convert to Unicode
  Result := TEncoding.Default.GetString(Bytes);
end;

function TOEMTextViewer.IsPrimaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is the "primary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if the viewer is a primary viewer, False if not.
  }
begin
  Result := FmtID = CF_OEMTEXT;
end;

function TOEMTextViewer.IsSecondaryViewer(const FmtID: Word): Boolean;
  {Checks if the viewer is a "secondary" viewer for a clipboard format.
    @param FmtID [in] ID of required clipboard format.
    @return True if the viewer is a secondary viewer for the FmtID, False if
      not.
  }
begin
  Result := False;
end;

initialization

// Register viewer
ViewerRegistrar.RegisterViewer(TUnicodeTextViewer.Create);
ViewerRegistrar.RegisterViewer(TAnsiTextViewer.Create);
ViewerRegistrar.RegisterViewer(TUTF8TextViewer.Create);
ViewerRegistrar.RegisterViewer(TASCIITextViewer.Create);
ViewerRegistrar.RegisterViewer(TOEMTextViewer.Create);

end.

