{
 * UClipFmt.pas
 *
 * Declares and registers custom Windows clipboard formats.
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
 * The Original Code is UClipFmt.pas.
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


unit UClipFmt;


interface


uses
  // Delphi
  Windows;


const

  // Redefinition of predefined clipboard formats

  CF_TEXT = Windows.CF_TEXT;
  CF_BITMAP = Windows.CF_BITMAP;
  CF_METAFILEPICT = Windows.CF_METAFILEPICT;
  CF_SYLK = Windows.CF_SYLK;
  CF_DIF = Windows.CF_DIF;
  CF_TIFF = Windows.CF_TIFF;
  CF_OEMTEXT = Windows.CF_OEMTEXT;
  CF_DIB = Windows.CF_DIB;
  CF_PALETTE = Windows.CF_PALETTE;
  CF_PENDATA = Windows.CF_PENDATA;
  CF_RIFF = Windows.CF_RIFF;
  CF_WAVE = Windows.CF_WAVE;
  CF_UNICODETEXT = Windows.CF_UNICODETEXT;
  CF_ENHMETAFILE = Windows.CF_ENHMETAFILE;
  CF_HDROP = Windows.CF_HDROP;
  CF_LOCALE = Windows.CF_LOCALE;
  CF_DIBV5 = Windows.CF_DIBV5;
  CF_DSPTEXT = Windows.CF_DSPTEXT;
  CF_DSPBITMAP = Windows.CF_DSPBITMAP;
  CF_DSPMETAFILEPICT = Windows.CF_DSPMETAFILEPICT;
  CF_DSPENHMETAFILE = Windows.CF_DSPENHMETAFILE;


var

  // Custom clipboard formats (registered below)

  // Shell format: file name as ANSI text
  CF_FILENAMEA: Word;
  // Shell format: file name as Unicode text
  CF_FILENAMEW: Word;
  /// Shell format: URL as ANSI text
  CF_INETURLA: Word;
  // Shell format: URL as Unicode text
  CF_INETURLW: Word;
  // Shell format: Description of object transfer operations for use in UI
  CF_OBJECTDESCRIPTOR: Word;
  // Shell format: Description of links in transfer operations for use in UI
  CF_LINKSRCDESCRIPTOR: Word;
  // Shell format: Shell ID list for a folder
  CF_IDLIST: Word;
  // Shell format: ANSI version of file group descriptor
  CF_FILEGROUPDESCRIPTORA: Word;
  // Shell format: Unicode version of file group descriptor
  CF_FILEGROUPDESCRIPTORW: Word;
  // Rich Edit Format code.
  CF_RTF: Word;
  // Rich Edit Format code with no objects.
  CF_RTFNOOBJS: Word;
  // Rich Edit Format code as text.
  CF_RTFASTEXT: Word;
  // HTML code snippets. Stored as text.
  CF_HTML: Word;
  // Complete HTML document. Stored as text.
  CF_HYPERTEXT: Word;
  // MIME: Plain text
  CF_MIME_PLAINTEXT: Word;
  // MIME: Rich text code
  CF_MIME_RICHTEXT: Word;
  // MIME: HTML code (may be partial document)
  CF_MIME_HTML: Word;
  // Complete HTML tag structure wrapping a selection
  CF_MIME_MOZHTMLCONTEXT: Word;


implementation


uses
  // Delphi
  ShlObj, RichEdit;


const
  // Names of custom clipboard formats
  CFSTR_FILENAMEA           = ShlObj.CFSTR_FILENAMEA;
  CFSTR_FILENAMEW           = ShlObj.CFSTR_FILENAMEW;
  CFSTR_INETURLA            = ShlObj.CFSTR_INETURLA;
  CFSTR_INETURLW            = ShlObj.CFSTR_INETURLW;
  CFSTR_OBJECTDESCRIPTOR    = 'Object Descriptor';
  CFSTR_LINKSRCDESCRIPTOR   = 'Link Source Descriptor';
  CFSTR_SHELLIDLIST         = ShlObj.CFSTR_SHELLIDLIST;
  CFSTR_FILEDESCRIPTORA     = ShlObj.CFSTR_FILEDESCRIPTORA;
  CFSTR_FILEDESCRIPTORW     = ShlObj.CFSTR_FILEDESCRIPTORW;
  CFSTR_HTML                = 'HTML Format';
  CFSTR_HYPERTEXT           = 'HTML (HyperText Markup Language)';
  CFSTR_RTF                 = RichEdit.CF_RTF;
  CFSTR_RTFNOOBJS           = RichEdit.CF_RTFNOOBJS;
  CFSTR_RTFASTEXT           = 'RTF As Text';
  CFSTR_MIME_PLAINTEXT      = 'text/plain';
  CFSTR_MIME_RICHTEXT       = 'text/richtext';
  CFSTR_MIME_HTML           = 'text/html';
  CFSTR_MIME_MOZHTMLCTX     = 'text/_moz_htmlcontext';


initialization

// Register custom clipboard formats
CF_FILENAMEA            := RegisterClipboardFormat(CFSTR_FILENAMEA);
CF_FILENAMEW            := RegisterClipboardFormat(CFSTR_FILENAMEW);
CF_INETURLA             := RegisterClipboardFormat(CFSTR_INETURLA);
CF_INETURLW             := RegisterClipboardFormat(CFSTR_INETURLW);
CF_RTF                  := RegisterClipboardFormat(CFSTR_RTF);
CF_RTFNOOBJS            := RegisterClipboardFormat(CFSTR_RTFNOOBJS);
CF_RTFASTEXT            := RegisterClipboardFormat(CFSTR_RTFASTEXT);
CF_HTML                 := RegisterClipboardFormat(CFSTR_HTML);
CF_HYPERTEXT            := RegisterClipboardFormat(CFSTR_HYPERTEXT);
CF_MIME_PLAINTEXT       := RegisterClipboardFormat(CFSTR_MIME_PLAINTEXT);
CF_MIME_RICHTEXT        := RegisterClipboardFormat(CFSTR_MIME_RICHTEXT);
CF_MIME_HTML            := RegisterClipboardFormat(CFSTR_MIME_HTML);
CF_MIME_MOZHTMLCONTEXT  := RegisterClipboardFormat(CFSTR_MIME_MOZHTMLCTX);
CF_OBJECTDESCRIPTOR     := RegisterClipboardFormat(CFSTR_OBJECTDESCRIPTOR);
CF_LINKSRCDESCRIPTOR    := RegisterClipboardFormat(CFSTR_LINKSRCDESCRIPTOR);
CF_IDLIST               := RegisterClipboardFormat(CFSTR_SHELLIDLIST);
CF_FILEGROUPDESCRIPTORA := RegisterClipboardFormat(CFSTR_FILEDESCRIPTORA);
CF_FILEGROUPDESCRIPTORW := RegisterClipboardFormat(CFSTR_FILEDESCRIPTORW);

end.

