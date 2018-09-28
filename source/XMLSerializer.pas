{
    XMLSerializer - writes XML data from components to disk
    Copyright (C) 2001  JWB Software

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Web:   http://people.zeelandnet.nl/famboek/txmlserializer/
    Email: jwbsoftware@zeelandnet.nl
}

unit XMLSerializer;

interface

uses Classes, XMLDoc, XMLIntf, TypInfo, Variants, SysUtils, XmlDom;

type
  TXMLSerializer = class(TComponent)
  private
    XMLData: IXMLDocument;
    FFilename: TFilename;

    procedure SetXML(Value:TStrings);
    function GetXML: TStrings;

    procedure SetFilename(Value:TFilename);
    procedure SetEncoding(Value:DomString);
    procedure SetStandalone(Value:DomString);
    procedure SetVersion(Value:DomString);

    function GetFilename: TFilename;
    function GetEncoding:DomString;
    function GetStandalone:DomString;
    function GetVersion:DomString;

    procedure InitVarTypes;
    function StringToVarType(VarString:String):TVarType;
    function VarTypeToString(VarType:TVarType):String;
  public
    constructor Create(AOwner: TComponent); override;

    procedure SaveObject(Instance:TPersistent; Name:String);
    procedure LoadObject(Instance:TPersistent; Name:String);

    function LoadFile: Boolean;
    function SaveFile: Boolean;
  published
    property XMLText: TStrings read GetXML write SetXML;
    property Filename: TFilename read GetFilename write SetFilename;
    property Encoding: DomString read GetEncoding write SetEncoding;
    property Standalone: DomString read GetStandalone write SetStandalone;
    property Version: DomString read GetVersion write SetVersion;
  end;

var
  VarTypes: array[$0000..$4000] of String;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Custom', [TXMLSerializer]);
end;

constructor TXMLSerializer.Create(AOwner: TComponent);
var
  DocumentElement: IXMLNode;
begin
  inherited;

  XMLData := NewXMLDocument;
  XMLData.Options := [doNodeAutoIndent];

  DocumentElement := XMLData.CreateElement('classes', '');
  XMLData.DocumentElement := DocumentElement;
  XMLData.Encoding := 'ISO-8859-1';
  XMLData.Version := '1.0';
  XMLData.Standalone := 'yes';

  XMLData.Active := True;
end;

procedure TXMLSerializer.InitVarTypes;
begin
  VarTypes[varEmpty] := 'Empty';
  VarTypes[varNull] := 'Null';
  VarTypes[varSmallint] := 'Smallint';
  VarTypes[varInteger] := 'Integer';
  VarTypes[varSingle] := 'Single';
  VarTypes[varDouble] := 'Double';
  VarTypes[varCurrency] := 'Currency';
  VarTypes[varDate] := 'Date';
  VarTypes[varOleStr] := 'OleStr';
  VarTypes[varDispatch] := 'Dispatch';
  VarTypes[varError] := 'Error';
  VarTypes[varBoolean] := 'Boolean';
  VarTypes[varVariant] := 'Variant';
  VarTypes[varUnknown] := 'Unknown';
  VarTypes[varShortInt] := 'ShortInt';
  VarTypes[varByte] := 'Byte';
  VarTypes[varWord] := 'Word';
  VarTypes[varLongWord] := 'LongWord';
  VarTypes[varInt64] := 'Int64';
  VarTypes[varStrArg] := 'StrArg';
  VarTypes[varString] := 'String';
  VarTypes[varAny] := 'Any';
  VarTypes[varTypeMask] := 'TypeMask';
  VarTypes[varArray] := 'Array';
  VarTypes[varByRef] := 'ByRef';
end;

function TXMLSerializer.VarTypeToString(VarType:TVarType):String;
begin
  InitVarTypes;
  Result := VarTypes[VarType];
end;

function TXMLSerializer.StringToVarType(VarString:String):TVarType;
var
  Count: Integer;
begin
  InitVarTypes;

  Result := 0;

  for Count := $0000 to $4000 do
  begin
    if (VarTypes[Count] = VarString) then
    begin
      Result := Count;
      Exit;
    end;
  end;
end;

procedure TXMLSerializer.LoadObject(Instance:TPersistent; Name:String);
var
  Count: Integer;
  Node: IXMLNode;
  VariantData: Variant;
