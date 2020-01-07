unit P11_DEP;

INTERFACE
uses graph;

const
V_MAX    =   5; MAX_SMOKE  =   50;
GROUND_Y = 300; TREE_Y     =  230;
SMOKE_VY = 0.3; S_TICK     =   30;

CON_LEN  =  35; BOX_LEN    =   15;
BOXH_D2  =   5; CSHAFT_LEN =   60;
EPS  = 0.00001; PI_2       = 6.28;

BR = 20; SR  =  10;
WR = 14; FPS =  20;
C  =  3; dt  = 0.5;

Type
GameObject = Object
  x,y     : integer;
  xr,yr,vx: real;
  procedure getParams;
  procedure putFrame;
  procedure move;virtual;
  procedure draw;virtual;
  Constructor init;
end;
Wheel = Object(GameObject)
  r: integer;
  a,da,w: real;
  procedure getXY(var x1,y1: integer);
  procedure incAngle;
  procedure draw;virtual;
  procedure move;virtual;
  Constructor Init(x1,y1,r1:integer; a1:real);
end;
Train = Object(GameObject)
  wheels: array[1..3] of wheel;
  procedure drawConnector;
  procedure drawBody;
  procedure draw;virtual;
  procedure move;virtual;
  function checkRange:boolean;virtual;
  Constructor Init(sx: integer);
end;
Tree = Object(GameObject)
  r: integer;
  procedure draw;virtual;
  Constructor Init(x1,r1: integer);
end;
Smoke = Object(GameObject)
  r: integer;
  procedure move;virtual;
  procedure draw;virtual;
  Constructor Init(x1:integer;vx1:real);
end;

IMPLEMENTATION
procedure GameObject.getParams;
begin
  move;
end;
procedure GameObject.putFrame;
begin
  draw;
end;
procedure GameObject.move;begin end;
procedure GameObject.draw;begin end;
Constructor GameObject.init;begin end;
Constructor Smoke.Init(x1:integer;vx1:real);
begin
  x := x1+100;
  y := 190;
  yr := y;
  r := 3 + trunc(2.5*vx1);
end;
procedure Smoke.move;
begin
  yr := yr - (SMOKE_VY*3/dt);
  y := trunc(yr);
  x := x - random(2) + random(2);
  if (random(8) = 4)  then
    r := r + random(2);
end;
procedure Smoke.draw;
begin
  SetColor(white);
  SetFillStyle(1, white);
  circle(x,y,r);
  floodfill(x,y,white);
end;
Constructor Tree.Init(x1,r1: integer);
begin
  x := x1; r := r1;
end;
procedure Tree.draw;
begin
  setcolor(green);
  setFillStyle(1,green);
  circle(x, TREE_Y, r);
  floodfill(x, TREE_Y, green);
  setColor(brown);
  SetLineStyle(0,0,ThickWidth);
  line(x,TREE_Y,x,TREE_Y+40);
  line(x-10,TREE_Y+5,x,TREE_Y+20);
  line(x+10,TREE_Y+5,x,TREE_Y+20);
  SetLineStyle(0,0,0);
end;
constructor Wheel.Init(x1,y1,r1:integer;a1:real);
begin
  x := x1; y := y1;
  r := r1; a := a1;
  xr := x; yr := y;
end;
procedure Wheel.getXY(var x1,y1:integer);
begin
  x1 := x; y1 := y;
end;
procedure Wheel.incAngle;
begin
  a := a + da;
  if a > PI_2 then
    a := a - PI_2;
end;
procedure Wheel.move;
begin
  w := (vx+c)/(r/(vx+EPS));
  da := w*dt - w/(r/2);
  xr := xr + vx/dt;
  x  := trunc(xr);
  incAngle;
end;
procedure Wheel.draw;
var i: integer;ang:real;
begin
	setColor(red);
  circle(x,y,r+4);
  circle(x,y,r+3);
  da := PI_2/8;
  for i:=1 to 8 do
  begin
    line(x, y, trunc(x+r*cos(a)), trunc(y+r*sin(a)));
    incAngle;
  end;
