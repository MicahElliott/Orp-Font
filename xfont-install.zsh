#! /bin/zsh

# Create a X Windows PCF font from a BDF.
#
# See README for more details.

usage="Usage: ${0:t} FONT-NAME.bdf

Generate and install a PCF.

To start a new font, copy an existing BDF:
  cp .../orp-medium.bdf lib/my-font.bdf

Hack your new font:
  gbdfed lib/my-font.bdf

Install it:
  $0:t lib/my-font.bdf
"

# Check for a bunch of misuses.
[[ $# > 0 ]] || { print $usage; exit 1 }
bdf=${1?Must provide font.bdf file}
[[ -f $bdf ]]           || { print "ERROR: missing $bdf file.\n\n$usage"; exit 1 }
[[ $bdf:t:e == 'bdf' ]] || { print "ERROR: only will work with .bdf files.\n\n$usage"; exit 1 }
bdfdir=$bdf:h
font=$bdf:t:r
cd $0:h
basedir=$PWD
cd -
libdir=$basedir/lib
[[ -d $libdir ]] || { print $usage; exit 1 }
# Do the generation work from the local misc dir.
pcfdir=$PWD/misc
[[ -d $pcfdir ]] || { print "INFO: creating a misc dir to sit on your font path"; mkdir $pcfdir }

# Mysterious temp file.
trunc="$font-trunc"
# Needed for something UTF stuff.
utfs=$libdir/8859-1.TXT

# Check for system utility dependencies.
deps=( bdftruncate.pl ucs2any bdftopcf mkfontdir gzip xset )
print "Checking for dependencies…"
for d in $deps; do
    which $d >/dev/null || exit 1
done

pushd $bdfdir

# Generate intermediate truncated file.
# Performance workaround for sparse fonts.
# Taken out of package:
# http://www.cl.cam.ac.uk/~mgk25/download/ucs-fonts.tar.gz
bdftruncate.pl 'U+3200' <$font.bdf >$trunc.bdf

# Generate BDF fonts containing subsets of ISO 10646-1 codepoints.
ucs2any +d $font.bdf $utfs ISO8859-1

# Generate the PCF.
bdftopcf $trunc.bdf >$font.pcf

# Remove mysterious generated file.
rm ${font}-ISO8859-1.bdf

# Turn into compressed/usable form.
gzip -f -9 $font.pcf

# Clean up junk.
rm $trunc.bdf

pushd $pcfdir
mv ~1/$font.pcf.gz .

# Add this new PCF-GZ to $PWD/fonts.dir
mkfontdir

# Tell X that this font is now available.
# Stupid stupid xsel bug makes adding multiple times cause duplicate
# path entries, so have to delete the dir (which successfully removes
# all duplicates), and then add. Use `xset q` to see everything.
xset -fp $PWD
xset +fp $PWD

# Show new font path.
xset q |grep -A1 'Font Path:'
print "\nYou can remove this path if you messed up with:"
print "  xset -fp $PWD"
