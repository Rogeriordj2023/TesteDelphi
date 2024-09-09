unit UServer;

interface

uses
  IdHTTPServer, IdCustomHTTPServer, IdContext, System.SysUtils, System.Classes, UNegocio, Data.DB;

type
  TServidorREST = class
  private
    FServer: TIdHTTPServer;
    procedure OnCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    procedure StartServer;
    procedure StopServer;
  end;

implementation

uses
  System.JSON;

procedure TServidorREST.OnCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Negocio: TClienteNegocio;
  JSONArr: TJSONArray;
  Cliente: TJSONObject;
  DataSet: TDataSet;
begin
  if ARequestInfo.Document = '/clientes' then
  begin
    Negocio := TClienteNegocio.Create;
    try
      DataSet := Negocio.ListarClientes;
      JSONArr := TJSONArray.Create;
      while not DataSet.Eof do
      begin
        Cliente := TJSONObject.Create;
        Cliente.AddPair('ID', DataSet.FieldByName('ID').AsString);
        Cliente.AddPair('Nome', DataSet.FieldByName('Nome').AsString);
        JSONArr.AddElement(Cliente);
        DataSet.Next;
      end;
      AResponseInfo.ContentType := 'application/json';
      AResponseInfo.ContentText := JSONArr.ToString;
      AResponseInfo.ResponseNo := 200;
    finally
      Negocio.Free;
    end;
  end
  else
    AResponseInfo.ResponseNo := 404;
end;

procedure TServidorREST.StartServer;
begin
  FServer := TIdHTTPServer.Create(nil);
  FServer.DefaultPort := 8080;
  FServer.OnCommandGet := OnCommandGet;
  FServer.Active := True;
  Writeln('Servidor REST rodando na porta 8080...');
end;

procedure TServidorREST.StopServer;
begin
  FServer.Active := False;
  FreeAndNil(FServer);
end;

end.
