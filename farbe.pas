{Copyright (C) 2005-2008  Benito van der Zander

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
}
unit farbe;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,math, ComCtrls, Spin,extraListView;

  //Formate der Farbausgabe
  const colorImageWidth=200;   //Gr��e des Auswahlfeldes
       colorImageHeight=200;
       colorImageBarWidth=200; //Gr��e der ScrollBar
       colorImageBarHeight=26;

  //Die Indizes der Combobox, bei denen ein bestimmer Scrollbarmodus benutzt wird
  const BarIsLightness=0;   //Helligkeit
        BarIsHue=1;         //Farbton
        BarIsSatturation=2; //S�ttigung
        BarIsRed=3;         //Rotton
        BarIsGreen=4;       //Gr�nton
        BarIsBlue=5;        //Blauton

type
  //Farbarray f�r ScanLine
  PColorArray=^TColorArray;
  TColorArray=array[0..4096] of record
    case integer of
      0: (b,g,r:byte);                 //R,G,B wird umgedreht gespeichert
      1: (colors:array[0..2] of byte)  //Zweite Repr�sentation als Array
  end;
  //Gibt an, welche Bereiche aktualisiert werden sollen
  TColorUpdate=set of (cuImage, //Das gro�e Auswahlfeld das alle m�glichen Kombinationen
                                //von je zwei Farbwerten zeigt (der dritte wird von der
                                //Scrollbar bestimmt
                       cuBottomBar, //Die Unterseite der Bar, die einen Farbwert "rein" zeigt
                       cuTopBar, //Die Oberseite der Bar, die zus�tzlich noch von der
                                 //Auswahl der anderen Farbwerte ah�ngt
                       cuBarPos, //Der Marker der auf der Bar bewegt wird
                       cuSpinHLS, //SpinEdits die die HLS-Werte der gew�hlten Farbe zeigen
                       cuSpinRGB, //SpinEdits die die RGB-Werte der gew�hlten Farbe zeigen
                       cuHex ); //Editfeld welches die HTML-Hex-Repr�sentation zeigt

  //Gibt an, welches Farbmodel genommen wird
  TUsedColorBase= (useRGB, useHLS, //auf jeden Fall RGB oder HLS
                   useSelected); //oder das in der ComboBox ausgew�hlte

  //Speichert die benutzten Farbwerte
  TColorValue=record
    typ: TValueType;
    name,hint: string;
    oldColor,newColor:TColor;  //Farbwerte
  end;
  TColorValues=array of TColorValue;
  TcolorManager = class(TForm)
    //Beide Farbmodelle(RGB und HLS) sind 3 dimensional, deshalb wird eine
    //Dimension (R,G,B,H,L oder S, welcbe davon h�ngt von colorBarMode.itemIndex
    //ab �ber ColorBar eingestellt, und die beiden anderen des gleichen Farbmodells
    //�ber colorImageWindow.
    colorImageWindow: TPaintBox; //Gro�e Farbauswahl
    ColorBar: TPaintBox;         //Farbauswahlbalken
    colorBarTopSelector: TPaintBox; //Positionsmarker oben
    colorBarBottomSelector: TPaintBox; //    "       unten
    colorBarMode: TComboBox; //Combobox zur Auswahl des Colorbarmodus (Farbton/Helligkeit...)
    selColorPanel: TPanel;//Paintbox die �ber dem Ausgabepanel liegt, weil es recht tr�ge ist
    //Spinedits zur Anzeige/�nderung der RGB-Daten
    spinR: TSpinEdit;    spinG: TSpinEdit;    spinB: TSpinEdit;
    //Spinedits zur Anzeige/�nderung der HLS-Daten
    spinH: TSpinEdit;    spinL: TSpinEdit;    spinS: TSpinEdit;
    hex: TEdit; //RGB-Hexauswahl
    OK: TButton;  //OK-Button
    Cancel: TButton; //Abbrechen-Button
    ListBox1: TListBox; //Dient zur Auswahl der Farbe, die man �ndern will
    HeaderControl1: THeaderControl; //Schreibt die Farbe zur�ck in die ListBox
    resetColor: TButton;

    //Designelemente
    bevel1: TBevel;    Bevel2: TBevel;    Label1: TLabel;    Label2: TLabel;
    Label3: TLabel;    Label4: TLabel;    Label5: TLabel;    Label6: TLabel;
    Label7: TLabel;    Label8: TLabel;    Label9: TLabel;    Label10: TLabel;
    listboxpanel: TPanel;
    selColorBox: TPaintBox;

    //Das gro�e Farbauswahlfeldes muss aktualisiert werden
    procedure colorImageWindowPaint(Sender: TObject);
    //Der Farbauswahlbalken muss aktualisiert werden
    procedure ColorBarPaint(Sender: TObject);
    procedure colorBarTopSelectorPaint(Sender: TObject);
    //Die durch ColorBar einstellbare Farbkomponente wird gewechselt
    procedure colorBarModeChange(Sender: TObject);
    //Initalisierung (vom Doublebuffer und der Listbox)
    procedure FormCreate(Sender: TObject);
    //Freigabe
    procedure FormDestroy(Sender: TObject);
    //Listbox und Farben aktualisieren
    procedure FormShow(Sender: TObject);
    //Auswahl auf dem gro�en Auswahlfenster starten
    procedure colorImageWindowMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    //ausgew�hlte Farbe �ndern
    procedure colorImageWindowMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    //Auswahl beenden
    procedure colorImageWindowMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    //Auswahl am Farbbalken starten
    procedure colorBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    //ausgew�hlte Farbe �ndern
    procedure colorBarMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    //Auswahl beenden
    procedure ColorBarMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    //Eine der HLS-Komponenten ge�ndert
    procedure spinHLSChange(Sender: TObject);
    //Eine der RGB-Komponenten ge�ndert
    procedure spinRGBChange(Sender: TObject);
    //RGB-Hex ge�ndert
    procedure hexChange(Sender: TObject);

    //gew�hlte Farbe in die Listbox schreiben
    procedure useColorClick(Sender: TObject);
    //Gew�hlte Farbe durch die aus der Listbox ersetzen
    procedure resetColorClick(Sender: TObject);

    //Fenster schlie�en und �nderungen speichern
    procedure OKClick(Sender: TObject);
    //Fenster schlie�en und �nderungen verwerfen
    procedure CancelClick(Sender: TObject);

    //Farbe ausw�hlen
    procedure ListBox1Click(Sender: TObject);
    //ListBox-Hilfe aktualisieren
    procedure ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure selColorBoxPaint(Sender: TObject);
  private
    { Private-Deklarationen}
    colorImageBar:TBitmap; //Doublebuffer f�r den Farbauswahlbalken
    colorImage,colorImageBuffer:TBitmap;//Doublebuffer f�r die Farbauswahl
    startColor: tcolor;
    selH,selL,selS:integer; //HLS-Komponenten der gew�hlten Farbe
    selR,selG,selB:integer; //RGB-Komponenten der gew�hlten Farbe
    oldSelX,oldSelY:integer; //Versch�nerung durch Fadenkreuz
    newSelX,newSelY:integer; //"
    selBarPos:integer; //Markierte Stelle des Farbauswahlbalkens
    isUpdating: boolean; //R�ckkopplung  verhindern

    extraListView:TExtraListView; //ListVie
    fcolorList:TColorValues;

  public
    currentColor: TColor;
    property colorList: TColorValues read fcolorlist;
    { Public-Deklarationen}
    //Position der Scrollbar setzen
    procedure setColorBarPos(const newPos:integer);
    //Gro�es Auswahlfeld neuzeichnen
    procedure updateColorImage;
    //Auswahlbalken neuzeichnen
    procedure updateColorImageBar(updateAll:boolean);
    //Aktualisiert die angegebenen Werte (siehe TColorUpdate).
    //Alle Aktualisierungen laufen werden �ber diese Prozedure ausgel�st
    procedure updateSelectedColor(const colorBase:TUsedColorBase;update:TColorUpdate);

    //Zeichnet Farben in die Listbox
    procedure DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);

    procedure addToColorList(name:string; typ: TValueType; oldColor:TColor=clNone; hint:string='');
    function findInColorList(name:string):TColor;
  end;

