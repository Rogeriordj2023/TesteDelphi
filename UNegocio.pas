unit UNegocio;

interface

uses
  UData, Data.DB, System.SysUtils,
  System.Classes, IdHTTPServer, IdContext, IdCustomHTTPServer, IdGlobal, System.JSON,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param, FireDAC.Stan.Intf;

type
  TClienteNegocio = class
  public
    function ListarClientes: TDataSet;
    function DeletePessoa(const ClientId: string): Integer;
    //function InserirPessoa:  ****
  end;

implementation

function TClienteNegocio.DeletePessoa(const ClientId: string): Integer;
var 
  Query: TFDQuery;
begin
  Result := 0;

  if not DataProvider.Conectar then
    raise Exception.Create('Erro ao conectar ao banco de dados');

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := DataProvider.FDConnection;
    Query.SQL.Text := 'DELETE FROM PESSOA WHERE idpessoa = :id';
    Query.ParamByName('id').AsInteger := StrToInt(ClientId);
    Query.ExecSQL;

    Result := Query.RowsAffected;
  finally
    Query.Free;
  end;
end;

function TClienteNegocio.ListarClientes: TDataSet;
begin
  if not DataProvider.Conectar then
    raise Exception.Create('Erro ao conectar ao banco de dados'); 

  Result := DataProvider.ExecutarQuery('SELECT * FROM PESSOA');
end;



end.

