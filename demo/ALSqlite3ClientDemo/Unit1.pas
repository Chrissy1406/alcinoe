unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StrUtils, ExtCtrls, StdCtrls, AlScrollBar, ALMemo, ALButton,
  ALEdit, ALComboBox;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Label5: TLabel;
    ALMemoResult: TALMemo;
    Label6: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label19: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    ALEditSqlite3Lib: TALEdit;
    ALMemoSqlite3Query: TALMemo;
    ALButtonSqlLite3Select: TALButton;
    ALEditSqlite3Database: TALEdit;
    ALButtonSqlite3Update: TALButton;
    RadioGroupSqlite3Journal_Mode: TRadioGroup;
    RadioGroupSQLite3Temp_Store: TRadioGroup;
    RadioGroupSqlite3Synhcronous: TRadioGroup;
    ALEditSqlite3Cache_Size: TALEdit;
    ALEditSqlite3Page_Size: TALEdit;
    ALCheckBoxSqlite3SharedCache: TALCheckBox;
    ALCheckBoxSqlite3ReadUncommited: TALCheckBox;
    OpenDialog1: TOpenDialog;
    ALButtonSqlLite3Vacuum: TALButton;
    OpenDialog2: TOpenDialog;
    procedure ALButtonPaint(Sender: TObject; var continue: Boolean);
    procedure ALMemoPaint(Sender: TObject; var continue: Boolean);
    procedure ALMemoPaintScrollBar(Sender: TObject; var continue: Boolean; Area: TALScrollbarArea);
    procedure ALEditPaint(Sender: TObject; var continue: Boolean);
    procedure ALButtonSqlLite3SelectClick(Sender: TObject);
    procedure ALButtonSqlite3UpdateClick(Sender: TObject);
    procedure ALButtonSqlLite3VacuumClick(Sender: TObject);
    procedure ALEditSqlite3DatabaseButtonClick(Sender: TObject);
    procedure ALEditSqlite3LibButtonClick(Sender: TObject);
  private
  public
  end;

var Form1: TForm1;

implementation

uses alFcnSkin,
     AlSqlite3client,
     alStringList,
     ALFcnHTML,
     alXmlDoc,
     ALWindows,
     alFcnString;

{$R *.dfm}

{*********************************************************************}
procedure TForm1.ALButtonPaint(Sender: TObject; var continue: Boolean);
begin
  PaintAlButtonBlueSkin(Sender, Continue);
end;

{*******************************************************************}
procedure TForm1.ALMemoPaint(Sender: TObject; var continue: Boolean);
begin
  paintAlMemoBlueSkin(sender, Continue);
end;

{****************************************************************************************************}
procedure TForm1.ALMemoPaintScrollBar(Sender: TObject; var continue: Boolean; Area: TALScrollbarArea);
begin
  paintAlMemoScrollBarBlueSkin(sender, Continue, area);
end;

{*******************************************************************}
procedure TForm1.ALEditPaint(Sender: TObject; var continue: Boolean);
begin
  PaintAlEditBlueSkin(Sender, Continue);
end;

{*****************************************************************}
procedure TForm1.ALEditSqlite3DatabaseButtonClick(Sender: TObject);
begin
  If OpenDialog1.Execute then (Sender as TALedit).Text := OpenDialog1.FileName;
end;

{************************************************************}
procedure TForm1.ALEditSqlite3LibButtonClick(Sender: TObject);
begin
  If OpenDialog2.Execute then (Sender as TALedit).Text := OpenDialog2.FileName;
end;

{***********************************************************}
procedure TForm1.ALButtonSqlite3UpdateClick(Sender: TObject);
Var aSqlite3Client: TalSqlite3Client;
    aStartDate: int64;
    aEndDate: int64;
    aStartCommitDate: int64;
    aEndCommitDate: int64;
    LstSql: TstringList;
    S1: String;
    i: integer;