var
  colorManager: TcolorManager;
implementation
{$R *.DFM}


//Wandelt eine HLS-Farbe in RGB um.
//h = farbton, s = s�ttigung, l = helligkeit,
//Die Funktionsweise habe herausgefunden, in dem ich mir im Malprogramm angesehen
//habe, was sich �ndert wenn der Farbton bei voller S�ttigung und 50% Helligkeit
//erh�ht/verringert wird, und anschlie�end was bei �nderungen der S�ttigung
//und Helligkeit jeweils passiert, und dann entsprechend den 3-Satz angewandt habe.
//Hintereinander ausgef�hrt hat es dann sehr gut zusammen gepasst.
procedure HLSToRGB(const h,s,l:integer;out r_out,g_out,b_out:byte);
var r,g,b:integer;
begin
  //Grundfarbton berechen, die reinen Grundfarbt�nen sind Farbverl�ufe zwischen
  //den Werten die jeweils bei Vielfachen von 60� auftreten:
  if h<=60 then begin                          //0� : rot
    r:=255;
    g:=h*255 div 60;
    b:=0;
  end else if h<=120 then begin                //60� : gelb
    r:=255-(h-60)*255 div 60;
    g:=255;
    b:=0;
  end else if h<=180 then begin                //120� : gr�n
    r:=0;
    g:=255;
    b:=(h-120)*255 div 60;
  end  else if h<=240 then begin               //180� : cyan
    r:=0;
    g:=255-(h-180)*255 div 60;
    b:=255;
  end  else if h<=300 then begin               //240� : blau
    r:=(h-240)*255 div 60;
    g:=0;
    b:=255;
  end  else if h<=360 then begin               //300� : violett
    r:=255;
    g:=0;
    b:=255-(h-300)*255 div 60;
  end else begin //Das sollte nie eintreten
    r:=0;
    g:=0;
    b:=0;
  end;
  //S�ttigung, die Farbwerte n�hert sich immer mehr 128
  if s< 100 then begin
    r:=(r-128)*s div 100 + 128;
    g:=(g-128)*s div 100 + 128;
    b:=(b-128)*s div 100 + 128;
  end;
  //Helligkeit
  if l<50 then begin //Dunkler (die Farbwerte n�hern sich immer mehr 0)
    r:=r * l div 50;
    g:=g * l div 50;
    b:=b * l div 50;
  end else if l>50 then begin //Heller (die Farbwerte n�hern sich immer mehr 255)
    r:=(255-r) * (l - 50) div 50 + r;
    g:=(255-g) * (l - 50) div 50 + g;
    b:=(255-b) * (l - 50) div 50 + b;
  end;
  r_out:=byte(min(max(r,0),255));
  g_out:=byte(min(max(g,0),255));
  b_out:=byte(min(max(b,0),255));
end;

//Wandelt eine HLS-Farbe in eine TColor-Farbe um
function HLSToRGBColor(const h,s,l:integer):TColor;
var r,g,b:byte;
begin
  HLSToRGB(h,s,l,r,g,b);
  result:=rgb(r,g,b);
end;
//Wandelt RGB in HLS um.
//Den Algorithmus habe ich gefunden, nachdem mir aufgefallen war, dass der
//h�chste und niedrigste RGB-Farbwert vor der Berechnung der S�ttigung und
//Helligkeit 255 und 0 war, so dass ich ein Gleichungssystem zur�ck rechnen konnte.
procedure RGBToHLS(const r,g,b:integer;out h,s,l:integer);
var colors:array[0..2] of byte;
    i:integer;
    lowest, biggest,middest:integer;
    s1,s2,l1,l2:single;
    d1,d2:single;
    tmid:single;
