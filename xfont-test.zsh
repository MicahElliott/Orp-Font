#! /usr/bin/env zsh

# Test (via eyeballs) the extended glyphs for interesting characters,
# like maths, drawing, prompts, languages, etc.
#
# Also a placeholder for more extensive future tests.

cat ${0:h}/UTF-8-demo.txt

for c in {1..7}; do echo -e "\e[0;$c;3${c}muNintErest1n6 5tR|ng"; done

print 'Bold italic:'
print '\e[1;3mfoo'
