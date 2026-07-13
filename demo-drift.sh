#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  DRIFT DETECTION DEMO
#  Simulates someone bypassing GitOps (manual kubectl change)
#  ArgoCD detects and self-heals automatically
# ─────────────────────────────────────────────────────────────

KEY="/home/namdeoks1214/webinars/ai-powered-gitops/namdeo_pawar.pem"
ARGOCD_PASS="Ihqg0Ee0bTJHfdOg"
MASTER="ubuntu@15.206.153.218"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ssh_cmd() { ssh -i "$KEY" -o StrictHostKeyChecking=no "$MASTER" "$1"; }

echo -e "\n${BOLD}════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}  DRIFT DETECTION DEMO — Ksolves GitOps Webinar${RESET}"
echo -e "${BOLD}════════════════════════════════════════════════${RESET}\n"

# Step 1: Show current healthy state
echo -e "${GREEN}[BEFORE]${RESET} Current cluster state:"
ssh_cmd "kubectl get deployment gitops-demo-api -n demo --no-headers \
  -o custom-columns='NAME:.metadata.name,DESIRED:.spec.replicas,READY:.status.readyReplicas'"
echo ""

# Step 2: Simulate the "bad" manual change
echo -e "${RED}[DRIFT]${RESET} Simulating engineer bypassing GitOps..."
echo -e "${YELLOW}  Running: kubectl scale deployment gitops-demo-api -n demo --replicas=0${RESET}"
echo -e "${YELLOW}  (This is what happens when someone runs kubectl in production directly)${RESET}\n"
ssh_cmd "kubectl scale deployment gitops-demo-api -n demo --replicas=0"
sleep 3

# Step 3: Show the damage
echo -e "\n${RED}[DRIFT DETECTED]${RESET} Cluster is now out of sync with Git:"
ssh_cmd "kubectl get pods -n demo"
echo ""
echo -e "${RED}  Git says: replicas=3  |  Cluster has: replicas=0${RESET}"
echo -e "${YELLOW}  App is DOWN. Check http://15.206.153.218:31000 — no response.${RESET}\n"

# Step 4: Get ArgoCD token and trigger sync immediately
echo -e "${CYAN}[ARGOCD]${RESET} Triggering ArgoCD sync (selfHeal would auto-correct in ~3 min)..."
TOKEN=$(ssh_cmd "curl -sk -X POST https://localhost:30858/api/v1/session \
  -H 'Content-Type: application/json' \
  -d '{\"username\":\"admin\",\"password\":\"$ARGOCD_PASS\"}' \
  | python3 -c \"import sys,json; print(json.load(sys.stdin)['token'])\"")

ssh_cmd "curl -sk -X POST https://localhost:30858/api/v1/applications/gitops-demo-api/sync \
  -H 'Authorization: Bearer $TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{\"prune\":false,\"force\":false}' > /dev/null"

echo -e "${CYAN}  ArgoCD sync triggered — restoring to Git desired state...${RESET}\n"

# Step 5: Wait and show recovery
echo -e "Waiting for pods to recover..."
for i in $(seq 1 24); do
  READY=$(ssh_cmd "kubectl get deployment gitops-demo-api -n demo \
    -o jsonpath='{.status.readyReplicas}' 2>/dev/null")
  DESIRED=$(ssh_cmd "kubectl get deployment gitops-demo-api -n demo \
    -o jsonpath='{.spec.replicas}' 2>/dev/null")
  echo -ne "  Pods ready: ${READY:-0}/${DESIRED:-3}\r"
  if [ "${READY}" = "${DESIRED}" ] && [ -n "$READY" ]; then
    break
  fi
  sleep 5
done

echo ""
echo -e "\n${GREEN}[RECOVERED]${RESET} Cluster restored to Git desired state:"
ssh_cmd "kubectl get pods -n demo"
echo ""

# Step 6: Verify app is back
HTTP=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://15.206.153.218:31000/health)
if [ "$HTTP" = "200" ]; then
  echo -e "${GREEN}✓ App is LIVE again: http://15.206.153.218:31000 → HTTP $HTTP${RESET}"
else
  echo -e "${YELLOW}  App returning HTTP $HTTP — pods still starting${RESET}"
fi

echo -e "\n${BOLD}KEY MESSAGE:${RESET} Git is the source of truth."
echo -e "Manual kubectl changes are ${RED}automatically detected and corrected${RESET}."
echo -e "Every drift is logged. Every correction is audited.\n"
