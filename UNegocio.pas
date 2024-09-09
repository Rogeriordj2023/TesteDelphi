unit UNegocio;

interface

uses
  UDados, Data.DB, System.SysUtils,
  System.Classes, IdHTTPServer, IdContext, IdCustomHTTPServer, IdGlobal, System.JSON;

type
  TClienteNegocio = class
  public
    function ListarClientes: TDataSet;
    function DeleteClientById(const ClientId: string): Boolean;
  end;

implementation

function TClienteNegocio.DeleteClientById(const ClientId: string): Boolean;
begin
                //
end;

function TClienteNegocio.ListarClientes: TDataSet;
begin
  if not DataModuleDB.Conectar then
    raise Exception.Create('Erro ao conectar ao banco de dados');

  Result := DataModuleDB.ExecutarQuery('SELECT * FROM clientes');
end;



end.