begin
  if (r=g)and (g=b) then begin
    //grau
    h:=0;
    l:=g*100 div 255;
    s:=0;
    exit;
  end;
  colors[0]:=r;
  colors[1]:=g;
  colors[2]:=b;
  lowest:=0;
  biggest:=0;
  //H�chsten und niedrigsten Wert finden
  for i:=1 to 2 do begin
    if colors[i]>colors[biggest] then biggest:=i;
    if colors[i]<colors[lowest] then lowest:=i;
  end;
  //Farbwert in der Mitte finden
  middest:=0;
  for i:=1 to 2 do
    if (i<>lowest) and (i<>biggest) then middest:=i;
  {for i:=1 to 2 do
    if (colors[i]<>colors[biggest]) and  (colors[i]<>colors[lowest]) then
      middest:=i;}
  //lowest war direkt nach der Farbtonberechnung bei HLSToRGB exakt 0
  //biggest war direkt nach der Farbtonberechnung bei HLSToRGB exakt 255
  //middest dazwischen
  //L�sung des Gleichungssystem das bei "dunkler", durch einsetzten der Ausgabe
  //von der S�ttigungsberechnung in die der Helligketisberechnung, entsteht
  s1:=(12800*(colors[biggest] - colors[lowest])) / (127*colors[lowest] + 128*colors[biggest]);
  l1:= 5*(127*colors[lowest] + 128*colors[biggest])/3264;
  //L�sung des Gleichungssystem das bei "heller" entsteht
  s2:= (12700*(colors[lowest] - colors[biggest]))/ (127*colors[lowest] + 128*colors[biggest] - 65025);
  l2:= 10*(127*colors[lowest] + 128*colors[biggest] - 255)/6477;

  if (l1<0) or (l1>55) or (s1<0) or (s1>100) then begin
    //Erste L�sung ung�ltig (wenn die Helligkeit �ber 50 ist, m�sste die L�sung
    //f�r das Gleichungssystem f�r "heller" genommen werden
    s:=round(s2);
    l:=round(l2);
  end else if (s2<0) or (s2>100)or (s2<0) or (s2>100) then begin
    //Erste L�sung ung�ltig (wenn die Helligkeit �ber 50 ist, m�sste die L�sung
    //f�r das Gleichungssystem f�r "dunkler" genommen werden
    s:=round(s1);
    l:=round(l1);
  end else begin
    //Beide L�sungen sind g�ltig, deshalb werden die Farbwerte berechnet,
    //die herauskommen, wenn die Werte eingesetz werden. 
    //Erstes Paar
    if l1<50 then
      d1:=abs(((-128)*s1 / 100 + 128) * l1 / 50 -  colors[lowest]) +
          abs(((255-128)*s1 / 100 + 128) * l1 / 50 -  colors[biggest])
     else
      d1:=abs((l1*(32*s1 + 3175) - 50*(64*s1 - 25))/1250 -  colors[lowest]) +
          abs((100*(127*s1 + 50) - 127*l1*(s1 - 100))/5000 -  colors[biggest]);
    //Zweites Paar
    if l2<50 then
      d2:=abs(((-128)*s2 / 100 + 128) * l2 / 50 -  colors[lowest]) +
          abs(((255-128)*s2 / 100 + 128) * l2 / 50 -  colors[biggest])
     else
      d2:=abs((l2*(32*s2 + 3175) - 50*(64*s2 - 25))/1250 -  colors[lowest]) +
          abs((100*(127*s2 + 50) - 127*l2*(s2 - 100))/5000 -  colors[biggest]);
    //Die L�sung mit den kleinsten Unterschieden zu den echten Werten wird genommt
    if d1>d2 then begin
      s:=round(s2);
      l:=round(l2);
    end else begin
      s:=round(s1);
      l:=round(l1);
    end;
  end;
  //Ist die Helligkeit maximale/minimal oder die S�ttigung minimal kann der Farb-
  //ton nicht berechnet werden. 
  if (l=100)or(l=0)or(s=0) then begin
    h:=0;
    exit;
  end;

  //Jetzt ist die Helligkeit und die S�ttigung bekannt, und der Farbton kann aus
  //middest zur�ckgerechnet werden
  //Helligkeit zur�ck
  if l<=50 then tmid:=colors[middest] * 50 / l  //Dunkler
  else tmid:=(colors[middest]-255 * (l - 50) / 50)/(1-(l - 50) / 50); //Heller

  //S�ttigung zur�ck
  tmid:=(tmid-128)*100/s+128;

  //Farbton zur�ck
  case biggest of
    0: case lowest of //tR = 255
         1: h:=round((255-tmid)*60/255+300); //h zwischen 300 und 360
         2: h:=round(tmid*60/255); //h zwischen 0 und 60
       end;
    1: case lowest of //tG = 255
         0: h:=round(tmid*60/255 + 120);     //h zwischen 120 und 180
         2: h:=round((255-tmid)*60/255+60); //h zwischen 60 und 120
       end;
    2: case lowest of //tB = 255
         0: h:=round((255-tmid)*60/255+180);//h zwischen 180 und 240
         1: h:=round(tmid*60/255 + 240);//h zwischen 240 und 300
       end;
  end;
end;


//Das gro�e Auswahfeld soll gezeichnet werden
procedure TcolorManager.colorImageWindowPaint(Sender: TObject);
begin
  with colorImageBuffer.Canvas do begin
    //Die Farbwerte aus dem Farbwertbuffer in den Doublebuffer zeichnen
    draw(0,0,colorImage);

    //Ein Fadenkreuz zur markierten Farbe zeichnen.
    pen.color:=rgb(255-8,255-8,255-8);
    pen.mode:=pmXor;
    //Kreuz zur alten Farbe zeichnen
    moveTo(oldSelX,0);
    lineTo(oldSelX,colorImageWindow.Height);
    moveTo(0,oldSelY);
    lineTo(colorImageWindow.width,oldSelY);

    //Kreuz zur neuen Farbe zeichnen, wenn die jeweiligen Linien an unterschiedlichen
    //Positionen sind.
    if newSelX<>oldSelX then begin
      moveTo(newSelX,0);
      lineTo(newSelX,colorImageWindow.Height);
    end;
    if newSelY<>oldSelY then begin
      moveTo(0,newSelY);
      lineTo(colorImageWindow.width,newSelY);
    end;
  end;
  //Doublebuffer ausgeben
  colorImageWindow.Canvas.Draw(0,0,colorImageBuffer);
