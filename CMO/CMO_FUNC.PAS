unit cmo_func;

INTERFACE

const
EPS = 0.00001;

type
Request = Record
  TPost: real;
  ID: integer;
end;

pQueue = ^queue;
Queue = Record
  Req: Request;
  Next: pQueue;
end;

Pribor = Object
  LAM: real;
  TAYOB, TOSV: real;
  Idle: boolean;
  Req: Request;

  Constructor Init(Lambda: real);
  Procedure obsluz(nreq: Request);
  Procedure getNextTOSV;
end;

Istocnik = Object
  ID: integer;
  LAM: real;
  TPOST: real;

  KOL, KOBR, KOTK: integer;
  TOG, MTOG, BOTK: real;

  Procedure getNextPost;
  Procedure updateStats(OBR: boolean; DT: real);
  Procedure Reset;
  Constructor Init(N:integer; L: real);
end;

Buffer = Object
  pFirst,  pLast:   pQueue;
  First,    Last:  Request;
  Size, Max_Size:  integer;

  Constructor Init(MSIZE: integer);
  Procedure Push(id:integer; TPost:real);
  Procedure Pop;
  Procedure Reset;
  Function Full: Boolean;
  Function Empty: Boolean;
end;

IMPLEMENTATION

Procedure Pribor.Obsluz(nReq: Request);
begin
  Req := nReq;
  Idle := false;
end;
Procedure Pribor.GetNextTOSV;
begin
  TAYOB := -1/Lam*ln(random);
  TOSV := req.TPOST + TAYOB;
end;
Constructor Pribor.Init(Lambda: real);
begin
  LAM  := Lambda;
  TOSV := 0;
  idle := true;
end;
Constructor Istocnik.Init(N:integer; L: real);
begin
  LAM := L; ID := n;
  Reset;
end;
Procedure Istocnik.Reset;
begin
  TPOST := 0;
  KOL := 0; KOBR := 0; KOTK :=0;
  TOG := 0; MTOG := 0; BOTK :=0;
  getNextPost;
end;
Procedure Istocnik.GetNextPost;
begin
  TPOST := TPOST + -1/Lam*ln(random);
end;
Procedure Istocnik.updateStats(OBR: boolean; DT: real);
begin
  KOL := KOL + 1;
  if OBR then
  begin
    KOBR := KOBR + 1;
    TOG  := TOG + DT;
    MTOG := TOG / KOBR;
  end
  else KOTK := KOTK + 1;

  BOTK := KOTK / KOL;
end;
Constructor Buffer.Init(MSIZE: integer);
begin
  Max_Size := MSIZE;
  Reset;
end;
Procedure Buffer.Reset;
var tmp: pQueue;
begin
  while pFirst <> NIL do
  begin
    tmp := pFirst;
    pFirst := pFirst^.Next;
    Dispose(tmp);
  end;
  Size := 0;
  pFirst := NIL;
  pLast := NIL;
end;
Procedure Buffer.Push(id:integer; TPOST:real);
var tmp: pQueue; rTmp: Request;
begin
  rTmp.ID := id;
  rTmp.TPOST := TPOST;

  new(tmp);
  tmp^.Req  := rTmp;
  tmp^.Next := NIL;

  if pFirst = NIL then
  begin
    pFirst := tmp;
    pLast := tmp;
  end
  else begin
    pLast^.Next := tmp;
    pLast := tmp;
  end;

  Size  := size + 1;
  Last  := pLast^.Req;
  First := pFirst^.Req;
end;
Procedure Buffer.Pop;
var tmp: pQueue;
begin
  if pFirst <> NIL then
  begin
    Tmp := pFirst;
    pFirst := pFirst^.Next;
    Dispose(tmp);
    Size := Size - 1;
    First := pFirst^.Req;
  end;
end;
Function Buffer.Full: Boolean;
begin
  Full := false;
  if Size >= Max_Size then
    Full := true;
end;
Function Buffer.Empty: Boolean;
begin
  Empty := false;
  if Size = 0 then
    Empty := true;
end;

begin
end.