{
 * UHelpManager.pas
 *
 * Implements static class that manages the Clipboard Format Spy HTML Help
 * system.
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
 * The Original Code is UHelpManager.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2008-2014 Peter
 * Johnson. All Rights Reserved.
 *
 * ***** END LICENSE BLOCK *****
}


unit UHelpManager;


interface


uses
  // Delphi
  Windows;


type

  ///  <summary>Structure used to specify one or more ALink names or KLink
  ///  keywords to be searched for.</summary>
  ///  <remarks>The LPCTSTR fields behave strangely when using the Unicode API.
  ///  In this case LPCTSTR is defined as PWideChar, but casting a Unicode
  ///  string to a PChar (=PWideChar) causes HTML Help to see only the first
  ///  character of the keyword, implying HTML Help is treating the string an
  ///  ANSI string. To get this to work a Unicode Delphi string must first be
  ///  cast to an ANSI string and then to a pointer before assiging to the
  ///  LPCTSTR valued field.</remarks>
  THHAKLink = packed record
    ///  <summary>Size of record in bytes.</summary>
    cbStruct: Integer;
    ///  <summary>Reserved. Must be False.</summary>
    fReserved: BOOL;
    ///  <summary>Semi-colon separated keywords.</summary>
    pszKeywords: LPCTSTR;
    ///  <summary>URL to jump to if none of the keywords are found (may be nil).
    ///  </summary>
    pszUrl: LPCTSTR;
    ///  <summary>Text to be displayed in a message box on failure (may be nil).
    ///  </summary>
    pszMsgText: LPCTSTR;
    ///  <summary>Title of any failure message box.</summary>
    pszMsgTitle: LPCTSTR;
    ///  <summary>Name of window where pszUrl is to be displayed.</summary>
    pszWindow: LPCTSTR;
    ///  <summary>Flag determining if help index is displayed if keyword lookup
    ///  fails.</summary>
    fIndexOnFail: BOOL;
  end;

  {
  THelpManager:
    Static class that manages the Clipboard Format Spy HTML help system.
  }
  THelpManager = class(TObject)
  private
    class function HelpFileName: string;
      {Gets name of help file.
        @return Fully qualified help file name.
      }
    class function TopicURL(const TopicName: string): string;
      {Gets fully specified topic URL from a topic name.
        @param TopicName [in] Name of topic (same as associated topic file,
          without the extension).
        @return Full topic URL.
      }
    class procedure DoAppHelp(const Command: LongWord;
      const TopicName: string; const Data: LongWord);
      {Calls the HtmlHelp API with a specified command and parameters.
        @param Command [in] Command to send to HTML Help.
        @param TopicName [in] Names an HTML topic file within the help file,
          without extension. May be '' if no specific topic is required.
        @param Data [in] Command dependent data to pass to HTML Help.
      }
  public
    class procedure Contents;
      {Displays help contents.
      }
    class procedure ShowTopic(Topic: string);
      {Displays a given help topic.
        @param Topic [in] Help topic to display. Topic is the name of the HTML
          file that stores the topic, without the extension.
      }
    class procedure ShowALink(const AKeyword: string; const ErrTopic: string);
      {Displays help topic(s) specified by an A-Link keyword.
        @param AKeyword [in] Required A-Link keyword.
        @param ErrTopic [in] Name of topic to display if keyword not found.
      }
    class procedure Quit;
      {Closes down the help system.
      }
  end;


const
  // Help topics
  // license topic
  cLicenseTopic = 'license';
  // topic displayed when a viewer has no associated topic
  cViewerErrTopic = 'viewer-nohelp';


implementation


uses
  // Delphi
  SysUtils;


{ THelpManager }

class procedure THelpManager.Contents;
  {Displays help contents.
  }
begin
  DoAppHelp(HH_DISPLAY_TOC, '', 0);
end;

class procedure THelpManager.DoAppHelp(const Command: LongWord;
  const TopicName: string; const Data: LongWord);
  {Calls the HtmlHelp API with a specified command and parameters.
    @param Command [in] Command to send to HTML Help.
    @param TopicName [in] Names an HTML topic file within the help file, without
      extension. May be '' if no specific topic is required.
    @param Data [in] Command dependent data to pass to HTML Help.
  }
var
  HelpURL: string; // URL of help file, or topic with help file
begin
  if TopicName = '' then
    HelpURL := HelpFileName
  else
    HelpURL := TopicURL(TopicName);
  HtmlHelp(GetDesktopWindow(), PChar(HelpURL), Command, Data);
end;

class function THelpManager.HelpFileName: string;
  {Gets name of help file.
    @return Fully qualified help file name.
  }
begin
  Result := ChangeFileExt(ParamStr(0), '.chm');
end;

class procedure THelpManager.Quit;
  {Closes down the help system.
  }
begin
  HtmlHelp(0, nil, HH_CLOSE_ALL, 0);
end;

class procedure THelpManager.ShowALink(const AKeyword: string;
  const ErrTopic: string);
  {Displays help topic(s) specified by an A-Link keyword.
    @param AKeyword [in] Required A-Link keyword.
    @param ErrTopic [in] Name of topic to display if keyword not found.
  }
var
  ALink: THHAKLink;   // structure containing details of A-Link
begin
  // Fill in A link structure
  ZeroMemory(@ALink, SizeOf(ALink));
  ALink.cbStruct := SizeOf(ALink);      // size of structure
  ALink.fIndexOnFail := False;
  ALink.pszUrl := PChar(TopicURL(ErrTopic));
  ALink.pszKeywords := PChar(AKeyword); // required keyword
  // Display help
  DoAppHelp(HH_ALINK_LOOKUP, '', LongWord(@ALink));
end;

class procedure THelpManager.ShowTopic(Topic: string);
  {Displays a given help topic.
    @param Topic [in] Help topic to display. Topic is the name of the HTML file
      that stores the topic, without the extension.
  }
begin
  DoAppHelp(HH_DISPLAY_TOPIC, Topic, 0);
end;


class function THelpManager.TopicURL(const TopicName: string): string;
  {Gets fully specified topic URL from a topic name.
    @param TopicName [in] Name of topic (same as associated topic file, without
      the extension).
    @return Full topic URL.
  }
begin
  Result := HelpFileName + '::/HTML/' + TopicName + '.htm';
end;

end.

