## REPLACE_APPNAME
  
  DESCRIBE:
  
Requires scripts to be installed: sudo bash -c "$(curl -LSs https://github.com/wallpapermgr/installer/raw/master/install.sh)" && sudo wallpapermgr install installer
Automatic install/update:  
```shell
wallpapermgr install REPLACE_APPNAME
```
OR  
```shell
bash -c "$(curl -LSs https://github.com/wallpapermgr/REPLACE_APPNAME/raw/master/install.sh)"
```
  
Manual install:  
```shell
git clone https://github.com/wallpapermgr/REPLACE_APPNAME "$HOME/.local/share/CasjaysDev/wallpapermgr/REPLACE_APPNAME"
rsync -avhP "$HOME/.local/share/CasjaysDev/wallpapermgr/REPLACE_APPNAME/images/." "$HOME/.local/share/wallpapers/REPLACE_APPNAME" --delete
```
  
Manual update:    
```shell
git -C "$HOME/.local/share/CasjaysDev/wallpapermgr/REPLACE_APPNAME" pull
rsync -avhP "$HOME/.local/share/CasjaysDev/wallpapermgr/REPLACE_APPNAME/images/." "$HOME/.local/share/wallpapers/REPLACE_APPNAME" --delete
```

