REM ;; Copyright (c) 2004 - 2011, Boy.Wang <cjboy1984@gmail.com>                                   
REM ;; All rights reserved.
REM ;; 
REM ;; README:
REM ;; It's a tool runing on Win32 compatable system to help you export the changed files and directories based on svn.
REM ;; It'll create two folders, "Original" for svn head repository and "Modify" for your working copy.
REM ;; You may use a compare tool to check the result like BeyondCompare.

@echo off

set PATH=%PATH%;%CD%\bin
set BuildTime=%time:~0,2%-%time:~3,2%-%time:~6,2%
set BuildDate=%date:~6,4%-%date:~0,2%-%date:~3,2%
set OutputDir=D:\temp\%BuildDate%\%BuildTime%-IB1216####
set TmpFile=C:\__tmp__.txt
set DummyFile=C:\__dummy__.txt

if not exist %OutputDir% mkdir %OutputDir%
if not exist %OutputDir%\Modify mkdir %OutputDir%\Modify
if not exist %OutputDir%\Original mkdir %OutputDir%\Original

cd ..
set WorkDir=%CD%

REM ;; svn change, read file line by line
setlocal ENABLEDELAYEDEXPANSION
echo f > %DummyFile%
svn status|grep "^[AMD]" > %TmpFile%

for /f "tokens=*" %%i in (%TmpFile%) do (
  set FilePath=%%i
  set FilePath=!FilePath:~8!
  set FilePath=!FilePath:%CD%\=!
  call :ParseResult %%i !FilePath!
)

echo.
echo ======================= Result =======================
for /f "tokens=*" %%i in (%TmpFile%) do (
  echo %%i
)
echo ======================================================
echo.

del %TmpFile%
del %DummyFile%
pause

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
if not "!FileDir!"=="" (
  @mkdir !OutputDir!\Original\!FileDir!
  
  cd !FileDir!
  call :GetDirSvnUrl
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
REM ;; get svn url
svn info|grep "URL:" > __svn.tmp
for /f "tokens=*" %%i in (__svn.tmp) do set "SvnRoot=%%i"
set SvnRoot=!SvnRoot:URL: =!

REM ;; svn export
@svn export !SvnRoot!/!FileName! !OutputDir!\Original\!FileDir!
goto :eof