end;

//Farbauswahlbalken neuzeichnen
procedure TcolorManager.ColorBarPaint(Sender: TObject);
begin
  //Farbwerte zeichnen
  colorBar.Canvas.draw(0,0,colorImageBar);

  //Strich an der Auswahlposition zeichnen
  colorBar.Canvas.Pen.Color:=rgb(255-8,255-8,255-8);
  colorBar.Canvas.Pen.mode:=pmXor;
  colorBar.Canvas.MoveTo(selBarPos-1,0);
  colorBar.Canvas.LineTo(selBarPos-1,colorImageHeight);
end;

//Die Dreiecke an den Ecken der Auswahllinie neuzeichnen
procedure TcolorManager.colorBarTopSelectorPaint(Sender: TObject);
begin
  with colorBarTopSelector.Canvas do begin //oben
    brush.color:=clBtnFace;
    Rectangle(-1,-1,1000,1000);
    brush.Color:=clBlack;
    Polygon([point(selBarPos,0),point(selBarPos+10,0),point(selBarPos+5,5)]);
  end;
  with colorBarBottomSelector.Canvas do begin //unten
    brush.color:=clBtnFace;
    Rectangle(-1,-1,1000,1000);
    brush.Color:=clBlack;
    Polygon([point(selBarPos,5),point(selBarPos+10,5),point(selBarPos+5,0)]);
  end;
  //Zur Sicherheit auch den Rest des Balkens aktualisieren
  colorBarPaint(colorBar);
end;

//Den Farbwert der �ber den Balken eingestellt wird �ndern
procedure TcolorManager.colorBarModeChange(Sender: TObject);
var selected, others:string;
begin
  //Die Hilfetexte aktualisieren
  case colorBarMode.ItemIndex of
    BarIsLightness: begin selected:='die Helligkeit'; others:='Farbton oder S�ttigung';end;
    BarIsHue: begin selected:='den Farbton'; others:='Helligkeit oder S�ttigung';end;
    BarIsSatturation: begin selected:='die S�ttigung'; others:='Farbton oder Helligkeit';end;
    BarIsRed: begin selected:='den Rotton'; others:='Helligkeit, Farbton, S�ttigung';end;
    BarIsGreen: begin selected:='den Gr�nton'; others:='Helligkeit, Farbton, S�ttigung';end;
    BarIsBlue: begin selected:='die Blauton'; others:='Helligkeit, Farbton, S�ttigung';end;
  end;
  colorBar.Hint:='Hier k�nnen Sie '+selected+' der gew�nschte  Farbe einstellen. '+
                  'Wollen sie eine andere Farbeigenschaft (z.B.: '+others+') k�nnen Sie'+
                  'diese in der mit "Balkenmodus" beschriefteten Auswahlfeld w�hlen.';
  colorBarTopSelector.Hint:=colorBar.Hint;colorBarBottomSelector.Hint:=colorBar.Hint;
  //Der Aktualisierungsfunktion bescheid geben, um alle Farbauswahlfelder zu aktualisieren
  updateSelectedColor(useSelected,[cuImage,cuTopBar,cuBottomBar,cuBarPos]);
end;

//Doublebuffer und Listbox erzeugen
procedure TcolorManager.FormCreate(Sender: TObject);
var i:integer;
begin
  //Farbbuffer f�rs 2D Auswahlfeld
  colorImage:=TBitmap.create;
  colorImage.Width:=colorImageWidth;
  colorImage.Height:=colorImageHeight;
  colorImage.PixelFormat:=pf24bit; //Das Pixelformat ist bei ScanLine wichtig
  //Doublebuffer dazu
  colorImageBuffer:=TBitmap.create;
  colorImageBuffer.Width:=colorImageWidth;
  colorImageBuffer.Height:=colorImageHeight;

  //Farbbuffer f�r Auswahlbalken
  colorImageBar:=TBitmap.create;
  colorImageBar.Width:=colorImageWidth;
  colorImageBar.Height:=colorImageHeight;
  colorImageBar.PixelFormat:=pf24bit;

  //Standardm��ig Helligkeit auf den Balken legen
  colorBarMode.ItemIndex:=BarIsLightness;
  //Neutrale Helligkeit und S�ttigung
  selBarPos:=colorImageBarWidth div 2;
  selH:=0;
  selL:=50;
  selS:=100;
  isUpdating:=false;

  extraListView:=nil;
  //Ge�ndert Farbe = Alte Farbe, bevor irgendetwas ver�ndert wurde ;-)
  for i:=0 to high(colorList) do
    colorList[i].newColor:=colorList[i].oldColor;
end;

//Freigabe
procedure TcolorManager.FormDestroy(Sender: TObject);
begin
  //Bitmaps
  colorImage.free;
  colorImageBuffer.free;
  colorImageBar.free;
  //ListView
  extraListView.free;
end;

//Farbbuffer des 2D-Auswahlfenster
procedure tcolorManager.updateColorImage;
var x,y,index:integer;
    line:PColorArray;
begin
  index:=colorBarMode.ItemIndex; //Barmodus
  for y:=0 to 199 do begin //Von oben nach unten
    line:=colorImage.ScanLine[y]; //Farbzeile w�hlen
    for x:=0 to 199 do begin
       //In den jeweiligen Pixel die beiden Farbkomponenten zeichnen, die �brigbleieb
       //wenn eine durch den Balken gew�hlt wurde
       case index of
         BarIsHue: HLSToRGB(selH,x div 2,y div 2,line[x].r,line[x].g,line[x].b);
         BarIsSatturation: HLSToRGB(x*360 div 200,selS,y div 2,line[x].r,line[x].g,line[x].b);
         BarIsLightness: HLSToRGB(x*360 div 200,y div 2,selL,line[x].r,line[x].g,line[x].b);
         BarIsRed: begin
                     line[x].r:=selR;
                     line[x].g:=min(255,x * 255 div 200);
                     line[x].b:=min(255,y * 255 div 200);
                   end;
         BarIsGreen: begin
                     line[x].r:=min(255,x * 255 div 200);
                     line[x].g:=selG;
                     line[x].b:=min(255,y * 255 div 200);
                   end;
         BarIsBlue: begin
                     line[x].r:=min(255,x * 255 div 200);
                     line[x].g:=min(255,y * 255 div 200);
                     line[x].b:=selB;
                   end;
       end;
    end;
  end;
  //Farbuffer ausgeben
  colorImageWindowPaint(colorImageWindow);
