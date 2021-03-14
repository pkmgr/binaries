## GEN_SCRIPT_REPLACE_APPNAME
  
  DESCRIBE:  
  
Requires scripts to be installed: sudo bash -c "$(curl -LSs https://github.com/fontmgr/installer/raw/master/install.sh)" && sudo fontmgr install installer  
Automatic install/update:
```shell
fontmgr install GEN_SCRIPT_REPLACE_APPNAME
```
OR  
```shell
bash -c "$(curl -LSs https://github.com/fontmgr/GEN_SCRIPT_REPLACE_APPNAME/raw/master/install.sh)"
```
  
Manual install:  
```shell
git clone https://github.com/fontmgr/GEN_SCRIPT_REPLACE_APPNAME "$HOME/.local/share/CasjaysDev/fontmgr/GEN_SCRIPT_REPLACE_APPNAME"
rsync -avhP "$HOME/.local/share/CasjaysDev/fontmgr/GEN_SCRIPT_REPLACE_APPNAME/fonts/." "$HOME/.local/share/fonts/GEN_SCRIPT_REPLACE_APPNAME" --delete
```
  
Manual update:    
```shell
git -C "$HOME/.local/share/CasjaysDev/fontmgr/GEN_SCRIPT_REPLACE_APPNAME" pull
rsync -avhP "$HOME/.local/share/CasjaysDev/fontmgr/GEN_SCRIPT_REPLACE_APPNAME/fonts/." "$HOME/.local/share/fonts/GEN_SCRIPT_REPLACE_APPNAME" --delete
```
