unit UNegocio;

interface

uses
  UData, Data.DB, System.SysUtils,
  System.Classes, IdHTTPServer, IdContext, IdCustomHTTPServer, IdGlobal, System.JSON,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param, FireDAC.Stan.Intf,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, REST.Types;

type
  TClienteNegocio = class
  public
    function ListarClientes: TDataSet;
    function DeletePessoa(const ClientId: string): Integer;
    function ConsultarCEP(const ACep: string): string;
    function InserirPessoa(const DJson: TJSONObject): Integer;
    function AlterarPessoa(const DJson: TJSONObject; const IdPessoa:integer): Integer;
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

function TClienteNegocio.InserirPessoa(const DJson: TJSONObject): Integer;
var
  Query: TFDQuery;
begin
  Result := 0;

  if not DataProvider.Conectar then
    raise Exception.Create('Erro ao conectar ao banco de dados');

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := DataProvider.FDConnection;
    Query.SQL.Text := 'INSERT INTO PESSOA(flnatureza, dsdocumento, nmprimeiro, nmsegundo, dtregistro)' +
                      'VALUES(:flnatureza, :dsdocumento, :nmprimeiro, :nmsegundo, :dtregistro)';           ;
    Query.ParamByName('flnatureza').AsInteger := StrtoInt(DJson.Values['flnatureza'].Value);
    Query.ParamByName('dsdocumento').AsString := DJson.Values['dsdocumento'].Value;
    Query.ParamByName('nmprimeiro').AsString  := DJson.Values['nmprimeiro'].Value;
    Query.ParamByName('nmsegundo').AsString   := DJson.Values['nmsegundo'].Value;
    Query.ParamByName('dtregistro').AsDate    := date();
    Query.ExecSQL;

    DataProvider.FDConnection.Commit;
    Result := 1;
  finally
    Query.Free;
  end;
end;

function TClienteNegocio.ListarClientes: TDataSet;
begin
  if not DataProvider.Conectar then
    raise Exception.Create('Erro ao conectar ao banco de dados'); 

  Result := DataProvider.ExecutarQuery('SELECT P.*, E.dsCep FROM PESSOA P '+
                                       'LEFT JOIN endereco E ON E.idpessoa = p.idpessoa ');
end;

function TClienteNegocio.AlterarPessoa(const DJson: TJSONObject; const IdPessoa: integer): Integer;
var
  Query: TFDQuery;
begin
  Result := 0;

  if not DataProvider.Conectar then
    raise Exception.Create('Erro ao conectar ao banco de dados');

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := DataProvider.FDConnection;
    Query.SQL.Text := 'UPDATE PESSOA SET flnatureza=:flnatureza, dsdocumento=:dsdocumento, nmprimeiro=:nmprimeiro, nmsegundo=:nmsegundo ' +
                      'WHERE IDPESSOA=:IDPESSOA';
    Query.ParamByName('IDPESSOA').AsInteger   := IdPessoa;
    Query.ParamByName('flnatureza').AsInteger := StrtoInt(DJson.Values['flnatureza'].Value);
    Query.ParamByName('dsdocumento').AsString := DJson.Values['dsdocumento'].Value;
    Query.ParamByName('nmprimeiro').AsString  := DJson.Values['nmprimeiro'].Value;
    Query.ParamByName('nmsegundo').AsString   := DJson.Values['nmsegundo'].Value;
    Query.ExecSQL;

    DataProvider.FDConnection.Commit;
    Result := 1;
  finally
    Query.Free;
  end;

end;

function TClienteNegocio.ConsultarCEP(const ACep: string): string;
var
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;
  JSONValue: TJSONValue;
begin
  if Length(ACep) <> 8 then
    raise Exception.Create('O CEP deve conter 8 d�gitos.');

  RESTClient := TRESTClient.Create('https://viacep.com.br/ws/' + ACep + '/json/');
  RESTRequest := TRESTRequest.Create(nil);
  RESTResponse := TRESTResponse.Create(nil);
  
  try
    RESTRequest.Client := RESTClient;
    RESTRequest.Response := RESTResponse;

    RESTRequest.Method := rmGet;
    RESTRequest.Execute;

    if RESTResponse.StatusCode = 200 then
    begin
      JSONValue := TJSONObject.ParseJSONValue(RESTResponse.Content);
      if Assigned(JSONValue) then
      begin
        Result := JSONValue.ToString;
        JSONValue.Free;
      end
      else
        raise Exception.Create('N�o foi poss�vel interpretar a resposta.');
    end
    else
    begin
      raise Exception.Create('Erro na consulta do CEP: ' + RESTResponse.StatusText);
    end;

  finally
    RESTClient.Free;
    RESTRequest.Free;
    RESTResponse.Free;
  end;
end;



end.

