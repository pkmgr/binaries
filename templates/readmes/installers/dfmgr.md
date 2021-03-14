## GEN_SCRIPT_REPLACE_APPNAME  
  
  DESCRIBE:  
  
Requires scripts to be installed: sudo bash -c "$(curl -LSs https://github.com/dfmgr/installer/raw/master/install.sh)" && sudo dfmgr install installer
  
Automatic install/update:
```shell
dfmgr install GEN_SCRIPT_REPLACE_APPNAME
```
OR
```shell
bash -c "$(curl -LSs https://github.com/dfmgr/GEN_SCRIPT_REPLACE_APPNAME/raw/master/install.sh)"
```
  
requirements:
  
Debian based:
```shell
apt install GEN_SCRIPT_REPLACE_APPNAME
```  

Fedora Based:
```shell
yum install GEN_SCRIPT_REPLACE_APPNAME
```  

Arch Based:
```shell
pacman -S GEN_SCRIPT_REPLACE_APPNAME
```  

MacOS:  
```shell
brew install GEN_SCRIPT_REPLACE_APPNAME
```
  
Manual install:  
  ```shell
APPDIR="$HOME/.local/share/CasjaysDev/dfmgr/GEN_SCRIPT_REPLACE_APPNAME"
mv -fv "$HOME/.config/GEN_SCRIPT_REPLACE_APPNAME" "$HOME/.config/GEN_SCRIPT_REPLACE_APPNAME.bak"
git clone https://github.com/dfmgr/GEN_SCRIPT_REPLACE_APPNAME "$APPDIR"
cp -Rfv "$APPDIR/etc/." "$HOME/.config/GEN_SCRIPT_REPLACE_APPNAME/"
[ -d "$APPDIR/bin" ] && cp -Rfv "$APPDIR/bin/." "$HOME/.local/bin/"
```
  
<p align=center>
   <a href="https://travis-ci.com/github/dfmgr/GEN_SCRIPT_REPLACE_APPNAME" target="_blank" rel="noopener noreferrer">
     <img src="https://travis-ci.com/dfmgr/GEN_SCRIPT_REPLACE_APPNAME.svg?branch=master" alt="Build Status"></a><br />
  <a href="https://wiki.archlinux.org/index.php/GEN_SCRIPT_REPLACE_APPNAME" target="_blank" rel="noopener noreferrer">GEN_SCRIPT_REPLACE_APPNAME wiki</a>  |  
  <a href="GEN_SCRIPT_REPLACE_APPNAME" target="_blank" rel="noopener noreferrer">GEN_SCRIPT_REPLACE_APPNAME site</a>
</p>  
