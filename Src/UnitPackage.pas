unit UnitPackage;

interface

uses
  System.SysUtils, System.Rtti, UnitType;

type
  TCustomPackage = class(TInterfacedObject)
  private
{$IFNDEF DEBUG}
    FPackageName: string;
    FModuleHandle: HMODULE;
{$ENDIF}
    FUnitName: string;
    FClassName: string;
    FTypeName: string;
    FType: TRttiType;
    FInstanceType: TRttiInstanceType;
  protected
    procedure OnCreate; virtual; abstract;
    procedure OnDestroy; virtual; abstract;
  public
    constructor Create(APackageName: string; AUnitName: string; AClassName: string); overload;
    constructor Create(APackageName: string); overload;
    constructor Create(AUnitName: string; AClassName: string); overload;
    destructor Destroy; override;
  public
    property InstanceType: TRttiInstanceType read FInstanceType;
  end;

  TPackage = class(TCustomPackage)
  private
    FInterface: TInterfacedObject;
  protected
    procedure OnCreate; override;
    procedure OnDestroy; override;
  public
    function Supports(AIID: TGUID; out AIntf): Boolean;
  public
    property IInterface: TInterfacedObject read FInterface;
  end;

  TForm = class(TPackage, IForm)
  private
    FForm: IForm;
  protected
    procedure OnCreate; override;
    procedure OnDestroy; override;
  public
    property Form: IForm read FForm implements IForm;
  end;

  TDialog = class(TForm, IDialog)
  private
    FDialog: IDialog;
  protected
    procedure OnCreate; override;
    procedure OnDestroy; override;
  public
    property Dialog: IDialog read FDialog implements IDialog;
  end;

  TBase = class(TForm, IBase, ISmtp)
  private
    FBase: IBase;
    FSmtp: ISmtp;
  protected
    procedure OnCreate; override;
    procedure OnDestroy; override;
  public
    constructor Create;
  public
    property Base: IBase read FBase implements IBase;
    property Smtp: ISmtp read FSmtp implements ISmtp;
  end;

  TTips = class(TForm, ITips)
  private
    FTips: ITips;
  protected
    procedure OnCreate; override;
    procedure OnDestroy; override;
  public
    constructor Create;
  public
    property Tips: ITips read FTips implements ITips;
  end;

  TImport = class(TDialog, IImport)
  private
    FImport: IImport;
  protected
    procedure OnCreate; override;
    procedure OnDestroy; override;
  public
    constructor Create;
  public
    property Import: IImport read FImport implements IImport;
  end;

implementation

{ TCustomPackage }

constructor TCustomPackage.Create(APackageName: string; AUnitName: string; AClassName: string);
begin
{$IFNDEF DEBUG}
  FPackageName := APackageName;
  if APackageName.Trim <> '' then
    FModuleHandle := LoadPackage(FPackageName);
{$ENDIF}
  FUnitName := AUnitName;
  FClassName := AClassName;
  FTypeName := FUnitName + '.' + FClassName;
  with TRttiContext.Create do
  try
    FType := FindType(FTypeName);
    FInstanceType := FType as TRttiInstanceType;
  finally
    Free;
  end;
  OnCreate;
end;

constructor TCustomPackage.Create(AUnitName, AClassName: string);
begin
  Create('', AUnitName, AClassName);
end;

constructor TCustomPackage.Create(APackageName: string);
begin
  Create('.\Packages\sm' + APackageName + '.bpl', 'Unit' + APackageName, 'T' + APackageName);
end;

destructor TCustomPackage.Destroy;
begin
  OnDestroy;
  FInstanceType := nil;
{$IFNDEF DEBUG}
  if FModuleHandle > 0 then
    UnLoadPackage(FModuleHandle);
{$ENDIF}
  inherited;
end;

{ TPackage }

procedure TPackage.OnCreate;
begin
  FInterface := TInterfacedObject(FInstanceType.MetaclassType.Create);
end;

procedure TPackage.OnDestroy;
begin
  FInterface := nil;
end;

function TPackage.Supports(AIID: TGUID; out AIntf): Boolean;
begin
  Result := System.SysUtils.Supports(FInterface, AIID, AIntf);
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

{ TBase }

constructor TBase.Create;
begin
  inherited Create('UnitBase', 'TBase');
end;

procedure TBase.OnCreate;
begin
  inherited;
  Supports(StringToGUID('{3C52642F-1EF3-42D2-B6E3-4E4A9D021544}'), FBase);
  Supports(StringToGUID('{B01FB75A-0399-439F-AAE6-2F2EDA3C90FF}'), FSmtp);
end;

procedure TBase.OnDestroy;
begin
  FSmtp := nil;
  FBase := nil;
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

