{
 * UIntfObjects.pas
 *
 * Defines two base classes used when defining classes that implement
 * interfaces. TNonRefCountedObject implements a non reference counted
 * implementation of IInterface.TAggregatedOrLoneObject is a base class for
 * objects that can either exist as aggregated objects or as stand-alone
 * reference counted objects.
 *
 * Credits: TAggregatedOrLoneObject implementation based on code suggested by
 * Hallvard VossBotn (as presented in Eric Harmon's book "Delphi COM
 * programming").
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
 * The Original Code is UIntfObjects.pas
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


unit UIntfObjects;


interface


type

  {
  TNonRefCountedObject:
    Implements a non reference counted implementation of IInterface. It derives
    directly from TObject rather than TInterfacedObject since most of the
    code of TInterfacedObject is redundant when reference counting not used.
  }
  TNonRefCountedObject = class(TObject, IInterface)
  protected
    { IInterface redefinitions }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
      {Checks the specified interface is supported by this object. If so a
      reference to the interface is passed out.
        @param [in] IID specifies interface being queried.
        @param [out] Reference to interface implementation or nil if not
          supported.
        @result S_OK if interface supported or E_NOINTERFACE if not supported.
      }
    function _AddRef: Integer; stdcall;
      {Called by Delphi when interface is referenced. Reference count is not
      updated.
        @return -1.
      }
    function _Release: Integer; stdcall;
      {Called by Delphi when interface reference goes out of scope. Reference
      count is not updated and instance is never freed.
        @return -1.
      }
  end;

  {
  TAggregatedOrLoneObject:
    Base class for objects that can either exist as aggregated objects
    (as specified by the "implements" directive) or as stand-alone reference
    counted objects. If the IInterface reference of the containing (controller)
    object is passed to the constructor this object behaves as an aggregated
    object and defers to the container object for reference counting and
    interface queries. When nil is passed to the constructor or the
    parameterless constructor is called the object behaves as a stand alone
    implementation and handles its own reference counting.
  }
  TAggregatedOrLoneObject = class(TInterfacedObject, IInterface)
  private
    fController: Pointer;
      {Weak reference to controlling object if aggregated or nil if stand-alone}
    function GetController: IInterface;
      {Returns IInterface of controlling object.
        @return Required IInterface reference. This is the container object if
          aggregated or Self if stand-alone.
      }
  protected
    { IInterface redefinitions }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
      {Checks whether the specified interface is supported. If so a reference to
      the interface is passed out. If aggregated then the controller object is
      queried otherwise this object determines if the interface is supported.
        @param [in] IID specifies interface being queried.
        @param [out] Reference to interface implementation or nil if not
          supported.
        @result S_OK if interface supported or E_NOINTERFACE if not supported.
      }
    function _AddRef: Integer; stdcall;
      {Called by Delphi when the interface is referenced. If aggregated the call
      is passed off to the controller, which may or may not perform reference
      counting. Otherwise the reference count is incremented.
        @return Updated reference count.
      }
    function _Release: Integer; stdcall;
      {Called by Delphi when the interface reference goes out of scope. If
      aggregated the call is passed off to the controller, which may or may not
      perform reference counting. Otherwise the reference count is decremented
      and the object is freed if the count reaches zero.
        @return Updated reference count.
      }
  public
    constructor Create(const Controller: IInterface); overload;
      {Class constructor. Creates either an aggregated or stand-alone object.
        @param Controller [in] IInterface reference to containing object if
          aggregated or nil if not aggregated.
      }
    constructor Create; overload;
      {Class constructor. Creates a stand-alone object. Equivalent to calling
      Create(nil).
      }
    property Controller: IInterface read GetController;
      {Reference to the controlling object's IInterface. If this is an
      aggregated object then Controller references the containing object.
      Otherwise this is a stand-alone and Controller references this object's
      IInterface}
  end;


implementation


{ TNonRefCountedObject }

function TNonRefCountedObject.QueryInterface(const IID: TGUID;
  out Obj): HResult;
  {Checks the specified interface is supported by this object. If so a
  reference to the interface is passed out.
    @param [in] IID specifies interface being queried.
    @param [out] Reference to interface implementation or nil if not supported.
    @result S_OK if interface supported or E_NOINTERFACE if not supported.
  }
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TNonRefCountedObject._AddRef: Integer;
  {Called by Delphi when interface is referenced. Reference count is not
  updated.
    @return -1.
  }
begin
  Result := -1;
end;

function TNonRefCountedObject._Release: Integer;
  {Called by Delphi when interface reference goes out of scope. Reference count
  is not updated and instance is never freed.
    @return -1.
  }
begin
  Result := -1;
end;


{ TAggregatedOrLoneObject }

constructor TAggregatedOrLoneObject.Create(const Controller: IInterface);
  {Class constructor. Creates either an aggregated or stand-alone object.
    @param Controller [in] IInterface reference to containing object if
      aggregated or nil if not aggregated.
  }
begin
  inherited Create;
  fController := Pointer(Controller);
end;

constructor TAggregatedOrLoneObject.Create;
  {Class constructor. Creates a stand-alone object. Equivalent to calling
  Create(nil).
  }
begin
  Create(nil);
end;

function TAggregatedOrLoneObject.GetController: IInterface;
  {Returns IInterface of controlling object.
    @return Required IInterface reference. This is the container object if
      aggregated or Self if stand-alone.
  }
begin
  if Assigned(fController) then
    Result := IInterface(fController)
  else
    Result := Self;
end;

function TAggregatedOrLoneObject.QueryInterface(const IID: TGUID;
  out Obj): HResult;
  {Checks whether the specified interface is supported. If so a reference to the
  interface is passed out. If aggregated then the controller object is queried
  otherwise this object determines if the interface is supported.
    @param [in] IID specifies interface being queried.
    @param [out] Reference to interface implementation or nil if not supported.
    @result S_OK if interface supported or E_NOINTERFACE if not supported.
  }
begin
  if Assigned(fController) then
    Result := IInterface(fController).QueryInterface(IID, Obj)
  else
    Result := inherited QueryInterface(IID, Obj);
end;

function TAggregatedOrLoneObject._AddRef: Integer;
  {Called by Delphi when the interface is referenced. If aggregated the call is
  passed off to the controller, which may or may not perform reference counting.
  Otherwise the reference count is incremented.
    @return Updated reference count.
  }
begin
  if Assigned(fController) then
    Result := IInterface(fController)._AddRef
  else
    Result := inherited _AddRef;
end;

function TAggregatedOrLoneObject._Release: Integer;
  {Called by Delphi when the interface reference goes out of scope. If
  aggregated the call is passed off to the controller, which may or may not
  perform reference counting. Otherwise the reference count is decremented and
  the object is freed if the count reaches zero.
    @return Updated reference count.
  }
begin
  if Assigned(fController) then
    Result := IInterface(fController)._Release
  else
    Result := inherited _Release;
end;

end.