end;
//Farbbuffer des Farbauswahlbalkens zeichnen
procedure tcolorManager.updateColorImageBar(updateAll:boolean);
var x,y,index:integer;
    line2,line:PColorArray;
begin
  index:=colorBarMode.ItemIndex;
  //Obere H�lfte zeichnen, die von den beiden anderen gew�hlten Farbkomponenten
  //abh�ngt
  //Erste Zeile zeichnen
  line:=colorImageBar.ScanLine[0];
  if index>= BarIsRed then begin //RGB-Modus
    //Gesamte Fl�che mit der gew�hlten Farbe �berziehen
    colorImageBar.canvas.brush.color:=selColorPanel.Color;
    colorImageBar.Canvas.Rectangle(-1,-1,colorImageBarWidth+1,colorImageBarHeight div 2);
  end;
  //Die erste Zeile wird gezeichnet
  for x:=0 to 199 do begin
     case index of
       //Bei HLS werden die RGB-Farbkomponente an jeder Stelle neu aus den HLS-Werten
       //berechnet
       BarIsLightness: HLSToRGB(selH,selS,x*100div colorImageBarWidth,line[x].r,line[x].g,line[x].b);
       BarIsHue: HLSToRGB(x * 360 div colorImageBarWidth,selS,selL,line[x].r,line[x].g,line[x].b);
       BarIsSatturation: HLSToRGB(selH,x*100div colorImageBarWidth,selL,line[x].r,line[x].g,line[x].b);

       //Bei RGB wird einfach der ausgew�hlt Wert eingesetzt, die beiden anderen
       //sind bereit durch das F�llen gespeichert
       BarIsRed,BarIsGreen,BarIsBlue: line[x].colors[BarIsBlue-index]:=x * 255 div colorImageBarWidth;
    end;
  end;
  //Die erste Zeile wird runter kopiert, bis die H�lfte des Balkens ausgef�llt ist
  for y:=0 to colorImageBarHeight div 2 -1 do begin
    line2:=colorImageBar.ScanLine[y];
    CopyMemory(@line2[0],@line[0],colorImageWidth*3);
  end;

  if updateAll then begin //Soll der untere Teil auch neugezeichnet werden?
    //Wieder zuerst die erste Zeile neu zeichnet (allerdings ist die jetzt in
    //der Mitte)
    line:=colorImageBar.ScanLine[colorImageBarHeight div 2];
    if index>= BarIsRed then //Im RGB-Modus den Hintergrund l�schen, so dass die
      ZeroMemory(@line[0],colorImageWidth*3); //gezeichneten Farben rein sind
    for x:=0 to 199 do begin
       case index of
         //Farbwert mit voller S�ttigung und neutraler Helligkeit
         BarIsHue: HLSToRGB(x * 360 div colorImageBarWidth,100,50,line[x].r,line[x].g,line[x].b);
         //S�ttigung: neutrale Helligkeit und rot 
         BarIsSatturation: HLSToRGB(0,x*100 div colorImageBarWidth,50,line[x].r,line[x].g,line[x].b);
         //Helligkeit: komplett grau
         BarIsLightness: HLSToRGB(0,0,x*100 div colorImageBarWidth,line[x].r,line[x].g,line[x].b);

         //Die jeweilige Farbe ganz rein (der Rest ist ja schwarz) 
         BarIsRed,BarIsGreen,BarIsBlue: line[x].colors[BarIsBlue-index]:=x * 255 div colorImageBarWidth;
       end;
    end;

    //Die Zeile wird runter kopiert, bis der Rest des Balkens ausgef�llt ist
    for y:=colorImageBarHeight div 2 to colorImageBarHeight -1 do begin
      line2:=colorImageBar.ScanLine[y];
      CopyMemory(@line2[0],@line[0],colorImageWidth*3);
    end;
  end;
  //Farbbuffer ausgeben
  colorBarPaint(colorBar);
end;

//Auswahl im gro�en Wahlfeld starten
procedure TcolorManager.colorImageWindowMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var rec:TRect;
begin
  //Mausbereich aufs Auswahlfeld begrenzen
  rec.TopLeft:=ClientToScreen(point(colorImageWindow.left-1,colorImageWindow.top-1));
  rec.BottomRight:=ClientToScreen(point(colorImageWindow.left+colorImageWindow.width+1,
                                        colorImageWindow.top+colorImageWindow.height+1));
  ClipCursor(@rec);

  //Angeklickte Farbe w�hlen
  colorImageWindowMouseMove(sender,[ssLeft] + shift,x,y);
