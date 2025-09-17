# Capitaine cursors - Installation

### NIXes, BSDs, and possibly others

To install the cursor theme simply copy the theme to your icons directory.
For local user installation:

```bash
mkdir -p ~/.icons/capitaine-cursors
cp -pr path/to/theme/ ~/.icons/capitaine-cursors
```

For system-wide installation for all users:

```bash
sudo cp -pr path/to/theme/ /usr/share/icons/capitaine-cursors
```

Then set the theme with your preferred desktop tools.

#### Fedora and EPEL

There is a third-party Copr repository with ready-to-use RPMs:

```bash
sudo dnf copr enable tcg/themes
sudo dnf install la-capitaine-cursor-theme
```

#### Arch Linux

Capitaine cursors are available in the official Arch Linux repositories.

```bash
pacman -S capitaine-cursors
```

### Windows

The Windows build comes with an INF file to make installation easy.

1.  Open `.windows/` in Explorer, and right click on `install.inf`.
2.  Click 'Install' from the context menu, and authorise the modifications to your system.
3.  Open `Control Panel` > `Personalisation and Appearance` > `Change mouse pointers`, and select Capitaine cursors.
4.  Click 'Apply'.
