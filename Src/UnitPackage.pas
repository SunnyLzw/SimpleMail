unit UnitPackage;

interface

uses
  System.SysUtils, System.Rtti;

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
    constructor Create(APackageName: string; AUnitName: string; AClassName: string); virtual;
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

implementation

{ TCustomPackage }

constructor TCustomPackage.Create(APackageName: string; AUnitName: string; AClassName: string);
begin
{$IFNDEF DEBUG}
  FPackageName := APackageName;
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

destructor TCustomPackage.Destroy;
begin
  OnDestroy;
  FInstanceType := nil;
{$IFNDEF DEBUG}
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

end.

