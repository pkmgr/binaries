## REPLACE_APPNAME
  
  DESCRIBE:  
  
Requires scripts to be installed: sudo bash -c "$(curl -LSs https://github.com/fontmgr/installer/raw/master/install.sh)" && sudo fontmgr install installer  
Automatic install/update:
```shell
fontmgr install REPLACE_APPNAME
```
OR  
```shell
bash -c "$(curl -LSs https://github.com/fontmgr/REPLACE_APPNAME/raw/master/install.sh)"
```
  
Manual install:  
```shell
git clone https://github.com/fontmgr/REPLACE_APPNAME "$HOME/.local/share/CasjaysDev/fontmgr/REPLACE_APPNAME"
rsync -avhP "$HOME/.local/share/CasjaysDev/fontmgr/REPLACE_APPNAME/fonts/." "$HOME/.local/share/fonts/REPLACE_APPNAME" --delete
```
  
Manual update:    
```shell
git -C "$HOME/.local/share/CasjaysDev/fontmgr/REPLACE_APPNAME" pull
rsync -avhP "$HOME/.local/share/CasjaysDev/fontmgr/REPLACE_APPNAME/fonts/." "$HOME/.local/share/fonts/REPLACE_APPNAME" --delete
```

