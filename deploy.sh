#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

ECR_URL="$1"
ALB_INGRESS_SG_ID="$2"
ACM_ARN="$3"
DOMAIN_NAME="$4"

helm upgrade --install --wait simpleapp ./helm -n dev --set image.repository="${ECR_URL}" -f - <<EOF
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/security-groups: ${ALB_INGRESS_SG_ID}
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    alb.ingress.kubernetes.io/certificate-arn: ${ACM_ARN}
    alb.ingress.kubernetes.io/healthcheck-path: /
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80,"HTTPS": 443}]'
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: instance
    external-dns.alpha.kubernetes.io/hostname: tomcat-app.${DOMAIN_NAME}.
  hosts:
    - host: tomcat-app.${DOMAIN_NAME}
      paths: ["/*"]
  tls: []
EOF
