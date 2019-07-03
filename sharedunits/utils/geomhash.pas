{*******************************************************************************
This file is part of the Open Chemera Library.
This work is public domain (see README.TXT).
********************************************************************************
Author: Ludwig Krippahl
Date: 20.3.2011
Purpose:
  Geometric hashing class
Requirements:
Revisions:
To do:
*******************************************************************************}
unit geomhash;

{$mode objfpc}

interface

uses
  Classes, SysUtils, basetypes, geomutils;

type

  { TGeomHasher }

  TGeomHasher=class
  //Only stores indexes in the grid
  //The size of the grid cell must be > 1e-6 and the points array must not
  //be empty
  private
    FHashGrid:array of array of array of TIntegers;  //indexes of hashed points
    FShiftToGrid:TCoord;
    FInvGridStep:TFloat;                             //1/gridstep
    FHighX,FHighY,FHighZ:Integer;                      //max grid cells
    FPoints:TCoords;
    FRads:TFloats;
    procedure GridBounds(out B1,B2:Integer; const Val:TFloat; const Hi:Integer);
      //Computes bounds of neighboring cells in one dimension, with max of Hi
  public
    constructor Create(Points:TCoords;GridStep:TFloat;maxX:Integer;maxY:Integer;maxZ:Integer;Rads:TFloats=nil;dummyCreate:Boolean = false);
    function ListNeighours(C:TCoord):TIntegers;
     procedure SumAtomIndexes(currentIndex:Integer);
    function getLoopCount():Integer;
    procedure ResetAtomCounter();
      //Returns all indexes in the 27 grid cells belonging to the neighbourhood
      //of the cell corresponding to C
    function IsInnerPoint(C:TCoord):Boolean;
      //Use only if Rads supplied in create; otherwise points are not kept
  end;
implementation

{ TGeomHasher }
var iix:Integer;
procedure TGeomHasher.GridBounds(out B1, B2: Integer; const Val: TFloat;
  const Hi: Integer);
begin
  B1:=Trunc(Val)-1;
  B2:=Trunc(Val)+1;

  if B1>Hi then B1:=Hi;
  if B1<0 then B1:=0;
  if B2>Hi then B2:=Hi;
  if B2<0 then B2:=0;
end;
{procedure TGeomHasher.PrintTCoords(C:TCoord);
begin
     WriteLn('TCOORDS: ');
     WriteLn('C[0]',C[0]);
     WriteLn('C[1]',C[1]);
     WriteLn('C[2]',C[2]);
end;}
function TGeomHasher.getLoopCount():Integer;
begin
     Result:= iix;
end;

procedure TGeomHasher.SumAtomIndexes(currentIndex:Integer);
begin
     iix := iix + currentIndex;
end;
constructor TGeomHasher.Create(Points:TCoords;GridStep:TFloat;maxX:Integer;maxY:Integer;maxZ:Integer;Rads:TFloats=nil;dummyCreate:Boolean=false);

  procedure Setup;

  var
    minc,maxc:TCoord;

  begin
  maxc:=Max(Points);
  minc:=Min(Points);
  FShiftToGrid:=Simmetric(minc);
  // calcular o indice máximo das células em cada eixo do referencial
  if not dummyCreate then
  begin
  FHighX:=Trunc((maxc[0]-minc[0])/GridStep);
  FHighY:=Trunc((maxc[1]-minc[1])/GridStep);
  FHighZ:=Trunc((maxc[2]-minc[2])/GridStep);
    SetLength(FHashGrid,FHighX+1,FHighY+1,FHighZ+1);
  end
  else
  begin
  FHighX:=  maxX;
  FHighY:=   maxY;
  FHighZ:=   maxZ;
   SetLength(FHashGrid,FHighX,FHighY,FHighZ);
   end;
 {
    WriteLn('FHX',FHighX+1);
    WriteLn('FHY',FHighY+1);
    WriteLn('FHZ',FHighZ+1);

    WriteLn('maxX',maxc[0]);
    WriteLn('maxY',maxc[1]);
    WriteLn('maxZ',maxc[2]);

    WriteLn('minX',minc[0]);
    WriteLn('minY',minc[1]);
    WriteLn('minZ',minc[2]);
 }
  WriteLn('GridStep',GridStep);
