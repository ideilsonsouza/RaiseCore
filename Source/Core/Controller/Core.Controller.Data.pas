unit Core.Controller.Data;

{$IFDEF FPC}
{$mode ObjFPC}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils, Core.Model.Data;

type

  IConfiguracao = interface
    ['{ECBDA6AE-A73E-4C34-A983-42ADFEB39B04}']
    function ListarProtocolo(Lista: TStrings): IConfiguracao;
    function ExibirDados(EnviarDados: TEnviarDados): IConfiguracao;
    function SalvarDados(Protocolo, Servidor, Porta, Usuario, Senha, Banco: string): IConfiguracao;
    function RegistrarErro(aModulo, aErro: string): IConfiguracao;
  end;

  IDados = interface
    ['{4C516F0F-2262-4DC1-B921-D585B3B1DF6F}']
    function SelecionarTabela(Readcommand: string): string;
    function InserirRegistro(InsertCommand: string): boolean;
    function AtualizarRegistro(UpdateCommand: string): boolean;
    function DeletarRegistro(DeleteCommand: string): boolean;
  end;

  TConfiguracao = class(TInterfacedObject, IConfiguracao)
  private

  public
    constructor Create;
    destructor Destroy; override;
    function ListarProtocolo(Lista: TStrings): IConfiguracao;
    function ExibirDados(EnviarDados: TEnviarDados): IConfiguracao;
    function SalvarDados(Protocolo, Servidor, Porta, Usuario, Senha, Banco: string): IConfiguracao;
    function RegistrarErro(aModulo, aErro: string): IConfiguracao;
    class function Action: IConfiguracao;
  end;

  TDados = class(TInterfacedObject, IDados)
  private

  public
    constructor Create;
    destructor Destroy; override;
    class function Action: IDados;
    function SelecionarTabela(Readcommand: string): string;
    function InserirRegistro(InsertCommand: string): boolean;
    function AtualizarRegistro(UpdateCommand: string): boolean;
    function DeletarRegistro(DeleteCommand: string): boolean;
  end;

implementation

constructor TConfiguracao.Create;
begin

end;

destructor TConfiguracao.Destroy;
begin
  inherited Destroy;
end;

class function TConfiguracao.Action: IConfiguracao;
begin
  Result := Self.Create;
end;

function TConfiguracao.ListarProtocolo(Lista: TStrings): IConfiguracao;
begin
  Result := Self;
  if Assigned(Lista) then
    TModelConfiguracao.Action.ListarProtocolo(Lista)
  else
    Exit;
end;

function TConfiguracao.ExibirDados(EnviarDados: TEnviarDados): IConfiguracao;
begin
  Result := Self;
  TModelConfiguracao.Action.ExibirDados(EnviarDados);
end;

function TConfiguracao.SalvarDados(Protocolo, Servidor, Porta, Usuario, Senha, Banco: string): IConfiguracao;
begin
  Result := Self;
  if (Length(Protocolo) = 0) then
    raise Exception.Create('Esta faltando informações, verifique o protocolo!');

  if (Length(Banco) = 0) then
    raise Exception.Create(
      'Esta faltando informações, verifique o nome do banco dedados');

  TModelConfiguracao.Action.SalvarDados(Protocolo, Servidor, Porta,
    Usuario, Senha, Banco);
end;

function TConfiguracao.RegistrarErro(aModulo, aErro: string): IConfiguracao;
begin
  Result := Self;
  TModelConfiguracao.Action.RegistrarErro(aModulo, aErro);
end;

{##########################################################################################################}

constructor TDados.Create;
begin

end;

destructor TDados.Destroy;
begin
  inherited Destroy;
end;

class function TDados.Action: IDados;
begin
  Result := Self.Create;
end;

function TDados.SelecionarTabela(Readcommand: string): string;
begin
  if not Length(Readcommand) = 0 then
  begin
    if not UpperCase(Trim(Readcommand)).StartsWith('SELECT') then
      raise Exception.Create(
        'Sua consulta não esta correta!, Verifique e tente novamente');
    Result := TModelConnection.Action.SelecionarTabela(Readcommand);
  end
  else
    raise Exception.Create('Sua consulta não esta correta!, Verifique e tente novamente');
end;

function TDados.InserirRegistro(InsertCommand: string): boolean;
begin
  if not UpperCase(Trim(InsertCommand)).StartsWith('INSERT INTO ') then
    raise Exception.Create('Comando InserirR inválido');
  Result := TModelConnection.Action.ExecutarComandoSQL(InsertCommand);
end;

function TDados.AtualizarRegistro(UpdateCommand: string): boolean;
begin
  if not UpperCase(Trim(UpdateCommand)).StartsWith('UPDATE') then
    raise Exception.Create('Comando Atualizar inválido');
  Result := TModelConnection.Action.ExecutarComandoSQL(UpdateCommand);
end;

function TDados.DeletarRegistro(DeleteCommand: string): boolean;
begin
  if not UpperCase(Trim(DeleteCommand)).StartsWith('DELETE') then
    raise Exception.Create('Comando Deletar inválido');
  Result := TModelConnection.Action.ExecutarComandoSQL(DeleteCommand);
end;

end.