end;
procedure Train.move;
var i: integer;
begin
  for i:=1 to 3 do
  begin
    wheels[i].vx := vx;
    wheels[i].getParams;
  end;
  x := wheels[1].x-2*BR;
end;
procedure Train.draw;
var i: integer;
begin
  drawBody;
  for i := 1 to 3 do
	  with wheels[i] do
		  putFrame;
  drawConnector;
end;
function Train.checkRange:boolean;
begin
  checkRange := true;
  if wheels[1].x > 700 then
    checkRange := false;
end;
Constructor Train.init(sx:integer);
begin
  wheels[1].Init(sx    ,GROUND_Y-BR,BR,1);
  wheels[2].Init(sx+50 ,GROUND_Y-BR,BR,1);
  wheels[3].Init(sx+130,GROUND_Y-SR,SR,1);
  y := GROUND_Y - 5*BR - 5;
end;

procedure Train.drawConnector;
var x1,y1,x2,y2,p1x,p1y,p2x,p2y: integer;a1:real;
begin
  a1 := wheels[1].a;
  wheels[1].getXY(x1,y1);
  wheels[2].getXY(x2,y2);
  p1x := trunc(x1 + WR*cos(a1));
  p1y := trunc(y1 + WR*sin(a1));
  p2x := trunc(x2 + WR*cos(a1));
  p2y := trunc(y2 + WR*sin(a1));
  {details}
  setColor(white);
  circle(p1x,p1y, 2);
  circle(p2x,p2y, 2);
  circle(p2x+CON_LEN+BOX_LEN div 2,y2, 4);
  {fixed shaft}
  rectangle(x2+30,y2-BOXH_d2-1,x2+CSHAFT_LEN,y2+BOXH_d2+1);
  {mechanism}
  rectangle(p2x+CON_LEN,y2-BOXH_d2, p2x+CON_LEN+BOX_LEN, y2+BOXH_d2);
  line(p2x,p2y,p2x+CON_LEN+BOX_LEN div 2, y2);
  {between wheels}
  line(p1x,p1y,p2x,p2y);
end;
procedure Train.drawBody;
var i: integer;
begin
  setFillStyle(9,1);
  {kabina}
  bar(x+10, y+5, x+2*BR, y+3*BR);
  {zaden kalnik}
  bar(x+10, y+3*BR, x+15, y+5*BR-5);
  {behind/around wheels}
  bar(x+10, y+3*BR, x+190, y+4*BR);
  for i:=1 to 2 do
		with wheels[i] do
      bar(x-r+8, y+5, x+r-8, y-r+5);
  for i:=1 to 2 do
    with wheels[i] do
      bar(x+r+3, y-r+10, x+r+8, y+ 5);
  with wheels[2] do
    bar(x+CSHAFT_LEN, y-BOXH_d2, x+CSHAFT_LEN+35, y+BOXH_d2);
	{fuel tank}
  SetFillStyle(1, red);
  SetColor(red);
  bar(x+2*BR, y+30, x+170, y+3*BR);
  line(x+170,y+30,x+170,y+3*BR);
  line(x+170,y+3*BR, x+180,y+3*BR);
  line(x+170,y+30,x+180,y+40);
  line(x+180,y+40,x+180,y+3*BR);
  floodfill(x+171,y+40,red);
  {roof}
  bar(x, y, x+2*BR, y+5);
  {crank box}
  with wheels[2] do
    bar(x+30,y-BOXH_d2-1,x+CSHAFT_LEN,y+BOXH_d2+1);
  {odzaci}
  setFillStyle(1, 1);
  bar(x+130,y,x+150,y+30);
  bar(x+80,y+10,x+100,y+30);
  {window}
  bar(x+20,y+15,x+2*BR-10,y+2*BR);
end;
begin
end.