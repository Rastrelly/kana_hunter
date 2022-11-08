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

  smbstate = record
    tries:integer;
    succ:integer;
    fail:integer;
    perc:integer;
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    but_ans_0: TButton;
    but_ans_1: TButton;
    but_ans_2: TButton;
    but_ans_3: TButton;
    but_ans_4: TButton;
    but_ans_5: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit1: TEdit;
    gbField: TGroupBox;
    gbSettings: TGroupBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
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
    Panel3: TPanel;
    ProgressBar1: TProgressBar;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    TrackBar1: TTrackBar;
    ValueListEditor1: TValueListEditor;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure but_ans_0Click(Sender: TObject);
    procedure but_ans_1Click(Sender: TObject);
    procedure but_ans_2Click(Sender: TObject);
    procedure but_ans_3Click(Sender: TObject);
    procedure but_ans_4Click(Sender: TObject);
    procedure but_ans_5Click(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure GroupBox3Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure RadioButton4Change(Sender: TObject);
    procedure refreshProgressBar;
    procedure loadsymboltables;
    procedure showSymbol(sym:integer);
    procedure printlatestsymbol(ls:smb);
    procedure gbFieldClick(Sender: TObject);
    procedure makequestion;
    procedure TrackBar1Change(Sender: TObject);
    procedure buildcheatsheet;
    procedure togglecheatsheet;
    procedure refreshAnsButtons;
    procedure updateAnsStyle;
    procedure resetNewSymbols;
  private

  public

  end;

var
  Form1: TForm1;
  symboldb:array of smb;
  smbstatedb:array of smbstate;

  activesdb: array of integer;

  filearr:array of string;

  gamelevel:integer=0;

  answerset:array[0..5] of string;

  newsymbols:array of integer;

  correct:smb;
  correct_id:integer;
  score:integer=0;
  totscore:integer=0;

  txfile,statefile:TextFile;

  r,w:integer;

  exptp:integer=3;

  sym_tempo:integer=2;

  prev_symb_id:integer=-1;

  sel_answ:integer=0;


implementation

{$R *.lfm}

{ TForm1 }

uses ukhnewsymbols, ukhstats;

procedure tform1.resetNewSymbols;
begin
  SetLength(newsymbols,0);
end;

procedure recordToNewsymbols(id:integer);
begin
  setlength(newsymbols,length(newsymbols)+1);
  newsymbols[high(newsymbols)]:=id;
end;

function resetProgress:boolean;
var i,l:integer;
begin
  if(MessageDlg('Reset progress','Are you sure you want to reset progress? All aggregated states and unlocks will be removed.',
  mtConfirmation,mbOKCancel,0)=mrOK) then
  begin
    l:=length(smbstatedb);
    for i:=0 to l-1 do
    begin
      with symboldb[i] do
        active:=false;
      with smbstatedb[i] do
      begin
        tries:=0;
        succ:=0;
        fail:=0;
        succ:=0;
      end;
    end;
    result:=true;
  end
  else
    result:=false;
end;

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

procedure unclockSymbolByName(sym:string);
var i:integer;
    expcat1,expcat2:integer;
begin

  if exptp=1 then
  begin
    expcat1:=0;
    expcat2:=-1;
  end;

  if exptp=2 then
  begin
    expcat1:=1;
    expcat2:=-1;
  end;

  if exptp=3 then
  begin
    expcat1:=0;
    expcat2:=1;
  end;

  if length(symboldb)>0 then
  for i:=0 to length(symboldb)-1 do
  begin
    if symboldb[i].written=sym then
    if (symboldb[i].category=expcat1) or (symboldb[i].category=expcat2) then
    begin
      symboldb[i].active:=true;
      recordToNewsymbols(i);
      inc(gamelevel);
    end;
  end;
end;

procedure unlockNewSymbol(rndUnlocks:boolean; showunlockwnd:boolean);
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
    recordToNewsymbols(i);
    inc(gamelevel);

    if showunlockwnd then Form2.Show;
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


procedure tform1.refreshProgressBar;
begin
  if score<ProgressBar1.Min then ProgressBar1.Min:=score;
  if (score>=0) then ProgressBar1.Min:=0;
  ProgressBar1.Position:=score;
  ProgressBar1.Max:=gamelevel*sym_tempo;
end;

procedure tform1.makequestion;
var i,j,mx,k:integer;
    qid,av,rav:integer;
    qs:smb;
    canexit:boolean;
    ts:string;
    gp:integer;
    adbl:integer;
    tries:integer;
begin

  genactivesdb;

  adbl:=length(activesdb);
  mx:=Length(symboldb);
  qid:=activesdb[random(adbl)];

  if length(activesdb)>1 then
  if (qid=prev_symb_id) then
  while(qid=prev_symb_id) do
  begin
    qid:=activesdb[random(adbl)];
  end;

  prev_symb_id:=qid;

  rav:=random(6);
  qs:=symboldb[qid];
  correct:=qs;
  correct_id:=qid;
  canexit:=false;

  tries:=0;

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

        if (adbl<2) or (tries>1000) then
        begin
          k:=random(mx);
          ts:=symboldb[k].written;
        end
        else
        begin
          k:=random(adbl);
          ts:=symboldb[activesdb[k]].written;
        end;

        for j:=0 to 5 do
        begin
          if(ts=answerset[j]) then canexit:=false;
        end;

        if (ts = correct.written) then canexit:=false;

        inc(tries);

      end;
      answerset[i]:=ts;
    end;

  end;

  ListBox1.Clear;

  for i:=0 to 5 do
  begin
    ListBox1.Items.Add(answerset[i]);
  end;

  but_ans_0.Caption:=answerset[0];
  but_ans_1.Caption:=answerset[1];
  but_ans_2.Caption:=answerset[2];
  but_ans_3.Caption:=answerset[3];
  but_ans_4.Caption:=answerset[4];
  but_ans_5.Caption:=answerset[5];

  sel_answ:=-1;

  refreshAnsButtons;

  Label2.Caption:=correct.symb;
  Label3.Caption:='Level '+inttostr(gamelevel);

  if(w=0) then gp:=100
  else gp:=round((r/(r+w))*100);

  if (gp<=60) then Label6.Font.Color:=clRed;
  if (gp>60) then Label6.Font.Color:=RGBToColor(255,137,39);
  if (gp>80) then Label6.Font.Color:=clYellow;
  if (gp>90) then Label6.Font.Color:=clLime;


  Label6.Caption:='Total score: '+inttostr(totscore) + ' (right: '+inttostr(r)+'; wrong: '+inttostr(w)+': '+inttostr(gp)+'%)';

  buildcheatsheet;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  sym_tempo:=TrackBar1.Position;
  refreshProgressBar;
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

  setlength(smbstatedb,length(symboldb));

end;

procedure storesmbstate;
var i,l:integer;
begin
  AssignFile(statefile, 'gamsaav.sav');
  Rewrite(statefile);

  WriteLn(statefile,inttostr(gamelevel));
  WriteLn(statefile,inttostr(exptp));
  WriteLn(statefile,inttostr(totscore));
  WriteLn(statefile,inttostr(sym_tempo));
  WriteLn(statefile,inttostr(r));
  WriteLn(statefile,inttostr(w));

  l:=length(symboldb);

  for i:=0 to l-1 do
  begin
    if symboldb[i].active then
    WriteLn(statefile,'1')
    else
    WriteLn(statefile,'0');
    WriteLn(statefile,inttostr(smbstatedb[i].tries));
    WriteLn(statefile,inttostr(smbstatedb[i].succ));
    WriteLn(statefile,inttostr(smbstatedb[i].fail));
    WriteLn(statefile,inttostr(smbstatedb[i].perc));
  end;

  CloseFile(statefile);
end;

procedure restoresmbstate;
var i,l,tmp:integer;
begin
  if FileExists('gamsaav.sav') then
  begin
    AssignFile(statefile, 'gamsaav.sav');
    Reset(statefile);

    ReadLn(statefile,gamelevel);
    ReadLn(statefile,exptp);
    ReadLn(statefile,totscore);
    ReadLn(statefile,sym_tempo);
    ReadLn(statefile,r);
    ReadLn(statefile,w);

    l:=length(symboldb);

    for i:=0 to l-1 do
    begin
      ReadLn(statefile,tmp);
      if (tmp=0) then symboldb[i].active:=false;
      if (tmp=1) then symboldb[i].active:=true;
      ReadLn(statefile,smbstatedb[i].tries);
      ReadLn(statefile,smbstatedb[i].succ);
      ReadLn(statefile,smbstatedb[i].fail);
      ReadLn(statefile,smbstatedb[i].perc);
    end;

    with form1 do
    begin
      edit1.Text:=inttostr(gamelevel);
      if exptp=1 then RadioButton1.Checked:=true;
      if exptp=2 then RadioButton2.Checked:=true;
      if exptp=3 then RadioButton3.Checked:=true;
    end;

    CloseFile(statefile);

    form1.makequestion;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  randomize;
  loadsymboltables;
  togglecheatsheet;
  updateAnsStyle;
  restoresmbstate;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  refreshAnsButtons;
end;

procedure TForm1.GroupBox3Click(Sender: TObject);
begin

end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
  sel_answ:=ListBox1.ItemIndex;
end;

procedure TForm1.RadioButton4Change(Sender: TObject);
begin
  UpdateAnsStyle;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  togglecheatsheet;
end;

procedure TForm1.Button2Click(Sender: TObject);
var i,n:integer;
begin

  if(resetProgress)then
  begin

    gamelevel:=0;

    if RadioButton1.Checked then exptp:=1;
    if RadioButton2.Checked then exptp:=2;
    if RadioButton3.Checked then exptp:=3;

    sym_tempo:=TrackBar1.Position;

    totscore:=0;
    w:=0;
    r:=0;

    for i:=0 to Length(symboldb)-1 do symboldb[i].active:=false;

    if (not TryStrToInt(edit1.Text,n)) then n:=1;

    if (n<1) then n:=1;

    if (CheckBox2.Checked) then
    begin
      unclockSymbolByName('a');
      unclockSymbolByName('i');
      unclockSymbolByName('u');
      unclockSymbolByName('e');
      unclockSymbolByName('o');
    end;

    if (gamelevel<(n-1)) then
    for i:=gamelevel to n-1 do
    begin
      unlockNewSymbol(CheckBox1.Checked, false);
    end;

    Form2.Show;

    makequestion;

    storesmbstate;

  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var seltext:string;
begin

  if (Form2.Visible) then form2.Close;
  if (sel_answ<>-1) then
  begin
    seltext:=answerset[sel_answ];

    inc(smbstatedb[correct_id].tries);

    if(seltext=correct.written) then
    begin
       inc(score);
       inc(totscore);
       inc(smbstatedb[correct_id].succ);
       if(score>=gamelevel*sym_tempo)then
       begin
         unlockNewSymbol(CheckBox1.Checked, true);
         score:=0;
       end;
       refreshProgressBar;
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
      inc(smbstatedb[correct_id].fail);
    end;

    if (smbstatedb[correct_id].fail>0) then smbstatedb[correct_id].perc:=round(100*smbstatedb[correct_id].succ/smbstatedb[correct_id].tries)
    else smbstatedb[correct_id].perc:=100;

    makequestion;

    storesmbstate;
  end;

end;

procedure TForm1.Button4Click(Sender: TObject);
var i,l:integer;
begin
  ResetProgress;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  form3.Show;
end;

procedure TForm1.but_ans_0Click(Sender: TObject);
begin
  sel_answ:=0;
  refreshAnsButtons;
end;

procedure TForm1.but_ans_1Click(Sender: TObject);
begin
  sel_answ:=1;
  refreshAnsButtons;
end;

procedure TForm1.but_ans_2Click(Sender: TObject);
begin
  sel_answ:=2;
  refreshAnsButtons;
end;

procedure TForm1.but_ans_3Click(Sender: TObject);
begin
  sel_answ:=3;
  refreshAnsButtons;
end;

procedure TForm1.but_ans_4Click(Sender: TObject);
begin
  sel_answ:=4;
  refreshAnsButtons;
end;

procedure TForm1.but_ans_5Click(Sender: TObject);
begin
  sel_answ:=5;
  refreshAnsButtons;
end;

procedure TForm1.CheckBox3Change(Sender: TObject);
begin
  Label4.Visible:=CheckBox3.Checked;
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


procedure tForm1.refreshAnsButtons;
var bw:integer;
begin
  bw:=round(Panel3.Width/6);
  but_ans_0.Width:=bw;
  but_ans_1.Width:=bw;
  but_ans_2.Width:=bw;
  but_ans_3.Width:=bw;
  but_ans_4.Width:=bw;
  but_ans_5.Width:=bw;
  but_ans_0.Font.Style:=[];
  but_ans_1.Font.Style:=[];
  but_ans_2.Font.Style:=[];
  but_ans_3.Font.Style:=[];
  but_ans_4.Font.Style:=[];
  but_ans_5.Font.Style:=[];
  if(sel_answ=0) then but_ans_0.Font.Style:=[fsBold];
  if(sel_answ=1) then but_ans_1.Font.Style:=[fsBold];
  if(sel_answ=2) then but_ans_2.Font.Style:=[fsBold];
  if(sel_answ=3) then but_ans_3.Font.Style:=[fsBold];
  if(sel_answ=4) then but_ans_4.Font.Style:=[fsBold];
  if(sel_answ=5) then but_ans_5.Font.Style:=[fsBold];

end;

procedure tform1.updateAnsStyle;
begin
  if(RadioButton4.Checked) then
  begin
    Panel3.Visible:=true;
    Panel2.Visible:=false;
  end;
  if(RadioButton5.Checked) then
  begin
    Panel3.Visible:=false;
    Panel2.Visible:=true;
  end;
end;

end.

