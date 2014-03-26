ISOren
======
To rename files and directories to ISO level 2 or to DOS convention.

This program is published under the GNU General Public License.

Disclaimer
~~~~~~~~~~
You are using this program at your own risk. The the author gives no
warranty for the function or any others things affected by this program.
Under no circumstances the author is liable for any loss or damage supposed
to derive from the use of the program.

1) PM Version
~~~~~~~~~~~~~
ISOren.exe is the PM-Version. It needs the Watcom VX-Rexx runtime library
VROBJ.DLL.
At first select the drive with the listbox in the left of the window. This
indicates the reading of the directories of the selected drive, you see it
in the status line.
If this is complete you can select the directory in the listbox in the middle
of the window. Then you can change the filespec from '*.*' to another.
If you want to rename subdirs (!) and files in subdirs you can check the
appropriate checkbox. At least you have to select the ISO level.
Now you can press the "Rename" button to rename the files and / or directories.

2) Commandline version
~~~~~~~~~~~~~~~~~~~~~~
The commandline version is a standalone rexx script.

Usage: ISO [-sq21] <arg> ...

       -s  include subdirectories
       -q  do not print progress messages
       -2  translate to level 2 (max. 31, one point)
       -1  translate to level 1 (8.3)

Known bugs:
~~~~~~~~~~~
The <arg> parameter doesn't have spaces. Then there are no files found
to rename. This happens also in the PM version. But you can specify a path
that has subdirectories with spaces. If you check the "subdirs" checkbox
(parameter -S in commandline version) all subdirs with spaces are renamed.

Contact and Website:
~~~~~~~~~~~~~~~~~~~~
Thomas@Bohn-Stralsund.de
http://Bohn-Stralsund.de
