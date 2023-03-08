object BaseDataModule: TBaseDataModule
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 240
  Width = 308
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
    Left = 168
    Top = 40
  end
  object IdSMTP1: TIdSMTP
    SASLMechanisms = <>
    Left = 88
    Top = 40
  end
  object IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 40
    Top = 40
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    Left = 120
    Top = 32
  end
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
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 152
    Top = 8
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'FMX'
    ScreenCursor = gcrHourGlass
    Left = 128
    Top = 96
  end
end
