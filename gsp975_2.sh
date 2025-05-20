gcloud compute addresses create http-lb-ipv4 \
  --ip-version=IPV4 \
  --global
gcloud compute health-checks create tcp http-lb-health-check \
  --port 80
gcloud compute backend-services create http-lb-backend \
  --protocol HTTP \
  --health-checks http-lb-health-check \
  --global \
  --enable-logging \
  --log-sample-rate 1
gcloud compute backend-services add-backend http-lb-backend \
  --instance-group us-east1-mig \
  --instance-group-zone us-east1-b \
  --balancing-mode RATE \
  --max-rate-per-instance 50 \
  --capacity-scaler 1 \
  --global
gcloud compute backend-services add-backend http-lb-backend \
  --instance-group europe-west1-mig \
  --instance-group-zone europe-west1-b \
  --balancing-mode UTILIZATION \
  --max-utilization 0.8 \
  --capacity-scaler 1 \
  --global
gcloud compute url-maps create http-lb-url-map \
  --default-service http-lb-backend
gcloud compute target-http-proxies create http-lb-proxy \
  --url-map=http-lb-url-map
gcloud compute forwarding-rules create http-lb-ipv4-forwarding-rule \
  --address=http-lb-ipv4 \
  --global \
  --target-http-proxy=http-lb-proxy \
  --ports=80
gcloud compute forwarding-rules create http-lb-ipv6-forwarding-rule \
  --ip-version=IPV6 \
  --global \
  --target-http-proxy=http-lb-proxy \
  --ports=80
