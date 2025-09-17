# Capitaine cursors - Build

Building from source can take a really long time, depending on the max specified DPI.
Pre-built packages are available for download.

That said, you'll find everything you need to build and modify this cursor set in the `src/` directory.

Make sure `inkscape` and `xcursorgen` are installed

```
sudo apt install inkscape x11-apps          # Debian, Ubuntu based distros
sudo dnf install inkscape xorg-x11-apps     # Fedora, EPEL based distros
brew cask install xquartz inkscape          # macOS
```

Then run the provided script:

```
./build.sh
```

This will generate the pixmaps and appropriate aliases.
The freshly compiled cursor theme will be located in the `dist/` folder.

The script has a few options described below:

| Option | Values          | Description                     |
| :----- | :-------------- | :------------------------------ |
| `-p`   | `unix`, `win32` | Build for BSD/Linux, or Windows |
| `-t`   | `dark`, `light` | Choose the variant to build     |
| `-d`   | See DPIs        | Set the max DPI to render       |

<small>\*Note: building the win32 cursors from source is not currently supported, but it is on the roadmap.</small>
