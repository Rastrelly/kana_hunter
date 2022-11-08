unit ukhnewsymbols;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ukanahunter;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    ListBox1: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

function composesymbol(id:integer):string;
var med:string;
begin
  med:='';
  if(id>=0) and (id<Length(symboldb)) then
  begin
    med:=symboldb[id].symb+' - '+symboldb[id].written;
    if (symboldb[id].category=0) then med:=med+' (hiragana)';
    if (symboldb[id].category=1) then med:=med+' (katakana)';
  end;
  Result:=med;
end;

{ TForm2 }

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  form1.resetNewSymbols;
end;

procedure TForm2.FormShow(Sender: TObject);
var i:integer;
begin
  ListBox1.Clear;
  if length(newsymbols)>0 then
  for i:=0 to length(newsymbols)-1 do
  begin
    ListBox1.Items.Add(composesymbol(newsymbols[i]));
  end;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  form1.resetNewSymbols;
  Form2.Close;
end;

end.

