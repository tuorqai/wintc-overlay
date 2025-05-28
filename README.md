wintc-overlay
=============

This repository contains Gentoo ebuilds for [rozniak/xfce-winxp-tc](https://github.com/rozniak/xfce-winxp-tc.git).

## Configuration

Create `/etc/portage/repos.conf/wintc-overlay.conf` with the following content:

```
[wintc-overlay]
location = /var/db/repos/wintc-overlay
sync-type = git
sync-uri = https://github.com/tuorqai/wintc-overlay.git
```

*Alternatively, add those settings in `/etc/portage/repos.conf` if it's a file.*

## Installation

This repo contains a single package: `x11-themes/xfce-winxp-tc`.

It's a live ebuild, so only version `9999` is available.

Add the following to your `/etc/portage/package.accept_keywords`:

```
x11-themes/xfce-winxp-tc ~amd64
```

The package has the following USE flags:

+ `fonts` (enabled by default): include Windows XP fonts
+ `lightdm`: build theme for LightDM (*warning: not tested*)
+ `plymouth`: build bootscreen for Plymouth (*warning: not tested*)
+ `shell` (enabled by default): build programs mimicking Windows XP tools, disable to build themes only
+ `sounds` (enabled by default): include Windows XP sound scheme
+ `themes` (enabled by default): include GTK, Xfwm, cursor and icon themes
+ `wallpapers` (enabled by default): include Windows XP wallpapers
+ `webkit`: build Explorer, which requires Webkit (meaningless without `shell` USE enabled)

*Warning: there might be some licensing issues, which is ignored by the ebuild. Use at your own risk.*

Installation is as simple as:

```
emerge --ask x11-themes/xfce-winxp-tc
```

## Disclaimer

The ebuild is not optimal and has lots of issues. In particular, shared libraries
are compiled during the configuration stage, among other things.
