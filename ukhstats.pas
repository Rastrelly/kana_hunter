unit ukhstats;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ukanahunter;

type

  { TForm3 }

  TForm3 = class(TForm)
    StringGrid1: TStringGrid;
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.FormShow(Sender: TObject);
var i,j,k,l,cr:integer;
begin
  l:=Length(symboldb);
  j:=0;
  k:=3;
  cr:=1;
  StringGrid1.ColCount:=5;
  StringGrid1.RowCount:=k;
  for i:=0 to l-1 do
  begin

    StringGrid1.Cells[j,cr]  :=symboldb[i].symb + ' ('+symboldb[i].written+')';
    StringGrid1.Cells[j,cr+1]:=inttostr(smbstatedb[i].tries) +
    ' ('+inttostr(smbstatedb[i].succ)+'/'+inttostr(smbstatedb[i].fail)+': '+inttostr(smbstatedb[i].perc)+'%)';

    inc(j);
    if (j>4) or (symboldb[i].written[High(symboldb[i].written)]='o') or (symboldb[i].written[High(symboldb[i].written)]='n') then
    begin
      j:=0;
      inc(k,2);
      inc(cr,2);
      StringGrid1.RowCount:=k;
    end;
  end;

end;

end.

