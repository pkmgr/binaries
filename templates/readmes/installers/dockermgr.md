## REPLACE_APPNAME
  
  DESCRIBE:  
  
Requires scripts to be installed: sudo bash -c "$(curl -LSs https://github.com/dockermgr/installer/raw/master/install.sh)" && sudo dockermgr install installer  
Automatic install/update:  
```shell
dockermgr install REPLACE_APPNAME
```
OR
```shell
bash -c "$(curl -LSs https://github.com/dockermgr/REPLACE_APPNAME/raw/master/install.sh)"
```
  
Manual install:    
```shell
git clone https://github.com/dockermgr/REPLACE_APPNAME "$HOME/.local/share/CasjaysDev/dockermgr/REPLACE_APPNAME"
bash -c "$HOME/.local/share/CasjaysDev/dockermgr/REPLACE_APPNAME/install.sh"
```
  
Manual update:   
```shell
git -C "$HOME/.local/share/CasjaysDev/dockermgr/REPLACE_APPNAME" pull
bash -c "$HOME/.local/share/CasjaysDev/dockermgr/REPLACE_APPNAME/install.sh"
```

