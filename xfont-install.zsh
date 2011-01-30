#! /bin/zsh

# Create a xterm-usable PCF from a BDF.
#
# To start a new font, copy an existing BDF:
#   cp 6x12.bdf myfont.bdf
#
# Hack your new font:
#   gbdfed myfont.bdf

font=${1?Must provide font name sans ext}
trunc="$font-trunc"
#resources="${0:h}/resources"
resources="${0:h}"

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

# Add this new PCF-GZ to $PWD/fonts.dir
mkfontdir

# Tell X that this font is now available.
xset +fp $PWD

# Clean up junk.
rm $trunc.bdf
