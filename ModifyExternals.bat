@echo off

REM ;; configure text editor, default is notepad.
REM set EDITOR=notepad

cd ..
svn propedit svn:externals %CD%
exit