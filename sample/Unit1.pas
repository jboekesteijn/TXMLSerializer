unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XMLSerializer, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    XMLSerializer1: TXMLSerializer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  XMLSerializer1.Filename := ExtractFilePath(Application.ExeName) + '\button.xml';
  XMLSerializer1.SaveObject(Button1,'test');
  XMLSerializer1.SaveObject(Button2,'test2');
  XMLSerializer1.SaveFile;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  XMLSerializer1.Filename := ExtractFilePath(Application.ExeName) + '\button.xml';
  XMLSerializer1.LoadFile;
  XMLSerializer1.LoadObject(Button1,'test');
  XMLSerializer1.LoadObject(Button2,'test2');  
end;

end.
