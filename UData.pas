unit UData;

interface

uses
  System.SysUtils, System.Classes, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Phys.PG,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Phys.PGDef;

type
  TDataProvider = class(TObject)
    FDConnection: TFDConnection;
    FDQuery: TFDQuery;
  public
    function Conectar: Boolean;
    function ExecutarQuery(const ASQL: string): TFDQuery;
  end;

var
  DataProvider: TDataProvider;

implementation

function TDataProvider.Conectar: Boolean;
begin
  Self.FDConnection := TFDConnection.Create(nil);

  try
    Self.FDConnection.DriverName := 'PG';
    Self.FDConnection.Params.Database := 'postgres';
    Self.FDConnection.Params.UserName := 'postgres';
    Self.FDConnection.Params.Password := 'postgres';
    Self.FDConnection.Params.Add('Server=localhost');
    Self.FDConnection.Params.Add('Port=5432');
    Self.FDConnection.Connected := True;

    Self.FDQuery := TFDQuery.create(nil);
    Self.FDQuery.Connection := Self.FDConnection;

    Result := True;
  except
    on E: Exception do
    begin
      Result := False;
      raise Exception.Create('Erro ao conectar ao banco de dados: ' + E.Message);
    end;
  end;
end;

function TDataProvider.ExecutarQuery(const ASQL: string): TFDQuery;
begin
  FDQuery.Close;
  FDQuery.SQL.Text := ASQL;
  FDQuery.Open;
  Result := FDQuery;
end;

end.

