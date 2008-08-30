unit ExtraListView;

interface
uses controls,stdctrls,comctrls,classes,graphics,sysutils,windows;
type
  {$Z4}
  TValueType=(vtValue,vtCaptionH1,vtCaptionH2,vtCaptionH3); //Typ eines Eintrages
  //ausreichen gro�es Eintragarray (es wird nat�rlich immer mit Zeigern gearbeitet)
  TExtraListView=class(TObject)
  { TExtraListView macht aus einer ListBox ein ListView mit mehreren Spalten
    und unterschiedlich hohen Eintr�gen (bei OwnerDraw w�ren sie n�mlich alle
    gleich hoch)
  }
  private
    fontHeight:array[0..3] of integer; //H�he der jeweiligen Schriftgr��e
    listBox:TListBox; //Zugeh�rige Listbox
    header:theaderControl; //Zugeh�riger Spaltenkomponennte
    drawItemEvent:TDrawItemEvent; //Methode zum Ausf�llen der Spalten

    //H�he zur�ck geben
    procedure ListBoxMeasureItem(Control: TWinControl; Index: Integer;  var Height: Integer);
    //Eintrag zeichnen
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer;
                              Rect: TRect; State: TOwnerDrawState);
    //Neuzeichnen wenn eine Spalte ver�ndert wird
    procedure HeaderSectionResize(HeaderControl: THeaderControl;
                                          Section: THeaderSection);
  public
    valueTypes: array of TValueType;  //diese informationen m�ssen in einer extra Eigenschaft stehen, da man sie nicht pro listbox eintrag (zumindest nicht per addobject) festlegen kann, da problem mit measureitem 
    //ListBox zurecht setzen
    constructor create(listBox:TListBox; header:theaderControl);
    destructor destroy;override;

    //Eintrag zeichnen
    procedure drawItem(i:integer);

    //Methode zum Ausf�llen der Spalten
    property OnDrawItem:TDrawItemEvent read drawItemEvent write drawItemEvent;
  end;
implementation
const fontSize:array[0..3] of integer=(8,18,14,10); //Schriftgr��en
      fontStyle:array[0..3] of TFontStyles=([],[fsBold],[fsBold],[fsBold]); //Schriftstyle
        //der jeweiligen Eintragstypen
//H�he eines Eintrages zur�ckgeben
procedure TExtraListView.ListBoxMeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
begin
  Height:=fontheight[integer(valueTypes[index])]+1
end;

//Eintrag zeichnen
procedure TExtraListView.ListBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var tr:TRect; //Tempor�res Beschr�nkungsrechteck
    i:integer;
    curValue: TValueType;
begin
  curValue:=valueTypes[index];
  with ListBox.canvas do begin

    pen.Style:=psClear;
    //Zeilenhintergrund zeichnen
    if (odSelected in State)or(odFocused in State) then begin
      //Wenn markiert, nicht die ganze Zeile ausf�llen (um den gepunkteten Rand
      //nicht zu l�schen)
      brush.Color:=clHighlight;
      font.Color:=clHighlightText;
      Rectangle(rect.left+1,rect.top+1,rect.right-1,rect.bottom)
    end else begin
      //Ansonsten schon
      brush.Color:=clWindow;
      font.Color:=clWindowText;
      FillRect(rect);
    end;

    //Vertikale Trennlinien
    pen.Style:=psSolid;
    if curValue>=vtValue then pen.Color:=clSilver //Hellgrau bei �berschriften
    else pen.Color:=clGray; //sonst dunkelgrau
    //alle Spalten durchlaufen
    for i:=0 to Header.Sections.Count-1 do begin
      MoveTo(Header.Sections[i].Right,rect.top);
      LineTo(Header.Sections[i].Right,rect.bottom);
    end;

    //Schriftart setzen
    Font.Size:=fontsize[integer(curValue)];
    Font.Style:=fontstyle[integer(curValue)];
    brush.Style:=bsClear;
    if curValue>vtValue then
      //�berschriften Text ausgeben
      TextRect(rect,rect.left+2,rect.top+1,listBox.items[index])
    else begin
      //Eintragstext ausgeben, aber auf die erste Spalte begrenzen
      tr.TopLeft:=Rect.TopLeft;
      tr.Right:=Header.Sections[0].Right;
      tr.Bottom:=rect.bottom;
      TextRect(tr,tr.left+2,tr.top+1,listBox.items[index]);
    end;
    //Angegeben Funktion f�r die restlichen Spalten aufrufen
    if assigned(onDrawItem) then ondrawItem(Control,index,rect,state);
  end;
end;

//ListView neuzeichnen, wenn ein Spalte vergr��ert wird
procedure TExtraListView.HeaderSectionResize(HeaderControl: THeaderControl;
  Section: THeaderSection);
begin
  ListBox.Repaint;
end;

constructor TExtraListView.create(listBox:TListBox; header:theaderControl);
var i:integer;
begin
  //Listbox und Header sind n�tig
  if listBox=nil then raise exception.create('Keine ListBox �bergeben (TExtraListView.create)');
  if header=nil then raise exception.create('Kein Header �bergeben (TExtraListView.create)');
  self.listBox:=listBox;
  self.header:=header;
  //Eigenschaften setzten, und Ereignisse registrieren
  listBox.Style:=lbOwnerDrawVariable;
  listBox.OnMeasureItem:=ListBoxMeasureItem;
  listBox.OnDrawItem:=ListBoxDrawItem;
  header.OnSectionResize:=HeaderSectionResize;
  //Fontgr��en laden
  for i:=0 to 3 do begin
    ListBox.Canvas.Font.Size:=fontsize[i];
    ListBox.Canvas.Font.Style:=fontstyle[i];
    fontHeight[i]:=ListBox.Canvas.TextHeight('AZqg�|');
  end;
end;
destructor TExtraListView.destroy;
begin
  listBox.OnMeasureItem:=nil;
  listBox.OnDrawItem:=nil;
  inherited;
end;

//Eintrag zeichnen
procedure TExtraListView.drawItem(i:integer);
var state:TOwnerDrawState;
begin
  //Status berechnen
  state:=[];
  if ListBox.Selected[i] then Include(state,odSelected);
  if ListBox.ItemIndex=i then Include(state,odFocused);
  //zeichnen
  ListBoxDrawItem(nil,i,ListBox.ItemRect(i),state);
end;
end.

