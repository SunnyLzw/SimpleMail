unit ImportUnit;

interface

uses
  TipsUnit, System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Layouts, FMX.StdCtrls,
  FMX.ScrollBox, FMX.Memo, FMX.Memo.Types, FMX.Controls.Presentation;

type
  TImportForm = class(TForm)
    MainLayout: TLayout;
    Button1: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure Memo1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
    FTipsForm: TTipsForm;
    FMailAddresss: TStrings;
  public
    { Public declarations }
    function AutoPostfix(var AString: string): Boolean;
    function AutoPostfixs(AString: string): TStrings;
    procedure AutoComplete;
    property MailAddresss: TStrings read FMailAddresss write FMailAddresss;
  end;

implementation

uses
  BaseUnit, Winapi.Windows;

{$R *.fmx}

procedure TImportForm.AutoComplete;
var
  LPostfix, LHeadString, LTailString: string;
  LCaret: TCaretPosition;
begin
  FTipsForm.Hide;
  LPostfix := FTipsForm.GetPostfix;

  LCaret := Memo1.TextPosToPos(Memo1.SelStart);

  LHeadString := Memo1.Lines[LCaret.Line].Substring(0, LCaret.Pos);
  LTailString := '';
  if LCaret.Pos <> Memo1.Lines[LCaret.Line].Length then
    LTailString := Memo1.Lines[LCaret.Line].Substring(LCaret.Pos, Memo1.Lines[LCaret.Line].Length);

  if GBaseDataModule.SettingsData.AutoWrap then
  begin
    Memo1.Lines[LCaret.Line] := LHeadString + LPostfix;
    Memo1.Lines.Insert(LCaret.Line + 1, LTailString);
    LCaret.Line := LCaret.Line + 1;
    LCaret.Pos := 0;
    Memo1.SelStart := Memo1.PosToTextPos(LCaret);
  end
  else
  begin
    Memo1.Lines[LCaret.Line] := LHeadString + LPostfix + LTailString;
    LCaret.Pos := LCaret.Pos + LPostfix.Length;
    Memo1.SelStart := Memo1.PosToTextPos(LCaret);
  end;
  Memo1.SetFocus;
end;

function TImportForm.AutoPostfix(var AString: string): Boolean;
begin
  Result := False;
  AString := AString.Trim;
  if AString <> '' then
  begin
    if AString.IndexOf('@') = -1 then
      AString := AString + '@' + GBaseDataModule.SettingsData.DefaultPostfix;
    Result := True;
  end;
end;

function TImportForm.AutoPostfixs(AString: string): TStrings;
var
  LStrings: TStrings;
  LString, LTempString: string;
begin
  LStrings := TStringList.Create;
  LStrings.StrictDelimiter := True;
  LStrings.Text := AString;
  Result := TStringList.Create;
  for LString in LStrings do
  begin
    LTempString := LString;
    if not AutoPostfix(LTempString) then
      Continue;

    if GBaseDataModule.SettingsData.FilterRepeat then
      if Result.IndexOf(LTempString) <> -1 then
        Continue;

    Result.Append(LTempString);
  end;
end;

procedure TImportForm.Button1Click(Sender: TObject);
begin
  FMailAddresss := AutoPostfixs(Memo1.Lines.Text);
  Close;
end;

procedure TImportForm.FormCreate(Sender: TObject);
begin
  StyleBook := Application.MainForm.StyleBook;
  FTipsForm := TTipsForm.Create(nil);
  with FTipsForm do
  begin
    Parent := Self;
    SetAutoComplete(AutoComplete);
    SetPostfixs(GBaseDataModule.Postfixs);
    Show;
    Hide;
  end;
  FMailAddresss := TStringList.Create;
  FMailAddresss.StrictDelimiter := True;
end;

procedure TImportForm.FormDestroy(Sender: TObject);
begin
  FTipsForm.Free;
  FTipsForm := nil;
end;

procedure TImportForm.Memo1KeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  LClient: TPointF;
  LCaret: TCaretPosition;
  LHeight, LWidth: Single;
  LHeadString, LTailString: string;
begin
  LClient := ClientToScreen(MainLayout.Position.Point);
  LCaret := Memo1.TextPosToPos(Memo1.SelStart);

  if (ssShift in Shift) and (KeyChar = '@') then
  begin
    if Memo1.Lines[LCaret.Line].Trim <> '' then
    begin
      LHeight := Canvas.TextHeight(Memo1.Lines[LCaret.Line]) * (LCaret.Line + 1);
      LWidth := Canvas.TextWidth(Memo1.Lines[LCaret.Line].Substring(0, LCaret.Pos) + KeyChar) + 2;

      FTipsForm.Top := Round(LClient.Y + Memo1.BoundsRect.Top + LHeight);
      if Memo1.HScrollBar.Visible then
      begin
        if (FTipsForm.Top > LClient.Y + Memo1.BoundsRect.Bottom - Memo1.HScrollBar.Height) then
          FTipsForm.Top := Round(LClient.Y + Memo1.BoundsRect.Bottom - Memo1.HScrollBar.Height);
      end
      else
      begin
        if (FTipsForm.Top > LClient.Y + Memo1.BoundsRect.Bottom) then
          FTipsForm.Top := Round(LClient.Y + Memo1.BoundsRect.Bottom);
      end;

      FTipsForm.Left := Round(LClient.X + Memo1.BoundsRect.Left + LWidth);
      if Memo1.VScrollBar.Visible then
      begin
        if (FTipsForm.Left > LClient.X + Memo1.BoundsRect.Right - Memo1.VScrollBar.Width) then
          FTipsForm.Left := Round(LClient.X + Memo1.BoundsRect.Right - Memo1.VScrollBar.Width);
      end
      else
      begin
        if (FTipsForm.Left > LClient.X + Memo1.BoundsRect.Right) then
          FTipsForm.Left := Round(LClient.X + Memo1.BoundsRect.Right);
      end;

      FTipsForm.Show;
    end;
  end
  else if Key = VK_RETURN then
  begin
    if LCaret.Pos = 0 then
      Exit;
    LHeadString := Memo1.Lines[LCaret.Line].Substring(0, LCaret.Pos);
    LTailString := '';
    if LCaret.Pos <> Memo1.Lines[LCaret.Line].Length then
      LTailString := Memo1.Lines[LCaret.Line].Substring(LCaret.Pos, Memo1.Lines[LCaret.Line].Length);

    if AutoPostfix(LHeadString) then
    begin
      Memo1.Lines[LCaret.Line] := LHeadString + LTailString;
      Memo1.SelStart := Memo1.SelStart + (LHeadString.Length - LCaret.Pos);
    end;
  end;
end;

procedure TImportForm.Memo1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if FTipsForm.Visible then
    FTipsForm.Hide;
end;

end.

