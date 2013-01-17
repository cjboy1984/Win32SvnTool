@echo off
setlocal EnableDelayedExpansion

echo .-----------.
echo :  SvnTool  :
echo '-----------'

set WorkDrv=%CD:~0,2%
set DirListFile=%WorkDrv%\__dlist__.txt
set DirNumFile=%WorkDrv%\__dnum__.txt

if exist %DirListFile% del %DirListFile%
if exist %DirNumFile% del %DirNumFile%

REM ;; configure text editor, default is notepad.
REM set EDITOR=notepad

cd ..
call :BrowseDir
svn propedit svn:externals .
exit

:BrowseDir
set DirListFile=%WorkDrv%\__dlist__.txt
set DirNumFile=%WorkDrv%\__dnum__.txt
set Index=0

if exist %DirListFile% del %DirListFile%
if exist %DirNumFile% del %DirNumFile%
for /f "tokens=*" %%d in ('dir /b /a:d') do (
  set /a Index+=1
  echo [!Index!] %%d >> %DirListFile%
)

cls
echo ## Choose Directory ##
echo Now : %CD%
echo ==============================================
type %DirListFile%
echo ==============================================

set DirNum=
set /p DirNum="# Enter > "
find "[!DirNum!]" < %DirListFile% > %DirNumFile%
for /f "tokens=*" %%t in (%DirNumFile%) do (
  set WorkDir=%%t
  set WorkDir=!WorkDir:[%DirNum%] =!
)
cd "%WorkDir%"

@REM ;; Find into sub-directory
if not exist History.txt goto BrowseDir

del %DirNumFile%
del %DirListFile%
goto :eof