unit cmo_interf;

INTERFACE
uses crt, graph;

const
MBOX_W = 160;
MBOX_H = 30;

WDOW_W = 300;
WDOW_h = 200;

TBOX_W = 180;
TBOX_H = 30;
MAX_C  = 10;

Type
MenuBox = Object
  X, Y: integer;
  H, W: integer;
  Text: String[MAX_C+1];
  Foc: boolean;
  Opened: boolean;
  visible: boolean;
  Procedure Redraw;virtual;
  Procedure SetFocus;
  Procedure ClearFocus;
  Procedure SetText(s: String);
  Procedure Show;
  Constructor Init(x1,y1: integer);
end;
MenuList = Object(MenuBox)
  N_Items: integer;
  Items: array[1..3] of MenuBox;
  Procedure Redraw;virtual;
  Procedure AddItem(s: String);
  Procedure Open;
  Procedure Close;
  Constructor Init(x1,y1: integer);
end;
TextBox = Object(MenuBox)
  CPOS: integer; {Cursor Position}
  Constructor Init(x1,y1: integer);
  Procedure PutChar(c: char);
  Procedure ClearChar;
  Procedure Activate;
  Procedure Deactivate;
  Procedure SetText(s: string);
  Function getReal: real;
  Function getInt: integer;
end;
Window = Object
  X,Y: integer;
  H,W: integer;
  N_TextBoxes: integer;
  ActiveBox: integer;
  Title: String[20];
  Labels: array[1..3] of String[5];
  TextBoxes: array[1..3] of TextBox;
  Constructor Init(x1,y1: integer);
  Procedure AddTextBox(text: string);
  Procedure SetTitle(s: string);
  Procedure AddText(filename: string);
  Function HandleInput:boolean;
  Procedure Show;
end;
GUI = Object
  Menus: array[1..4] of MenuList;
  Windows: array[1..6] of Window;
  ActiveList: integer;
  ActiveBox: integer;
  Constructor Init;
  Function HandleInput(c: char):integer;
  Procedure Redraw;
end;

IMPLEMENTATION

{* * * * * * MenuBox * * * * * * * * }

Constructor MenuBox.Init(x1,y1: integer);
begin
  X := x1; Y := y1;
  H := MBOX_H;
  W := MBOX_W;
  Foc := false; Opened := false;
  Visible := false;
end;
Procedure MenuBox.Show;
begin
  Visible := true;
  Redraw;
end;
Procedure MenuBox.SetText(s: String);
begin
  Text := s;
  if Visible then
    Redraw;
end;
Procedure MenuBox.Redraw;
begin
  if FOC then
    SetFillStyle(1, cyan)
  else
    SetFillStyle(1, blue);
  bar(X,Y,X+W, Y+H);

  SetColor(white);
  Rectangle(X,Y,X+W,Y+H);

  if NOT FOC then
    SetColor(blue);
  Rectangle(X+2,Y+2, X+W-2, Y+H-2);

  SetColor(white);
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(X+5,Y+5, Text);
end;
Procedure MenuBox.SetFocus;
begin
  Foc := true;
  Redraw;
end;
Procedure MenuBox.ClearFocus;
begin
  Foc := false;
  Redraw;
end;

{ * * * * * * * MenuList * * * * * * * * * }

Procedure MenuList.Redraw;
var i: integer;
begin
  inherited Redraw;
  If Opened then
    for i:=1 to N_Items do
      Items[i].Redraw;
end;
Procedure MenuList.AddItem(s: string);
begin
  N_Items := N_Items+1;
  Items[N_Items].Init(X, Y+N_Items*H);
  Items[N_Items].SetText(s);
end;
Procedure MenuList.Open;
var i: integer;
begin
  Opened := true;
  for i:=1 to N_Items do
    Items[i].Show;
end;
Procedure MenuList.Close;
begin
  Opened := false;
end;
Constructor MenuList.Init(x1,y1:integer);
begin
  Inherited Init(x1,y1);
  N_Items := 0;
  Opened := false;
end;

{ * * * * * * TextBox * * * * * * * * * * * }

Constructor TextBox.Init(x1,y1: integer);
begin
  X := x1; H := TBOX_H;
  Y := y1; W := TBOX_W;
  CPOS := 1; Text[0] := '0';
  FOC := false;
end;
Procedure TextBox.Activate;
begin
  Text[CPOS] := '_';
  inherited setFocus;
end;
Procedure TextBox.Deactivate;
begin
  Text[CPOS] := #0;
  inherited ClearFocus;
end;
Function TextBox.getReal: real;
var r: real; err: integer; s: string[10];
begin
  s := Copy(Text, 1, CPOS-1);
  val(s, r, err);
  getReal := r;
end;
Function TextBox.getInt: integer;
begin
  getInt := trunc(getReal);
end;
Procedure TextBox.ClearChar;
begin
  if CPOS > 1 then
  begin
    Text[CPOS-1] := '_';
    Text[CPOS] := #0;
    CPOS := CPOS-1;
    Redraw;
  end;
