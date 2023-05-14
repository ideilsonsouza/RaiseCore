unit Core.Model.Mesagens;

{$IFDEF FPC}
{$mode ObjFPC}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils;

type
  TRecMensagens = record
    Nome: string;
    PTBR: string;
    ENG: string;
  end;
  
const
  MaxMsg = 2; //Quantidade de Mensagens;

resourcestring
  Mensagem_Falha_Configuracao = 'MFC';
  Mensagem_Dados_NaoEncontrado = 'DNEQ';

const
  RecMensagens: array[0..MaxMsg] of TRecMensagens = (
    (Nome: 'MFC'; 
    PTBR: 'Arquivo de configuração inválido ou ausente.';
    ENG: 'Error: something is wrong with the configuration file.'),

    (Nome: 'MFC1'; 
    PTBR: 'Arquivo de configuração inválido ou ausente.';
    ENG: 'Error: something is wrong with the configuration file.'),

    (Nome: 'DNEQ'; 
    PTBR: '{"erro":"Não foi encontrado nem um registro","mensagen":"Veifique a sua consuta e tente novamente"}';
    ENG: '{"erro":"Não foi encontrado nem um registro","mensagen":"Veifique a sua consuta e tente novamente"}')
    );

function GetMensagem(const Nome: string; const PT: boolean = True;
  const PTDefault: boolean = True): string;
  
implementation

function GetMensagem(const Nome: string; const PT: boolean = True;
  const PTDefault: boolean = True): string;
var
  I: integer;
begin
  Result := '';
  for I := Low(RecMensagens) to High(RecMensagens) do
  begin
    if LowerCase(RecMensagens[I].Nome) = LowerCase(Nome) then
    begin
      if PT then
        Result := RecMensagens[I].PTBR
      else
        Result := RecMensagens[I].ENG;
      Break;
    end;
  end;
  if Result = '' then
  begin
    if PTDefault then
      Result := 'Mensagem não encontrada'
    else
      Result := 'Message not found';
  end;
end;

end.  