end;
//Maus wurde bewegt
procedure TcolorManager.colorImageWindowMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if ssLeft in shift then begin
    //Rausfinden, welche Farbe gew�hlt wurde
    case colorBarMode.ItemIndex of
      BarIsHue: begin //Farbton fest
           selL:=y * 100 div colorImageHeight;
           selS:=x * 100 div colorImageWidth;
         end;
      BarIsSatturation: begin //S�ttigung fest
           selH:=x * 360 div colorImageWidth;
           selL:=y * 100 div colorImageHeight;
         end;
      BarIsLightness: begin //Helligkeit fest
           selH:=x * 360 div colorImageWidth;
           selS:=y * 100 div colorImageHeight;
         end;
      BarIsRed: begin //Farbton fest
           selG:=x*255 div colorImageWidth;
           selB:=y*255 div colorImageHeight;
         end;
      BarIsGreen: begin //S�ttigung fest
           selR:=x*255 div colorImageWidth;
           selB:=y*255 div colorImageHeight;
         end;
      BarIsBlue: begin //Helligkeit fest
           selR:=x*255 div colorImageWidth;
           selG:=y*255 div colorImageHeight;
         end;
    end;
    //Sicherstellen, dass die Farbe g�ltig ist
    if selL<0 then selL:=0;
    if selL>100 then selL:=100;
    if selS<0 then selS:=0;
    if selS>100 then selS:=100;
    if selH<0 then selH:=0;
    if selH>360 then selH:=360;
    if selR<0 then selR:=0;
    if selR>255 then selR:=255;
    if selG<0 then selG:=0;
    if selG>255 then selG:=255;
    if selB<0 then selB:=0;
    if selB>255 then selB:=255;

    //andere Anzeigen aktualisieren
    updateSelectedColor(useSelected,[cuSpinHLS,cuSpinRGB,cuTopBar,cuHex]);

    //Auswahlfeld selber aktualiseren
    newSelX:=x;
    newSelY:=y;
    colorImageWindowPaint(colorImageWindow);
  end;
end;

//Auswahl beenden
procedure TcolorManager.colorImageWindowMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ClipCursor(nil); //Mausbegrenzung aufheben
  if button=mbLeft then begin //Linke Taste los gelassen?
    //Farbe von der aktuellen Position �bernehmen
    oldSelX:=x;
    oldSelY:=y;
    colorImageWindowPaint(colorImageWindow);
  end else begin
    //Farbe vom ersten Klick �bernehmen
    oldSelX:=newSelX;
    oldSelY:=newSelY;
    colorImageWindowPaint(colorImageWindow);
  end;
end;

//Setzt die Position des Farbauswahlbalken
procedure TcolorManager.setColorBarPos(const newPos:integer);
begin
  selBarPos:=newPos;
  if selBarPos<0 then selBarPos:=0;
  if selBarPos>colorImageBarWidth then selBarPos:=colorImageBarWidth;
  //Farbwert feststellen
  case colorBarMode.ItemIndex of
    BarIsHue: selH:=selBarPos*360 div colorImageBarWidth;
    BarIsSatturation: selS:=selBarPos*100 div colorImageBarWidth;
    BarIsLightness: selL:=selBarPos*100 div colorImageBarWidth;
    BarIsRed: selR:=selBarPos*255 div colorImageBarWidth;
    BarIsGreen: selG:=selBarPos*255 div colorImageBarWidth;
    BarIsBlue: selB:=selBarPos*255 div colorImageBarWidth;
  end;
  //andere Felder Aktualisieren
  updateSelectedColor(useSelected,[cuSpinHLS,cuSpinRGB,cuImage,cuHex]);
  //Markierung aktualisieren
  colorBarTopSelectorPaint(nil);
end;

//generelle Aktualisierungsprozedure.
//SIe wird bei jeder Farb�nderung aufgerufen, und aktualisiert die anderen
//Werte, siehe TColorUpdate.
procedure TcolorManager.updateSelectedColor(const colorBase:TUsedColorBase;
                                     update:TColorUpdate);
var r,g,b:byte;
begin
  if isUpdating then exit; //R�ckkopplung verhindern
  try
    isUpdating:=true;

    //Sicherstellen, dass die Farbe sowohl in HLS wie in RGB verf�gbar ist.
    if (colorBase=useRGB) or ((colorBase=useSelected) and (
                              colorBarMode.ItemIndex in [barIsRed..BarIsBlue])) then
      RGBToHLS(selR,selG,selB,selH,selS,selL) //Wenn RGB ausgew�hlt ist, HLS berechnen
     else begin
      //Wenn HLS gew�hlt ist RGB berechnen-
      HLSToRGB(selH,selS,selL,r,g,b);
      selR:=r;
      selG:=g;
      selB:=b;
    end;
    //Farbe anzeigen
    currentColor:=rgb(selR,selG,selB);
    //selColorPanel.Color:=rgb(selR,selG,selB);
    //Nochmal dr�ber zeichnen, weil die Panels tr�ge reagieren
    //selColor.canvas.brush.color:=rgb(selR,selG,selB);
    //selColor.Canvas.rectangle(-1,-1,1000,1000);
    selColorBoxPaint(nil);

    //HLS ausgeben
    if cuSpinHLS in update then begin
      spinH.Value:=selH;
      spinL.Value:=selL;
      spinS.Value:=selS;
    end;
    //RGB ausgeben
    if cuSpinRGB in update then begin
      spinR.Value:=selR;
      spinG.Value:=selG;
      spinB.Value:=selB;
    end;

    //2D-Auswahlfeld aktualisieren
    if cuImage in update then begin
      //Fadenkreuzposition berechnen
      case colorBarMode.ItemIndex of
        BarIsHue: begin //Farbton fest
           oldSelY:=selL * colorImageHeight div 100;
           oldSelX:=selS * colorImageWidth div 100;
         end;
        BarIsSatturation: begin //S�ttigung fest
           oldSelX:=selH * colorImageHeight div 360;
           oldSelY:=selL * colorImageWidth div 100;
         end;
        BarIsLightness: begin //Helligkeit fest
           oldSelX:=selH * colorImageHeight div 360;
           oldSelY:=selS * colorImageWidth div 100;
         end;
         BarIsRed: begin //Farbton fest
           oldSelX:=selG *  colorImageWidth div 255;
           oldSelY:=selB *  colorImageWidth div 255;
         end;
         BarIsGreen: begin //S�ttigung fest
           oldSelX:=selR *  colorImageWidth div 255;
           oldSelY:=selB *  colorImageWidth div 255;
         end;
         BarIsBlue: begin //Helligkeit fest
           oldSelX:=selR *  colorImageWidth div 255;
           oldSelY:=selG *  colorImageWidth div 255;
         end;
      end;
      newSelX:=oldSelX;
      newSelY:=oldSelY;
      //2D-Auswahlfeld aktualisieren
      updateColorImage;
      colorImageWindowPaint(colorImageWindow);
    end;

    //Auswahlbalken aktualisieren
    if (cuBottomBar in update) or (cuTopBar in update) then begin
      updateColorImageBar(cuBottomBar in update);
      colorBarPaint(colorBar);
    end;

    //Markierung auf dem Auswahlbalken aktualisieren
    if (cuBarPos in update) then begin
      //Neue berechnen
      case colorBarMode.ItemIndex of
        BarIsHue: selBarPos:=selH*colorImageBarWidth div 360;
        BarIsSatturation: selBarPos:=selS*colorImageBarWidth div 100;
        BarIsLightness: selBarPos:=selL*colorImageBarWidth div 100;
        BarIsRed: selBarPos:=selR*colorImageBarWidth div 255;
        BarIsGreen: selBarPos:=selG*colorImageBarWidth div 255;
        BarIsBlue: selBarPos:=selB*colorImageBarWidth div 255;
      end;
      //aktualisieren
      colorBarTopSelectorPaint(nil);
    end;
    //Hex-Wert aktualisieren
    if (cuHex in update) then
       hex.Text:='$'+IntToHex(selR,2)+IntToHex(selG,2)+IntToHex(selB,2);

    //listbox farbe aktualisiereb
    if (ListBox1.ItemIndex>=0) and (ListBox1.ItemIndex<=high(colorList)) and
       (colorList[ListBox1.ItemIndex].typ=vtValue) then begin
      //Wenn es in der Zeile eine Farbe gibt...
      //Farbe speichern
      colorList[ListBox1.ItemIndex].newColor:=rgb(selR,selG,selB);
      //aktualisieren
      extraListView.drawItem(ListBox1.ItemIndex);
    end;

    if (ListBox1.ItemIndex>=0) and (ListBox1.ItemIndex<=high(colorList)) then
      resetColor.enabled:=(colorList[ListBox1.ItemIndex].typ=vtValue) and (colorList[ListBox1.ItemIndex].newcolor<>colorList[ListBox1.ItemIndex].oldcolor)
     else
      resetColor.enabled:=startColor<>currentColor;
  finally
    isUpdating:=false;
  end;
