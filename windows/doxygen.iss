; InnoSetup script to create doxygen installer for running in GitHub action
; r: should point to the root of GitHub action
; r:\doxygen should point to the source directory
; r:\doxygen-install should point to the installation directory
; $VERSION is a placeholder that needs to be replaced

[Setup]
; Source and Output directories for the compiler:
SourceDir=r:
OutputDir=r:\installer\
; Required information about doxygen
AppName=doxygen
AppVerName=doxygen $VERSION
DefaultDirName={commonpf}\doxygen
; Other standard information about doxygen:
AppPublisher=Dimitri van Heesch
AppPublisherURL=http://www.doxygen.org
AppSupportURL=http://www.doxygen.org
AppUpdatesURL=http://www.doxygen.org
AppVersion=$VERSION
; Configuration of the installer executable:
OutputBaseFilename=doxygen-$VERSION-setup
Compression=bzip/9
LicenseFile=r:\doxygen\LICENSE
InfoAfterFile=r:\doxygen\README.md
DisableStartupPrompt=yes
; Other useful settings for the installation:
AllowRootDirectory=no
DefaultGroupName=doxygen
AllowNoIcons=yes
; AlwaysCreateUninstallIcon=yes
UninstallFilesDir={app}\system
ChangesEnvironment=true
ArchitecturesInstallIn64BitMode=x64compatible

[Types]
; Defines which types of installation are possible
Name: "full";     Description: "Full Installation"
Name: "minimum";  Description: "Minimum Installation"
Name: "custom";   Description: "Custom Installation"; Flags: iscustom

[Components]
; Defines collections of files, and the types of installation they can be included in
Name: "main";      Description: "doxygen Core Installation"; Types: full minimum custom; Flags: fixed
Name: "gui";       Description: "doxywizard GUI"; Types: full custom
Name: "docs_html"; Description: "doxygen manual (HTML)"; Types: full custom
Name: "docs_chm";  Description: "doxygen manual (compressed HTML)";  Types: full custom
Name: "examples";  Description: "doxygen Example Projects"; Types: full custom

[Files]
; Defines the files to include, and which installation components they are to be included in
Source: "r:\doxygen-install\share\doc\packages\doxygen\html\*.html";        DestDir: "{app}\html";          Flags: promptifolder;                Components: docs_html;
Source: "r:\doxygen-install\share\doc\packages\doxygen\html\*.svg";         DestDir: "{app}\html";          Flags: promptifolder;                Components: docs_html;
Source: "r:\doxygen-install\share\doc\packages\doxygen\html\*.png";         DestDir: "{app}\html";          Flags: promptifolder;                Components: docs_html;
Source: "r:\doxygen-install\share\doc\packages\doxygen\html\*.css";         DestDir: "{app}\html";          Flags: promptifolder;                Components: docs_html;
Source: "r:\doxygen-install\share\doc\packages\doxygen\html\*.js";          DestDir: "{app}\html";          Flags: promptifolder;                Components: docs_html;
Source: "r:\doxygen-install\share\doc\packages\doxygen\html\search\*";      DestDir: "{app}\html\search";   Flags: promptifolder recursesubdirs; Components: docs_html;
Source: "r:\doxygen-install\share\doc\packages\doxygen\html\examples\*";    DestDir: "{app}\html\examples"; Flags: promptifolder recursesubdirs; Components: docs_html;
Source: "r:\doxygen-install\share\doc\packages\doxygen\*.chm";              DestDir: "{app}";               Flags: promptifolder;                Components: docs_chm;
Source: "r:\doxygen\examples\*";                                            DestDir: "{app}\examples";      Flags: promptifolder recursesubdirs; Components: examples;
Source: "r:\doxygen-install\bin\doxygen.exe";                               DestDir: "{app}\bin";           Flags: promptifolder;                Components: main;
Source: "r:\doxygen-install\bin\libclang.dll";                              DestDir: "{app}\bin";           Flags: promptifolder;                Components: main;
Source: "r:\doxygen-install\bin\doxysearch.cgi.exe";                        DestDir: "{app}\bin";           Flags: promptifolder;                Components: main;
Source: "r:\doxygen-install\bin\doxyindexer.exe";                           DestDir: "{app}\bin";           Flags: promptifolder;                Components: main;
Source: "r:\doxygen-install\bin\doxywizard.exe";                            DestDir: "{app}\bin";           Flags: promptifolder;                Components: gui;

[INI]
; Create an internet shortcut to the doxygen web site, for inclusion on the Start menu
; (An internet shortcut is actually just a specialised INI file.)
Filename: "{app}\system\doxygen.url"; Section: "InternetShortcut"; Key: "URL"; String: "https://www.doxygen.org"

[Icons]
; Adds icons to the Start menu. This section has to be here, but the user can
; choose not to install any icons if that is their wish.
Name: "{group}\Doxygen on the Web";                      Filename: "{app}\system\doxygen.url"; Flags: createonlyiffileexists
Name: "{group}\Doxygen documentation (HTML)";            Filename: "{app}\html\index.html"; Components: docs_html; Flags: createonlyiffileexists
Name: "{group}\Doxygen documentation (compressed HTML)"; Filename: "{app}\doxygen_manual.chm"; Components: docs_chm; Flags: createonlyiffileexists
Name: "{group}\Examples Folder";                         Filename: "{app}\examples\"; Components: examples
Name: "{group}\Doxywizard";                              FileName: "{app}\bin\doxywizard.exe"; Comment: "GUI front-end for creating configuration files"; Components: gui;
Name: "{group}\Uninstall doxygen";                       FileName: "{uninstallexe}"

[InstallDelete]
Type: files; Name: "{app}\bin\libclang.dll"

[UninstallDelete]
; This file has to deleted explicitly in the uninstall because it was
; created by the installer rather than just copied into place.
Type: files; Name: "{app}\system\doxygen.url"

[code]

const EnvironmentKey = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';

procedure EnvAddPath(Path: string);
var
    Paths: string;
begin
    { Retrieve current path (use empty string if entry not exists) }
    if not RegQueryStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths)
    then Paths := '';

    { Skip if string already found in path }
    if Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths) + ';') > 0 then exit;

    { App string to the end of the path variable }
    Paths := Paths + ';'+ Path +';'

    { Overwrite (or create if missing) path environment variable }
    if RegWriteStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths)
    then Log(Format('The [%s] added to PATH: [%s]', [Path, Paths]))
    else Log(Format('Error while adding the [%s] to PATH: [%s]', [Path, Paths]));
end;

procedure EnvRemovePath(Path: string);
var
    Paths: string;
    P: Integer;
begin
    { Skip if registry entry not exists }
    if not RegQueryStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths) then
        exit;

    { Skip if string not found in path }
    P := Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths) + ';');
    if P = 0 then exit;

    { Update path variable }
    Delete(Paths, P - 1, Length(Path) + 1);

    { Overwrite path environment variable }
    if RegWriteStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths)
    then Log(Format('The [%s] removed from PATH: [%s]', [Path, Paths]))
    else Log(Format('Error while removing the [%s] from PATH: [%s]', [Path, Paths]));
end;


procedure CurStepChanged(CurStep: TSetupStep);
begin
    if CurStep = ssPostInstall 
    then EnvAddPath(ExpandConstant('{app}') +'\bin');
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
    if CurUninstallStep = usPostUninstall
    then EnvRemovePath(ExpandConstant('{app}') +'\bin');
end;
