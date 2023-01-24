unit UnitImport;

interface

uses
  UnitType, UnitPackage, Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls;

type
  TFormImport = class(TForm, IImport)
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
    FMailAddresss: TStrings;
    FPackageBase: TBase;
    FPackageTips: TTips;
    FCustomFormTips: TCustomForm;
    FOriginalActive: TNotifyEvent;
    procedure NewActivate(Sender: TObject);
    function AutoPostfix(var AString: string): Boolean;
    function AutoPostfixs(AString: string): TStrings;
    procedure AutoComplete;
  public
    { Public declarations }
  end;

  TImport = class(TInterfacedObject, IForm, IDialog, IImport)
  private
    FFormImport: TFormImport;
    FImport: IImport;
  public
    procedure Create;
    procedure Destroy; reintroduce;
    function GetObject: TObject;
    function Show: TObject;
  public
    property Import: IImport read FImport implements IImport;
  end;

implementation
{$IFDEF DEBUG}

uses
  UnitTips;
{$ENDIF}
{$R *.dfm}

procedure TFormImport.AutoComplete;
var
  LPostfix, LHeadString, LTailString: string;
  LColumn, LLine, LCurrent: Integer;
begin
  FCustomFormTips.Hide;
  LPostfix := FPackageTips.Tips.GetPostfix;
  if FPackageBase.Base.GetSettingsData.AutoWrap then
    LPostfix := LPostfix + #13#10;

  LLine := Memo1.CaretPos.Y;
  LColumn := Memo1.CaretPos.X;

  LHeadString := Memo1.Lines[LLine].Substring(0, LColumn);
  LTailString := '';
  if LColumn <> Memo1.Lines[LLine].Length then
    LTailString := Memo1.Lines[LLine].Substring(LColumn, Memo1.Lines[LLine].Length);

//  LCurrent := Memo1.SelStart + LPostfix.Length + LTailString.Length;
  LCurrent := Memo1.SelStart + LPostfix.Length;
  Memo1.Lines[LLine] := LHeadString + LPostfix + LTailString;
  Memo1.SelStart := LCurrent;
  Memo1.SetFocus;
end;

function TFormImport.AutoPostfix(var AString: string): Boolean;
begin
  AString := AString.Trim;
  if AString <> '' then
  begin
    if AString.IndexOf('@') = -1 then
      AString := AString + '@' + FPackageBase.Base.GetSettingsData.DefaultPostfix
    else if AString.IndexOf('.') = -1 then
      AString := AString + FPackageBase.Base.GetSettingsData.DefaultPostfix;
    Result := True;
  end
  else
    Result := False;
end;

function TFormImport.AutoPostfixs(AString: string): TStrings;
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

    if FPackageBase.Base.GetSettingsData.FilterRepeat then
      if Result.IndexOf(LTempString) <> -1 then
        Continue;

    Result.Append(LTempString);
  end;
end;

procedure TFormImport.ButtonImportClick(Sender: TObject);
begin
  FMailAddresss := AutoPostfixs(Memo1.Lines.Text);
  Close;
end;

procedure TFormImport.FormCreate(Sender: TObject);
begin
  FOriginalActive := Application.OnActivate;
  Application.OnActivate := NewActivate;
  FPackageBase := UnitPackage.TBase.Create;
  FPackageTips := UnitPackage.TTips.Create;
  FPackageTips.Tips.SetAutoComplete(AutoComplete);
  FPackageTips.Tips.SetPostfixs(FPackageBase.Base.GetPostfixs);
  FCustomFormTips := TCustomForm(FPackageTips.Form.GetObject);
  FMailAddresss := TStringList.Create;
  FMailAddresss.StrictDelimiter := True;
end;

procedure TFormImport.FormDestroy(Sender: TObject);
begin
  FCustomFormTips := nil;
  FPackageTips.Free;
  FPackageBase.Free;
  Application.OnActivate := FOriginalActive;
end;

procedure TFormImport.Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LClient: TPoint;
  LVScrollBarInfo, LHScrollBarInfo: tagSCROLLBARINFO;
  LColumn, LLine, LHeight, LWidth: Integer;
