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

call :BrowseDir
svn propedit svn:externals .
exit

:BrowseDir
cd ..
set Index=0
for /f "tokens=*" %%d in ('dir /b /a:d') do (
  set /a Index+=1
  echo [!Index!] %%d >> %DirListFile%
)

echo =========================================
type %DirListFile%
echo =========================================

set DirNum=
set /p DirNum=Step 1. Choose a directory : 

find "[!DirNum!]" < %DirListFile% > %DirNumFile%
for /f "tokens=*" %%t in (%DirNumFile%) do (
  set WorkDir=%%t
  set WorkDir=!WorkDir:[%DirNum%] =!
)
cd %WorkDir%
set WorkDir=%CD%

del %DirListFile%
del %DirNumFile%
goto :eof