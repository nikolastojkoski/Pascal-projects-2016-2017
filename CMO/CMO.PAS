program cmo;
uses crt, graph, cmo_interf, cmo_func, cmo_graph;

type
Modulator = Object
  ist: array[1..3] of Istocnik;
  prib: Pribor;
  buf: Buffer;
  graf1, graf2: Graphic;

  KMIN, NMIN, PMIN: integer;
  LamOb: real;
  color: array[1..3] of integer;

  aMTOG, aBOTK: array[1..3, 1..50] of Real;
  rGraf1, rGraf2: Graphic;
  tabl1, tabl2: Table;
  bchart1, bchart2: BarChart;

  LIst, LPrib: array[1..3] of real;
  Finished: boolean;

  Constructor Init(BSize, kmin1: integer);
  Procedure SetIstocniki(L1,L2,L3: real);
  Procedure SetPribor(L1,L2,DL: real);
  Procedure Reset;
  Procedure Modulate(var log: text);
  Procedure Run(var log: text; delay: boolean);
  Procedure ShowFinalGraphic;
  Procedure ShowFinalBarChart;
  Procedure ShowFinalTable;
  Procedure ShowFinalPogresnost;
end;
Constructor Modulator.Init(BSize:integer; kmin1: integer);
var i: integer;
begin
  KMIN := kmin1;
  buf.init(BSize);
  Finished := false;
  color[1] := red;
  color[2] := green;
  color[3] := blue;
end;
Procedure Modulator.SetIstocniki(L1,L2,L3: real);
var i: integer;
begin
  LIst[1] := L1;
  LIst[2] := L2;
  LIst[3] := L3;

  for i:=1 to 3 do
    ist[i].Init(i, LIst[i]);

  PMIN := 1;
  for i:=2 to 3 do
    if ist[i].LAM < ist[PMIN].LAM then
      PMIN := i;
end;
Procedure Modulator.SetPribor(L1,L2,DL: real);
begin
  LPrib[1] := L1;
  LPrib[2] := L2;
  LPrib[3] := DL;
end;
Procedure Modulator.Run(var log: text; delay: boolean);
var CLOB: real; i,j: integer;
begin
  i := 1;
  CLOB := LPrib[1];
  while (CLOB - LPrib[2]) < EPS do
  begin
    LamOb := CLOB;
    Reset;
    Modulate(log);

    if delay then
      readkey;

    for j:=1 to 3 do
    begin
      aMTOG[j][i] := Ist[j].MTOG;
      aBOTK[j][i] := Ist[j].BOTK;
    end;
    CLOB := CLOB + LPrib[3];
    i := i+1;
  end;
  Finished := true;
end;
Procedure Modulator.ShowFinalGraphic;
var i, j: integer; CLOB: real;
begin
  cleardevice;
  rGraf1.init(60,210, red, LPrib[2], 100, LPrib[1], 'LamOb', 'Botk');
  rGraf1.AddTitle('Final Results', 2);
  rGraf1.AddColorGuide(LIst[1], LIst[2], LIst[3]);
  rGraf2.init(60,440, blue, LPrib[2], 0, LPrib[1], 'LamOb', 'MTog');

  i := 1;
  CLOB := LPrib[1];
  while (CLOB - LPrib[2]) < EPS do
  begin
    for j:=1 to 3 do
    begin
      rGraf1.addPoint(CLOB, aBOTK[j][i], Color[j], j);
      rGraf2.addPoint(CLOB, aMTOG[j][i], Color[j], j);
    end;
    CLOB := CLOB + LPrib[3];
    i := i+1;
  end;
  readkey;
