#!/bin/bash



sh /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/0_0_wipe_lab.sh
sh  /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/0_1_routerdmz_masquerade.sh
sh  /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/1_1_db_preparation.sh
sh  /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/1_2_db_webapp.sh
sh  /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/1_3_db_seafile.sh
sh  /home/lab/labs/Unternehmensnetzwerk/FaPraSecurity/scripts/2_1_webserver.sh
