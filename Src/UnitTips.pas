unit UnitTips;

interface

uses
  UnitType, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls;

type
  TFormTips = class(TForm, ITips)
    ListBox1: TListBox;
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ListBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    AutoComplete: procedure of object;
    procedure SetAutoComplete(AAutoComplete: TAutoComplete);
    procedure SetPostfixs(APostfixs: TStrings);
    function GetPostfix: string;
  public
    { Public declarations }
  end;

  TTips = class(TInterfacedPersistent, IForm, ITips)
  private
    FFormTips: TFormTips;
    FTips: ITips;
  public
    procedure Create;
    procedure Destroy; reintroduce;
    function GetObject: TObject;
  public
    property Tips: ITips read FTips implements ITips;
  end;

implementation

uses
  System.IOUtils;
{$R *.dfm}

procedure TFormTips.FormShow(Sender: TObject);
begin
  ListBox1.ItemIndex := 0;
end;

function TFormTips.GetPostfix: string;
begin
  Result := ListBox1.Items[ListBox1.ItemIndex];
end;

procedure TFormTips.ListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Visible then
  begin
    if Key = VK_RETURN then
    begin
      if ListBox1.ItemIndex <> -1 then
        if Assigned(AutoComplete) then
          AutoComplete;
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
    if Assigned(AutoComplete) then
      AutoComplete;
  end;
end;

procedure TFormTips.SetAutoComplete(AAutoComplete: TAutoComplete);
begin
  AutoComplete := AAutoComplete;
end;

procedure TFormTips.SetPostfixs(APostfixs: TStrings);
begin
  ListBox1.Items := APostfixs;

  if ListBox1.Items.Count > 10 then
    Height := 10 * ListBox1.ItemHeight + ListBox1.Margins.Top + ListBox1.Margins.Bottom
  else
    Height := ListBox1.Items.Count * ListBox1.ItemHeight + ListBox1.Margins.Top + ListBox1.Margins.Bottom;
end;

{ TTips }

procedure TTips.Create;
begin
  FFormTips := TFormTips.Create(Application);
  Supports(FFormTips, StringToGUID('{1BFA1839-F9B6-414C-87E6-034AC3C6AB28}'), FTips);
end;

procedure TTips.Destroy;
begin
  FTips := nil;
  FFormTips.Free;
  FFormTips := nil;
end;

function TTips.GetObject: TObject;
begin
  Result := FFormTips;
end;

initialization
  RegisterClass(TTips);


finalization
  UnRegisterClass(TTips);

end.

