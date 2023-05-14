unit Core.Model.Data;

{$IFDEF FPC}
{$mode ObjFPC}{$H+}
{$ENDIF}

interface

uses
{$IFDEF FPC}
     Classes, SysUtils, DB, ZConnection, ZDataset;
{$ENDIF}

type
    TEnviarDados = procedure(Protocolo, Servidor, Porta, Usuario, Senha, Banco: string) of object;

    IModelConfiguracao = interface
        ['{ECBDA6AE-A73E-4C34-A983-42ADFEB39B04}'] 
        function ListarProtocolo(Lista: TStrings): IModelConfiguracao;
        function ExibirDados(EnviarDados: TEnviarDados): IModelConfiguracao; 
        function SalvarDados(const Protocolo, Servidor, Porta, Usuario, Senha, Banco: string): IModelConfiguracao;
        function RegistrarErro(aModulo, aErro: string): IModelConfiguracao;
      end;

    IModelConnection = interface
        ['{7157578B-7DC4-4040-B567-E1792D84A396}']
        function SelecionarTabela(Readcommand:string): string;
        function ExecutarComandoSQL(WriteCommand: string): boolean;
    end;

    { TModelConfiguracao }

    TModelConfiguracao = class (TInterfacedObject, IModelConfiguracao)
    private
        FExibirDados:TEnviarDados;
    public
        constructor Create;
        destructor Destroy; override;
        function ListarProtocolo(Lista: TStrings): IModelConfiguracao;
        function ExibirDados(EnviarDados: TEnviarDados): IModelConfiguracao; 
        function SalvarDados(const Protocolo, Servidor, Porta, Usuario, Senha, Banco: string): IModelConfiguracao;
        function RegistrarErro(aModulo, aErro: string): IModelConfiguracao;
        class function Action:IModelConfiguracao;
    end;  

    TModelConexao = class (TInterfacedObject, IModelConnection)
    private
        FConexao:TZConnection;
        function TestarConexao: boolean;
    public
        constructor Create;
        destructor Destroy; override; 
        function SelecionarTabela(Readcommand:string): string;
        function ExecutarComandoSQL(WriteCommand: string): boolean;
        class function Action: IModelConnection;
    end;  

implementation 

uses
    Core.Model.GenFiles, Core.Model.Consts, Model.JDados;

constructor TModelConfiguracao.Create;
begin

end; 

destructor TModelConfiguracao.Destroy;
begin
  inherited Destroy; 
end;

function TModelConfiguracao.ListarProtocolo(Lista: TStrings): IModelConfiguracao;
begin
    Result := Self;
    TZConnection(nil).GetProtocolNames(Lista);
end;

function TModelConfiguracao.ExibirDados(EnviarDados: TEnviarDados): IModelConfiguracao;
begin
    Result := Self;
    with TArquivos.Action.Configuracao do
    begin
        EnviarDados(
        ReadString(IniDataSession, KeyProtocol, DefaultProtocol),
        ReadString(IniDataSession, KeyServer, DefaultServer),
        ReadString(IniDataSession, KeyPort, '3306'),
        ReadString(IniDataSession, KeyUser, DefaultUser),
        ReadString(IniDataSession, KeyPass, EmptyStr),
        ReadString(IniDataSession, KeyData, DefaultData)); 
    end;
end;

function TModelConfiguracao.SalvarDados(const Protocolo, Servidor, Porta, Usuario, Senha, Banco: string): IModelConfiguracao;
begin
    Result := Self;
    with TArquivos.Action.Configuracao do
    begin
        WriteString(IniDataSession, KeyProtocol, Protocolo);
        WriteString(IniDataSession, KeyServer, Servidor);
        WriteString(IniDataSession, KeyPort, Porta);
        WriteString(IniDataSession, KeyUser, Usuario);
        WriteString(IniDataSession, KeyPass, Senha);
        WriteString(IniDataSession, KeyData, Banco);
        UpdateFile;
    end;       
end;

function TModelConfiguracao.RegistrarErro(aModulo, aErro: string): IModelConfiguracao;
var
  aLog: string;
  aFile: TextFile;
