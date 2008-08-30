unit colorManagerExample_u;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,farbe,
  StdCtrls, ExtCtrls,extralistview;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    procedure Button1Click(Sender: TObject);
    procedure Shape1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var colorManager: TcolorManager;
begin
 colorManager:=TcolorManager.create(nil);
 colorManager.addToColorList('Farbeinstellungen',vtCaptionH1);
 colorManager.addToColorList('',vtCaptionH3);
 colorManager.addToColorList('Quadrate',vtCaptionH3);
 colorManager.addToColorList('Q 1',vtValue,Shape1.brush.color);
 colorManager.addToColorList('Q 2',vtValue,Shape2.brush.color);
 colorManager.addToColorList('Q 3',vtValue,Shape3.brush.color);
 colorManager.addToColorList('',vtCaptionH3);
 colorManager.addToColorList('Kreise',vtCaptionH3);
 colorManager.addToColorList('K 1',vtValue,Shape4.brush.color);
 colorManager.addToColorList('K 2',vtValue,Shape5.brush.color);
 colorManager.addToColorList('K 3',vtValue,Shape6.brush.color);
 colorManager.addToColorList('',vtCaptionH3);
 colorManager.addToColorList('rundes Quadrat',vtCaptionH3);
 colorManager.addToColorList('eben dies'
 ,vtValue,Shape7.brush.color);
 colorManager.addToColorList('',vtCaptionH3);
 colorManager.addToColorList('Hintergrund',vtValue,color);
 colorManager.showModal;
 Shape1.brush.color:=colorManager.findInColorList('Q 1');
 Shape2.brush.color:=colorManager.findInColorList('Q 2');
 Shape3.brush.color:=colorManager.findInColorList('Q 3');
 Shape4.brush.color:=colorManager.findInColorList('K 1');
 Shape5.brush.color:=colorManager.findInColorList('K 2');
 Shape6.brush.color:=colorManager.findInColorList('K 3');
 Shape7.brush.color:=colorManager.findInColorList('eben dies');
 color:=colorManager.findInColorList('Hintergrund');
 colorManager.free;

end;

procedure TForm1.Shape1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var colorManager: TcolorManager;
begin
 colorManager:=TcolorManager.create(nil);
 colorManager.currentColor:=(sender as tshape).brush.color;
 colorManager.showModal;
 (sender as tshape).brush.color:=colorManager.currentColor;
 colorManager.free;
end;

end.
