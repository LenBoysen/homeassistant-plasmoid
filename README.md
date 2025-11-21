# Home Assistant plasmoid


## Get started

### Setup
Creates build environment. 
```bash
mkdir build -p
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
```
### Run (from project folder)
Previews sandbox for widget.
```bash
cd build
make run
```

### Installation
Installs widget so KDE Plasma can use it.
```bash
cd build
sudo make install
```
### Uninstall
Deletes installed widget.
```bash
sudo rm -rf /usr/share/plasma/plasmoids/com.github.lenboysen.hasswidget.dev
```

## Screenshots

### Widget

![Widget](widget.png)






### Genereal Settings
![Genereal Settings](settings_1.png)


### Appearance Settings
![Appearance Settings](settings_2.png)
