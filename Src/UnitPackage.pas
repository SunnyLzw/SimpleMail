unit UnitPackage;

interface

uses
  System.Classes, System.SysUtils, UnitType;

type
  TCustomPackage = class(TInterfacedObject)
  private
{$IFNDEF DEBUG}
    FPackageName: string;
    FModuleHandle: HMODULE;
{$ENDIF}
    FPersistentClassName: string;
    FPersistentClass: TPersistentClass;
  private
    procedure OnCreate; virtual; abstract;
    procedure OnDestroy; virtual; abstract;
  public
    constructor Create(APackageName: string); virtual;
    destructor Destroy; override;
  public
    property PersistentClass: TPersistentClass read FPersistentClass;
  end;

  TPackage = class(TCustomPackage)
  private
    FPersistent: TPersistent;
    FIsSupported: Boolean;
  private
    procedure OnCreate; override;
    procedure OnDestroy; override;
  private
    procedure Supports(AIID: TGUID; out AIntf);
  end;

  TForm = class(TPackage, IForm)
  private
    FForm: IForm;
  private
    procedure OnCreate; override;
    procedure OnDestroy; override;
  public
    property Form: IForm read FForm implements IForm;
  end;

  TDialog = class(TForm, IDialog)
  private
    FDialog: IDialog;
  private
    procedure OnCreate; override;
    procedure OnDestroy; override;
  public
    property Dialog: IDialog read FDialog implements IDialog;
  end;

  TSmtp = class(TForm, ISmtp)
  private
    FSmtp: ISmtp;
  private
    procedure OnCreate; override;
    procedure OnDestroy; override;
  public
    constructor Create; reintroduce;
  public
    property Smtp: ISmtp read FSmtp implements ISmtp;
  end;

  TTips = class(TForm, ITips)
  private
    FTips: ITips;
  private
    procedure OnCreate; override;
    procedure OnDestroy; override;
  public
    constructor Create; reintroduce;
  public
    property Tips: ITips read FTips implements ITips;
  end;

  TImport = class(TDialog, IImport)
  private
    FImport: IImport;
  private
    procedure OnCreate; override;
    procedure OnDestroy; override;
  public
    constructor Create; reintroduce;
  public
    property Import: IImport read FImport implements IImport;
  end;

implementation

{ TCustomPackage }

constructor TCustomPackage.Create(APackageName: string);
begin
{$IFNDEF DEBUG}
  FPackageName := '.\Packages\sm' + APackageName + '.bpl';
  FModuleHandle := LoadPackage(FPackageName);
{$ENDIF}
  FPersistentClassName := 'T' + APackageName;
  FPersistentClass := GetClass(FPersistentClassName);
  OnCreate;
end;

destructor TCustomPackage.Destroy;
begin
  OnDestroy;
  FPersistentClass := nil;
{$IFNDEF DEBUG}
  UnLoadPackage(FModuleHandle);
{$ENDIF}
  inherited;
end;

{ TPackage }

procedure TPackage.OnCreate;
begin
  FPersistent := FPersistentClass.Create;
  FIsSupported := False;
end;

procedure TPackage.OnDestroy;
begin
  if not FIsSupported then
    if Assigned(FPersistent) then
      FPersistent.Free;

  FPersistent := nil;
end;

procedure TPackage.Supports(AIID: TGUID; out AIntf);
begin
  System.SysUtils.Supports(FPersistent, AIID, AIntf);
  FIsSupported := True;
end;

{ TForm }

procedure TForm.OnCreate;
begin
  inherited;
  Supports(StringToGUID('{444C733E-795D-4B58-BF82-AFB79C6AB0ED}'), FForm);
  FForm.Create;
end;

procedure TForm.OnDestroy;
begin
  FForm.Destroy;
  FForm := nil;
  inherited;
end;

{ TDialog }

procedure TDialog.OnCreate;
begin
  inherited;
  Supports(StringToGUID('{3D02B1E6-44EB-4DD0-9338-8F7F5A8960EB}'), FDialog);
end;

procedure TDialog.OnDestroy;
begin
  FDialog := nil;
  inherited;
end;

{ TSmtp }

constructor TSmtp.Create;
begin
  inherited Create('Smtp');
end;

procedure TSmtp.OnCreate;
begin
  inherited;
  Supports(StringToGUID('{3C52642F-1EF3-42D2-B6E3-4E4A9D021544}'), FSmtp);
end;

procedure TSmtp.OnDestroy;
begin
  FSmtp := nil;
  inherited;
end;

{ TTips }

constructor TTips.Create;
begin
  inherited Create('Tips');
end;

procedure TTips.OnCreate;
begin
  inherited;
  Supports(StringToGUID('{1BFA1839-F9B6-414C-87E6-034AC3C6AB28}'), FTips);
end;

procedure TTips.OnDestroy;
begin
  FTips := nil;
  inherited;
end;

{ TImport }

constructor TImport.Create;
begin
  inherited Create('Import');
end;

procedure TImport.OnCreate;
begin
  inherited;
  Supports(StringToGUID('{9BDB3246-7661-4729-A0E1-F4C0EE11C24D}'), FImport);
end;

procedure TImport.OnDestroy;
begin
  FImport := nil;
  inherited;
end;

end.

