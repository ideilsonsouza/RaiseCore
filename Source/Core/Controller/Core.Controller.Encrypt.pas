unit Core.Controller.Encrypt;

 {
   By: Ideilson Souza - Desenvolvedor;
   Data: 30/04/2023
   Hora: 02:50:40
   IDE: Lazarus v2.2.6
   FPC: 3.2.2-210709
 }

 {$IFDEF FPC}
   {$mode objfpc}{$H+}
 {$ENDIF}

interface

uses
  Classes, SysUtils, IdHashMessageDigest, Core.Controller.Encode64;

type
  TCodeOperation = (Md5, Encode, Decode);

function CodeString(const Input: string; Operation: TCodeOperation): string;  overload;
function CodeString(const Input: string; Operation: TCodeOperation;  CodeKey: string): string; overload;
function CodeCompare(const Input, ValueCompare: string;  Operation: TCodeOperation): boolean;

implementation

function CodeString(const Input: string; Operation: TCodeOperation): string;
begin
  Result := CodeString(Input, Operation, 'Default');
end;

function CodeString(const Input: string; Operation: TCodeOperation;
  CodeKey: string): string;
var
  vInput: string;
  idmd5: TIdHashMessageDigest5;
  KeyLen: integer;
  KeyPos: integer;
  OffSet: integer;
  Dest, Key: string;
  SrcPos: integer;
  SrcAsc: integer;
  TmpSrcAsc: integer;
  Range: integer;
begin
  if not (Input = EmptyStr) then
    vInput := Input
  else
    Exit('');

  Key := CodeKey;
  Dest := '';
  KeyLen := Length(Key);
  KeyPos := 0;
  SrcPos := 0;
  SrcAsc := 0;
  Range := 256;

  case Operation of
    MD5:
    begin
      idmd5 := TIdHashMessageDigest5.Create;
      try
        Result := idmd5.HashStringAsHex(vInput);
      finally
        idmd5.Free;
      end;
    end;
    Encode:
    begin
      Randomize;
      OffSet := Random(Range);
      Dest := Format('%1.2x', [OffSet]);
      for SrcPos := 1 to Length(vInput) do
      begin
        // Application.ProcessMessages;
        SrcAsc := (Ord(vInput[SrcPos]) + OffSet) mod 255;
        if KeyPos < KeyLen then
          KeyPos := KeyPos + 1
        else
          KeyPos := 1;
        SrcAsc := SrcAsc xor Ord(Key[KeyPos]);
        Dest := Dest + Format('%1.2x', [SrcAsc]);
        OffSet := SrcAsc;
      end;
      Result := Encode64(Dest);
    end;
    Decode:
    begin
      vInput := Decode64(Input);
      OffSet := StrToInt('$' + copy(vInput, 1, 2));
      SrcPos := 3;
      repeat
        SrcAsc := StrToInt('$' + copy(vInput, SrcPos, 2));
        if (KeyPos < KeyLen) then
          KeyPos := KeyPos + 1
        else
          KeyPos := 1;
        TmpSrcAsc := SrcAsc xor Ord(Key[KeyPos]);
        if TmpSrcAsc <= OffSet then
          TmpSrcAsc := 255 + TmpSrcAsc - OffSet
        else
          TmpSrcAsc := TmpSrcAsc - OffSet;
        Dest := Dest + Chr(TmpSrcAsc);
        OffSet := SrcAsc;
        SrcPos := SrcPos + 2;
      until (SrcPos >= Length(vInput));
      Result := Dest;
    end;
  end;
end;

function CodeCompare(const Input, ValueCompare: string;
  Operation: TCodeOperation): boolean;
begin
  Result := (Input = CodeString(ValueCompare, Operation));
end;

end.