end;
Procedure TextBox.PutChar(c: char);
begin
  if CPOS < MAX_C then
  begin
    Text[CPOS] := c;
    CPOS := CPOS + 1;
    Text[CPOS] := '_';
    TextBox.Redraw;
  end;
end;
Procedure TextBox.SetText(s: string);
var i: integer;
begin
  for i:=1 to Length(s) do
    Text[i] := s[i];
  CPOS := Length(s)+1;
end;

{* * * * * * * Window * * * * * * * * * * }

Constructor Window.Init(x1,y1: integer);
begin
  X := x1; W := WDOW_W;
  Y := y1; H := WDOW_H;
  N_TextBoxes := 0;
  ActiveBox := 1;
end;
Procedure Window.SetTitle(s: string);
begin
  Title := s;
end;
Procedure Window.AddTextBox(text: string);
begin
  N_TextBoxes := N_TextBoxes + 1;
  Labels[N_TextBoxes] := text;
  TextBoxes[N_TextBoxes].Init(X+W div 3,Y+15+N_TextBoxes*30);
end;
Procedure Window.Show;
var i: integer;
begin
  SetFillStyle(1, cyan);
  bar(X,Y,X+W,Y+MBOX_H);
  SetFillStyle(1, blue);
  bar(X,Y+MBOX_H,X+W, Y+H);

  SetColor(white);
  Rectangle(X,Y,X+W,Y+H);
  Rectangle(X+2,Y+2, X+W-2, Y+H-2);

  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(X+5,Y+5, Title);

  if N_TextBoxes >= 1 then
  Begin
    TextBoxes[1].Activate;
    for i:=1 to N_TextBoxes do
    begin
      OutTextXY(X+10, Y+20+i*30, Labels[i]);
      TextBoxes[i].Redraw;
    end;
  End;
end;
Function Window.HandleInput:boolean;
var c: char;
begin
  HandleInput := true;
  while true do
  begin
    if not keypressed then
      continue;

    c := readkey;
   case c of
    #8:  TextBoxes[ActiveBox].clearChar; {Backspace}
    #72: {Up arrow}
    begin
      if ActiveBox > 1 then
      begin
        TextBoxes[ActiveBox].Deactivate;
        ActiveBox := ActiveBox - 1;
        TextBoxes[ActiveBox].Activate;
      end;
    end;
    #13, #80:  {Enter, Down Arrow}
    begin
      if ActiveBox = N_TextBoxes then
      begin
        if c = #13 then
        begin
          TextBoxes[ActiveBox].Deactivate;
          ActiveBox := 1;
          break;
        end;
      end
      else begin
        TextBoxes[ActiveBox].Deactivate;
        ActiveBox := ActiveBox + 1;
        TextBoxes[ActiveBox].Activate;
      end;
    end;
    '0'..'9', '.': TextBoxes[ActiveBox].putChar(c);
    #27: {ESC}
    begin
      HandleInput := false;
      TextBoxes[ActiveBox].Deactivate;
      ActiveBox := 1;
      break;
    end;
   end;
  end;
end;
Procedure Window.AddText(filename: string);
var f: text; iy: integer; line: string;
begin
  assign(f, filename);
  reset(f);
   {
  SetTextStyle(SmallFont, HorizDir, 7);
  }
  SetTextStyle(DefaultFont, HorizDir, 1);
  iy := Y+30;
  while not eof(f) do
  begin
    readln(f, line);
    OutTextXY(X+10, iy, line);
    iy := iy+15;
  end;
  close(f);
end;
{ * * * * * GUI * * * * * * * * * }

Constructor GUI.Init;
begin
  ActiveList := 1;
  ActiveBox  := 0;

  Menus[1].Init(0,0);
  Menus[1].SetText('Options');
  Menus[1].SetFocus;

  Menus[1].AddItem('Istocniki');
  Menus[1].AddItem('Pribor');
  Menus[1].AddItem('Pogresnost');
  Menus[1].Show;

  Menus[2].Init(160, 0);
  Menus[2].SetText('Modelling');
  Menus[2].AddItem('Fast Mode');
  Menus[2].AddItem('Normal Mode');
  Menus[2].Show;

  Menus[3].Init(320, 0);
  Menus[3].SetText('Results');
  Menus[3].AddItem('Graph');
  Menus[3].AddItem('Table');
  Menus[3].AddItem('Bar Chart');
  Menus[3].Show;

  Menus[4].Init(480, 0);
  Menus[4].Settext('Help');
  Menus[4].AddItem('Usage');
  Menus[4].AddItem('About');
  Menus[4].Show;

  Windows[1].Init(160, 150);
  Windows[1].SetTitle('Istocniki');
  Windows[1].AddTextBox('Lam1');
  Windows[1].TextBoxes[1].SetText('4.00');
  Windows[1].AddTextBox('Lam2');
  Windows[1].TextBoxes[2].SetText('3.00');
  Windows[1].AddTextBox('Lam3');
  Windows[1].TextBoxes[3].SetText('3.00');

  Windows[2].Init(160, 150);
  Windows[2].SetTitle('Pribor');
  Windows[2].AddTextBox('Lam1');
  Windows[2].TextBoxes[1].SetText('1.00');
  Windows[2].AddTextBox('Lam2');
  Windows[2].TextBoxes[2].SetText('6.00');
  Windows[2].AddTextBox('DLam');
  Windows[2].TextBoxes[3].SetText('0.50');

  Windows[3].Init(160, 150);
  Windows[3].SetTitle('Dlina Realizacii');
  Windows[3].AddTextBox('KMIN');
  Windows[3].TextBoxes[1].SetText('3000');

  Windows[4].Init(160,150);
  Windows[4].SetTitle('Pogresnost');
  Windows[4].AddTextBox('DOV VER');
  Windows[4].TextBoxes[1].SetText('0.95');

  Windows[5].Init(150,100);
  Windows[5].H := 320;
  Windows[5].W := 380;
  Windows[5].SetTitle('Usage');

  Windows[6].Init(150,100);
  Windows[6].H := 200;
  Windows[6].W := 350;
  Windows[6].SetTitle('About');
