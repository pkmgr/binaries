## REPLACE_APPNAME  
  
  DESCRIBE:  
  
Requires scripts to be installed: sudo bash -c "$(curl -LSs https://github.com/dfmgr/installer/raw/master/install.sh)" && sudo dfmgr install installer
  
Automatic install/update:
```shell
dfmgr install REPLACE_APPNAME
```
OR
```shell
bash -c "$(curl -LSs https://github.com/dfmgr/REPLACE_APPNAME/raw/master/install.sh)"
```
  
requirements:
  
Debian based:
```shell
apt install REPLACE_APPNAME
```  

Fedora Based:
```shell
yum install REPLACE_APPNAME
```  

Arch Based:
```shell
pacman -S REPLACE_APPNAME
```  

MacOS:  
```shell
brew install REPLACE_APPNAME
```
  
Manual install:  
  ```shell
APPDIR="$HOME/.local/share/CasjaysDev/dfmgr/REPLACE_APPNAME"
mv -fv "$HOME/.config/REPLACE_APPNAME" "$HOME/.config/REPLACE_APPNAME.bak"
git clone https://github.com/dfmgr/REPLACE_APPNAME "$APPDIR"
cp -Rfv "$APPDIR/etc/." "$HOME/.config/REPLACE_APPNAME/"
[ -d "$APPDIR/bin" ] && cp -Rfv "$APPDIR/bin/." "$HOME/.local/bin/"
```
  
<p align=center>
   <a href="https://travis-ci.com/github/dfmgr/REPLACE_APPNAME" target="_blank" rel="noopener noreferrer">
     <img src="https://travis-ci.com/dfmgr/REPLACE_APPNAME.svg?branch=master" alt="Build Status"></a><br />
  <a href="https://wiki.archlinux.org/index.php/REPLACE_APPNAME" target="_blank" rel="noopener noreferrer">REPLACE_APPNAME wiki</a>  |  
  <a href="REPLACE_APPNAME" target="_blank" rel="noopener noreferrer">REPLACE_APPNAME site</a>
</p>  

