@echo off

pushd %~dp0

set UNZIPZIP=7za920.zip
set UNZIPDIR=7za920
set UNZIP=%UNZIPDIR%\7za
set VIMZIP=complete-x86.7z
set LUAZIP=lua-5.3.3_Win32_bin.zip
set VIMDIR=Vim80
set RGVER=0.8.1
set RGDIR=ripgrep-0.8.1
set RGZIP=ripgrep-0.8.1-i686-pc-windows-msvc.zip
set CTAGSVER=5.8
set CTAGSDIR=ctags58
set CTAGSZIP=ctags58.zip
set DOTFILESZIP=dotfiles.zip

:: Create Auxiliar Scripts
echo URL = WScript.Arguments(0) > download.vbs
echo saveTo = WScript.Arguments(1) >> download.vbs
echo Set objXMLHTTP = CreateObject("MSXML2.ServerXMLHTTP") >> download.vbs
echo objXMLHTTP.open "GET", URL, false >> download.vbs
echo objXMLHTTP.send() >> download.vbs
echo If objXMLHTTP.Status = 200 Then >> download.vbs
echo Set objADOStream = CreateObject("ADODB.Stream") >> download.vbs
echo objADOStream.Open >> download.vbs
echo objADOStream.Type = 1 'adTypeBinary >> download.vbs
echo objADOStream.Write objXMLHTTP.ResponseBody >> download.vbs
echo objADOStream.Position = 0    'Set the stream position to the start >> download.vbs
echo Set objFSO = Createobject("Scripting.FileSystemObject") >> download.vbs
echo If objFSO.Fileexists(saveTo) Then objFSO.DeleteFile saveTo >> download.vbs
echo Set objFSO = Nothing >> download.vbs
echo objADOStream.SaveToFile saveTo >> download.vbs
echo objADOStream.Close >> download.vbs
echo Set objADOStream = Nothing >> download.vbs
echo End if >> download.vbs
echo Set objXMLHTTP = Nothing >> download.vbs

echo set fso = CreateObject("Scripting.FileSystemObject") > unzip.vbs
echo pathToZipFile=fso.GetAbsolutePathName(Wscript.Arguments(0)) >> unzip.vbs
echo extractTo=fso.GetAbsolutePathName(Wscript.Arguments(1)) >> unzip.vbs
echo if not fso.FolderExists(extractTo) then >> unzip.vbs
echo fso.CreateFolder(extractTo) >> unzip.vbs
echo end if >> unzip.vbs
echo set sa = CreateObject("Shell.Application") >> unzip.vbs
echo set filesInzip=sa.NameSpace(pathToZipFile).items >> unzip.vbs
echo sa.NameSpace(extractTo).CopyHere filesInzip, 20 >> unzip.vbs

:: Download files
cscript download.vbs "http://7-zip.org/a/%UNZIPZIP%" %UNZIPZIP%
cscript download.vbs "http://tuxproject.de/projects/vim/%VIMZIP%" %VIMZIP%
cscript download.vbs "http://joedf.ahkscript.org/LuaBuilds/hdata/%LUAZIP%" %LUAZIP%
cscript download.vbs "https://github.com/BurntSushi/ripgrep/releases/download/%RGVER%/%RGZIP%" %RGZIP%
cscript download.vbs "http://ufpr.dl.sourceforge.net/project/ctags/ctags/%CTAGSVER%/%CTAGSZIP%" %CTAGSZIP%
cscript download.vbs "https://github.com/psicopep/dotfiles/archive/master/master.zip" %DOTFILESZIP%

:: Unzip
cscript unzip.vbs %UNZIPZIP% %UNZIPDIR%
%UNZIP% x %VIMZIP% -o%VIMDIR%
%UNZIP% x %LUAZIP% -o%VIMDIR%
%UNZIP% x %RGZIP% -o%RGDIR% rg.exe
%UNZIP% e %CTAGSZIP% -o%CTAGSDIR% %CTAGSDIR%/*.exe
%UNZIP% e %DOTFILESZIP% dotfiles-master/vim/*

:: Clean
del %UNZIPZIP% /q
rmdir %UNZIPDIR% /s /q
del %VIMZIP% /q
del %LUAZIP% /q
del %RGZIP% /q
del %CTAGSZIP% /q
del download.vbs /q
del unzip.vbs /q
del %DOTFILESZIP%

:: Install plugins
%VIMDIR%\vim -N -u NONE -S BundleMan.vim

popd
