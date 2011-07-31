#! /bin/zsh

# Create a X Windows PCF font from a BDF.
#
# See README for more details.

usage="
usage: ${0:t} FONT-NAME.bdf

Generate and install a PCF.

To start a new font, copy an existing BDF:
  cp orp-medium.bdf my-font.bdf

Hack your new font:
  gbdfed my-font.bdf

Install it:
  ./xfont-install.zsh my-font
"

font=${1?Must provide font name sans ext}
font=${font:t:r}
trunc="$font-trunc"
#resources="${0:h}/resources"
resources="${0:h}"

deps=( bdftruncate.pl ucs2any bdftopcf mkfontdir gzip xset )
print "Checking for dependencies…"
for d in $deps; do
    which $d >/dev/null || exit 1
done

# Generate intermediate truncated file.
# Performance workaround for sparse fonts.
# Taken out of package:
# http://www.cl.cam.ac.uk/~mgk25/download/ucs-fonts.tar.gz
bdftruncate.pl 'U+3200' <$font.bdf >$trunc.bdf

# Generate BDF fonts containing subsets of ISO 10646-1 codepoints.
ucs2any +d $font.bdf $resources/8859-1.TXT  ISO8859-1

# Generate the PCF.
bdftopcf $trunc.bdf >$font.pcf

# Remove mysterious generated file.
rm ${font}-ISO8859-1.bdf

# Turn into compressed/usable form.
gzip -f -9 $font.pcf

# Clean up junk.
rm $trunc.bdf

# Add this new PCF-GZ to $PWD/fonts.dir
mkfontdir

# Tell X that this font is now available.
xset +fp $PWD