end;

procedure TcolorManager.FormShow(Sender: TObject);
var i,mr,toselect:integer;
begin
  if extraListView=nil then begin
    //List View laden (siehe extralistview.pas)
    extraListView:=TExtraListView.create(listbox1,HeaderControl1);
    //extraListView.valueInfos:=@valueText;
    extraListView.OnDrawItem:=DrawItem;
    //ListBox f�llen
    if length(colorList)=0 then begin
      listboxpanel.Visible:=false;
      Width:=width-listboxpanel.Width-10;
      resetColor.left:=width-10-resetColor.Width;
    end;
  end;
  setlength(extraListView.valueTypes,length(colorList));
  ListBox1.Clear;
  toselect:=-1;
  for i:=0 to high(colorList) do begin
    extraListView.valueTypes[i]:=colorList[i].typ;
    colorList[i].newColor:=colorList[i].oldColor;
    if (toselect=-1)and( colorList[i].typ=vtValue) then
      toselect:=i;
    ListBox1.items.add(colorlist[i].name);//TODO
  end;
  if toselect<>-1 then begin
    ListBox1.ItemIndex:=toselect;
    startColor:=colorList[toSelect].oldColor;
  end else startColor:=currentColor;
  currentColor:=startColor;
  selR:=GetRValue(currentColor);selG:=GetGValue(currentColor);selB:=GetBValue(currentColor);
  updateSelectedColor(useRGB, [cuImage, cuBottomBar, cuTopBar, cuBarPos,  cuSpinHLS, cuSpinRGB, cuHex]);
//  updateColorImage; //gro�es Auswahlfeld aktualisen
//  updateColorImageBar(true); //Auswahlbalken aktualisieren
end;

//Auswahl auf dem Auswahlbalken beginnt
procedure TcolorManager.colorBarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var rec:TRect;
begin
  //Mausbegrenzen
  rec.TopLeft:=ClientToScreen(point(colorBar.left-2,colorBarTopSelector.top-2));
  rec.BottomRight:=ClientToScreen(point(colorBar.left+colorBar.width+2,
                                        colorBarBottomSelector.top+colorBarBottomSelector.height+2));
  ClipCursor(@rec);
  //Position aktualisieren (tag enth�lt den Unterschied in der Left Eigenschaft
  //zwischen colorBar, colorBarTopSelector und colorBarBottomSelector)
  setColorBarPos(x-tcontrol(sender).tag);
end;

//Auswahl ge�ndert
procedure TcolorManager.colorBarMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if ssLeft in shift then
    setColorBarPos(x-tcontrol(sender).tag);
end;

//Auswahl beenden
procedure TcolorManager.ColorBarMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ClipCursor(nil); //Begrenzung aufheben
end;

//HLS Repr�sentation der Farbe wurde ge�ndert
procedure TcolorManager.spinHLSChange(Sender: TObject);
begin
  try //Es kann sein das spin.value nicht gelesen werden kann
    if isUpdating then exit;//Wenn die �nderung vom Programm kommt nichts machen
    selH:=spinH.Value;
    selL:=spinL.Value;
    selS:=spinS.Value;
    //aktualisierung starten
    updateSelectedColor(useHLS,[cuTopBar,cuImage,cuSpinRGB,
                                cuImage,cuBarPos,cuHex]);
  except
  end;
end;

//RGB Repr�sentation der Farbe wurde ge�ndert
procedure TcolorManager.spinRGBChange(Sender: TObject);
begin
  try //Es kann sein das spin.value nicht gelesen werden kann
    if isUpdating then exit;//Wenn die �nderung vom Programm kommt nichts machen
    selR:=spinR.value;
    selG:=spinG.value;
    selB:=spinB.value;
    //aktualisierung starten
    updateSelectedColor(useRGB,[cuTopBar,cuImage,cuSpinHLS,
                                cuImage,cuBarPos,cuHex]);
  except
  end;
end;

