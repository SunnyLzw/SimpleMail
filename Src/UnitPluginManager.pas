unit UnitPluginManager;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, System.IOUtils,
  UnitPluginFrame;

type
  PPluginObject = ^TPluginObject;

  TPluginObject = record
    ModuleHandle: HMODULE;
    PluginInterface: IPlugin;
    PluginData: TPluginData;
  end;

  TPluginManager = class(TObject)
  protected
    FPlugins: TList<PPluginObject>;
  public
    constructor Create(APluginPath: string);
    destructor Destroy; override;
    procedure EnumPlugin(APluginPath: string);
  public
    property Plugins: TList<PPluginObject> read FPlugins;
  end;

implementation

uses
  System.Rtti;

{ TPluginManager }

constructor TPluginManager.Create(APluginPath: string);
begin
  EnumPlugin(APluginPath);
end;

destructor TPluginManager.Destroy;
begin
  for var i in FPlugins do
  begin
    i.PluginInterface.OnUnLoad;
    i.PluginInterface := nil;
    //UnloadPackage(i.ModuleHandle);
    Dispose(i);
  end;

  FPlugins.Free;
  inherited;
end;

procedure TPluginManager.EnumPlugin(APluginPath: string);
var
  LPackage: TRttiPackage;
  LType: TRttiType;
  LClass: TRttiInstanceType;
  LPluginObject: PPluginObject;
  LHandle: THandle;
  LPluginInterface: IPlugin;
begin
  FPlugins := TList<PPluginObject>.Create;
  if not DirectoryExists(APluginPath) then
    Exit;

  var fs := TDirectory.GetFiles(APluginPath, '*.bpl');
  for var i in fs do
  begin
    LHandle := LoadPackage(i);
    if LHandle <= 0 then
      Continue;

    with TRttiContext.Create do
    try
      for LPackage in GetPackages do
      begin
        if ExtractFileName(LPackage.Name) <> ExtractFileName(i) then
          Continue;

        for LType in LPackage.GetTypes do
        begin
          if not (LType.BaseType = GetType(TPlugin)) then
            Continue;

          LClass := LType as TRttiInstanceType;
          Supports(LClass.MetaclassType.Create as TPlugin, StringToGUID('{353D65E4-FAC1-4EB0-9CAF-E54911BB83CA}'), LPluginInterface);
          if not Assigned(LPluginInterface) then
          begin
            UnloadPackage(LHandle);
            Continue;
          end;
          New(LPluginObject);
          LPluginObject.ModuleHandle := LHandle;
          LPluginInterface.OnLoad;
          LPluginObject.PluginData := LPluginInterface.GetPluginData;
          LPluginObject.PluginInterface := LPluginInterface;
          FPlugins.Add(LPluginObject);
          LPluginInterface := nil;
        end;
      end;
    finally
      Free;
    end;
  end;
end;

end.

