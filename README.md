# The Sparrow Project

Sparrow is a immutable distribution that stays lightweight, and secure at the same time, it focuses on a simple yet essential goal. The goal to be customizable, scriptable, and extendable; using both secure user-space containers, and a simple/common scripting language for many applications/programs.

## The Essentials

Sparrow comes with a simple and lightweight approach of packages/applications that fits to your needs. It comes with the following essentials:

- Hyprland (Wayland Compositor)
- Noctalia v5 (Desktop Shell)
- Noctalia Greeter (Greetd Greeter)
- Foot (Terminal)
- Neovim (w/ Lazyvim Configuration)
- Helium (Web Browser w/ Privacy)
- Distrobox (Simple & Deployable Containers)
- Litterbox (Security First Containers)

**Any other packages/applications must be installed through flatpaks or through a Container.**

## Distributions
Unlike other immutable distributions where they are based on a specific distribution, Sparrow can use any base distribution provided there is:
1) Support with ``bootc``,
2) Provides the essentials (and their dependencies) listed above, and 
3) Is compatible with the Apache v2.0 License (see LICENSE for more information).

These are the currently supported Distributions:
- Arch Linux (AMD64)
- Fedora Linux (Using Universal Blue's base image)

**Sparrow DOES NOT support Debian due to technological reasons and release cycles not consistant with package releases.**

In the Sparrow container, there are currently 4 mainline image tags to pick from:
- ``atomic-sparrow:stable`` (arch)
- ``atomic-sparrow:stable-nvidia`` (arch)
- ``atomic-sparrow:ublue`` (ublue)
- ``atomic-sparrow:ublue-nvidia`` (ublue)

For Contributors, there is also:
- ``atomic-sparrow:devel`` (arch development)
- ``atomic-sparrow:ublue-devel`` (ublue development)

## Switching/Installing
> If you are switching to Sparrow using ``bootc``, use the compatible distribution otherwise you will experience a broken installation!
Migrating to Sparrow should be straight forward, provided that your system makes use of ``bootc``. If you are on a system that does not include ``bootc``, refer to installation via LiveCD.

### Switch via ``bootc``
Use ``bootc switch ghcr.io/voidusx/atomic-sparrow:stable`` to switch over from your existing bootc installation to Sparrow.
If you are using Secure Boot, use the ``--enforce-container-sigpolicy`` flag to ensure switching will not break your installation.

### Installing via LiveCD
Currently, Sparrow does not have a straightforward installation process for the Arch Linux based images. For the Ublue based image, Titanboa is provided as a installation process for the Ublue based Sparrow images; however, they do not come with a desktop session to test Sparrow.

To download the LiveCD(s), you can find them in Github Actions, Releases, or via the website (not implemented yet).
**Refer to Distributions section for available options to install your prefered image.**

## Build
Sparrow uses Lune as the builder for the images, as well as ``just`` for the recipes. Lune was chosen to fit the scope of a simple/common scripting language with extended types for build process. You should familiarize yourself with [Luau](https://luau.org) and the Lune runtime if you wish to contribute to the project. [You can grab the Lune runtime by following the runtime's own manual here.](https://lune-org.github.io/docs/getting-started/1-installation)

For more information about Just and the recipes tied to it, refer to Universal Blue's immutable distributions and their own documentations there.
