program C2PAS32APP;

uses
  System.StartUpCopy,
  FMX.Forms,
  main in 'main.pas' {fmmain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfmmain, fmmain);
  Application.Run;
end.
