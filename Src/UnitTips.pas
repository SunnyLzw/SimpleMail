unit UnitTips;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls;

type
  TFormTips = class(TForm)
    ListBox1: TListBox;
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ListBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormTips: TFormTips;

implementation

uses
  UnitImport;
{$R *.dfm}

procedure TFormTips.FormShow(Sender: TObject);
begin
  ListBox1.ItemIndex := 0;
end;

procedure TFormTips.ListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Visible then
  begin
    if Key = VK_RETURN then
    begin
      if ListBox1.ItemIndex <> -1 then
        FormImport.AutoComplete;
    end
    else if Key in [VK_LEFT, VK_RIGHT] then
      Hide
    else if not (Key in [VK_UP, VK_DOWN]) then
      Hide;
  end;
end;

procedure TFormTips.ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  i, index: Integer;
begin
  index := -1;
  for i := 0 to listBox1.Items.Count - 1 do
  begin
    if ListBox1.ItemRect(i).Contains(TPoint.Create(X, Y)) then
    begin
      index := i;
      break;
    end;
  end;
  if (index <> -1) and not listBox1.Selected[index] then
  begin
    listBox1.Selected[listBox1.ItemIndex] := False;
  end;

  if (index <> -1) and not listBox1.Selected[index] then
  begin
    listBox1.Selected[index] := True;
  end;
end;

procedure TFormTips.ListBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ListBox1.ItemIndex <> -1 then
  begin
    FormImport.AutoComplete;
  end;
end;

end.

