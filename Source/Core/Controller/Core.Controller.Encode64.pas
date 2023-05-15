unit Core.Controller.Encode64;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

interface

uses
  SysUtils;

function Encode64(AsString:string):string;
function Decode64(AsString:string):string;

implementation

const
  Codes64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';


function Base64Encode(const Data: TBytes): string;
const
  BASE64_CODES: array [0 .. 63] of Char = Codes64;
var
  InputLength, OutputLength, i, j: Integer;
  InputTriplet: array [0 .. 2] of Byte;
  OutputQuartet: array [0 .. 3] of Char;
begin
  InputLength := Length(Data);
  OutputLength := ((InputLength + 2) div 3) * 4;
  SetLength(Result, OutputLength);

  i := 0;
  j := 0;
  while i < InputLength do
  begin
    InputTriplet[0] := Data[i];
    InputTriplet[1] := 0;
    InputTriplet[2] := 0;

    Inc(i);
    if i < InputLength then
    begin
      InputTriplet[1] := Data[i];

      Inc(i);
      if i < InputLength then
      begin
        InputTriplet[2] := Data[i];
        Inc(i);
      end;
    end;

    OutputQuartet[0] := BASE64_CODES[(InputTriplet[0] and $FC) shr 2];
    OutputQuartet[1] := BASE64_CODES[((InputTriplet[0] and $03) shl 4) or
      ((InputTriplet[1] and $F0) shr 4)];
    OutputQuartet[2] := BASE64_CODES[((InputTriplet[1] and $0F) shl 2) or
      ((InputTriplet[2] and $C0) shr 6)];
    OutputQuartet[3] := BASE64_CODES[InputTriplet[2] and $3F];

    if j < OutputLength then
      Result[j + 1] := OutputQuartet[0];

    if j + 1 < OutputLength then
      Result[j + 2] := OutputQuartet[1];

    if j + 2 < OutputLength then
      Result[j + 3] := OutputQuartet[2];

    if j + 3 < OutputLength then
      Result[j + 4] := OutputQuartet[3];

    Inc(j, 4);
  end;

  for i := Length(Result) downto 1 do
  begin
    if Result[i] = '=' then
      Delete(Result, i, 1)
    else
      Break;
  end;

  Result := Result + StringOfChar('=', OutputLength - Length(Result));
end;

function Base64Decode(const EncodedStr: string): TBytes;
const
  Base64Table: array[0..79] of Byte = (
    $3e, $ff, $ff, $ff, $3f, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09,
    $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19,
    $ff, $ff, $ff, $ff, $ff, $ff, $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23,
    $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f, $30, $31, $32, $33
  );
var
  i, k, x: Integer;
  p: PByte;
begin
  Result := nil;
  if Length(EncodedStr) mod 4 <> 0 then Exit;

  SetLength(Result, (Length(EncodedStr) div 4) * 3);
  p := @Result[0];

  for i := 1 to Length(EncodedStr) div 4 do
  begin
    x := Base64Table[Ord(EncodedStr[(i - 1) * 4 + 1]) - 43];
    x := (x shl 6) or Base64Table[Ord(EncodedStr[(i - 1) * 4 + 2]) - 43];
    x := (x shl 6) or Base64Table[Ord(EncodedStr[(i - 1) * 4 + 3]) - 43];
    x := (x shl 6) or Base64Table[Ord(EncodedStr[(i - 1) * 4 + 4]) - 43];

    if x and $FF0000 <> 0 then
    begin
      k := x shr 16;
      p^ := k;
      Inc(p);
    end;

    if x and $FF00 <> 0 then
    begin
      k := (x shr 8) and $FF;
      p^ := k;
      Inc(p);
    end;

    k := x and $FF;
    p^ := k;
    Inc(p);
  end;

  SetLength(Result, NativeUInt(p) - NativeUInt(@Result[0]));

end;

function Encode64(AsString:string):string;
var
  bytes: TBytes;
begin
  bytes := TEncoding.UTF8.GetBytes(AsString);
  Result :=  Base64Encode(bytes);
end;

function Decode64(AsString:string):string;
var
  bytes: TBytes;
begin
  bytes := Base64Decode (AsString);
 Result := TEncoding.UTF8.GetString(Bytes);
end;

end.