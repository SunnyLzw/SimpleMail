unit UnitPlugin;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, System.IOUtils,
  Plugin;

type
  TPluginPair = TPair<HMODULE, PPluginData>;

  TPluginManager = class(TObject)
  protected
    FPlugins: TList<TPluginPair>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure EnumPlugin(APluginPath: string);
  public
    property Plugins: TList<TPluginPair> read FPlugins;
  end;

implementation

{ TPluginManager }

constructor TPluginManager.Create;
begin
  EnumPlugin('.\Plugin');
end;

destructor TPluginManager.Destroy;
begin
//  for var i in FPlugins do
//    CloseHandle(i.Key);

  FPlugins.Free;
  inherited;
end;

procedure TPluginManager.EnumPlugin(APluginPath: string);
begin
  FPlugins := TList<TPluginPair>.Create;
  if not DirectoryExists(APluginPath) then
    Exit;

  var fs := TDirectory.GetFiles(APluginPath, '*.dll');
  for var i in fs do
  begin
    var p: TPluginPair;
    p.Key := LoadLibrary(PChar(i));
    if p.Key <= 0 then
      Continue;

    var proc := GetProcAddress(p.Key, 'GetPlugin');
    if not Assigned(proc) then
    begin
      CloseHandle(p.Key);
      Continue;
    end;

    p.Value := TGetPlugin(proc);
    if not Assigned(p.Value) then
    begin
      CloseHandle(p.Key);
      Continue;
    end;

    FPlugins.Add(p);
  end;
end;

end.

