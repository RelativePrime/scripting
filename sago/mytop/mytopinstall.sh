#!/bin/bash
#
# This installs  mytop and its perl dependencies - or should.
# If you get any errors for missing perl modules please let me know.
#
# If install is successfull, you can add any other modules for color support, etc.
# just using cpan or cpan2rpm
#
#Pete Eby
#Sago Networks
#


mkdir /root/mytop
cd /root/mytop

rpm -Uhv http://apt.sw.be/redhat/el4/en/i386/rpmforge/RPMS/rpmforge-release-0.3.6-1.el4.rf.i386.rpm

wget ks.sagonet.com/mytop/cpan2rpm-2.028-1.noarch.rpm
wget ks.sagonet.com/mytop/perl-DBI-1.40-8.i386.rpm
wget ks.sagonet.com/mytop/perl-TermReadKey-2.30-1.i386.rpm
wget ks.sagonet.com/mytop/mytop-1.4-2.el4.rf.noarch.rpm


rpm -Uvh cpan2rpm-2.028-1.noarch.rpm
rpm -Uvh perl-DBI-1.40-8.i386.rpm
rpm -Uvh perl-TermReadKey-2.30-1.i386.rpm
rpm -Uvh mytop-1.4-2.el4.rf.noarch.rpm

echo 
echo You should now me able to run mytop with
echo '#mytop -u user --prompt -d database'
echo '(--prompt just prompt for password. -p works too)'
echo 
echo If you need to install other perl modules to enable color support
echo you can just use cpan or cpan2rpm:
echo '#cpan2rpm perl::module'
echo