begin
  XMLData.Active := True;

  repeat
    Node := XMLData.DocumentElement.ChildNodes.FindNode(Name);

    if Node <> nil then
    begin
      if (Node.Attributes['classname'] = Instance.ClassName) then
      begin
        for Count := 0 to Node.ChildNodes.Count-1 do
        begin
          if not(VarIsNull(Node.ChildNodes.Nodes[Count].NodeValue)) then
          begin
            VariantData := VarAsType(Node.ChildNodes.Nodes[Count].NodeValue,StringToVarType(Node.ChildNodes.Nodes[Count].Attributes['type']));
            if IsPublishedProp(Instance,Node.ChildNodes.Nodes[Count].Attributes['name']) then
              SetPropValue(Instance,Node.ChildNodes.Nodes[Count].Attributes['name'],VariantData);
          end;
        end;
      end;
    end;
  until not(Node = nil);
end;

function TXMLSerializer.LoadFile: Boolean;
var
  FilStr: String;
  mStream: TMemoryStream;
begin
  if FileExists(FFilename) then
  begin
    mStream := TMemoryStream.Create;
    mStream.LoadFromFile(FFilename);
    SetLength(FilStr, mStream.Size);
    mStream.Read(FilStr[1], Length(FilStr));
    mStream.Free;

    XMLData.XML.Text := FilStr;
    XMLData.Active := True;

    Result := True;
  end
  else
  begin
    Result := False;
  end;
end;

function TXMLSerializer.SaveFile: Boolean;
var
  FilStr: String;
  mStream: TMemoryStream;
begin
  try
    FilStr := XMLData.XML.Text;

    mStream := TMemoryStream.Create;
    mStream.Write(FilStr[1],Length(FilStr));
    mStream.SaveToFile(FFilename);
    mStream.Free;

    Result := True;
  except
    Result := False;
  end;
end;

procedure TXMLSerializer.SaveObject(Instance:TPersistent;Name:String);
var
  I, Count: Integer;
  PropInfo: PPropInfo;
  PropList: PPropList;
  PropValue: Variant;
  PropType: PPTypeInfo;
  PropReturnValue: Word;
  ChildNode: IXMLNode;
  Node: IXMLNode;
begin
  XMLData.Active := True;

  repeat
    ChildNode := XMLData.DocumentElement.ChildNodes.FindNode(Name);
    if ChildNode <> nil then
    begin
      if (ChildNode.Attributes['classname'] = Instance.ClassName) then
        XMLData.DocumentElement.ChildNodes.Remove(ChildNode);
    end;
  until ChildNode = nil;

  ChildNode := XMLData.DocumentElement.AddChild(Name);

  ChildNode.Attributes['classname'] := Instance.ClassName;

  Count := GetTypeData(Instance.ClassInfo)^.PropCount;
  if Count > 0 then
  begin
    GetMem(PropList, Count * SizeOf(Pointer));
    try
      GetPropInfos(Instance.ClassInfo, PropList);
      for I := 0 to Count - 1 do
      begin
        PropInfo := PropList^[I];
        PropType := PropList^[i].PropType;

        if (PropInfo <> nil) and (not(PropType^.Kind = tkMethod)) and (not(PropType^.Kind = tkClass)) then
        begin
          PropValue := GetPropValue(Instance,PropInfo.Name,False);
          PropReturnValue := VarType(PropValue);

          Node := ChildNode.AddChild('data');
          Node.Attributes['name'] := PropInfo.Name;
          Node.Attributes['type'] := VarTypeToString(PropReturnValue);
          Node.NodeValue := VarToStr(PropValue);
        end;
      end;
    finally
      FreeMem(PropList, Count * SizeOf(Pointer));
    end;
  end;
end;

procedure TXMLSerializer.SetXML(Value:TStrings);
begin
  XMLData.XML := Value;
  XMLData.Active := True;
end;

function TXMLSerializer.GetXML: TStrings;
begin
  Result := XMLData.XML;
end;

procedure TXMLSerializer.SetFilename(Value:TFilename);
begin
  FFilename := Value;
end;

function TXMLSerializer.GetFilename: TFilename;
begin
  Result := FFilename;
end;

procedure TXMLSerializer.SetEncoding(Value:DomString);
begin
  XMLData.Active := True;
  XMLData.Encoding := Value;
end;

procedure TXMLSerializer.SetStandalone(Value:DomString);
begin
  XMLData.Active := True;
  XMLData.Standalone := Value;
end;

procedure TXMLSerializer.SetVersion(Value:DomString);
begin
  XMLData.Active := True;
  XMLData.Version := Value;
end;

function TXMLSerializer.GetEncoding:DomString;
begin
  XMLData.Active := True;
  Result := XMLData.Encoding;
end;

function TXMLSerializer.GetStandalone:DomString;
begin
  XMLData.Active := True;
  Result := XMLData.Standalone;
end;

function TXMLSerializer.GetVersion:DomString;
begin
  XMLData.Active := True;
  Result := XMLData.Version;
end;

end.
