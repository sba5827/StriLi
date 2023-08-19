@ECHO OFF
cd Tests
ECHO "%~1" > _path.txt
cd Framework
lua54.exe GenerateTestFile.lua
cd ..
IF EXIST "_path.txt" DEL "_path.txt"
pause