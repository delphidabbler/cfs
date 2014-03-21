{
 * UHTMLClip.pas
 *
 * Implements classes that encapsulate and interpret data in the "HTML Format"
 * clipboard format.
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
 * The Original Code is UHTMLClip.pas.
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


unit UHTMLClip;


interface


{
  ABOUT THE HTML CLIPBOARD FORMAT
  -------------------------------

  Portions of the following note were extracted and edited from MSDN

  The HTML clipboard format is used for cutting and pasting fragments of an
  HTML document. The CF_HTML clipboard format allows a fragment of raw HTML text
  and its context to be stored on the clipboard as ANSI text. This allows the
  context of the HTML fragment, which consists of all preceding and surrounding
  tags, to be examined by an application so that the surrounding tags can be
  noted with their attributes.

  HTML clipboard data have clipboard format name "HTML Format". The structure is
  entirely in text format and uses the transformation format UTF-8. It includes
  a description, a context, and within the context, the fragment.

  The following is an example:

    Version:0.9
    StartHTML:71
    EndHTML:170
    StartFragment:140
    EndFragment:160
    StartSelection:140
    EndSelection:160
    <!DOCTYPE>
    <HTML>
    <HEAD>
    <TITLE>The HTML Clipboard</TITLE>
    <BASE HREF="http://sample/specs">
    </HEAD>
    <BODY>
    <!--StartFragment -->
    <P>The Fragment</P>
    <!--EndFragment -->
    </BODY>
    </HTML>

  Version vv      Version number of the clipboard. Starting version is 0.9.
  StartHTML       Byte count from the beginning of the clipboard to the start of
                  the context, or -1 if no context.
  EndHTML         Byte count from the beginning of the clipboard to the end of
                  the context, or -1 if no context.
  StartFragment   Byte count from the beginning of the clipboard to the start of
                  the fragment.
  EndFragment     Byte count from the beginning of the clipboard to the end of
                  the fragment.
  StartSelection  Byte count from the beginning of the clipboard to the start of
                  the selection.
  EndSelection    Byte count from the beginning of the clipboard to the end of
                  the selection.
  SourceURL       URL of file from which clipboard copy was taken. (Not shown in
                  above example).

  The StartSelection and EndSelection keywords are optional because sufficient
  information for basic pasting is included in the fragment description.
  However, the selection information indicates the exact HTML area the user has
  selected. This adds more information to the fragment description.

  The StartHTML and EndHTML keywords may have value -1 to indicate there is no
  context.

  The SourceURL keyword may be omitted.

  The context is the selected fragment and all preceding and surrounding start
  and end tags. These tags represent all the parent nodes of the fragment, up to
  the HTML node.

  The fragment contains valid HTML representing the area the user has selected.
  This includes the information required for basic pasting of an HTML fragment,
  as follows:
    + Selected text.
    + Opening tags and attributes of any element that has an end tag within the
      selected text.
    + End tags that match the included opening tags.
  The fragment should be preceded and followed by the HTML comments
  <!--StartFragment--> and <!--EndFragment--> (no space allowed between the !--
  and the text) to indicate where the fragment starts and ends.

  The selection information indicates the exact HTML area the user has selected.
  This adds more information to the fragment description.


  ABOUT THE IMPLEMENTATION
  ------------------------

  The class THTMLClip is used to encapsulate the CF_HTML data format and
  provides easy access to the data's properties.

  The values of the Version and SourceURL keywords are converted from UTF-8 and
  exposed as Unicode string properties.

  It can be seen that the other keywords act in pairs to define regions of the
  HTML code that follows the last keyword, i.e. the context, fragment and
  selection regions. THTMLClip defines a property for each of these regions:
  Context, Fragment and Selection. These properties are objects that support
  IHTMLClipSection and, for each property, StartPos, Size and HTML properties
  are provided. These given the starting position of the HTML in the snippet,
  the length of the code, and the HTML contained in the region. The HTML is
  converted from UTF-8 to Unicode. An IsPresent function is also provided to
  indicate whether the region is present (or defined) in the clipboard data.

  Finally THTMLClip provides a DisplayHTML method that returns the best region
  of HTML code that can be displayed in a browser control. This is normally the
  code contained in the Context region, but, if that region is not present then
  the Fragment HTML code is returned. DisplayHTML returns a Unicode
  representation of the HTML.

  THTMLClip is instantiated by passing data in CF_HTML formatted UTF-8 text to
  its constructor.
}


uses
  // Delphi
  Classes;


type

  {
  IHTMLClipSection:
    Interface supported by objects that can represent a section of an HTML clip.
  }
  IHTMLClipSection = interface(IInterface)
    ['{472DF678-6443-41D2-A597-D638D9CE8849}']
    function GetStartPos: Integer;
      {Start position of the section's HTML.
        @return Required start position.
      }
    function GetSize: Integer;
      {Size of the section.
        @return Required size.
      }
    function GetHTML: UnicodeString;
      {The HTML code encompassed by the section.
        @return Required HTML code converted to Unicode.
      }
    function IsPresent: Boolean;
      {Indicates if the section is actually present in the HTML clip.
        @return True if the section is present, false if not. When False all
          property values are undefined and should not be used.
      }
    property StartPos: Integer read GetStartPos;
      {Starting position of the section's HTML within the clipboard data}
    property Size: Integer read GetSize;
      {Size of the section's HTML}
    property HTML: UnicodeString read GetHTML;
      {HTML code contained in section, converted to Unicode}
  end;

  {
  IClipData:
    Interface supported by object that stores CF_HTML clipboard data. For
    internal use by THTMLClip only.
  }
  IClipData = interface(IInterface)
    ['{17C8D550-988D-4678-A853-1A8C960CEDA4}']
    function GetData: UTF8String;
      {Gets encapsulated data.
        @return Required data.
      }
  end;

  {
  THTMLClip:
    Class that encapsulates and interprets data in the "HTML Format" clipboard
    format.
  }
  THTMLClip = class(TObject)
  private
    fData: IClipData;
      {Copy of clipboard data}
    fVersion: UnicodeString;
      {Value of Version property}
    fSourceURL: UnicodeString;
      {Value of SourceURL property}
    fFragment: IHTMLClipSection;
      {Value of Fragment property}
    fContext: IHTMLClipSection;
      {Value of Context property}
    fSelection: IHTMLClipSection;
      {Value of Section property}
    procedure Parse;
      {Parses HTML clipboard data to retrieve values of keywords.
      }
    function FindProperty(const Prop: UnicodeString; const Lines: TStrings):
      UnicodeString;
      {Finds value of a named property in clipboard data as a string.
        @param Prop [in] Required property name.
        @param Lines [in] Lines of text in clipboard data.
        @return Value of property if found or '' if no property found.
      }
    function FindPropertyInt(const Prop: UnicodeString; const Lines: TStrings):
      Integer;
      {Finds value of a named property in clipboard data as an integer.
        @param Prop [in] Required property name.
        @param Lines [in] Lines of text in clipboard data.
        @return Value of property if found or -1 if no property found.
      }
  public
    constructor Create(const Clip: UTF8String);
      {Class constructor. Sets up object for a HTML clip.
        @param Clip [in] Data in HTML clipboard format.
      }
    function DisplayHTML: UnicodeString;
      {HTML from the snippet that is to be displayed. If present, this is the
      HTML contained in the Context property. If there is no context that
      the HTML from the Fragment property is used.
        @return Required HTML.
      }
    property Context: IHTMLClipSection read fContext;
      {Section of HTML code that represents the HTML context of the HTML
      snippet. The bounds of this code are defined by the StartHTML and EndHTML
      keywords. May be absent if the keywords have value -1}
    property Fragment: IHTMLClipSection read fFragment;
      {Section of HTML code that represents the HTML code fragment. This is
      defined by the StartFragment and EndFragment keywords. Always present.}
    property Selection: IHTMLClipSection read fSelection;
      {Section of HTML code that represents the Selection. This is defined by
      the StartSelection and EndSelection keywords. May be absent if keywords
      are not present}
    property Version: UnicodeString read fVersion;
      {Data format version}
    property SourceURL: UnicodeString read fSourceURL;
      {URL of document from which clipboard data was copied}
  end;


implementation


uses
  // Delphi
  SysUtils, StrUtils;



type

  {
  TClipData:
    Class that stores CF_HTML clipboard data and can be passed around objects
    without duplicating the data in memory. Instantiated objects are
    automatically freed when last reference goes out of scope. This object is
    used instead of a string to prevent clipboard data being duplicated each
    time a THTMLClipSection object is created.
  }
  TClipData = class(TInterfacedObject,
    IClipData
  )
  private
    fData: UTF8String;
      {Copy of clipboard data as UTF-8 string}
  protected
    { IClipData }
    function GetData: UTF8String;
      {Gets clipboard data.
        @return Required data.
      }
  public
    constructor Create(const Data: UTF8String);
      {Class constructor. Sets up object with copy of data.
        @param Data [in] Data to be stored in object.
      }
  end;

  {
  THTMLClipSection:
    Class that represents a section of code in an HTML clip.
  }
  THTMLClipSection = class(TInterfacedObject,
    IHTMLClipSection
  )
  private
    fData: IClipData;
      {Reference to CF_HTML clipboard data}
    fStartPos: Integer;
      {Starting position of HTML in clipboard data}
    fEndPos: Integer;
      {End position of HTML in clipboard data}
  protected
    { IHTMLClipSection }
    function GetStartPos: Integer;
      {Start position of the section's HTML.
        @return Required start position.
      }
    function GetSize: Integer;
      {Size of the section.
        @return Required size.
      }
    function GetHTML: UnicodeString;
      {The HTML code encompassed by the section.
        @return Required HTML code.
      }
    function IsPresent: Boolean;
      {Indicates if the section is actually present in the HTML clip.
        @return True if the section is present, false if not. When False all
          property values are undefined and should not be used.
      }
  public
    constructor Create(const Data: IClipData; const StartPos, EndPos: Integer);
      {Class constructor. Creates an HTML clip section.
        @param Data [in] Reference to clipboard data
        @param StartPos [in] Starting position of HTML in clipboard data.
        @param EndPos [in] Ending position of HTML in clipboard data.
      }
  end;


{ THTMLClip }

constructor THTMLClip.Create(const Clip: UTF8String);
  {Class constructor. Sets up object for a HTML clip.
    @param Clip [in] Data in HTML clipboard format.
  }
begin
  inherited Create;
  fData := TClipData.Create(Clip);
  Parse;
end;

function THTMLClip.DisplayHTML: UnicodeString;
  {HTML from the snippet that is to be displayed. If present, this is the HTML
  contained in the Context property. If there is no context that the HTML from
  the Fragment property is used.
    @return Required HTML.
  }
begin
  if Context.IsPresent then
    Result := Context.HTML
  else
    Result := Fragment.HTML;
end;

function THTMLClip.FindProperty(const Prop: UnicodeString;
  const Lines: TStrings): UnicodeString;
  {Finds value of a named property in clipboard data as a string.
    @param Prop [in] Required property name.
    @param Lines [in] Lines of text in clipboard data.
    @return Value of property if found or '' if no property found.
  }
var
  Idx: Integer; // loops through lines of data
begin
  Result := '';
  for Idx := 0 to Pred(Lines.Count) do
  begin
    // property names start at beginning of line
    if AnsiStartsStr(Prop + ':', Lines[Idx]) then
    begin
      // value runs from after property name to end of line
      Result := AnsiRightStr(
        Lines[Idx], Length(Lines[Idx]) - (Length(Prop) + 1)
      );
    end;
  end;
end;

function THTMLClip.FindPropertyInt(const Prop: UnicodeString;
  const Lines: TStrings): Integer;
  {Finds value of a named property in clipboard data as an integer.
    @param Prop [in] Required property name.
    @param Lines [in] Lines of text in clipboard data.
    @return Value of property if found or -1 if no property found.
  }
begin
  Result := StrToIntDef(FindProperty(Prop, Lines), -1);
end;

procedure THTMLClip.Parse;
  {Parses HTML clipboard data to retrieve values of keywords.
  }
var
  Lines: TStringList; // stores clipboard data as line of text
begin
  // Split data into Unicode text lines
  Lines := TStringList.Create;
  try
    Lines.Text := UTF8ToUnicodeString(fData.GetData);
    // Record property values based on single keywords
    fVersion := FindProperty('Version', Lines);
    fSourceURL := FindProperty('SourceURL', Lines);
    // Create properties based on pairs of keywords that reference HTML code
    fContext := THTMLClipSection.Create(
      fData,
      FindPropertyInt('StartHTML', Lines),
      FindPropertyInt('EndHTML', Lines)
    );
    fFragment := THTMLClipSection.Create(
      fData,
      FindPropertyInt('StartFragment', Lines),
      FindPropertyInt('EndFragment', Lines)
    );
    fSelection := THTMLClipSection.Create(
      fData,
      FindPropertyInt('StartSelection', Lines),
      FindPropertyInt('EndSelection', Lines)
    );
  finally
    Lines.Free;
  end;
end;

{ THTMLClipSection }

constructor THTMLClipSection.Create(const Data: IClipData;
  const StartPos, EndPos: Integer);
  {Class constructor. Creates an HTML clip section.
    @param Data [in] Reference to clipboard data
    @param StartPos [in] Starting position of HTML in clipboard data.
    @param EndPos [in] Ending position of HTML in clipboard data.
  }
begin
  inherited Create;
  // Records properties
  fData := Data;
  fStartPos := StartPos;
  fEndPos := EndPos;
end;

function THTMLClipSection.GetHTML: UnicodeString;
  {The HTML code encompassed by the section.
    @return Required HTML code.
  }
begin
  if (fStartPos >= 0) and (fEndPos >= fStartPos) then
    // get slice of clip data addressed by start and end positions
    Result := UTF8ToUnicodeString(
      Copy(fData.GetData, fStartPos + 1, fEndPos - fStartPos)
    )
  else
    Result := '';
end;

function THTMLClipSection.GetSize: Integer;
  {Size of the section.
    @return Required size.
  }
begin
  Result := fEndPos - fStartPos + 1;
end;

function THTMLClipSection.GetStartPos: Integer;
  {Start position of the section's HTML.
    @return Required start position.
  }
begin
  Result := fStartPos;
end;

function THTMLClipSection.IsPresent: Boolean;
  {Indicates if the section is actually present in the HTML clip.
    @return True if the section is present, false if not. When False all
      property values are undefined and should not be used.
  }
begin
  Result := fStartPos >= 0;
end;

{ TClipData }

constructor TClipData.Create(const Data: UTF8String);
  {Class constructor. Sets up object with copy of data.
    @param Data [in] Data to be stored in object.
  }
begin
  inherited Create;
  fData := Data;
end;

function TClipData.GetData: UTF8String;
  {Gets clipboard data.
    @return Required data.
  }
begin
  Result := fData;
end;

end.

