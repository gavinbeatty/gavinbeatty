#!/usr/bin/awk -f
# tee.awk --- tee in awk
#
# Copy standard input to all named output files.
# Append content if -a option is supplied.
#
     
     
BEGIN    \
{
 for (i = 1; i < ARGC; i++)
  copy[i] = ARGV[i]

 if (ARGV[1] == "-a") {
  append = 1
  delete ARGV[1]
  delete copy[1]
  ARGC--
 }
 if (ARGC < 2) {
  print "usage: tee [-a] file ..." > "/dev/stderr"
  exit 1
 }
 ARGV[1] = "-"
 ARGC = 2
}

{
 # moving the if outside the loop makes it run faster
 if (append)
  for (i in copy) {
   print >> copy[i]
   fflush(copy[i])
  }
 else
  for (i in copy) {
   print > copy[i]
   fflush(copy[i])
  }
 print
 fflush()
}
END    \
{
 for (i in copy)
  close(copy[i])
}
