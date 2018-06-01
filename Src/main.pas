unit main;

interface

uses
  Winapi.windows, Winapi.Messages, System.SysUtils, System.Types,
  System.UITypes,
  System.Classes, System.Variants, FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs, FMX.StdCtrls, FMX.Edit, FMX.ScrollBox, FMX.Memo,
  FMX.Controls.Presentation, DosCommand, FMX.WebBrowser, FMX.TabControl,
  FMX.Layouts, System.IOUtils;

type
  Tfmmain = class(TForm)
    DosCommand1: TDosCommand;
    Button1: TButton;
    Memo1: TMemo;
    Edit1: TEdit;
    SpeedButton1: TSpeedButton;
    OpenDialog1: TOpenDialog;
    Label2: TLabel;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Memo2: TMemo;
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Splitter1: TSplitter;
    Button2: TButton;
    WebBrowser1: TWebBrowser;
    Layout4: TLayout;
    Memo3: TMemo;
    ToolBar1: TToolBar;
    SpeedButton2: TSpeedButton;
    StyleBook1: TStyleBook;
    Label1: TLabel;
    Label3: TLabel;
    AniIndicator1: TAniIndicator;

    procedure SpeedButton1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Memo3ChangeTracking(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DosCommand1Terminated(Sender: TObject);

  private
    finaldir: string;
    newdir: string;
    pasdir: string;
    AFile: string;
    BaseDir: String;
    procedure makeTestfile(dir: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmmain: Tfmmain;
  maindir: string;

implementation

{$R *.fmx}

procedure DeleteFiles(APath, AFileSpec: string);
var
  lSearchRec: TSearchRec;
  lPath: string;
begin
  lPath := IncludeTrailingPathDelimiter(APath);

  if FindFirst(lPath + AFileSpec, faAnyFile, lSearchRec) = 0 then
  begin
    try
      repeat
        DeleteFile(lPath + lSearchRec.Name);
      until FindNext(lSearchRec) <> 0;
    finally
      FindClose(lSearchRec); // Free up resources on successful find
    end;
  end;
end;

procedure Tfmmain.Button1Click(Sender: TObject);
var
  xs, ns, SX: string;
  extlen: integer;
  value: integer;
  ToProcess: String;
  cmddir: string;
begin
  Button1.Enabled := false;
  SpeedButton1.Enabled := false;
  AniIndicator1.Visible := true;
  AniIndicator1.Enabled := true;
  finaldir := '';
  if DosCommand1.IsRunning then
    DosCommand1.Stop;

  Memo3.Lines.add('Preparing to Run');
  sleep(50);
  Memo3.Lines.add('FileDirectory and file to Process: ' + Edit1.text);
  sleep(50);
  DosCommand1.InputtoOutput := false;
  DosCommand1.MaxTimeAfterBeginning := 1;
  DosCommand1.MaxTimeAfterLastOutput := 30;
  // allows the app to save the pas file
  Memo3.Lines.add('Opening Commandfile :' + GetEnvironmentVariable
    ('COMSPEC') + '...');
  DosCommand1.CommandLine := GetEnvironmentVariable('COMSPEC');
  // opens the CMD.exe
  Memo3.Lines.add('Executing Process...');
  sleep(50);
  Memo3.Lines.add('Parsing the file...');
  Application.processmessages;
  // force CMD.exe to open fully especially for slow machines
  DosCommand1.Execute; // execute the cmd.exe
  sleep(500);
  if fileexists(extractfiledir(paramstr(0) + '\TEST.C')) = false then
    makeTestfile(maindir); // make the file
  ToProcess := 'C2PAS32 ' + extractfilename(BaseDir);
  DosCommand1.SendLine(ToProcess, true); // back to c dir
  DosCommand1.SendLine('', true); // equivalent to press enter key
  sleep(100);
end;

procedure Tfmmain.Button2Click(Sender: TObject);
begin
  TabControl1.ActiveTab := TabItem2;
end;

procedure Tfmmain.DosCommand1Terminated(Sender: TObject);
var
  xs, ns, SX: string;
  extlen: integer;
  i: integer;
begin
  Memo3.Lines.add('Process completing...');

  Memo3.Lines.add('Creating new file...');
  sleep(100);
  if extractfilename(BaseDir) = 'TEST.C' then
  begin
    finaldir := extractfiledir(paramstr(0)) + '\TEST_C.pas';
    Label1.text := 'C2PAS32 - Output file  ' + finaldir;
  end
  else
  begin
    xs := extractfileext(BaseDir);
    extlen := length(xs);
    newdir := BaseDir.Substring(0, BaseDir.length - (extlen));

    Delete(xs, 1, 1);
    newdir := newdir + '_' + xs + '.pas';
    pasdir := newdir;
    sleep(300);
    finaldir := extractfiledir(AFile) + Tpath.DirectorySeparatorChar +
      ChangeFileExt(extractfilename(AFile), '_' + xs + '.pas');
    Label1.text := 'C2PAS32 - Output file  ' + newdir;
    if fileexists(finaldir) then // in final path

      DeleteFile(finaldir);

    Tfile.Move(pasdir, finaldir);
    // move to the final folder where c,cpp or h file found

    if fileexists(pasdir) then // in final path
      DeleteFile(pasdir); // deletefile in C232pas folder if processed before
  end;

  Memo3.Lines.add('File Directory: ' + finaldir);
  sleep(500);
  Memo3.Lines.add('Loading the "pas" translated file');

  OpenDialog1.Initialdir := AFile;
  AniIndicator1.Enabled := false;
  AniIndicator1.Visible := false;
  if fileexists(finaldir) then
  begin
    Memo2.Lines.LoadFromFile(finaldir)
  end
  else
  begin
    showmessage(' Did not convert');
  end;

  Label3.text := 'Total Converted Lines: ' + inttostr(Memo2.Lines.Count);
  if fileexists(BaseDir) then // check if basefile .c / .h exists
    DeleteFile(BaseDir); // delete basefile .c /.h
  Button1.Enabled := true;
  SpeedButton1.Enabled := true;
end;

procedure Tfmmain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FormDestroy(self);
end;

procedure Tfmmain.FormDestroy(Sender: TObject);
begin
  fmmain := nil;
end;

procedure Tfmmain.FormResize(Sender: TObject);
begin
  Layout1.Width := fmmain.Width div 2;
end;

procedure Tfmmain.FormShow(Sender: TObject);
var
  cdir: string;
begin
  AniIndicator1.Visible := true;
  maindir := '';
  cdir := '';
  BaseDir := '';
  maindir := extractfiledir(paramstr(0)) + '\';
  // clean up folder  - delete any .pas files or special .~as in the C2PAS32 before processing
  DeleteFiles(maindir, '*.pas');
  DeleteFiles(maindir, '*.~as');
  DeleteFiles(maindir, '*.h');
  DeleteFiles(maindir, '*.c');
  DeleteFiles(maindir, '*.cpp');

  OpenDialog1.Initialdir := cdir;
  Label1.text := 'C2PAS32';
  WebBrowser1.URL := 'file://' + maindir + 'c2pas32.htm';
  Edit1.text := maindir + 'TEST.C';
  if fileexists(Edit1.text) = false then // file deleted
    makeTestfile(maindir); // make the file

  BaseDir := Edit1.text;
  Memo1.Lines.LoadFromFile(BaseDir);
  Memo3.EnabledScroll := true;
  TabControl1.ActiveTab := TabItem1;
  Label3.text := 'Total Converting Lines: ' + inttostr(Memo1.Lines.Count);
end;

procedure Tfmmain.makeTestfile(dir: string);
var
  newfile: string;
begin
  if not fileexists(dir) then
  begin
    newfile :=
      '    BOOL APIENTRY DlgProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)  '
      + #13#10 + '{               ' + #13#10 + '	switch (msg) {      ' + #13#10
      + '		case WM_INITDIALOG:  ' + #13#10 + '			static int a;   ' + #13#10
      + '	 		return TRUE;  ' + #13#10 + '                   ' + #13#10 +
      '	case WM_CLOSE:   ' + #13#10 + '		int b;    ' + #13#10 +
      '		EndDialog(hwnd, IDOK);    ' + #13#10 + '		break;   ' + #13#10 +
      '              ' + #13#10 + '       case WM_COMMAND: ' + #13#10 +
      '           switch (LOWORD(wParam)) {  ' + #13#10 +
      '               case IDC_EXIT:      ' + #13#10 +
      '                    EndDialog(hwnd, IDOK); ' + #13#10 +
      '                    break;        ' + #13#10 +
      '               case IDCANCEL:    ' + #13#10 +
      '                    EndDialog(hwnd, IDCANCEL);   ' + #13#10 +
      '			break;                    ' + #13#10 + '           }       ' +
      #13#10 + '           break;  ' + #13#10 + '   }    ' + #13#10 +
      '    return FALSE; ' + #13#10 + '}  ';

    Tfile.writealltext(dir + 'TEST.C', newfile);
  end;
end;

procedure Tfmmain.Memo3ChangeTracking(Sender: TObject);
begin
  Memo3.ScrollBy(0, 21);
end;

procedure Tfmmain.SpeedButton1Click(Sender: TObject);
begin
  if DosCommand1.IsRunning then
    DosCommand1.Stop;

  Label3.text := '';;
  BaseDir := '';

  if OpenDialog1.Execute then
  begin
    Edit1.text := '';
    OpenDialog1.Title := 'Select a C,CPP or H file to Process';
    Edit1.text := OpenDialog1.FileName;
    AFile := Edit1.text;

    BaseDir := maindir + extractfilename(OpenDialog1.FileName);

  Memo3.Lines.Clear;
  Memo2.Lines.Clear;
  sleep(100);
  Memo3.Lines.add('Loading File: ' + BaseDir);
  sleep(100);

  if AFile = (maindir + 'TEST.C') then
  begin
    Memo1.Lines.Clear;
    Edit1.text := AFile;
    sleep(100);
    Memo1.Lines.LoadFromFile(AFile);
    BaseDir := Edit1.text;
  end
  else
  begin
    Memo3.Lines.add('Copying original ' + extractfilename(BaseDir) +
      ' to parse');
    Tfile.Copy(AFile, BaseDir); // copy the file to based directory to parse
    sleep(100);
    Memo1.Lines.Clear;
    Memo1.Lines.LoadFromFile(BaseDir);
    Memo3.Lines.add('File ready to Convert to Pas File');
  end;

  Label1.text := 'C2PAS32';
  Label3.text := 'Original File Size: ' + inttostr(Memo1.Lines.Count);
  sleep(100);
  Memo3.Lines.add('Opening Base File...');
  sleep(100);
  end
  else
  begin
    exit;
  end;
 end;

procedure Tfmmain.SpeedButton2Click(Sender: TObject);
begin
  TabControl1.ActiveTab := TabItem1;
end;

end.
