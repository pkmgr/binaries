## ProjectName  
  
DESCRIBE  
  
Automatic install/update:

```shell
bash -c "$(curl -LSs https://github.com/dfmgr/ProjectName/raw/master/install.sh)"
```

Manual install:
  
requires:

Debian based:

```shell
apt install ProjectName
```  

Fedora Based:

```shell
yum install ProjectName
```  

Arch Based:

```shell
pacman -S ProjectName
```  

MacOS:  

```shell
brew install ProjectName
```
  
```shell
mv -fv "$HOME/.config/ProjectName" "$HOME/.config/ProjectName.bak"
git clone https://github.com/dfmgr/ProjectName "$HOME/.config/ProjectName"
```
  
<p align=center>
   <a href="https://travis-ci.com/github/dfmgr/ProjectName" target="_blank" rel="noopener noreferrer">
     <img src="https://travis-ci.com/dfmgr/ProjectName.svg?branch=master" alt="Build Status"></a><br />
  <a href="https://wiki.archlinux.org/index.php/ProjectName" target="_blank" rel="noopener noreferrer">ProjectName wiki</a>  |  
  <a href="ProjectName" target="_blank" rel="noopener noreferrer">ProjectName site</a>
</p>  
