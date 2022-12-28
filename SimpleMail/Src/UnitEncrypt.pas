unit UnitEncrypt;

interface

uses
  System.Classes, System.SysUtils;

type
  TByteArray = TArray<Byte>;

  TByteArrayHelper = record Helper for TByteArray
    class function Create(AString: string): TByteArray; overload;
    class function Create(AString: string; AEncoding: TENcoding): TByteArray; overload;
    class function XOREncrypt(AData: TByteArray; AKey: Byte = $55): TByteArray; overload;
    class function XOREncrypt(AKey: Byte = $55): TByteArray; overload;
    class function XORDecrypt(AData: TByteArray; AKey: Byte = $55): TByteArray; overload;
    class function XORDecrypt(AKey: Byte = $55): TByteArray; overload;
    class function ToString(AData: TByteArray): string; overload;
    class function ToString(AData: TByteArray; AEncoding: TENcoding): string; overload;
    class function ToString: string; overload;
    class function ToString(AEncoding: TENcoding): string; overload;
  end;

  TXOREncrypt = class(TObject)
  protected
    FData: TByteArray;
    FKey: Byte;
  public
    constructor Create(AData: TByteArray; AKey: Byte = $55); overload;
    constructor Create(AData: string; AKey: Byte = $55); overload;
    function Encrypt: TByteArray;
    function Decrypt: TByteArray;
  public
    property Data: TByteArray read FData write FData;
    property Key: Byte read FKey write FKey;
  end;

function StrToBin(AStr: string): string; overload;

function StrToBin(AStr: string; AEncoding: TEncoding): string; overload;

function BinToStr(ABin: string): string; overload;

function BinToStr(ABin: string; AEncoding: TEncoding): string; overload;

implementation

function StrToBin(AStr: string): string;
begin
  Result := StrToBin(AStr, TEncoding.Default);
end;

function StrToBin(AStr: string; AEncoding: TEncoding): string;
var
  ss: TStringStream;
begin
  ss := TStringStream.Create(AStr, AEncoding);
  for var i in ss.Bytes do
    Result := Result + i.ToHexString(2);
end;

function BinToStr(ABin: string): string;
begin
  Result := BinToStr(ABin, TEncoding.Default);
end;

function BinToStr(ABin: string; AEncoding: TEncoding): string;
var
  ss: TStringStream;
  bs: TBytesStream;
  i: Int64;
  c: array[0..1] of Char;
  b: Byte;
begin
  ss := TStringStream.Create(ABin, AEncoding);
  bs := TBytesStream.Create;
  bs.SetSize(Trunc(ss.Size / 2));
  for i := 0 to bs.Size - 1 do
  begin
    ss.Read(c, 4);
    b := ('$' + string(c)).ToInteger;
    bs.Write(b, 1);
  end;
  ss.LoadFromStream(bs);
  Result:=ss.DataString;
end;

{ TByteArrayHelper }

class function TByteArrayHelper.Create(AString: string): TByteArray;
begin
  Result := Create(AString, TEncoding.Default);
end;

class function TByteArrayHelper.XORDecrypt(AData: TByteArray; AKey: Byte): TByteArray;
begin
  Result := TXOREncrypt.Create(AData, AKey).Decrypt;
end;

class function TByteArrayHelper.Create(AString: string; AEncoding: TENcoding): TByteArray;
begin
  Result := TStringStream.Create(AString, AEncoding).Bytes;
end;

class function TByteArrayHelper.ToString(AEncoding: TENcoding): string;
begin
  Result := ToString(Self, AEncoding);
end;

class function TByteArrayHelper.ToString(AData: TByteArray; AEncoding: TENcoding): string;
begin
  var ss := TStringStream.Create('', AEncoding);
  ss.LoadFromStream(TBytesStream.Create(AData));
  Result := ss.DataString;
end;

class function TByteArrayHelper.XORDecrypt(AKey: Byte): TByteArray;
begin
  Result := XORDecrypt(Self, AKey);
end;

class function TByteArrayHelper.XOREncrypt(AKey: Byte): TByteArray;
begin
  Result := XOREncrypt(Self, AKey);
end;

class function TByteArrayHelper.XOREncrypt(AData: TByteArray; AKey: Byte): TByteArray;
begin
  Result := TXOREncrypt.Create(AData, AKey).Encrypt;
end;

class function TByteArrayHelper.ToString: string;
begin
  Result := ToString(Self, TEncoding.Default);
end;

class function TByteArrayHelper.ToString(AData: TByteArray): string;
begin
  Result := ToString(AData, TEncoding.Default);
end;

{ TXOREncrypt }

constructor TXOREncrypt.Create(AData: TByteArray; AKey: Byte);
begin
  FData := AData;
  FKey := AKey;
end;

function TXOREncrypt.Decrypt: TByteArray;
begin
  SetLength(Result, Length(FData));
  for var i := Low(FData) to High(FData) do
  begin
    Result[i] := FData[i] xor FKey;
  end;
end;

function TXOREncrypt.Encrypt: TByteArray;
begin
  Result := Decrypt;
end;

constructor TXOREncrypt.Create(AData: string; AKey: Byte);
begin
  Create(TStringStream.Create(AData).Bytes, AKey);
end;

end.

