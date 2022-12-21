object FormTips: TFormTips
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 157
  ClientWidth = 108
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 14
  object ListBox1: TListBox
    Left = 0
    Top = 0
    Width = 108
    Height = 157
    Align = alClient
    ItemHeight = 14
    Items.Strings = (
      'qq.com'
      '88.com'
      '126.com'
      '163.com'
      '139.com'
      '188.com'
      '189.com'
      '263.com'
      'tom.com'
      'sina.com'
      'sohu.com'
      'yeah.com'
      'eyou.com'
      '21cn.com'
      'gmail.com'
      'aliyun.com'
      'xinnet.com'
      'foxmail.com'
      'hotmail.com'
      'outlook.com')
    TabOrder = 0
    OnKeyDown = ListBox1KeyDown
    OnMouseMove = ListBox1MouseMove
    OnMouseUp = ListBox1MouseUp
  end
end
