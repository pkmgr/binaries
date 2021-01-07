## scripts  
  
my custom scripts  
  
## Automatic install/update

```shell
sudo bash -c "$(curl -LSs https://github.com/systemmgr/installer/raw/master/install.sh)" && systemmgr install installer
```

## Manual install
  
requires:

```shell
sudo apt install git bash zsh fish python3-pip python3-setuptools net-tools fontconfig jq tf xclip curl wget dialog qalc rsync links html2text dict
```  

```shell
sudo yum install git bash zsh fish python3-pip python3-setuptools net-tools fontconfig jq tinyfugue xclip curl wget dialog qalc dictd
```  

```shell
sudo pacman -S git bash zsh fish python-pip python-setuptools net-tools fontconfig jq xclip curl wget dialog qalculate-gtk
yay -S tinyfugue
```  

```shell
export PATH="$PATH:/usr/local/share/CasjaysDev/scripts/bin"
sudo git clone https://github.com/systemmgr/installer "/usr/local/share/CasjaysDev/scripts"
```

Manual update:

```shell
sudo git -C /usr/local/share/CasjaysDev/scripts pull
```
  
  
<p align=center>
    <a href="https://travis-ci.com/casjay-dotfiles/scripts" target="_blank"><img alt="Qries" src="https://travis-ci.com/casjay-dotfiles/scripts.svg?branch=master"><br /> <br />

  <a href="https://github.com/dfmgr" target="_blank">dotfiles</a>  |
  <a href="https://github.com/fontmgr" target="_blank">fonts</a>  |  
  <a href="https://github.com/iconmgr" target="_blank">icons</a>  |  
  <a href="https://github.com/pkmgr" target="_blank">dotfile packages</a>  |  
  <a href="https://github.com/systemmgr" target="_blank">system packages</a> |  
  <a href="https://github.com/thememgr" target="_blank">themes</a>  |  
  <a href="https://github.com/wallpapermgr" target="_blank">wallpapers</a>  <br>
</p>  
  
  
<p align=center>
  <a href="https://github.com/systemmgr/installer" target="_blank">scripts site</a><br />
</p>  