end;
Procedure Modulator.ShowFinalTable;
var i, j: integer; CLOB: real; c: char;
begin
  cleardevice;
  SetColor(DarkGray);
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(200, 20, 'Final Results');

  tabl1.Init(40,80,350,270,trunc(((LPrib[2]-LPrib[1])/LPrib[3])+2),4);
  if tabl1.rows <= 12 then
    tabl1.DrawBorders;

  tabl1.setColText(1, 'LOB'  , magenta);
  tabl1.setColText(2, 'MTOG1', red);
  tabl1.setColText(3, 'MTOG2', green);
  tabl1.setColText(4, 'MTOG3', blue);
  tabl1.AddColorGuide(LIst[1], LIst[2], LIst[3]);

  tabl2.Init(330,80,350,270,trunc(((LPrib[2]-LPrib[1])/LPrib[3])+2),4);
  if tabl2.rows <= 12 then
    tabl2.DrawBorders;

  tabl2.setColText(1, 'LOB', magenta);
  tabl2.setColText(2, 'BOTK1', red);
  tabl2.setColText(3, 'BOTK2', green);
  tabl2.setColText(4, 'BOTK3', blue);

  i := 1;
  CLOB := LPrib[1];
  while (CLOB - LPrib[2]) < EPS do
  begin
    tabl1.SetCell(i+1, 1, CLOB, magenta, false);
    tabl2.SetCell(i+1, 1, CLOB, magenta, false);
    for j:=1 to 3 do
    begin
      tabl1.SetCell(i+1, j+1, aMTOG[j][i], darkGray, false);
      tabl2.SetCell(i+1, j+1, aBOTK[j][i], darkGray, false);
    end;
    CLOB := CLOB + LPrib[3];
    i := i+1;
  end;
  c := readkey;
  if keypressed then
    c := readkey;
  if c = #77 then
    ShowFinalPogresnost;
end;
Procedure Modulator.ShowFinalPogresnost;
var i, j: integer; CLOB, sig: real; c: char;
begin
  SetFillStyle(1, white);
  bar(330, 80, 640, 480);

  tabl2.Init(330,80,350,270,trunc(((LPrib[2]-LPrib[1])/LPrib[3])+2),4);
  if tabl2.rows <= 12 then
    tabl2.DrawBorders;
  tabl2.setColText(1, 'LOB', magenta);
  tabl2.setColText(2, 'Pogr1', red);
  tabl2.setColText(3, 'Pogr2', green);
  tabl2.setColText(4, 'Pogr3', blue);

  i := 1;
  CLOB := LPrib[1];
  while (CLOB - LPrib[2]) < EPS do
  begin
    tabl2.SetCell(i+1, 1, CLOB, magenta, false);
    for j:=1 to 3 do
    begin
      if aBOTK[j][i] = 0 then
        continue;
      sig := sqrt(3.84*(1-aBOTK[j][i])/(KMIN*aBOTK[j][i]));
      tabl2.SetCell(i+1, j+1, sig*100, darkGray, true);
    end;
    CLOB := CLOB + LPrib[3];
    i := i+1;
  end;

  c := readkey;
  if keypressed then
    c := readkey;
  if c = #75 then
    ShowFinalTable;
end;
Procedure Modulator.ShowFinalBarChart;
var i, j: integer; CLOB: real;
begin
  cleardevice;
  bChart1.init(60,210, red, LPrib[2], 100, LPrib[1], 'LamOb', 'Botk');
  bChart1.AddTitle('Final Results', 2);
  bChart1.AddColorGuide(LIst[1], LIst[2], LIst[3]);
  bChart2.init(60,440, blue, LPrib[2], 0, LPrib[1], 'LamOb', 'MTog');

  i := 1;
  CLOB := LPrib[1];
  while (CLOB - LPrib[2]) < EPS do
  begin
    for j:=1 to 3 do
    begin
      bChart1.addPoint(CLOB, aBOTK[j][i], Color[j], j);
      bChart2.addPoint(CLOB, aMTOG[j][i], Color[j], j);
    end;
    CLOB := CLOB + LPrib[3];
    i := i+1;
  end;
  readkey;
