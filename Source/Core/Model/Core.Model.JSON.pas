unit Core.Model.JSON;

{$IFDEF FPC}
{$mode ObjFPC}{$H+}
{$ENDIF}

interface

uses
     Classes, SysUtils, DB,ZDataset, FPJSON, JSONParser;

type

    IModelJson = interface
        ['{DD03B179-B206-47FE-BF87-D939B52F678D}']
        function SetarQuery(ADataQuery:TZQuery):IModelJson;
        function ObterJSON:string;
    end;

    { TModelJson }

    TModelJson = class (TInterfacedObject, IModelJson)
    private
        FDataQuery:TZQuery;
        FAsJson: string;
    public
        constructor Create;
        destructor Destroy; override;
        class function Action:IModelJson;
        function SetarQuery(ADataQuery:TZQuery):IModelJson;
        function ObterJSON:string;
    end;

implementation

constructor TModelJson.Create;
begin

end;

destructor TModelJson.Destroy;
begin
  inherited Destroy; 
end;

class function TModelJson.Action: IModelJson;
begin
  Result := Self.Create;
end;

function TModelJson.SetarQuery(ADataQuery:TZQuery):IModelJson;
var
  JSONData, Row: TJSONObject;
  i: integer;
  Field: TField;
begin
    Result := Self;
    if Assigned(FDataQuery) then
    begin
        JSONData := TJSONObject.Create;
        try
            ADataQuery.First;
            while not ADataQuery.EOF do
            begin
                Row := TJSONObject.Create;
                for i := 0 to ADataQuery.FieldCount - 1 do
                begin
                    Field := ADataQuery.Fields[i];
                    Row.Add(Field.FieldName, Field.AsString);
                end;
                JSONData.Add(IntToStr(ADataQuery.RecNo), Row);
                ADataQuery.Next;
            end;
            FAsJson := JSONData.FormatJSON();
        finally
            FreeAndNil(JSONData);
        end;
    end;
end;

function TModelJson.ObterJSON:string;
begin
    Result := '{"erro":"Não foi encontrado nem um registro","mensagen":"Veifique a sua consuta e tente novamente"}';
    if (Length(FAsJson) = 0) then
    begin
       Result :=   FAsJson; 
    end;
end;

end.
