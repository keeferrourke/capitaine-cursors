# Capitaine cursors
This is an x-cursor theme inspired by macOS and based on KDE Breeze. The source files were made in Inkscape, and the theme was designed to pair well with my icon pack, [La Capitaine](https://github.com/keeferrourke/la-capitaine-icon-theme).

Everything you need to build the xcursor theme is found in `src/`, and the prebuilt theme is found in `bin/xcursor/`

There is also a Windows cursor theme available in `bin/windows/`, though it is not buildable from source due to the broken nature of Microsoft's operating system. It also will not receive substantial updates.

## Notes
Building the x-cursor theme from SVG source requires a regular inkscape installation. If the build script fails, you should probably install inkscape using your preferred package manager :)

## License
Capitaine cursors is based on KDE Breeze cursors, as such it falls under the same license.
Capitaine cursors is LGPLv3. See COPYING for more details.

## Installation
### \*NIXes, \*BSDs, and possibly others
To install the cursor theme simply copy the compiled theme to your icons directory. For local user installation:

    cp -pr bin/xcursor ~/.icons/capitaine-cursors

For system-wide installation for all users:

    sudo cp -pr bin/xcursor /usr/share/icons/capitaine-cursors

Then set the theme with your preferred desktop tools.

### Windows
The Windows build comes with an INF file to make installation easy. Open `bin/windows` in Explorer, and right click on `install.inf`. Click 'Install' from the context menu, and authorise the modifications to your system. Then open Control Panel > Personalisation and Appearance > Change mouse pointers, and select Capitaine cursors. Click 'Apply'.

## Building from source
You'll find everything you need to build and modify this cursor set in the `src/` directory. To build the xcursor set from the SVG source run:

    ./build.sh

to generate the pixmaps and appropriate aliases. The freshly compiled cursor theme will be located in `src/build/`

## Donations
I'm a poor computer science student &ndash; and I spend many hours per week working on software and artwork for the community. If you like this cursor theme and want to support (buy me a coffee?), please consider [donating](https://paypal.me/keeferrourke).

## Preview
![](preview.png)


