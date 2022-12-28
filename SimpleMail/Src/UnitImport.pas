unit UnitImport;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls;

type
  TFormImport = class(TForm)
    Memo1: TMemo;
    ButtonImport: TButton;
    procedure ButtonImportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Memo1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    MailAddresss: TStrings;
    function AutoPostfix(var Str: string): Boolean;
    function AutoPostfixs(Str: string): TStrings;
    procedure AutoComplete;
  end;

var
  FormImport: TFormImport;

implementation

uses
  UnitSmtp, UnitTips;
{$R *.dfm}

procedure TFormImport.AutoComplete;
var
  str, head, tail: string;
  col, line, i: Integer;
begin
  FormTips.Hide;
  str := FormTips.ListBox1.Items[FormTips.ListBox1.ItemIndex];
  if DataModuleSmtp.SettingsData.AutoWrap then
    str := str + #13#10;

  line := Memo1.CaretPos.Y;
  col := Memo1.CaretPos.X;

  head := Memo1.Lines[line].Substring(0, col);
  tail := '';
  if col <> Memo1.Lines[line].Length then
    tail := Memo1.Lines[line].Substring(col, Memo1.Lines[line].Length);

//  i := Memo1.SelStart + str.Length + tail.Length;
  i := Memo1.SelStart + str.Length;
  Memo1.Lines[line] := head + str + tail;
  Memo1.SelStart := i;
  Memo1.SetFocus;
end;

function TFormImport.AutoPostfix(var Str: string): Boolean;
begin
  Str := Str.Trim;
  if Str <> '' then
  begin
    if Str.IndexOf('@') = -1 then
      Str := Str + '@' + DataModuleSmtp.SettingsData.DefaultPostfix
    else if Str.IndexOf('.') = -1 then
      Str := Str + DataModuleSmtp.SettingsData.DefaultPostfix;
    Result := True;
  end
  else
    Result := False;
end;

function TFormImport.AutoPostfixs(Str: string): TStrings;
var
  sl: TStringList;
  tmp: string;
begin
  sl := TStringList.Create;
  sl.Text := Str;
  Result := TStringList.Create;
  for var i in sl do
  begin
    tmp := i;
    if not AutoPostfix(tmp) then
      Continue;

    if DataModuleSmtp.SettingsData.FilterRepeat then
      if Result.IndexOf(tmp) <> -1 then
        Continue;

    Result.Append(tmp);
  end;
end;

procedure TFormImport.ButtonImportClick(Sender: TObject);
begin
  MailAddresss := AutoPostfixs(Memo1.Lines.Text);
  Close;
end;

procedure TFormImport.FormCreate(Sender: TObject);
begin
  FormTips := TFormTips.Create(nil);
  MailAddresss := TStringList.Create;
end;

procedure TFormImport.FormDestroy(Sender: TObject);
begin
  FormTips.Close;
  FormTips.Free;
  FormTips := nil;
end;

procedure TFormImport.Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  rect: TRect;
  vSbi, hSbi: tagSCROLLBARINFO;
  col, line, h, w: Integer;
begin
  rect := ClientToScreen(ClientRect);
  vSbi.cbSize := SizeOf(vSbi);
  hSbi.cbSize := SizeOf(hSbi);
  GetScrollBarInfo(Memo1.Handle, Integer(OBJID_VSCROLL), vSbi);
  GetScrollBarInfo(Memo1.Handle, Integer(OBJID_HSCROLL), hSbi);
  col := Memo1.CaretPos.X;
  line := Memo1.CaretPos.Y;
  if col = 0 then
    Exit;

  if (ssShift in Shift) and (Key = Ord('2')) then
  begin
    if Memo1.Lines[line].Trim <> '' then
    begin
      h := Canvas.TextHeight(Memo1.Lines[line]) * (line + 1);
      w := Canvas.TextWidth(Memo1.Lines[line] + '@') + 2;

      FormTips.Top := rect.Top + Memo1.BoundsRect.Top + h;
      if (FormTips.Top > rect.Top + Memo1.BoundsRect.Bottom - hSbi.rcScrollBar.Height) then
        FormTips.Top := rect.Top + Memo1.BoundsRect.Bottom - hSbi.rcScrollBar.Height;

      FormTips.Left := rect.Left + Memo1.BoundsRect.Left + w;
      if (FormTips.Left > rect.Left + Memo1.BoundsRect.Right - vSbi.rcScrollBar.Width) then
        FormTips.Left := rect.Left + Memo1.BoundsRect.Right - vSbi.rcScrollBar.Width;

      FormTips.Show;
    end;
  end;
end;

procedure TFormImport.Memo1KeyPress(Sender: TObject; var Key: Char);
var
  col, line: Integer;
  head, tail: string;
begin
  col := Memo1.CaretPos.X;
  line := Memo1.CaretPos.Y;
  if col = 0 then
    Exit;

  if Key = Chr(VK_RETURN) then
  begin
    if (line = 0) and (col = 0) then
      Exit;

    head := Memo1.Lines[line].Substring(0, col);
    tail := '';
    if col <> Memo1.Lines[line].Length then
      tail := Memo1.Lines[line].Substring(col, Memo1.Lines[line].Length);
    if AutoPostfix(head) then
    begin
      head := head + #13#10;
      Memo1.Lines[line] := head + tail;
      if tail <> '' then
        Memo1.SelStart := Memo1.SelStart - tail.Length;
      Key := #0;
    end;
  end;
end;

procedure TFormImport.Memo1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FormTips.Visible then
    FormTips.Hide;
end;

end.

