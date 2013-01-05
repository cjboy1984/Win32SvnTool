@ ModifyExternals.bat
=====================================================================
Edit the config file (\Users\YourUserName\AppData\Roaming\Subversion), uncomment the editor-cmd line and specify notepad++ as follows:

editor-cmd = "C:\Program Files (x86)\Notepad++\notepad++.exe" -nosession -multiInst

Note I am running 64-Bit windows 7. If you are on 32-bit your exe will be in /Program Files without the (x86) part. The "multiInst" parameter forces notepad++ to open as a new process. So now svn will properly wait for you to exit that window. The "nosession" parameter tells it not to load up the last session. Even though I have it configured to not use sessions current, I may change my mind and start using them. I wouldn't want a bunch of tabs to open just to edit my svn message or property.