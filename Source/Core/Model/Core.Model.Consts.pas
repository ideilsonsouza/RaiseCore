unit Core.Model.Consts;

{$IFDEF FPC}
{$mode ObjFPC}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils;

  resourcestring
    NomeArquivoConfiguracao = 'Config';
    ExtensaoArquivoConfiguracao = '.ini';

    //Sessoẽs
    IniDataSession = 'Data';
    IniConfigSession = 'Config';

    //Chaves
    KeyProtocol = 'protocol';
    KeyServer = 'servidor';
    KeyPort = 'porta';
    KeyUser = 'usuario';
    KeyPass = 'senha';
    KeyData = 'banco';

    //Padrões
    const
    DefaultProtocol = 'mysql';
    DefaultServer = 'localhost';
    DefaultPort = 3306;
    DefaultUser = 'root';
    DefaultData = 'raise_db';

implementation

end. 