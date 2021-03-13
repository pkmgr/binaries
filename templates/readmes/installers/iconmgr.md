## REPLACE_APPNAME
  
  DESCRIBE:  
  
Requires scripts to be installed: sudo bash -c "$(curl -LSs https://github.com/iconmgr/installer/raw/master/install.sh)" && sudo iconmgr install installer
Automatic install/update:  
```shell
iconmgr install REPLACE_APPNAME
```
OR  
```shell
bash -c "$(curl -LSs https://github.com/iconmgr/REPLACE_APPNAME/raw/master/install.sh)"
```
  
Manual install:    
```shell
git clone https://github.com/iconmgr/REPLACE_APPNAME "$HOME/.local/share/CasjaysDev/iconmgr/REPLACE_APPNAME"
rsync -avhP "$HOME/.local/share/CasjaysDev/iconmgr/REPLACE_APPNAME/icons/." "$HOME/.local/share/icons/REPLACE_APPNAME" --delete
```
  
Manual update:  
```shell
git -C "$HOME/.local/share/CasjaysDev/iconmgr/REPLACE_APPNAME" pull
rsync -avhP "$HOME/.local/share/CasjaysDev/iconmgr/REPLACE_APPNAME/icons/." "$HOME/.local/share/icons/REPLACE_APPNAME" --delete
```

