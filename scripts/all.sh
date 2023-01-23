#!/bin/bash



sh /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/0_0_wipe_lab.sh
sh  /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/0_1_routerdmz_masquerade.sh
sh  /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/1_1_db_preparation.sh
sh  /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/1_2_db_webapp.sh
sh  /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/1_3_db_seafile.sh
sh  /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/2_1_webserver.sh
sh  /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/3_1_haproxy.sh
sh  /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/4_1_seafile_nginx_installation.sh
#######MANUAL PART 4_2_manual_config

sh  /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/5_1_snort.sh
