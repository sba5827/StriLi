for %%i in ("%~dp0..") do set "folder=%%~fi"

set TEMPDIR=%folder%\temp738
rmdir %TEMPDIR%
mkdir %TEMPDIR%

set FILETOZIP=%~dp0*.lua
xcopy %FILETOZIP% %TEMPDIR%\StriLi\ /Y

set FILETOZIP=%~dp0*.xml
xcopy %FILETOZIP% %TEMPDIR%\StriLi\ /Y

set FILETOZIP=%~dp0*.md
xcopy %FILETOZIP% %TEMPDIR%\StriLi\ /Y

set FILETOZIP=%~dp0*.toc
xcopy %FILETOZIP% %TEMPDIR%\StriLi\ /Y

set FILETOZIP=%~dp0*.blp
xcopy %FILETOZIP% %TEMPDIR%\StriLi\ /Y

set FILETOZIP=%~dp0LICENSE
xcopy %FILETOZIP% %TEMPDIR%\StriLi\ /Y

set FILETOZIP=%~dp0Libs
xcopy %FILETOZIP% %TEMPDIR%\StriLi\Libs\ /E /Y

set FILETOZIP=%~dp0Lang
xcopy %FILETOZIP% %TEMPDIR%\StriLi\Lang\ /E /Y

echo Set objArgs = WScript.Arguments > _zipIt.vbs
echo InputFolder = objArgs(0) >> _zipIt.vbs
echo ZipFile = objArgs(1) >> _zipIt.vbs
echo CreateObject("Scripting.FileSystemObject").CreateTextFile(ZipFile, True).Write "PK" ^& Chr(5) ^& Chr(6) ^& String(18, vbNullChar) >> _zipIt.vbs
echo Set objShell = CreateObject("Shell.Application") >> _zipIt.vbs
echo Set source = objShell.NameSpace(InputFolder).Items >> _zipIt.vbs
echo objShell.NameSpace(ZipFile).CopyHere(source) >> _zipIt.vbs
echo wScript.Sleep 2000 >> _zipIt.vbs

CScript  _zipIt.vbs  %TEMPDIR%  %~dp0StriLi.zip

del /s /f /q %TEMPDIR%\*.*
for /f %%f in ('dir /ad /b %TEMPDIR%') do rd /s /q %TEMPDIR%\%%f

rd /s /q %TEMPDIR%

del %~dp0_zipIt.vbs

pause