end;
Procedure GUI.Redraw;
var i: integer;
begin
  cleardevice;
  for i:=1 to 4 do
    Menus[i].Show;
end;
Function GUI.HandleInput(c: char): integer;
begin
  HandleInput := 1;
  case c of
    #72:  {up arrow}
    begin
      if ActiveBox > 0 then
      begin
        Menus[ActiveList].Items[ActiveBox].ClearFocus;
        ActiveBox := ActiveBox - 1;
        if ActiveBox > 0 then
          Menus[ActiveList].Items[ActiveBox].SetFocus;
      end
      else
        ActiveBox := 0;
    end;
    #80: {down arrow}
    begin
      if (ActiveBox < Menus[ActiveList].N_Items) And
         (Menus[ActiveList].Opened) then
      begin
        If ActiveBox > 0 then
          Menus[ActiveList].Items[ActiveBox].ClearFocus;
        ActiveBox := ActiveBox + 1;
        Menus[ActiveList].Items[ActiveBox].SetFocus;
      end;
    end;
    #75: {Left arrow}
    begin
      if (ActiveList > 1) And (ActiveBox = 0) then
      begin
        Menus[ActiveList].ClearFocus;
        Menus[ActiveList].Close;
        ActiveList := ActiveList - 1;
        Menus[ActiveList].SetFocus;
        Redraw;
      end;
    end;
    #77: {Right Arrow}
    begin
      if (ActiveList < 4) And (ActiveBox = 0) then
      begin
        Menus[ActiveList].ClearFocus;
        Menus[ActiveList].Close;
        ActiveList := ActiveList + 1;
        Menus[ActiveList].SetFocus;
        Redraw;
      end;
    end;
    #13: {ENTER}
    begin
      if ActiveBox = 0 then
      begin
        ActiveBox := 1;
        Menus[ActiveList].Open;
        Menus[ActiveList].Items[ActiveBox].SetFocus;
      end
      else if (ActiveList = 1) AND (ActiveBox = 1) then
      begin
        Windows[1].Show;
        Windows[1].HandleInput;
        clrscr;
        Redraw;
      end
      else if (ActiveList = 1) AND (ActiveBox = 2) then
      begin
        Windows[2].Show;
        Windows[2].HandleInput;
        clrscr;
        Redraw;
      end
      else if (ActiveList = 1) AND (ActiveBox = 3) then
      begin
        Windows[4].Show;
        readkey;
        clrscr;
        Redraw;
      end
      else if (ActiveList = 2) AND (ActiveBox > 0) then
      begin
        Windows[3].Show;
        if Windows[3].HandleInput <> false then
          HandleInput := ActiveList*10 + ActiveBox;
        clrscr;
        Redraw;
      end
      else if (ActiveList = 3) AND (ActiveBox > 0) then
      begin
        HandleInput := ActiveList*10 + ActiveBox;
      end
      else if (ActiveList = 4) AND (ActiveBox = 1) then
      begin
        Windows[5].Show;
        Windows[5].AddText('Usage.txt');
        readkey;
        clrscr;
        Redraw;
      end
      else if (ActiveList = 4) AND (ActiveBox = 2) then
      begin
        Windows[6].Show;
        Windows[6].AddText('About.txt');
        readkey;
        clrscr;
        Redraw;
      end;
    end;
    #27:
    begin
      if Menus[ActiveList].Opened then
      begin
        if ActiveBox > 0 then
          Menus[ActiveList].Items[ActiveBox].ClearFocus;
        Menus[ActiveList].Close;
        ActiveBox := 0;
        Redraw;
      end
      else
        HandleInput := 0;  {ESC}
    end;
  end;
end;

begin
end.