end;
Procedure Modulator.Reset;
var i: integer; ns:string;
begin
  buf.Reset;

  {Generating First Zayavki}
  Randomize;
  for i:=1 to 3 do
    ist[i].Reset;

  prib.Init(LamOb);

  cleardevice;
  str(LamOb:3:1, ns);

  {Empty graphics}
  graf1.init(60, 210, red, KMIN, 100, 0, 't', 'Botk');
  graf1.addTitle('LamOb = ' + ns, 1);
  graf1.addColorGuide(ist[1].Lam, ist[2].Lam, ist[3].Lam);
  graf2.init(60, 440, blue, KMIN, 0, 0, 't', 'MTog');
  graf2.addColorGuide(ist[1].Lam, ist[2].Lam, ist[3].Lam);
end;
Procedure Modulator.Modulate(var log: text);
var i: integer;
begin
  while ist[PMIN].KOL < KMIN do
  begin
    NMIN := 1;
    for i:= 2 to 3 do
      if ist[i].TPOST < ist[NMIN].TPOST then
        NMIN := i;

    if (prib.TOSV <= ist[NMIN].TPOST) AND (not prib.IDLE) then
    begin
      ist[prib.req.id].updateStats(true, prib.TOSV - prib.req.TPOST);
      Prib.idle := true;
    end
    else if (not buf.empty) AND (prib.idle) then
    begin
      prib.obsluz(buf.first);
      buf.pop;
      prib.getNextTOSV;
    end
    else begin
      if not buf.full then
        buf.push(NMIN, ist[NMIN].TPOST)
      else
        ist[NMIN].updateStats(false, 0);
        ist[NMIN].getNextPost;
      end;
      for i:=1 to 3 do
      begin
        graf1.addPoint(ist[i].KOL, ist[i].BOTK, color[i], i);
        graf2.addPoint(ist[i].KOL, ist[i].MTOG, color[i], i);
      end;
    end;

    writeln(log, 'LamOb: ', LamOb:3:2);
    writeln(log, 'BOTK: ', ist[PMIN].BOTK:3:2);
    writeln(log, 'MTOG: ', ist[PMIN].MTOG:3:2);
end;

Procedure InitModulator(var g: GUI;var modl: Modulator);
begin
  {Buffer Size, Dlina Realizacii}
  Modl.Init(5, g.Windows[3].TextBoxes[1].getInt);
  {Lambda Istocniki}
  With g.Windows[1] do
    Modl.SetIstocniki(TextBoxes[1].getReal, TextBoxes[2].getReal,
                      TextBoxes[3].getReal);
  {Lambda Pribor}
  With g.Windows[2] do
    Modl.SetPribor(TextBoxes[1].getReal, TextBoxes[2].getReal,
                   TextBoxes[3].getReal);
end;

var
modl: Modulator; g: GUI;
log: text;  gd, gm, code: integer;
c: char;
begin

  assign(log, 'log.txt');
  rewrite(log);

  initgraph(gd, gm, '');
  setBkColor(white);
  cleardevice;

  g.init;
  while true do
  begin
    if KeyPressed then
    begin
      c := readKey;
      code := g.HandleInput(c);
      case code of
         0: {Exit Program}
          break;
        21: {Fast Modulation}
        begin
          InitModulator(g, modl);
          Modl.Run(log, false);
          g.Redraw;
        end;
        22: {Normal Modulation}
        begin
          InitModulator(g, modl);
          Modl.Run(log, true);
          g.Redraw;
        end;
        31: {Graph Final Results}
        begin
          if Modl.Finished then
            Modl.ShowFinalGraphic;
          g.Redraw;
        end;
        32: {Table Final Results}
        begin
          If Modl.Finished then
            Modl.ShowFinalTable;
          g.Redraw;
        end;
        33: {BarChart Final Results}
        begin
          if Modl.Finished then
            Modl.ShowFinalBarChart;
          g.Redraw;
        end;
      end;
    end;
  end;

  close(log);
  closegraph;
end.