object Form1: TForm1
  Left = 238
  Top = 154
  Width = 696
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 88
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 40
    Width = 249
    Height = 113
    Lines.Strings = (
      'TXMLSerializer Sample:'
      ''
      'Try hitting the '#39'Save'#39' button one time, after that, a '
      'xml file will become visible in the same directory as '
      'the exefile. Open it, and edit some values. After '
      'that, hit the '#39'Load'#39' button and see what happens.')
    TabOrder = 2
  end
  object XMLSerializer1: TXMLSerializer
    XMLText.Strings = (
      '<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>'
      '<classes/>')
    Encoding = 'ISO-8859-1'
    Standalone = 'yes'
    Version = '1.0'
    Left = 8
    Top = 8
  end
end