begin
  Screen.Cursor := CrHourGlass;
  try

    aSqlite3Client := TalSqlite3Client.Create(ALEditSqlite3lib.Text);
    LstSql := TstringList.Create;
    Try

      //enable or disable the shared cache
      aSqlite3Client.enable_shared_cache(ALCheckBoxSqlite3SharedCache.Checked);

      //connect
      aSqlite3Client.connect(ALEditSqlite3Database.text);

      //the pragma
      aSqlite3Client.UpdateData('PRAGMA page_size = '+ALEditSqlite3Page_Size.Text);
      aSqlite3Client.UpdateData('PRAGMA encoding = "UTF-8"');
      aSqlite3Client.UpdateData('PRAGMA legacy_file_format = 0');
      aSqlite3Client.UpdateData('PRAGMA auto_vacuum = NONE');
      aSqlite3Client.UpdateData('PRAGMA cache_size = '+ALEditSqlite3Cache_Size.Text);
      case RadioGroupSqlite3Journal_Mode.ItemIndex of
        0: aSqlite3Client.UpdateData('PRAGMA journal_mode = DELETE');
        1: aSqlite3Client.UpdateData('PRAGMA journal_mode = TRUNCATE');
        2: aSqlite3Client.UpdateData('PRAGMA journal_mode = PERSIST');
        3: aSqlite3Client.UpdateData('PRAGMA journal_mode = MEMORY');
        4: aSqlite3Client.UpdateData('PRAGMA journal_mode = WAL');
        5: aSqlite3Client.UpdateData('PRAGMA journal_mode = OFF');
      end;
      aSqlite3Client.UpdateData('PRAGMA locking_mode = NORMAL');
      If ALCheckBoxSqlite3ReadUncommited.Checked then aSqlite3Client.UpdateData('PRAGMA read_uncommitted = 1');
      case RadioGroupSqlite3Synhcronous.ItemIndex of
        0: aSqlite3Client.UpdateData('PRAGMA synchronous = OFF');
        1: aSqlite3Client.UpdateData('PRAGMA synchronous = NORMAL');
        2: aSqlite3Client.UpdateData('PRAGMA synchronous = FULL');
      end;
      case RadioGroupSQLite3Temp_Store.ItemIndex of
        0: aSqlite3Client.UpdateData('PRAGMA temp_store = DEFAULT');
        1: aSqlite3Client.UpdateData('PRAGMA temp_store = FILE');
        2: aSqlite3Client.UpdateData('PRAGMA temp_store = MEMORY');
      end;

      //the sql
      S1 := AlMemoSQLite3Query.Lines.Text;
      while AlPos('<#randomchar>', AlLowerCase(S1)) > 0 do S1 := AlStringReplace(S1, '<#randomchar>',AlRandomStr(1),[rfIgnoreCase]);
      while AlPos('<#randomnumber>', AlLowerCase(S1)) > 0 do S1 := AlStringReplace(S1, '<#randomnumber>',inttostr(random(10)),[rfIgnoreCase]);
      for i := 1 to maxint do begin
        if AlPos('<#randomnumber'+inttostr(i)+'>', AlLowerCase(S1)) > 0 then S1 := AlStringReplace(S1, '<#randomnumber'+inttostr(i)+'>',inttostr(random(10)),[rfIgnoreCase, rfReplaceAll])
        else break;
      end;
      S1 := AlStringReplace(S1,#13#10,' ',[RfReplaceALL]);
      LstSql.Text := Trim(AlStringReplace(S1,';',#13#10,[RfReplaceALL]));

      //do the job
      aStartDate := ALGetTickCount64;
      aSqlite3Client.TransactionStart;
      try
        aSqlite3Client.UpdateData(LstSql);
        aEndDate := ALGetTickCount64;
        aStartCommitDate := ALGetTickCount64;
        aSqlite3Client.TransactionCommit;
        aendCommitDate := ALGetTickCount64;
      Except
        aSqlite3Client.TransactionRollBack;
        raise;
      end;

      ALMemoResult.Lines.clear;
      ALMemoResult.Lines.add('Time Taken to Update the data: ' + inttostr(aEndDate - aStartDate) + ' ms');
      ALMemoResult.Lines.add('Time Taken to commit the modifications: ' + inttostr(aendCommitDate - aStartCommitDate) + ' ms');

    Finally
      aSqlite3Client.disconnect;
      aSqlite3Client.free;
      LstSql.free;
    End;

  Finally
    Screen.Cursor := CrDefault;
  End;
end;

{************************************************************}
procedure TForm1.ALButtonSqlLite3SelectClick(Sender: TObject);
Var aSqlite3Client: TalSqlite3Client;
    aXMLDATA: TalXmlDocument;
    aStartDate: int64;
    aEndDate: int64;
    aFormatSettings: TformatSettings;
    S1: String;
    i: integer;
begin
  GetLocaleFormatSettings(1033, aFormatSettings);
  Screen.Cursor := CrHourGlass;
  try

    aSqlite3Client := TalSqlite3Client.Create(ALEditSqlite3lib.Text);
    Try

      //enable or disable the shared cache
      aSqlite3Client.enable_shared_cache(ALCheckBoxSqlite3SharedCache.Checked);

      //connect
      aSqlite3Client.connect(ALEditSqlite3Database.text);

      //the pragma
      aSqlite3Client.UpdateData('PRAGMA page_size = '+ALEditSqlite3Page_Size.Text);
      aSqlite3Client.UpdateData('PRAGMA encoding = "UTF-8"');
      aSqlite3Client.UpdateData('PRAGMA legacy_file_format = 0');
      aSqlite3Client.UpdateData('PRAGMA auto_vacuum = NONE');
      aSqlite3Client.UpdateData('PRAGMA cache_size = '+ALEditSqlite3Cache_Size.Text);
      case RadioGroupSqlite3Journal_Mode.ItemIndex of
        0: aSqlite3Client.UpdateData('PRAGMA journal_mode = DELETE');
        1: aSqlite3Client.UpdateData('PRAGMA journal_mode = TRUNCATE');
        2: aSqlite3Client.UpdateData('PRAGMA journal_mode = PERSIST');
        3: aSqlite3Client.UpdateData('PRAGMA journal_mode = MEMORY');
        4: aSqlite3Client.UpdateData('PRAGMA journal_mode = WAL');
        5: aSqlite3Client.UpdateData('PRAGMA journal_mode = OFF');
      end;
      aSqlite3Client.UpdateData('PRAGMA locking_mode = NORMAL');
      If ALCheckBoxSqlite3ReadUncommited.Checked then aSqlite3Client.UpdateData('PRAGMA read_uncommitted = 1');
      case RadioGroupSqlite3Synhcronous.ItemIndex of
        0: aSqlite3Client.UpdateData('PRAGMA synchronous = OFF');
        1: aSqlite3Client.UpdateData('PRAGMA synchronous = NORMAL');
        2: aSqlite3Client.UpdateData('PRAGMA synchronous = FULL');
      end;
      case RadioGroupSQLite3Temp_Store.ItemIndex of
        0: aSqlite3Client.UpdateData('PRAGMA temp_store = DEFAULT');
        1: aSqlite3Client.UpdateData('PRAGMA temp_store = FILE');
        2: aSqlite3Client.UpdateData('PRAGMA temp_store = MEMORY');
      end;

      //the sql
      aXMLDATA := ALCreateEmptyXMLDocument('root');
      Try

        With aXMLDATA Do Begin
          Options := [doNodeAutoIndent];
          ParseOptions := [poPreserveWhiteSpace];
        end;

        S1 := AlMemoSQLite3Query.Lines.Text;
        while AlPos('<#randomchar>', AlLowerCase(S1)) > 0 do S1 := AlStringReplace(S1, '<#randomchar>',AlRandomStr(1),[rfIgnoreCase]);
        while AlPos('<#randomnumber>', AlLowerCase(S1)) > 0 do S1 := AlStringReplace(S1, '<#randomnumber>',inttostr(random(10)),[rfIgnoreCase]);
        for i := 1 to maxint do begin
          if AlPos('<#randomnumber'+inttostr(i)+'>', AlLowerCase(S1)) > 0 then S1 := AlStringReplace(S1, '<#randomnumber'+inttostr(i)+'>',inttostr(random(10)),[rfIgnoreCase, rfReplaceAll])
          else break;
        end;

        aStartDate := ALGetTickCount64;
        aSqlite3Client.SelectData(S1,
                                  'rec',
                                   0,
                                   200,
                                  aXMLDATA.DocumentElement,
                                  aFormatSettings);
        aEndDate := ALGetTickCount64;

        ALMemoResult.Lines.Text := 'Time Taken to select the data: ' + inttostr(aEndDate - aStartDate) + ' ms' + #13#10 +
                                   #13#10 +
                                   trim (aXMLDATA.XML.Text);

      Finally
        aXMLDATA.free;
      End;

    Finally
      aSqlite3Client.disconnect;
      aSqlite3Client.free;
    End;

  Finally
    Screen.Cursor := CrDefault;
  End;
end;

{************************************************************}
procedure TForm1.ALButtonSqlLite3VacuumClick(Sender: TObject);
Var aSqlite3Client: TalSqlite3Client;
    aStartDate: int64;
    aEndDate: int64;
begin
  Screen.Cursor := CrHourGlass;
  try

    aSqlite3Client := TalSqlite3Client.Create(ALEditSqlite3lib.Text);
    Try

      //enable or disable the shared cache
      aSqlite3Client.enable_shared_cache(ALCheckBoxSqlite3SharedCache.Checked);

      //connect
      aSqlite3Client.connect(ALEditSqlite3Database.text);

      //the pragma
      aSqlite3Client.UpdateData('PRAGMA page_size = '+ALEditSqlite3Page_Size.Text);
      aSqlite3Client.UpdateData('PRAGMA encoding = "UTF-8"');
      aSqlite3Client.UpdateData('PRAGMA legacy_file_format = 0');
      aSqlite3Client.UpdateData('PRAGMA auto_vacuum = NONE');
      aSqlite3Client.UpdateData('PRAGMA cache_size = '+ALEditSqlite3Cache_Size.Text);
      case RadioGroupSqlite3Journal_Mode.ItemIndex of
        0: aSqlite3Client.UpdateData('PRAGMA journal_mode = DELETE');
        1: aSqlite3Client.UpdateData('PRAGMA journal_mode = TRUNCATE');
        2: aSqlite3Client.UpdateData('PRAGMA journal_mode = PERSIST');
        3: aSqlite3Client.UpdateData('PRAGMA journal_mode = MEMORY');
        4: aSqlite3Client.UpdateData('PRAGMA journal_mode = WAL');
        5: aSqlite3Client.UpdateData('PRAGMA journal_mode = OFF');
      end;
      aSqlite3Client.UpdateData('PRAGMA locking_mode = NORMAL');
      If ALCheckBoxSqlite3ReadUncommited.Checked then aSqlite3Client.UpdateData('PRAGMA read_uncommitted = 1');
      case RadioGroupSqlite3Synhcronous.ItemIndex of
        0: aSqlite3Client.UpdateData('PRAGMA synchronous = OFF');
        1: aSqlite3Client.UpdateData('PRAGMA synchronous = NORMAL');
        2: aSqlite3Client.UpdateData('PRAGMA synchronous = FULL');
      end;
      case RadioGroupSQLite3Temp_Store.ItemIndex of
        0: aSqlite3Client.UpdateData('PRAGMA temp_store = DEFAULT');
        1: aSqlite3Client.UpdateData('PRAGMA temp_store = FILE');
        2: aSqlite3Client.UpdateData('PRAGMA temp_store = MEMORY');
      end;

      //do the job
      aStartDate := ALGetTickCount64;
      aSqlite3Client.UpdateData('VACUUM');
      aEndDate := ALGetTickCount64;

      ALMemoResult.Lines.clear;
      ALMemoResult.Lines.add('Time Taken to VACUUM the database: ' + inttostr(aEndDate - aStartDate) + ' ms');

    Finally
      aSqlite3Client.disconnect;
      aSqlite3Client.free;
    End;

  Finally
    Screen.Cursor := CrDefault;
  End;
end;

end.
