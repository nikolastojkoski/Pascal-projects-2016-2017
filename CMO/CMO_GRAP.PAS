unit cmo_graph;

INTERFACE
Uses crt, graph;

const
EPS = 0.00001;

type
Graphic = Object
  X0, Y0, H, W: integer;
  MAX_X, MAX_Y, OffsetX: real;
  Color: integer;
  PX,PY: array[1..3] of integer;
  RMX, RMY: real;
  Name_X, Name_Y: String[5];

  Constructor Init(x,y,cl:integer;mx1,my1,osx:real;nx,ny:String);
  Procedure DrawOy;
  Procedure DrawOx;virtual;
  Procedure AddPoint(mx, my: real; col, id: integer);virtual;
  Procedure AddTitle(title: String;FSize: integer);
  Procedure AddColorGuide(L1, L2, L3: real);
end;
BarChart = Object(Graphic)
  Procedure AddPoint(mx, my: real; col, id: integer);virtual;
  Procedure DrawOx;virtual;
end;
Table = Object
  X0, Y0, H, W: integer;
  ROWS, COLS: integer;
  Constructor Init(x1,y1,h1,w1,rows1,cols1: integer);
  Procedure DrawBorders;
  Procedure SetColText(col:integer; title:String; color:integer);
  Procedure SetCell(row, col:integer; inf:real; color:integer; prc:boolean);
  Procedure AddColorGuide(L1,L2,L3: real);
end;

IMPLEMENTATION

{ * * * * * TABLE * * * * * * }

Constructor Table.Init(x1,y1,h1,w1,rows1,cols1: integer);
begin
  X0 := x1; Y0 := y1;
  H  := h1; W  := w1;
  ROWS := rows1;
  COLS := cols1;
end;
Procedure Table.DrawBorders;
var i,x,dx,y,dy: integer;
begin
  SetColor(DarkGray);

  y := y0; dy := H div rows;
  for i:= 1 to rows+1 do
  begin
    Line(x0, y, x0+w, y);
    y := y + dy;
  end;

  x:=x0; dx:= W div cols;
  for i:=1 to cols+1 do
  begin
    Line(x, y0, x, y0+h);
    x := x + dx;
  end;
end;
Procedure Table.SetColText(col:integer; title:String; color: integer);
begin
  SetTextStyle(SmallFont, HorizDir, 7);
  SetColor(color);
  OutTextXY(x0+5+(col-1)*(w div cols), y0+5, title);
end;
Procedure Table.SetCell(row, col:integer; inf: real; color:integer; prc: boolean);
var x,y: integer; ns: String[4];
begin
  SetTextStyle(SmallFont, HorizDir, 7);
  SetColor(color);
  x := x0+5+(col-1)*(w div cols);
  y := y0+5+(row-1)*(h div rows);
  if prc then
  begin
    str(inf:2:0, ns);
    OutTextXY(x,y, ns + '%');
  end
  else begin
    str(inf:2:2, ns);
    OutTextXY(x,y, ns);
  end;
end;
Procedure Table.AddColorGuide(L1,L2,L3: real);
var ns: String[4];
begin
  SetColor(DarkGray);
  SetTextStyle(DefaultFont, HorizDir, 1);

  str(L1:2:1, ns);
  setFillStyle(1, red);
  bar(x0+140,y0-30, x0+150, y0-20);
  OutTextXY(x0+155, y0-30, 'Lam = ' + ns);

  str(L2:2:1, ns);
  setFillStyle(1, green);
  bar(x0+240, y0-30, x0+250, y0-20);
  OutTextXY(x0+255, y0-30, 'Lam = ' + ns);

  str(L3:2:1, ns);
  setFillStyle(1, blue);
  bar(x0+340,y0-30, x0+350, y0-20);
  OutTextXY(x0+355, y0-30, 'Lam = ' + ns);
end;

{ * * * * * * * GRAPHIC * * * * * * * }

Constructor Graphic.Init(x,y,cl:integer;mx1,my1,osx:real;nx,ny:String);
var i: integer;
begin
  X0 := x-1; Y0 := y+1;
  W  := 500; H  := 180;
  MAX_X := mx1; MAX_Y := my1;
  OffsetX := osx;

  for i:=1 to 3 do
  begin
    PX[i] := x0;
    PY[i] := y0;
  end;

  RMX := w/(MAX_X - OffsetX);
  if MAX_Y <> 0 then
    RMY := H/MAX_Y;

  Color := cl;
  Name_X := nx; Name_Y := ny;
  DrawOy; DrawOx;
