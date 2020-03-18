gcloud compute instance-templates create lamp-template --machine-type=f1-micro --metadata-from-file startup-script=startup-lamp.sh
gcloud compute target-pools create lamp-pool
gcloud compute instance-groups managed create lamp-group \
 --size 2 \
 --template lamp-template \
 --target-pool lamp-pool
gcloud compute firewall-rules create www-firewall --allow tcp:80
