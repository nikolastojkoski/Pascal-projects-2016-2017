program p11;
uses P11_DEP, graph, crt;

Type
GameController = Object
  gd, gm, pg: integer;
  n_smoke, target, distance: integer;
  _train: Train;
  smokes: array[1..MAX_SMOKE] of Smoke;
  trees : array[1..5] of Tree;
  procedure handleUserInput(var vx:real);
  procedure run;
  procedure initObjects(vx:real;tx:integer);
  procedure initDisplay;
  procedure spawnSmoke;
  procedure drawBackground;
  procedure drawShini;
  procedure StartFrame;
  procedure EndFrame;
end;
procedure gameController.run;
var i: integer;
begin
  while true do
  begin
    StartFrame;
    handleUserInput(_train.vx);

    _train.getParams;
    if _train.checkRange = false then
      initObjects(_train.vx, -200);

    spawnSmoke;
    drawBackground;
    _train.putFrame;
	  EndFrame;
  end;
end;
procedure gameController.drawBackground;
var i: integer;
begin
  for i:=1 to n_smoke do
  begin
    smokes[i].getParams;
    smokes[i].putFrame;
  end;
  drawShini;
  for i:=1 to 5 do
    trees[i].putFrame;
end;
procedure gameController.drawShini;
var i: integer;
begin
  SetFillStyle(1, green);
  SetColor(8);
  bar(0,GROUND_Y-40,640,350);
  line(0,GROUND_Y,640,GROUND_Y);
  line(0,GROUND_Y+2,640,GROUND_Y+2);
  SetFillStyle(1, brown);
  i := 5;
  while i < 640 do
  begin
    bar(i,GROUND_Y+1,i+5, GROUND_Y+5);
    i := i+ 20;
  end;
end;
procedure gameController.spawnSmoke;
begin
  distance := distance + trunc(_train.vx/dt);
  if (distance >= target) and (n_smoke < MAX_SMOKE) then
  begin
    target := target + S_TICK;
    n_smoke := n_smoke+1;
    smokes[n_smoke].init(_train.wheels[1].x, _train.vx);
  end;
end;
procedure gameController.initObjects(vx:real;tx:integer);
var i: integer;
begin
  n_smoke := 0;
  _train.vx := vx;
  _train.init(tx);
  trees[1].Init(20+random(100), 20+random(20));
  for i:=2 to 5 do
    trees[i].Init(trees[i-1].x+30+random(200), 20+random(20));
  if tx = 50 then begin
    distance := 50;
    target := 51;
  end;
end;
procedure gameController.initDisplay;
begin
  initgraph(gd, gm, '');
  gm := 1;
  setGraphMode(gm);
  pg := 0;
  setbkcolor(cyan);
end;
procedure gameController.startFrame;
begin
  setActivePage(pg);
  cleardevice;
end;
procedure gameController.endFrame;
begin
  setVisualPage(pg);
  delay(1000 div fps);
  pg := 1-pg;
end;
procedure gameController.handleUserInput(var vx: real);
var key: char;
begin
  if keypressed then
  begin
    key := readkey;
    Case key of
      #72: vx := vx+0.03;
      #80: vx := vx-0.1;
    end;
    if vx < 0 then
		  vx := 0;
    if vx > V_MAX then
		  vx := V_MAX;
  end;
end;

var
game: gameController;

begin
  game.initDisplay;
  game.initObjects(0, 50);
  game.run;
end.