end;
Procedure Graphic.AddColorGuide(L1,L2,L3: real);
var ns: String[4];
begin
  SetTextStyle(DefaultFont, HorizDir, 1);

  str(L1:2:1, ns);
  setFillStyle(1, red);
  bar(490,y0-160, 497, y0-153);
  OutTextXY(500, y0-160, 'Lam = ' + ns);

  str(L2:2:1, ns);
  setFillStyle(1, green);
  bar(490, y0-150, 497, y0-143);
  OutTextXY(500, y0-150, 'Lam = ' + ns);

  str(L3:2:1, ns);
  setFillStyle(1, blue);
  bar(490,y0-140, 497, y0-133);

  OutTextXY(500, y0-140, 'Lam = ' + ns);
end;
Procedure Graphic.AddTitle(title: String; FSize: integer);
begin
  SetTextStyle(DefaultFont, HorizDir, FSize);
  if FSize = 1 then
    OutTextXY(280, y0-180, title)
  else
    OutTextXY(200, 20, title);
end;
Procedure Graphic.DrawOx;
var ix, dx: real; rxi: integer;ns:String[4];
begin
  setColor(darkGray);
  setTextStyle(DefaultFont, HorizDir, 1);

  line(x0, y0, x0+w+20, y0);
  line(x0+w+20, y0, x0+w+15, y0+5);
  line(x0+w+20, y0, x0+w+15, y0-5);
  outTextXY(x0+w+21, y0, name_x);

  setTextStyle(SmallFont, VertDir, 4);
  DX := (max_x-OffsetX) / 10; ix := OffsetX;
  while (ix - max_x) < EPS{ <= max_x} do
  begin
    rxi := x0 + trunc((ix-OffsetX)*RMX);
    line(rxi, y0, rxi, y0+5);
    if OffsetX > 0 then
      str(ix:2:1, ns)
    else
      str(ix:3:0, ns);
    outTextXY(rxi - 5, y0+5, ns);
    ix := ix + dx;
  end;
end;
Procedure Graphic.DrawOy;
var iy, dy: integer; ns:String[4];
begin
  setColor(darkGray);
  setTextStyle(DefaultFont, HorizDir, 1);

  line(x0, y0, x0, y0-h-20);
  line(x0, y0-h-20, x0-5, y0-h-15);
  line(x0, y0-h-20, x0+5, y0-h-15);
  outTextXY(x0-40, y0-h-20, name_y);

  SetTextStyle(SmallFont, HorizDir, 4);
  dy := H div 10; iy := 0;
  while iy <= h do
  begin
    line(x0, y0-iy, x0-5, y0-iy);
    if MAX_Y = 0 then
      str(iy/100:3:1, ns)
    else
      str(iy/RMY:3:0, ns);
    outTextXY(x0-25, y0-iy-5, ns);
    iy := iy + dy;
  end;
end;
Procedure Graphic.AddPoint(mx, my:real; col, id: integer);
var X, Y: integer;
begin
  my := my*100;
  X := X0 - trunc(OffsetX*RMX) + trunc(mx*RMX);
  if MAX_Y = 0 then
    Y := Y0 - trunc(my)
  else
    Y := Y0 - trunc(my * RMY);

  if mx - MAX_X < EPS then
  begin
    SetColor(col);
    Line(PX[id], PY[id], X, Y);
    PX[id] := X; PY[id] := Y;
  end;
end;

{ * * * * * * * BAR CHART * * * * * * }

Procedure BarChart.AddPoint(mx, my: real; col, id: integer);
var X, Y: integer;
begin
  my := my*100;
  X := X0 - trunc(OffsetX*RMX) + trunc(mx*RMX);
  if MAX_Y = 0 then
    Y := Y0 - trunc(my)
  else
    Y := Y0 - trunc(my * RMY);

  if mx - MAX_X < EPS then
  begin
    SetColor(col);
    SetFillStyle(1, col);
    Bar(X-12+8*(id-1),Y, X-4+8*(id-1), Y0);
  end;
end;
Procedure BarChart.DrawOx;
begin
  SetColor(darkGray);
  Line(x0,y0,x0+25,y0);
  x0 := x0 + 25;
  inherited DrawOx;
end;
begin
end.