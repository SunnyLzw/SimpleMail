unit Plugin;

interface

uses
  Vcl.Forms;

type
  PPluginData = ^TPluginData;

  TGetPlugin = function: PPluginData; stdcall;

  TSetPlugin = procedure(APluginData: PPluginData); stdcall;

  TSetMainForm = procedure(AMainForm: TCustomForm); stdcall;

  TExecute = procedure; stdcall;

  {$Align 4}
  TFunctions = record
    SetPlugin: TSetPlugin;
    SetMainForm: TSetMainForm;
    Execute: TExecute;
  end;

  {$Align 4}
  TPluginData = record
    ParentIndex: Integer;
    ParentName: string;
    Name: string;
    Hint: string;
    Functions: TFunctions;
  end;

implementation

end.

