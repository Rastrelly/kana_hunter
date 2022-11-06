unit ukanahunter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, ValEdit, FileUtil;

type

  { TForm1 }

  smb = record
    written:string;
    symb:string;
    category:integer;
    active:boolean;
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    gbField: TGroupBox;
    gbSettings: TGroupBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ListBox1: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    ProgressBar1: TProgressBar;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    TrackBar1: TTrackBar;
    ValueListEditor1: TValueListEditor;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure loadsymboltables;
    procedure showSymbol(sym:integer);
    procedure printlatestsymbol(ls:smb);
    procedure gbFieldClick(Sender: TObject);
    procedure makequestion;
    procedure TrackBar1Change(Sender: TObject);
    procedure buildcheatsheet;
    procedure togglecheatsheet;
  private

  public

  end;

var
  Form1: TForm1;
  symboldb:array of smb;
  activesdb: array of integer;

  filearr:array of string;

  gamelevel:integer=0;

  answerset:array[0..5] of string;
  correct:smb;
  score:integer=0;
  totscore:integer=0;

  txfile:TextFile;

  r,w:integer;

  exptp:integer=3;

  sym_tempo:integer=2;


implementation

{$R *.lfm}

{ TForm1 }

procedure genactivesdb;
var i:integer;
begin
  setlength(activesdb,0);
  for i:=0 to length(symboldb)-1 do
  begin
    if symboldb[i].active then
    begin
      SetLength(activesdb,Length(activesdb)+1);
      activesdb[high(activesdb)]:=i;
    end;
  end;
end;

procedure unlockNewSymbol(rndUnlocks:boolean);
var i,runs:integer;
    cando:boolean;
begin
  if (rndUnlocks) then
     i:=random(length(symboldb))
  else
     i:=0;

  cando:=false;
  runs:=0;

  while not cando do
  begin
    cando:=true;
    if (symboldb[i].active) then cando:=false;
    if (exptp=1) and (symboldb[i].category<>0) then cando:=false;
    if (exptp=2) and (symboldb[i].category<>1) then cando:=false;
    if (cando=false) then inc(i);
    if ((i=Length(symboldb)) and (runs>1)) then cando:=true;
    if ((i=Length(symboldb)) and (runs<=1)) then
    begin
      cando:=false;
      inc(runs);
      i:=0;
    end;
  end;

  if i<Length(symboldb) then
  begin
    symboldb[i].active:=true;
    Form1.printlatestsymbol(symboldb[i]);
    inc(gamelevel);
  end;
end;



function stringtosmb(txt:string;mode:integer):smb;
var tsmb:smb;
    cstd:string;
    i,stp:integer;
begin
  tsmb.category:=mode;
  tsmb.active:=false;
  cstd:='';
  stp:=0;
  for i:=1 to length(txt) do
  begin
    if(txt[i]<>';')then
    begin
    cstd:=cstd+txt[i];
    end;
    if(txt[i]=';')or(i=length(txt))then
    begin
      stp:=stp+1;
      if (stp=1) then begin tsmb.written:=cstd; cstd:=''; end;
      if (stp=2) then begin tsmb.symb:=cstd; cstd:=''; stp:=0; end;
    end;
  end;
  result:=tsmb;
end;

procedure tform1.makequestion;
var i,j,mx,k:integer;
    qid,av,rav:integer;
    qs:smb;
    canexit:boolean;
    ts:string;
    gp:integer;
begin
  genactivesdb;
  mx:=Length(symboldb);
  qid:=activesdb[random(length(activesdb))];
  rav:=random(6);
  qs:=symboldb[qid];
  correct:=qs;
  canexit:=false;
  for i:=0 to 5 do answerset[i]:='@';
  for i:=0 to 5 do
  begin
    canexit:=false;
    if(i=rav) then answerset[i]:=correct.written;
    if(i<>rav) then
    begin
      while(not canexit) do
      begin
        canexit:=true;
        k:=random(mx);
        ts:=symboldb[k].written;
        for j:=0 to 5 do
        begin
          if(ts=answerset[j]) then canexit:=false;
        end;
        if (ts = correct.written) then canexit:=false;
      end;
      answerset[i]:=ts;
    end;
  end;

  ListBox1.Clear;
  for i:=0 to 5 do
  begin
    ListBox1.Items.Add(answerset[i]);
  end;
  Label2.Caption:=correct.symb;
  Label3.Caption:='Level '+inttostr(gamelevel);

  if(w=0) then gp:=100
  else gp:=round((r/(r+w))*100);

  if (gp<=60) then Label6.Font.Color:=clRed;
  if (gp>60) then Label6.Font.Color:=RGBToColor(255,137,39);
  if (gp>80) then Label6.Font.Color:=clYellow;
  if (gp>90) then Label6.Font.Color:=clGreen;


  Label6.Caption:='Total score: '+inttostr(totscore) + ' ('+inttostr(r)+'/'+inttostr(w)+': '+inttostr(gp)+'%)';

  buildcheatsheet;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  sym_tempo:=TrackBar1.Position;
