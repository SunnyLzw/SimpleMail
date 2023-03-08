unit HookMutexW;

interface

procedure Hook(APath: PChar); stdcall;

implementation

uses
  System.SysUtils, Winapi.Windows, WeChatMultiOpenerUnit, Sunny.Debugger;

var
  Debug: TDebugger;

procedure cbUnInit;
begin
  Debug.UnInit;
  Debug.Free;
  Debug := nil;
end;

procedure cbCreateMutexW;
var
  ct: TContext;
  p: PByte;
  guid: TGUID;
  lpName: string;
  len: NativeUInt;
  buf: Pointer;
begin
  // 获取线程上下文
  ct.ContextFlags := 65543;
  GetThreadContext(Debug.ProcessInformation.hThread, ct);

  // 获取栈顶指针
  p := PByte(ct.Esp);

  // ESP+0xC
  // CreateMutexW参数lpName
  Inc(p, $C);

  // 为了防止互斥体名称出现重复，使用GUID
  CreateGUID(guid);
  lpName := guid.ToString;

  // +1是字符串终止符
  // 老版本字符串默认编码是Ansi的
  len := (lpName.Length + 1) * SizeOf(Char);

  // 申请内存存放字符串
  buf := nil;
  Debug.Memory.Alloc(len, buf);

  // 将字符串复制到申请的内存中
  Debug.Memory.Write(buf, PChar(lpName), len);

  // 将CreateMutexW参数lpName指针修改为申请的内存地址
  Debug.Memory.Write(Pointer(p), @buf, 4);

  Debug.CreateThreadCallBack := cbUnInit;
end;

procedure cbEntry;
var
  hMod: THandle;
  pApi: Pointer;
begin
  hMod := LoadLibrary('kernel32.dll');
  pApi := GetProcAddress(hMod, 'CreateMutexW');
  Debug.SetBreakPoint(pApi, cbCreateMutexW);
end;

procedure Hook(APath: PChar);
begin
  Debug := TDebugger.Create;
  with Debug do
  try
    EntryPointCallBack := cbEntry;
    KillOnExit := False;
    Init(APath);
    Loop;
  finally
    Free;
  end;
end;

end.

