
//--- ItemIDList manipulation --------------------------------------------------
//
// These routines are for the manipulation of ItemIDList variables that
// are used extensively by the Windows Shell.
//
// They are based on routines written by Brad Stowers in his SystemTreeView
// component.
//
// Freeware - you get it for nothing - I make no promises
//
// Version 1.0  4-8-98 Grahame Marsh - poached from Brad's work
//                     PIDLSize, CreateEmptyPIDL, ConcatPIDL, CopyPIDL,
//                     CreateSimplePIDL, NextPIDL
//
// Version 1.1  26-12-2010 Peter Johnson (www.delphidabbler.com) - fixed to work
//                     with Unicode Delphis where PChar = PWideChar.
//
//------------------------------------------------------------------------------

unit IDLUtils;

interface

uses
  Windows, ActiveX, ShlObj;

// Our interface to the shell memory allocator, obtained and released automatically.
// available for use during the lifetime of this unit.
var
  ShellMalloc : IMalloc =  nil;

// Returns the length of the PIDL or 0 for a nil or empty PIDL
function PIDLSize (PIDL: PItemIDList) : integer;

// Creates a PIDL of a given size, all bytes set to zero
// returns nil if memory allocation fails
function CreateEmptyPIDL (Size : uint): PItemIDList;

// Create a new PIDL given two PIDLS by concatation.  PIDL1 may be nil in
// which case a new PIDL is created containing PIDL2 only; copy in effect.
function ConcatPIDLs (PIDL1, PIDL2: PItemIDList) : PItemIDList;
// not rocket science given the above
function CopyPIDL (PIDL : PItemIDList) : PItemIDList;

// Scan a PIDL for the next element of the given PIDL, returns a pointer
// to the position or nil if already at the end
function NextPIDL (PIDL: PItemIDList): PItemIDList;

// Extract the current element of the given PIDL and return it as a new PIDL,
// returns nil if memory allocation fails
function CreateSimplePIDL (PIDL : PItemIDList): PItemIDList;

implementation

function PIDLSize (PIDL: PItemIDList) : integer;
begin
  Result := 0;
  if Assigned (PIDL) then
  begin
    inc (Result, SizeOf (PIDL^.mkid.cb));
    while PIDL^.mkid.cb <> 0 do
    begin
      inc (Result, pidl^.mkid.cb);
      inc (longint(PIDL), PIDL^.mkid.cb)
    end
  end
end;

function CreateEmptyPIDL (Size : uint): PItemIDList;
begin
  Result := ShellMalloc.Alloc (Size);
  if Assigned (Result) then
    ZeroMemory (Result, Size)
end;

function ConcatPIDLs (PIDL1, PIDL2: PItemIDList) : PItemIDList;
var
  Size1,
  Size2: integer;
begin
  if Assigned (PIDL1) then
    Size1 := PIDLSize (PIDL1) - SizeOf (PIDL1.mkid.cb)
  else
    Size1 := 0;
  Size2 := PIDLSize (PIDL2);
  Result := CreateEmptyPIDL (Size1 + Size2);
  if Assigned (Result) then
  begin
    if Assigned (PIDL1) then
      Move (PIDL1^, Result^, Size1);
//  PJ 26-12-2010 - replaced use of PChar with PByte (use of PChar breaks code
//                  when PChar = PWideChar as on Unicode Delphis - use PByte
//                  instead which should work on all Delphis
//    Move (PIDL2^, PChar(Result)[Size1], Size2)
    Move (PIDL2^, PByte(Result)[Size1], Size2)
  end
end;

function CopyPIDL (PIDL: PItemIDList): PItemIDList;
begin
  Result := ConcatPIDLs (nil, PIDL)
end;

function NextPIDL (PIDL: PItemIDList): PItemIDList;
begin
  if PIDL.mkid.cb > 0 then
    Result := PItemIDList (Longint(PIDL) + PIDL.mkid.cb)
  else
    Result := nil
end;

function CreateSimplePIDL (PIDL : PItemIDList): PItemIDList;
var
  Size: integer;
begin
  Size := PIDL.mkid.cb + SizeOf (PIDL.mkid.cb);
  Result := CreateEmptyPIDL (Size);
  if Assigned (Result) then
    Move (PIDL^, Result^, PIDL.mkid.cb)
end;

initialization
  SHGetMalloc (ShellMalloc)
finalization
  ShellMalloc := nil
end.

