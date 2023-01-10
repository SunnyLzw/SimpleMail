object DataModuleBase: TDataModuleBase
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 182
  Width = 246
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=.\Data\DataBase.db')
    FetchOptions.AssignedValues = [evRowsetSize, evRecordCountMode]
    FetchOptions.RowsetSize = 0
    FetchOptions.RecordCountMode = cmTotal
    LoginPrompt = False
    Left = 40
    Top = 24
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    Left = 120
    Top = 32
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 152
    Top = 8
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    ScreenCursor = gcrHourGlass
    Left = 128
    Top = 96
  end
  object IdMessage1: TIdMessage
    AttachmentEncoding = 'UUE'
    BccList = <>
    CCList = <>
    Encoding = meDefault
    FromList = <
      item
      end>
    Recipients = <>
    ReplyTo = <>
    ConvertPreamble = True
    Left = 160
    Top = 56
  end
  object IdSMTP1: TIdSMTP
    SASLMechanisms = <>
    Left = 80
    Top = 56
  end
  object IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 32
    Top = 56
  end
end