begin
  Result := Self;
  aLog := Format(sLineBreak + 'Data: %s Modulo: %s disparou o seguinte erro:' +
    sLineBreak + '("%s")' + sLineBreak, [FormatDateTime('dd/mm/yyyy | hh:mm:ss', Now), aModulo, aErro]);
  AssignFile(aFile, 'Erro.log');
  try
    if FileExists('Erro.log') then
      Append(aFile)
    else
      Rewrite(aFile);
    Write(aFile, aLog);
  finally
    CloseFile(aFile);
  end;
end;

class function TModelConfiguracao.Action: IModelConfiguracao;
begin
  Result := Self.Create;
end;

{################------------------IINICO-----------------########################}

constructor TModelConexao.Create;
begin

end; 

destructor TModelConexao.Destroy;
begin

end;

class function TModelConexao.Action:IModelConnection;
begin
    Result := Self.Create;
end;

function TModelConexao.TestarConexao: boolean;
begin
  Result := False;

  if not Assigned(FConexao) then
  begin
    FConexao := TZConnection.Create(nil);
    try
      with FConexao do
      begin
        Protocol := TArquivos.Action.Configuracao.ReadString(IniDataSession, KeyProtocol, DefaultProtocol);
        HostName := TArquivos.Action.Configuracao.ReadString(IniDataSession, KeyServer, DefaultServer);
        Port := TArquivos.Action.Configuracao.ReadInteger(IniDataSession, KeyPort, DefaultPorta);
        User := TArquivos.Action.Configuracao.ReadString(IniDataSession, KeyUser, DefaultUser);
        Password := {Decode(} TArquivos.Action.Configuracao.ReadString(IniDataSession, KeyPass, EmptyStr){)};
        Database := TArquivos.Action.Configuracao.ReadString(IniDataSession, KeyData, DefaultData);
        Connect;
      end;
      Result := FConexao.Connected;
    except
      on E: Exception do
        TModelConfiguracao.Action.RegistrarErro('Erro: Conexao com a base de dados: ', e.Message);
    end;
  end;
end;    

function TModelConexao.SelecionarTabela(Readcommand:string): string;
var
  FQuery: TZQuery;
begin
  try
    if not (Length(Readcommand) = 0) then
    begin
      if TestarConexao then
      begin
        FQuery := TZQuery.Create(nil);
        try
          with FQuery do
          begin
            Connection := FConexao;
            SQL.Text := Readcommand;
            Open;
            if not IsEmpty then
            begin
              Result :=  TModelJDados.Action.SetarQuery(FQuery).ObterJSON;
            end
            else
              Result := '{"Mensagem":"Nenhun dado foi encontrado","reomendacao":"Veifique a sua consuta e tente novamente"}';
          end;
        finally
          FreeAndNil(FQuery);
        end;
      end
      else
        Result := '{"Mensagem":"Nenhun dado foi encontrado","reomendacao":"Veifique a sua consuta e tente novamente"}';
    end;
  except
    on E: Exception do
    begin
      Result := '{"Mensagem":"Nenhun dado foi encontrado","reomendacao":"Veifique a sua consuta e tente novamente"}';
      TModelConfiguracao.Action.RegistrarErro('Erro: Comando Select: ', e.Message);
    end;
  end;
end;

function TModelConexao.ExecutarComandoSQL(WriteCommand: string): boolean;
var
  FQuery: TZQuery;
begin
  Result := True;
  if (Length(WriteCommand) > 0) then
    if TestarConexao then
    begin
      FQuery := TZQuery.Create(nil);
      try
        try
          with FQuery do
          begin
            Connection := FConexao;
            SQL.Text := WriteCommand;
            ExecSQL;
          end;
        except
          on E: Exception do
          begin
            TModelConfiguracao.Action.RegistrarErro('Erro: Comando Insert, Update, Delete', e.Message);
            Result := False;
          end;
        end;
      finally
        FreeAndNil(FQuery);
      end;
    end;
end;
end.
