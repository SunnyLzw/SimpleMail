unit PluginManager;

interface

uses
  PluginFrame, System.SysUtils, System.Generics.Collections, System.IOUtils,
  System.Rtti;

type
  PPluginObject = ^TPluginObject;

  TPluginObject = record
    ModuleHandle: HMODULE;
    Plugin: IPlugin;
    PluginEvent: IPluginEvent;
    PluginMenuEvent: IPluginMenuEvent;
    PluginData: TPluginData;
  end;

  TPluginManager = class(TObject)
  protected
    FPluginObjectList: TList<PPluginObject>;
  public
    constructor Create(APluginPath: string);
    destructor Destroy; override;
    procedure EnumPlugin(APluginPath: string);
  public
    property PluginObjectList: TList<PPluginObject> read FPluginObjectList;
  end;

implementation

{ TPluginManager }

constructor TPluginManager.Create(APluginPath: string);
begin
  EnumPlugin(APluginPath);
end;

destructor TPluginManager.Destroy;
var
  LPluginObject: PPluginObject;
begin
  for LPluginObject in FPluginObjectList do
  begin
    LPluginObject.PluginEvent.OnUnLoad;
    LPluginObject.Plugin := nil;
    LPluginObject.PluginEvent := nil;
    LPluginObject.PluginMenuEvent := nil;
    //UnloadPackage(LPluginObject.ModuleHandle);
    Dispose(LPluginObject);
  end;

  FPluginObjectList.Free;
  inherited;
end;

procedure TPluginManager.EnumPlugin(APluginPath: string);
var
  LFileNames: TArray<string>;
  LFileName: string;
  LPackage: TRttiPackage;
  LType: TRttiType;
  LPluginObject: PPluginObject;
  LHandle: THandle;
  LObject: TInterfacedObject;
  LPlugin: IPlugin;
  LPluginEvent: IPluginEvent;
  LPluginMenuEvent: IPluginMenuEvent;
begin
  FPluginObjectList := TList<PPluginObject>.Create;
  if not DirectoryExists(APluginPath) then
    Exit;

  LFileNames := TDirectory.GetFiles(APluginPath, '*.bpl');
  for LFileName in LFileNames do
  begin
    LHandle := LoadPackage(LFileName);
    if LHandle <= 0 then
      Continue;

    with TRttiContext.Create do
    try
      for LPackage in GetPackages do
      begin
        if ExtractFileName(LPackage.Name) <> ExtractFileName(LFileName) then
          Continue;

        for LType in LPackage.GetTypes do
        begin
          if not Assigned(LType.BaseType) then
            Continue;

          {$IFDEF DEBUG}
          if LType.BaseType.Name <> GetType(TPlugin).Name then
            Continue;
          {$ELSE}
          if LType.BaseType <> GetType(TPlugin) then
            Continue;
          {$ENDIF}


          LObject := TInterfacedObject((LType as TRttiInstanceType).MetaclassType.Create);
          if not Assigned(LObject) then
          begin
            UnloadPackage(LHandle);
            Continue;
          end;
          Supports(LObject, StringToGUID('{353D65E4-FAC1-4EB0-9CAF-E54911BB83CA}'), LPlugin);
          Supports(LObject, StringToGUID('{8AEB9497-6C87-426B-A253-A518E45F9395}'), LPluginEvent);
          Supports(LObject, StringToGUID('{3CC5ADD0-4192-4256-92E2-590754B945E4}'), LPluginMenuEvent);
          New(LPluginObject);
          LPluginEvent.OnLoad;
          LPluginObject.ModuleHandle := LHandle;
          LPluginObject.PluginData := LPlugin.GetPluginData;
          LPluginObject.Plugin := LPlugin;
          LPluginObject.PluginEvent := LPluginEvent;
          LPluginObject.PluginMenuEvent := LPluginMenuEvent;
          FPluginObjectList.Add(LPluginObject);
          LPlugin := nil;
          LPluginEvent := nil;
          LPluginMenuEvent := nil;
        end;
      end;
    finally
      Free;
    end;
  end;
end;

end.

