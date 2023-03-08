unit TipsUnit;

interface

uses
  Types, System.SysUtils, System.UITypes, System.Classes, FMX.Types,
  FMX.Controls, FMX.Forms, FMX.ListBox, FMX.Layouts;

type
  TTipsForm = class(TForm)
    ListBox1: TListBox;
    procedure FormShow(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure ListBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
    FAutoComplete: procedure of object;
  public
    { Public declarations }
    procedure SetAutoComplete(AAutoComplete: TAutoComplete);
    procedure SetPostfixs(APostfixs: TStrings);
    function GetPostfix: string;
  end;

implementation

uses
  Winapi.Windows;

{$R *.fmx}

{ TForm1 }

procedure TTipsForm.FormShow(Sender: TObject);
begin
  ListBox1.ItemIndex := 0;
end;

function TTipsForm.GetPostfix: string;
begin
  Result := ListBox1.Items[ListBox1.ItemIndex];
end;

procedure TTipsForm.ListBox1KeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Visible then
  begin
    if Key = VK_RETURN then
    begin
      if ListBox1.ItemIndex <> -1 then
        if Assigned(FAutoComplete) then
          FAutoComplete;
    end
    else if not (Key in [VK_UP, VK_DOWN]) then
      Hide;
  end;
end;

procedure TTipsForm.ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  LItem: TListBoxItem;
begin
  LItem := ListBox1.ItemByPoint(X, Y);
  if not Assigned(LItem) then
    Exit;

  if not LItem.IsSelected then
  begin
    listBox1.Selected.IsSelected := False;
    LItem.IsSelected := True;
  end;
end;

procedure TTipsForm.ListBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if ListBox1.ItemIndex <> -1 then
  begin
    if Assigned(FAutoComplete) then
      FAutoComplete;
  end;
end;

procedure TTipsForm.SetAutoComplete(AAutoComplete: TAutoComplete);
begin
  FAutoComplete := AAutoComplete;
end;

procedure TTipsForm.SetPostfixs(APostfixs: TStrings);
begin
  ListBox1.Items := APostfixs;

  if ListBox1.Items.Count > 10 then
    Height := Round(10 * ListBox1.ItemHeight + ListBox1.Margins.Top + ListBox1.Margins.Bottom)
  else
    Height := Round(ListBox1.Items.Count * ListBox1.ItemHeight + ListBox1.Margins.Top + ListBox1.Margins.Bottom);
end;

end.

