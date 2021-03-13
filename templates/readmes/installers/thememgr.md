## REPLACE_APPNAME
  
  DESCRIBE:
  
Requires scripts to be installed: sudo bash -c "$(curl -LSs https://github.com/thememgr/installer/raw/master/install.sh)" && sudo thememgr install installer  
Automatic install/update:    
```shell
thememgr install REPLACE_APPNAME
```
OR  
```shell
bash -c "$(curl -LSs https://github.com/thememgr/REPLACE_APPNAME/raw/master/install.sh)"
```
  
Manual install:  
```shell
git clone https://github.com/thememgr/REPLACE_APPNAME "$HOME/.local/share/CasjaysDev/thememgr/REPLACE_APPNAME"
rsync -avhP "$HOME/.local/share/CasjaysDev/thememgr/REPLACE_APPNAME/theme/." "$HOME/.local/share/themes/REPLACE_APPNAME" --delete
```
  
Manual update:  
```shell
git -C "$HOME/.local/share/CasjaysDev/thememgr/REPLACE_APPNAME" pull
rsync -avhP "$HOME/.local/share/CasjaysDev/thememgr/REPLACE_APPNAME/theme/." "$HOME/.local/share/themes/REPLACE_APPNAME" --delete
```

