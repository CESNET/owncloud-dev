#!/bin/bash

run='su www-data -s /bin/bash -c'
$run 'php occ maintenance:install'
$run 'php occ config:system:set debug --value true'
$run "php occ config:system:set trusted_domains 1 --value $(hostname --ip-address)"

if [ $# -eq 2 ]; then
       appurl=$1
       appname=$2
       cd apps
       git clone $appurl $appname
       cd ../
       $run "php occ app:enable $appname"
fi

apache2-foreground
