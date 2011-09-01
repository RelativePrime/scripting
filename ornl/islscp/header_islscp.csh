#!/bin/csh
# (This was the original islscp header injection script.)
 set tmpfile = /tmp/undos.$$
 rm -f ${tmpfile}
 foreach file ($*)
         cat header.txt ${file} > ${tmpfile}
         mv ${tmpfile} ${file}
 end
