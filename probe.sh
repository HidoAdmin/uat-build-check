#!/bin/sh
# $1 = build | run. Prints one line per check; the run-time result is also served at the app URL.
out=/tmp/probe.txt; : > "$out"
say() { echo "[$1] $2: $3" | tee -a "$out"; }
port() { if nc -z -w 3 "$2" "$3" 2>/dev/null; then say "$PHASE" "$1" "OPEN  <-- report this"; else say "$PHASE" "$1" "BLOCKED"; fi; }
PHASE=$1
port "Kubernetes API"            kubernetes.default.svc.cluster.local 443
port "Kubernetes API (IP)"       10.43.0.1 443
port "Node kubelet"              172.31.1.2 10250
port "Node SSH"                  172.31.1.2 22
port "Wadiup API"                cp-api.ksapaas-control-plane.svc.cluster.local 4800
port "Wadiup database"           wadiup-db-rw.ksapaas-control-plane.svc.cluster.local 5432
port "Waitlist database"         waitlist-db-rw.wadiup-landing.svc.cluster.local 5432
port "Object storage (MinIO)"    minio.ksapaas-system.svc.cluster.local 9000
port "Logs (Loki)"               loki.ksapaas-system.svc.cluster.local 3100
port "Gateway control"           envoy-gateway.envoy-gateway-system.svc.cluster.local 18000
port "Another tenant's MongoDB"  hubsdb.t-benaskar21-hubs-production.svc.cluster.local 27017
port "Another tenant's app"      notify-hub.t-benaskar21-hubs-production.svc.cluster.local 80
if curl -s -m 3 http://169.254.169.254/ >/dev/null 2>&1; then say "$PHASE" "Cloud metadata" "OPEN  <-- report this"; else say "$PHASE" "Cloud metadata" "BLOCKED"; fi
if [ -s /var/run/secrets/kubernetes.io/serviceaccount/token ]; then say "$PHASE" "Kubernetes token in container" "PRESENT <-- report this"; else say "$PHASE" "Kubernetes token in container" "none"; fi
if dmesg 2>/dev/null | grep -qi gvisor; then say "$PHASE" "Sandbox" "gVisor"; else say "$PHASE" "Sandbox" "no gVisor"; fi
if curl -s -m 5 -o /dev/null https://example.com; then say "$PHASE" "internet" "reachable (expected)"; else say "$PHASE" "internet" "unreachable"; fi
exit 0