//  WriteLn('FHGLENGTH',Length(FHashGrid));
  if Rads=nil then
    begin  // geomhasher used only for indexing regions
    FPoints:=nil;
    FRads:=nil;
    end
  else     // used to detect collisions, inner points, etc
    begin
    Assert(Length(Points)=Length(Rads),'Different number of radii and points');
    FPoints:=Copy(Points,0,Length(Points));
    FRads:=Copy(Rads,0,Length(Rads));
    end;
  end;

var
  f,x,y,z,i:Integer;
  c:TCoord;

begin
  inherited Create;
   //Inicialização do HashGrid
  Assert(Points<>nil,'Empty points array for hashing');
  Assert(GridStep>1e-6,'GridStep too small');
  FInvGridStep:=1/GridStep;
  // Após o setup conhecemos os valores de highx, highy e highz
  Setup;
  i:=0;
  for x:=0 to FHighX do
    for y:=0 to FHighY do
      for z:=0 to FHighZ do
        FHashGrid[x,y,z]:=nil;
  // número de átomos -1
  //  Length(Points) adds ao hashgrid
  for f:=0 to High(Points) do
  begin
            c:=Add(Points[f],FShiftToGrid);
            x:=Trunc(c[0]*FInvGridStep);
            y:=Trunc(c[1]*FInvGridStep);
            z:=Trunc(c[2]*FInvGridStep);
            AddToArray(f, FHashGrid[x,y,z]);
  end;

end;
procedure TGeomHasher.ResetAtomCounter();
begin
      iix := 0;
end;

function TGeomHasher.ListNeighours(C:TCoord):TIntegers;


var
  count,x,y,z,x1,x2,y1,y2,z1,z2,f:Integer;

begin
  C:=Multiply(Add(C,FShiftToGrid),FInvGridStep);
  Result:=nil;
  GridBounds(x1,x2,C[0],FHighX);
  GridBounds(y1,y2,C[1],FHighY);
  GridBounds(z1,z2,C[2],FHighZ);
  count:=0;

  for x:=x1 to x2 do
    for y:=y1 to y2 do
      for z:=z1 to z2 do
       count:=count+Length(FHashGrid[x,y,z]);

  SetLength(Result,count);
  count:=0;
  for x:=x1 to x2 do
    for y:=y1 to y2 do
      for z:=z1 to z2 do
        for f:=0 to High(FHashGrid[x,y,z]) do
          begin
          Result[count]:=FHashGrid[x,y,z,f];
          Inc(count);
          end;
end;

function TGeomHasher.IsInnerPoint(C: TCoord): Boolean;

var
  x,y,z,x1,x2,y1,y2,z1,z2,f,ix:Integer;
  tmpc:TCoord;
  tmpIndex:Integer;
  dist:TFloat;
begin
//{$DEFINE ISPM}
  tmpc:=Multiply(Add(C,FShiftToGrid),FInvGridStep);
  Result:=False;
  GridBounds(x1,x2,tmpc[0],FHighX);
  GridBounds(y1,y2,tmpc[1],FHighY);
  GridBounds(z1,z2,tmpc[2],FHighZ);
  //Substituir os loops por uma chamada do isInnerPoint do marrow
 {$IFDEF ISPM}
 //=========Solução Marrow isInnerPoint========================/
//  Result:=isInnerPointM(C,FPoints,FRads,length(FPoints));
 //=========Solução Original========================/
 {$ELSE}
 tmpIndex := 0;
  for x:=0 to FHighX do
    begin
    for y:=0 to FHighY do
      begin
      for z:=0 to FHighZ do
        begin
        for f:=0 to High(FHashGrid[x,y,z]) do
          begin
            ix:=FHashGrid[x,y,z,f];   //
            dist := Distance(C,FPoints[ix]);
            tmpIndex:= tmpIndex + 1;
          if dist < FRads[ix] then
            begin
            Result:=True;
            Break;
            end;
         end;
            SumAtomIndexes(tmpIndex);
        if Result then Break;
        end;
      if Result then Break;
      end;
    if Result then Break;
    end;

   //  WriteLn('iix ', getLoopCount());
   //  ResetAtomCounter();
  {$ENDIF}
end;

end.
