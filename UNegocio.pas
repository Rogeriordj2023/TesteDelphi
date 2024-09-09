unit UNegocio;

interface

uses
  UDados, Data.DB, System.SysUtils;

type
  TClienteNegocio = class
  public
    function ListarClientes: TDataSet;
  end;

implementation

function TClienteNegocio.ListarClientes: TDataSet;
begin
  if not DataModuleDB.Conectar then
    raise Exception.Create('Erro ao conectar ao banco de dados');

  Result := DataModuleDB.ExecutarQuery('SELECT * FROM clientes');
end;

end.
