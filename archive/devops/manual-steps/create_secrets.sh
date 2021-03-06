#!/bin/bash

if [[ -z "$DOMAIN" ]]; then
  echo ".env does not appear to be sourced, sourcing now"
  . ../.env
fi

kseal() {
    name=$(basename -s .txt "$@")
    if [[ -z "$NS" ]]; then
      NS=default
    fi
    envsubst < "$@" > values.yaml | kubectl -n "$NS" create secret generic "$name" --from-file=values.yaml --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem && rm values.yaml
}

#################
# secrets
#################
# kubectl create secret generic fluxcloud --from-literal=slack_url="$SLACK_WEBHOOK_URL" --namespace flux --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/fluxcloud.yaml
# kubectl create secret generic traefik-basic-auth-jeff --from-literal=auth="$JEFF_AUTH" --namespace kube-system --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/basic-auth-jeff-kube-system.yaml
# kubectl create secret generic traefik-basic-auth-jeff --from-literal=auth="$JEFF_AUTH" --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/basic-auth-jeff.yaml
#kubectl create secret generic restic-secret --from-literal=RESTIC_PASSWORD="$RESTIC_PASSWORD" --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/restic-secret.yaml
#kubectl create secret generic restic-secret --from-literal=RESTIC_PASSWORD="$RESTIC_PASSWORD" --namespace kube-system --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/restic-secret-kube-system.yaml
#kubectl create secret generic restic-secret --from-literal=RESTIC_PASSWORD="$RESTIC_PASSWORD" --namespace logs --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/restic-secret-logs.yaml
kubectl create secret generic ceph-admin-secret --from-literal=auth="$EXTERNAL_CEPH_ADMIN_SECRET" --namespace kube-system --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/external-ceph-admin-secret-kube-system.yaml
kubectl create secret generic ceph-secret --from-literal=auth="$EXTERNAL_CEPH_SECRET" --namespace kube-system --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/external-ceph-secret-kube-system.yaml
# kubectl create secret generic registry-storage --from-file=config=values-to-encrypt/registry-storage.txt --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/registry-storage.yaml
# kubectl create secret generic gitlab-rails-storage --from-file=connection=values-to-encrypt/rails.txt --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/rails.yaml
# kubectl create secret generic s3cmd-config --from-file=config=values-to-encrypt/s3cmd.config --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/s3cmd-config.yaml
kubectl create secret generic azure-secret --from-literal=AZURE_ACCOUNT_NAME="$AZURE_ACCOUNT_NAME" --from-literal=AZURE_ACCOUNT_KEY="$AZURE_STORAGE_KEY" --from-literal=RESTIC_PASSWORD="$RESTIC_PASSWORD" --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/azure-secret.yaml
kubectl create secret generic azure-secret --from-literal=AZURE_ACCOUNT_NAME="$AZURE_ACCOUNT_NAME" --from-literal=AZURE_ACCOUNT_KEY="$AZURE_STORAGE_KEY" --from-literal=RESTIC_PASSWORD="$RESTIC_PASSWORD" --namespace kube-system --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/azure-secret-kube-system.yaml
kubectl create secret generic azure-secret --from-literal=AZURE_ACCOUNT_NAME="$AZURE_ACCOUNT_NAME" --from-literal=AZURE_ACCOUNT_KEY="$AZURE_STORAGE_KEY" --from-literal=RESTIC_PASSWORD="$RESTIC_PASSWORD" --namespace logs --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/azure-secret-logs.yaml
kubectl create secret generic route53-api-key --from-literal=api-key="$AWS_ACCESS_KEY_SECRET" --namespace cert-manager --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/route53-api-key.yaml
kubectl create secret generic smbcreds --from-literal=username="$SMB_USERNAME" --from-literal=password="$SMB_PASSWORD" --namespace default --type="microsoft.com/smb" --dry-run -o json  > ../secrets/smbcreds-default.yaml #| kubeseal --format=yaml --cert=../pub-cert.pem
kubectl create secret generic juliohm-smbcreds --from-literal=username="$SMB_USERNAME" --from-literal=password="$SMB_PASSWORD" --namespace default --type="juliohm/cifs" --dry-run -o json  > ../secrets/juliohm-smbcreds-default.yaml #| kubeseal --format=yaml --cert=../pub-cert.pem

NS=velero kseal values-to-encrypt/velero-values.txt > ../secrets/velero-values.yaml


###################
# helm chart values
###################

# NS=kube-system kseal values-to-encrypt/consul-values.txt > ../secrets/consul-values.yaml
NS=kube-system kseal values-to-encrypt/traefik-values.txt > ../secrets/traefik-values.yaml
NS=kube-system kseal values-to-encrypt/kubernetes-dashboard-values.txt > ../secrets/kubernetes-dashboard-values.yaml
NS=kube-system kseal values-to-encrypt/kured-values.txt > ../secrets/kured-values.yaml
NS=kube-system kseal values-to-encrypt/forwardauth-values.txt > ../secrets/forwardauth-values.yaml

NS=logs kseal values-to-encrypt/kibana-values.txt > ../secrets/kibana-values.yaml


NS=monitoring kseal values-to-encrypt/prometheus-operator-values.txt > ../secrets/prometheus-operator-values.yaml


NS=monitoring kseal values-to-encrypt/influxdb-values.txt > ../secrets/influxdb-values.yaml
NS=monitoring kseal values-to-encrypt/chronograf-values.txt > ../secrets/chronograf-values.yaml
#kseal values-to-encrypt/prometheus-values.txt > ../secrets/prometheus-values.yaml

kseal values-to-encrypt/hubot-values.txt > ../secrets/hubot-values.yaml
kseal values-to-encrypt/comcast-values.txt > ../secrets/comcast-values.yaml
# kseal values-to-encrypt/uptimerobot-values.txt > ../secrets/uptimerobot-values.yaml
kseal values-to-encrypt/grafana-values.txt > ../secrets/grafana-values.yaml
kseal values-to-encrypt/minio-values.txt > ../secrets/minio-values.yaml
kseal values-to-encrypt/rtorrent-flood-values.txt > ../secrets/rtorrent-flood-values.yaml
kseal values-to-encrypt/nzbget-values.txt > ../secrets/nzbget-values.yaml
kseal values-to-encrypt/plex-values.txt > ../secrets/plex-values.yaml
kseal values-to-encrypt/radarr-values.txt > ../secrets/radarr-values.yaml
kseal values-to-encrypt/sonarr-values.txt > ../secrets/sonarr-values.yaml
kseal values-to-encrypt/nzbhydra-values.txt > ../secrets/nzbhydra-values.yaml
kseal values-to-encrypt/hass-values.txt > ../secrets/hass-values.yaml
kseal values-to-encrypt/hass-mysql-values.txt > ../secrets/hass-mysql-values.yaml
kseal values-to-encrypt/unifi-values.txt > ../secrets/unifi-values.yaml
kseal values-to-encrypt/node-red-values.txt > ../secrets/node-red-values.yaml
kseal values-to-encrypt/rabbitmq-values.txt > ../secrets/rabbitmq-values.yaml
kseal values-to-encrypt/nextcloud-values.txt > ../secrets/nextcloud-values.yaml
kseal values-to-encrypt/tautulli-values.txt > ../secrets/tautulli-values.yaml
kseal values-to-encrypt/appdaemon-values.txt > ../secrets/appdaemon-values.yaml
kseal values-to-encrypt/zwave2mqtt-values.txt > ../secrets/zwave2mqtt-values.yaml
