unit UServer;

interface

uses
  IdHTTPServer, IdCustomHTTPServer, IdContext, System.SysUtils, System.Classes, UNegocio, Data.DB, UData;

type
  TServidorREST = class
  private
    FServer: TIdHTTPServer;

    procedure ProcessRequest(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure HandleGet(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure HandlePost(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure HandlePut(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure HandleDelete(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

    procedure HandleErrors400(AMsg: string; var AResponseInfo: TIdHTTPResponseInfo);
  public
    procedure StartServer;
    procedure StopServer;
  end;

implementation

uses
  System.JSON;

procedure TServidorREST.ProcessRequest(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  if ARequestInfo.Command = 'GET' then
    HandleGet(ARequestInfo, AResponseInfo)
  else
  if ARequestInfo.Command = 'POST' then
    HandlePost(ARequestInfo, AResponseInfo)
  else
  if ARequestInfo.Command = 'PUT' then
    HandlePut(ARequestInfo, AResponseInfo)
  else
  if ARequestInfo.Command = 'DELETE' then
    HandleDelete(ARequestInfo, AResponseInfo)
  else
  begin
    AResponseInfo.ResponseNo := 405;
    AResponseInfo.ContentText := 'M�todo n�o permitido';
  end;
end;

procedure TServidorREST.StartServer;
begin
  DataProvider := TDataProvider.Create();
  FServer := TIdHTTPServer.Create(nil);
  FServer.DefaultPort := 8080;
  FServer.OnCommandGet := ProcessRequest;
  FServer.OnCommandOther := ProcessRequest;

  FServer.Active := True;
  Writeln('Servidor REST rodando na porta 8080...');
end;

procedure TServidorREST.HandleErrors400(AMsg: string; var AResponseInfo: TIdHTTPResponseInfo);
begin
  AResponseInfo.ContentText := AMsg;
  AResponseInfo.ResponseNo := 400;
end;

procedure TServidorREST.HandleGet(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Negocio: TClienteNegocio;
  JSONArr: TJSONArray;
  Cliente: TJSONObject;
  DataSet: TDataSet;
begin
  if (ARequestInfo.Document = '/pessoa') then
  begin
    Negocio := TClienteNegocio.Create;
    try
      DataSet := Negocio.ListarClientes;
      JSONArr := TJSONArray.Create;

      while not DataSet.Eof do
      begin
        Cliente := TJSONObject.Create;
        Cliente.AddPair('idpessoa', DataSet.FieldByName('idpessoa').AsInteger);
        Cliente.AddPair('flnatureza', DataSet.FieldByName('flnatureza').AsInteger);
        Cliente.AddPair('dsdocumento', DataSet.FieldByName('dsdocumento').AsString);
        Cliente.AddPair('nmprimeiro', DataSet.FieldByName('nmprimeiro').AsString);
        Cliente.AddPair('nmsegundo', DataSet.FieldByName('nmsegundo').AsString);
        Cliente.AddPair('dtregistro', DataSet.FieldByName('dtregistro').AsString);
        Cliente.AddPair('dsCep', DataSet.FieldByName('dsCep').AsString);

        JSONArr.AddElement(Cliente);
        DataSet.Next;
      end;

      AResponseInfo.ContentType := 'application/json';
      AResponseInfo.ContentText := JSONArr.ToString;
      AResponseInfo.ResponseNo := 200;
    finally
      Negocio.Free;
    end;
  end;
end;

procedure TServidorREST.HandlePost(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Negocio: TClienteNegocio;
  JSONBody: TJSONObject;
  ResponseText: string;
  PostData: TStringStream;
begin
  if (ARequestInfo.Document = '/pessoa') then
  begin
    PostData := TStringStream.Create('', TEncoding.UTF8);
    ARequestInfo.PostStream.Position := 0;
    PostData.CopyFrom(ARequestInfo.PostStream, ARequestInfo.PostStream.Size);

    JSONBody := TJSONObject.ParseJSONValue(PostData.DataString) as TJSONObject;
    try
      if Assigned(JSONBody) then
      begin
        Negocio.InserirPessoa(JSONBody);
        AResponseInfo.ContentText := ResponseText;
        AResponseInfo.ResponseNo := 200;
      end;
    finally
      JSONBody.Free;
    end;
  end
end;

procedure TServidorREST.HandlePut(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Negocio: TClienteNegocio;
  Route, IdPessoa: string;
  RowsAffected: Integer;
  JSONBody: TJSONObject;
  ResponseText: string;
  PostData: TStringStream;
  JSONObj: TJSONObject;
begin
  PostData := TStringStream.Create('', TEncoding.UTF8);
  ARequestInfo.PostStream.Position := 0;
  PostData.CopyFrom(ARequestInfo.PostStream, ARequestInfo.PostStream.Size);

  Route := ARequestInfo.Document;
  IdPessoa := Route.Substring(8);
  JSONObj := TJSONObject.Create;
  JSONBody := TJSONObject.ParseJSONValue(PostData.DataString) as TJSONObject;

  try
    if Assigned(JSONBody) then
    begin
      Negocio.AlterarPessoa(JSONBody,StrtoInt(IdPessoa));
      AResponseInfo.ContentType := 'application/json';
      AResponseInfo.ContentText := JSONObj.ToString;

      AResponseInfo.ResponseNo := 200;
    end;
  finally
    JSONBody.Free;
    JSONObj.Free;
  end;
end;

procedure TServidorREST.HandleDelete(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Negocio: TClienteNegocio;
  Route, IdPessoa: string;
  RowsAffected: Integer;
  JSONObj: TJSONObject;
begin
  if (ARequestInfo.Document.StartsWith('/pessoa')) then
  begin
    JSONObj := TJSONObject.Create;
    try
      Route := ARequestInfo.Document;
      IdPessoa := Route.Substring(8);

      if (IdPessoa = '') then
      begin
        HandleErrors400('Parametro IdPessoa � obrigat�rio.', AResponseInfo);
        exit;
      end;

      RowsAffected := Negocio.DeletePessoa(IdPessoa);

      AResponseInfo.ContentType := 'application/json';
      AResponseInfo.ContentText := JSONObj.ToString;

      if (RowsAffected > 0) then
        AResponseInfo.ResponseNo := 200
      else
        AResponseInfo.ResponseNo := 404;
    finally
      JSONObj.Free;
    end;
  end;
end;

procedure TServidorREST.StopServer;
begin
  FServer.Active := False;
  FreeAndNil(FServer);
end;

end.

