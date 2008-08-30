program colorManagerExample;

uses
  Forms,
  colorManagerExample_u in 'colorManagerExample_u.pas' {Form1},
  farbe in '..\farbe.pas' {colorManager};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TcolorManager, colorManager);
  Application.Run;
end.