end;

procedure tform1.printlatestsymbol(ls:smb);
begin
  Label4.Caption:='Latest symbol: '+ls.symb+' ('+ls.written+')';
end;

procedure tform1.loadsymboltables;
var cl:string;
begin

  setlength(symboldb,0);

  AssignFile(txfile, 'hiragana.csv');
  Reset(txfile);
  while(not(eof(txfile))) do
  begin
    readln(txfile, cl);
    setlength(symboldb,length(symboldb)+1);
    symboldb[high(symboldb)]:=stringtosmb(cl,0);
    symboldb[high(symboldb)].category:=0;
  end;
  closefile(txfile);

  AssignFile(txfile, 'katakana.csv');
  Reset(txfile);
  while(not(eof(txfile))) do
  begin
    readln(txfile, cl);
    setlength(symboldb,length(symboldb)+1);
    symboldb[high(symboldb)]:=stringtosmb(cl,0);
    symboldb[high(symboldb)].category:=1;
  end;
  closefile(txfile);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  randomize;
  loadsymboltables;
  togglecheatsheet;
end;

procedure TForm1.Button1Click(Sender: TObject);
var i:integer;
begin
  togglecheatsheet;
end;

procedure TForm1.Button2Click(Sender: TObject);
var i,n:integer;
begin
  gamelevel:=0;

  if RadioButton1.Checked then exptp:=1;
  if RadioButton2.Checked then exptp:=2;
  if RadioButton3.Checked then exptp:=3;

  sym_tempo:=TrackBar1.Position;

  for i:=0 to Length(symboldb)-1 do symboldb[i].active:=false;

  if (not TryStrToInt(edit1.Text,n)) then n:=1;

  if (n<1) then n:=1;

  for i:=0 to n-1 do
  begin
    unlockNewSymbol(CheckBox1.Checked);
  end;

  makequestion;
end;

procedure TForm1.Button3Click(Sender: TObject);
var seltext:string;
begin
  if (ListBox1.ItemIndex<>-1) then
  begin
    seltext:=ListBox1.Items[ListBox1.ItemIndex];
    if(seltext=correct.written) then
    begin
       inc(score);
       inc(totscore);
       if(score>=gamelevel*sym_tempo)then
       begin
         unlockNewSymbol(CheckBox1.Checked);
         score:=0;
       end;
       ProgressBar1.Min:=0;
       ProgressBar1.Max:=gamelevel;
       ProgressBar1.Position:=score;
       Label7.Caption:='Correct! It was '+correct.written+' ('+correct.symb+')';
       Label7.Font.Color:=clGreen;
       inc(r);
    end
    else
    begin
      score:=score-1;
      totscore:=totscore-1;
      ProgressBar1.Min:=0;
      ProgressBar1.Max:=gamelevel;
      ProgressBar1.Position:=score;
      Label7.Caption:='Wrong! It was '+correct.written+' ('+correct.symb+')';
      Label7.Font.Color:=clRed;
      inc(w);
    end;
    makequestion;
  end;
end;

procedure Tform1.showSymbol(sym:integer);
begin
  label2.Caption:=symboldb[sym].symb;
end;

procedure TForm1.gbFieldClick(Sender: TObject);
begin

end;

procedure tform1.buildcheatsheet;
var i:integer;
begin
  ValueListEditor1.Clear;
  ValueListEditor1.RowCount:=length(activesdb)+1;
  ValueListEditor1.Cells[0,0]:='Kana';
  ValueListEditor1.Cells[1,0]:='Syllable';
  if length(activesdb)>0 then
  begin
    for i:=0 to length(activesdb)-1 do
    begin
      ValueListEditor1.Cells[0,i+1]:=symboldb[activesdb[i]].symb;
      ValueListEditor1.Cells[1,i+1]:=symboldb[activesdb[i]].written;
    end;
  end;
end;

procedure tform1.togglecheatsheet;
begin
  if (GroupBox2.Visible) then
  begin
    GroupBox2.Visible:=false;
    Form1.ClientWidth:=Form1.ClientWidth-GroupBox2.Width;
  end
  else
  begin
    GroupBox2.Visible:=true;
    Form1.ClientWidth:=Form1.ClientWidth+GroupBox2.Width;
  end;
end;

end.