begin
  LClient := ClientToScreen(ClientRect.Location);
  LVScrollBarInfo.cbSize := SizeOf(LVScrollBarInfo);
  LHScrollBarInfo.cbSize := SizeOf(LHScrollBarInfo);
  GetScrollBarInfo(Memo1.Handle, Integer(OBJID_VSCROLL), LVScrollBarInfo);
  GetScrollBarInfo(Memo1.Handle, Integer(OBJID_HSCROLL), LHScrollBarInfo);
  LColumn := Memo1.CaretPos.X;
  LLine := Memo1.CaretPos.Y;
  if LColumn = 0 then
    Exit;

  if (ssShift in Shift) and (Key = Ord('2')) then
  begin
    if Memo1.Lines[LLine].Trim <> '' then
    begin
      LHeight := Canvas.TextHeight(Memo1.Lines[LLine]) * (LLine + 1);
      LWidth := Canvas.TextWidth(Memo1.Lines[LLine] + '@') + 2;

      FCustomFormTips.Top := LClient.Y + Memo1.BoundsRect.Top + LHeight;
      if (FCustomFormTips.Top > LClient.Y + Memo1.BoundsRect.Bottom - LHScrollBarInfo.rcScrollBar.Height) then
        FCustomFormTips.Top := LClient.Y + Memo1.BoundsRect.Bottom - LHScrollBarInfo.rcScrollBar.Height;

      FCustomFormTips.Left := LClient.X + Memo1.BoundsRect.Left + LWidth;
      if (FCustomFormTips.Left > LClient.X + Memo1.BoundsRect.Right - LVScrollBarInfo.rcScrollBar.Width) then
        FCustomFormTips.Left := LClient.X + Memo1.BoundsRect.Right - LVScrollBarInfo.rcScrollBar.Width;

      FCustomFormTips.Show;
    end;
  end;
end;

procedure TFormImport.Memo1KeyPress(Sender: TObject; var Key: Char);
var
  LColumn, LLine: Integer;
  LHeadString, LTailString: string;
begin
  LColumn := Memo1.CaretPos.X;
  LLine := Memo1.CaretPos.Y;
  if LColumn = 0 then
    Exit;

  if Key = Chr(VK_RETURN) then
  begin
    if (LLine = 0) and (LColumn = 0) then
      Exit;

    LHeadString := Memo1.Lines[LLine].Substring(0, LColumn);
    LTailString := '';
    if LColumn <> Memo1.Lines[LLine].Length then
      LTailString := Memo1.Lines[LLine].Substring(LColumn, Memo1.Lines[LLine].Length);
    if AutoPostfix(LHeadString) then
    begin
      LHeadString := LHeadString + #13#10;
      Memo1.Lines[LLine] := LHeadString + LTailString;
      if LTailString <> '' then
        Memo1.SelStart := Memo1.SelStart - LTailString.Length;
      Key := #0;
    end;
  end;
end;

procedure TFormImport.Memo1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FCustomFormTips.Visible then
    FCustomFormTips.Hide;
end;

procedure TFormImport.NewActivate(Sender: TObject);
var
  LCursor: TPoint;
begin
  if Assigned(FOriginalActive) then
    FOriginalActive(Application);

  GetCursorPos(LCursor);
  ShowCursor(False);
  SetCursorPos(Left, Top);
  mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
  SetCursorPos(LCursor.X, LCursor.Y);
  ShowCursor(True);
end;

{ TImport }

procedure TImport.Create;
begin
  FFormImport := TFormImport.Create(Application);
  Supports(FFormImport, StringToGUID('{9BDB3246-7661-4729-A0E1-F4C0EE11C24D}'), FImport);
end;

procedure TImport.Destroy;
begin
  FImport := nil;
  FFormImport.Free;
  FFormImport := nil;
end;

function TImport.GetObject: TObject;
begin
  Result := FFormImport;
end;

function TImport.Show: TObject;
begin
  FFormImport.ShowModal;
  Result := TObject(FFormImport.FMailAddresss);
end;

end.

