unit Core.Model.GenFiles;

{$IFDEF FPC}
{$mode ObjFPC}{$H+}
{$ENDIF}

interface

uses
{$IFDEF FPC}
  Classes, SysUtils, IniFiles, Dialogs;
{$ENDIF}

type
    IArquivos = interface
        ['{710D72DA-B331-42C0-AAEA-686F40B8C08D}'] 
        function Diretorio:string;
        function VerificarConfiguracao:boolean;
        function Configuracao:TIniFile;
    end;

    TArquivos = class(TInterfacedObject, IArquivos)
    private
        FConfiguracao: TIniFile;  
    public
        constructor Create; 
        destructor Destroy; override;
        class function Action:IArquivos;
        function Diretorio:string;
        function VerificarConfiguracao:boolean;
        function Configuracao:TIniFile;
    end;

implementation

uses
    Core.Model.Consts, Core.Model.Mesagens;

constructor TArquivos.Create; 
begin
   if not VerificarConfiguracao then
    Abort;  
end;

destructor TArquivos.Destroy;
begin
    FreeAndNil(FConfiguracao); 
    inherited Destroy; 
end;

class function TArquivos.Action:IArquivos;
begin
    Result := Self.Create;
end;

function TArquivos.Diretorio:string;
begin
     Result := ExtractFilePath(ParamStr(0)); 
end;

function TArquivos.VerificarConfiguracao:boolean;
begin
Result := True;
  try
    if not FileExists(Concat(Diretorio, NomeArquivoConfiguracao,
      ExtensaoArquivoConfiguracao)) then
    begin
      FConfiguracao := TMemIniFile.Create(Concat(Diretorio,
        NomeArquivoConfiguracao, ExtensaoArquivoConfiguracao));
      with FConfiguracao do
      begin
        //Configurações locais
        WriteString(IniDataSession, KeyProtocol, DefaultProtocol);
        WriteString(IniDataSession, KeyServer, DefaultServer);
        WriteString(IniDataSession, KeyPort, '3306');
        WriteString(IniDataSession, KeyUser, DefaultUser);
        WriteString(IniDataSession, KeyPass, EmptyStr);
        WriteString(IniDataSession, KeyData, DefaultData);
      end;
    end
    else
      FConfiguracao := TMemIniFile.Create(Concat(Diretorio,
        NomeArquivoConfiguracao, ExtensaoArquivoConfiguracao));
  except
    begin
      Result := False;
      ShowMessage(GetMensagem(Mensagem_Falha_Configuracao));
    end;
  end;
end;

function TArquivos.Configuracao:TIniFile;
begin
  if VerificarConfiguracao then
  Result := FConfiguracao
  else
        Abort;
end;

end.

