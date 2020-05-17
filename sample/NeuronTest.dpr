program NeuronTest;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown:=True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
