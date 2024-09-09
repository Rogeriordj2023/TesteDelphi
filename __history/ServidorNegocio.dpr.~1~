program ServidorNegocio;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UServer in 'UServer.pas',
  UNegocio in 'UNegocio.pas',
  UDados in 'UDados.pas' {DataModule1: TDataModule};

var
  Servidor: TServidorREST;

begin
  try
    Servidor := TServidorREST.Create;
    try
      Servidor.StartServer;
      Readln;
    finally
      Servidor.StopServer;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
