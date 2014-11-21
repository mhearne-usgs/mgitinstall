https://github.com/mhearne-usgs/mgitinstallmgitinstaller 

This script allows the user to download Matlab repositories (packages) of code from GitHub.

Using this script does NOT require the use of git (although it can be used)

Methods for installing the gitinstall.m function:

* git clone https://github.com/mhearne-usgs/mgitinstall.git
  - Then add the folder "mgitinstall" that was just created to your Matlab path.
* Click on the "Download zip" button on the right side of this page.  Unpack zip file, add resulting folder to Matlab path.
* Click on the "gitinstall.m" link above, then click on the "Raw" button above the file contents.  Then save the file to a folder in your Matlab path using "File->Save Page As" (or equivalent) in your browser. 

Usage:

 gitinstall - Install a Matlab package from a GitHub repository URL.
 Usage:
 gitinstall https://github.com/mhearne-usgs/mgitinstall
 The first time this function is called, you will be prompted to select
 a folder where this and all other future packages will be installed.



