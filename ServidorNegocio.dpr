program ServidorNegocio;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UServer in 'UServer.pas',
  UNegocio in 'UNegocio.pas',
  UData in 'UData.pas';

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