//RGB-Hex Repr�sentation der Farbe wurde ge�ndert
procedure TcolorManager.hexChange(Sender: TObject);
begin
  try //Es kann Konvertierungsfehler geben
    if isUpdating then exit;//Wenn die �nderung vom Programm kommt nichts machen
    if (length(hex.text)<>7)or(hex.text[1]<>'$') then
      exit; //das w�re ung�ltig
    selR:=strtoint(copy(hex.text,1,3));
    selG:=strtoint('$'+copy(hex.text,4,2));
    selB:=strtoint('$'+copy(hex.text,6,2));
    updateSelectedColor(useRGB,[cuTopBar,cuImage,cuSpinHLS,cuSpinRGB,cuBarPos]);
  except
  end;
end;


//Farben in der LittBox zeichnen
procedure TcolorManager.DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var save:tcolor;
begin
  if (Index>=0) and (Index<=high(colorList)) and (colorList[index].typ=vtValue) then
    with ListBox1.canvas do begin
      //Farbeinstellungen
      brush.Style:=bsSolid;
      pen.Color:=clBlack;
      pen.Style:=psSolid;
      save:=brush.color; //Brush.color speichern

      //Alte Farbe
      brush.Color:=colorList[index].oldColor;
      Rectangle(HeaderControl1.Sections[1].Left+5,rect.top+1,
                HeaderControl1.Sections[1].Right-5,rect.bottom-1);

      //Neue Farbe
      brush.Color:=colorList[index].newColor;
      Rectangle(HeaderControl1.Sections[2].Left+5,rect.top+1,
                HeaderControl1.Sections[2].Right-5,rect.bottom-1);

      brush.color:=save; //Brush.color wiederherstellen (sonst bekommt eine
                         //Markierung eine falsche Farbe)
    end;
end;

//Farbe wurde ausgew�hlt
procedure TcolorManager.ListBox1Click(Sender: TObject);
begin
  if (ListBox1.ItemIndex>=0) and (ListBox1.ItemIndex<=high(colorList)) and (colorList[ListBox1.ItemIndex].typ=vtValue) then begin
    //Wenn es in der Zeile eine Farbe gibt...
    //RGB ausw�hlen
    selR:=getRValue(colorList[ListBox1.ItemIndex].newColor);
    selG:=getGValue(colorList[ListBox1.ItemIndex].newColor);
    selB:=getBValue(colorlist[ListBox1.ItemIndex].newColor);
    //alles aktualisieren
    updateSelectedColor(useRGB,[cuTopBar,cuImage,cuSpinHLS,cuSpinRGB,
                                cuImage,cuBarPos,cuHex]);
  end;
  //Buttons enstprechend einstellen
  resetColor.enabled:=(colorList[ListBox1.ItemIndex].typ=vtValue) and (colorList[ListBox1.ItemIndex].newcolor<>colorList[ListBox1.ItemIndex].oldcolor);
end;
//Hilfe entsprechend setzen
procedure TcolorManager.ListBox1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var item:Integer;
begin
  //Zeile finden
  item:=ListBox1.ItemAtPos(point(x,y),true);
  if item<>-1 then
    ListBox1.hint:=colorList[item].hint; //Hilfe setzen
end;

//Farbe in der Liste speichern
procedure TcolorManager.useColorClick(Sender: TObject);
begin
end;

//Farbe zur�cksetzten
procedure TcolorManager.resetColorClick(Sender: TObject);
begin
  if (ListBox1.ItemIndex>=0) and (ListBox1.ItemIndex<=high(colorList))  and (colorList[ListBox1.ItemIndex].typ=vtValue) then begin
    //Wenn es in der Zeile eine Farbe gibt...
    //alte Farbe auslesen und setzen
    //alles aktualisieren
    currentColor:=colorList[ListBox1.ItemIndex].oldColor;
  end else currentColor:=startColor;

  selR:=getRValue(currentColor);
  selG:=getGValue(currentColor);
  selB:=getBValue(currentColor);
  updateSelectedColor(useRGB,[cuTopBar,cuImage,cuSpinHLS,cuSpinRGB, cuImage,cuBarPos,cuHex]);
end;

//Alles speichern und Schlie�en
procedure TcolorManager.OKClick(Sender: TObject);
begin
  //Schlie�en
  ModalResult:=mrOk;
  close;
end;

//Alles zur�cksetzen und Schlie�en
procedure TcolorManager.CancelClick(Sender: TObject);
var i:integer;
begin
  //alles durchlaufen, und wenn es eine Farbzeile ist, zur�cksetzen
  for i:=0 to high(colorList) do
    colorList[i].newColor:=colorList[i].oldColor;
  currentColor:=startColor;
  //Schlie�en
  ModalResult:=mrCancel;
  close;
end;

procedure TcolorManager.addToColorList(name:string; typ: TValueType; oldColor:TColor=clNone; hint:string='');
begin
  SetLength(fcolorList,length(colorList)+1);
  colorList[high(colorList)].name:=name;
  colorList[high(colorList)].typ:=typ;
  colorList[high(colorList)].oldColor:=ColorToRGB(oldColor);//special colors can't be used
  colorList[high(colorList)].hint:=hint;
  BorderStyle:=bsSizeToolWin;
end;

function TcolorManager.findInColorList(name:string):TColor;
var i:longint;
begin
  for i:=0 to high(colorList) do
    if colorList[i].name=name then begin
      result:=colorlist[i].newcolor;
      exit;
    end;
  result:=clnone;
end;

procedure TcolorManager.selColorBoxPaint(Sender: TObject);
begin
  //TShape is to slow
  if length(colorList)=0 then selColorBox.Canvas.brush.Color:=startColor
  else if (ListBox1.ItemIndex>=0)and(listbox1.itemindex<=high(colorList)) then selColorBox.Canvas.brush.Color:=colorList[listbox1.itemindex].oldColor
  else selColorBox.Canvas.brush.Color:=currentColor;
  selColorBox.canvas.FillRect(rect(0,0,34,selColorBox.height));
  selColorBox.Canvas.brush.Color:=currentColor;
  selColorBox.canvas.FillRect(rect(34,0,selColorBox.width,selColorBox.height));
end;

end.
