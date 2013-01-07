@REM ;; Copyright (c) 2004 - 2011, Boy.Wang <cjboy1984@gmail.com>                                   
@REM ;; All rights reserved.
@REM ;; 
@REM ;; README:
@REM ;; It's a tool runing on Win32 compatable system to help you export the changed files and directories based on svn.
@REM ;; It'll create two folders, "Original" for svn head repository and "Modify" for your working copy.
@REM ;; You may use a compare tool to check the result like BeyondCompare.

@echo off
setlocal EnableDelayedExpansion

echo .-----------.
echo :  SvnTool  :
echo '-----------'

set PATH=%PATH%;%CD%\bin

set BuildTime=%time:~0,5%
set BuildTime=%BuildTime: =0%
set BuildTime=%BuildTime::=%

set BuildDate=%date:~0,10%
set BuildDate=%BuildDate: =0%
set BuildDate=%BuildDate:/=-%

set WorkDrv=%CD:~0,2%

set SvnFile=%WorkDrv%\__svn__.txt
set DummyFile=%WorkDrv%\__dummy__.txt

echo.
set /p IBNum=Step 1. Enter IB######## : 
echo.
set OutputDir=%WorkDrv%\temp\%BuildDate%\%IBNum%-%BuildTime%

if exist %SvnFile% del %SvnFile%
if exist %DummyFile% del %DummyFile%
if exist %OutputDir% del %OutputDir%

if not exist %OutputDir%\ mkdir %OutputDir%
if not exist %OutputDir%\Modify\ mkdir %OutputDir%\Modify
if not exist %OutputDir%\Original\ mkdir %OutputDir%\Original

call :BrowseDir

@REM ;; svn change, read file line by line
echo f > %DummyFile%
svn status|findstr "^[AMD]" > %SvnFile%

for /f "tokens=*" %%i in (%SvnFile%) do (
  set FilePath=%%i
  set FilePath=!FilePath:~8!
  set FilePath=!FilePath:%CD%\=!
  call :ParseResult %%i !FilePath!
)

@REM ;; find svn:externals diff
cd %WorkDir%

set FileName=svn-externals.txt
svn info|findstr "URL:" > __svn.tmp
for /f "tokens=*" %%r in (__svn.tmp) do ( set "SvnRoot=%%r" )
set SvnRoot=%SvnRoot:URL: =%
del __svn.tmp

@svn diff|findstr "svn:externals"
if errorlevel 0 (
  svn propget svn:externals . > %OutputDir%\Modify\%FileName%
  svn propget svn:externals %SvnRoot% > %OutputDir%\Original\%FileName%
)

del %SvnFile%
del %DummyFile%
exit

:BrowseDir
cd ..
set DirListFile=%WorkDrv%\__dlist__.txt
set DirNumFile=%WorkDrv%\__dnum__.txt
set Index=0

if exist %DirListFile% del %DirListFile%
if exist %DirNumFile% del %DirNumFile%

for /f "tokens=*" %%d in ('dir /b /a:d') do (
  set /a Index+=1
  echo [!Index!] %%d >> %DirListFile%
)

echo =========================================
type %DirListFile%
echo =========================================

set DirNum=
set /p DirNum=Step 2. Choose a directory : 

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

:ParseResult
if %1==A (
  if exist "%2%\" (
    @mkdir %OutputDir%\Modify\%3
  ) else (
    @xcopy %3 %OutputDir%\Modify\%3 < %DummyFile%
  )
)
if %1==M (
  @xcopy %3 %OutputDir%\Modify\%3 < %DummyFile%
  call :ExportSvnFile %3
)
if %1==D (
  call :ExportSvnFile %3
)
goto :eof

:ExportSvnFile
call :GetFileDir %1
call :GetFileName %1

if not "!FileDir!\!FileName!"=="" (
  @mkdir !OutputDir!\Original\!FileDir!
  
  cd !FileDir!  
  call :GetDirSvnUrl
  @REM ;; svn export
  @svn export !SvnUrl!/!FileName! !OutputDir!\Original\!FileDir!
  cd !WorkDir!
)
goto :eof

:GetFileDir
set FileDir=%~dp1
set FileDir=!FileDir:%CD%\=!
goto :eof

:GetFileName
set FileName=%~nx1
goto :eof

:GetDirSvnUrl
@REM ;; get svn url
svn info|findstr "URL:" > __svn.tmp
for /f "tokens=*" %%i in (__svn.tmp) do set "SvnUrl=%%i"
set SvnUrl=!SvnUrl:URL: =!
del __svn.tmp
goto :eof