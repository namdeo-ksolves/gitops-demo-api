#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  AI-ASSISTED SERVICE GENERATION DEMO
#  Uses Claude to generate a new microservice config,
#  adds it to index.js, and commits for GitOps deployment
# ─────────────────────────────────────────────────────────────

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'; BOLD='\033[1m'; RESET='\033[0m'

DEMO_DIR="$(cd "$(dirname "$0")" && pwd)"
INDEX_JS="$DEMO_DIR/src/index.js"

echo -e "\n${BOLD}════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}  AI SERVICE GENERATOR — LLM-Assisted GitOps${RESET}"
echo -e "${BOLD}════════════════════════════════════════════════${RESET}\n"

echo -e "${CYAN}Prompt to Claude:${RESET}"
echo -e "${YELLOW}\"Generate a JavaScript object for a new microservice to add to our"
echo -e " Ksolves Service Operations Center. Service: Order Processing Service,"
echo -e " category API, team Commerce, port 8005, 3 replicas, tech stack:"
echo -e " Node.js + Kafka + PostgreSQL. Return ONLY the JS object literal,"
echo -e " no explanation, matching this exact shape: { id, name, category,"
echo -e " status, version, replicas, uptime, team, port, description, deployedAt,"
echo -e " tech }. Use APP_VERSION for version and new Date().toISOString() for deployedAt.\"${RESET}\n"

echo -e "${MAGENTA}[Claude is generating...]${RESET}\n"

# Call Claude CLI to generate the service object
GENERATED=$(claude -p "Generate a JavaScript object for a new microservice to add to our Ksolves Service Operations Center dashboard.

Service details:
- Name: Order Processing Service
- Category: API
- Team: Commerce
- Port: 8005
- Replicas: 3
- Uptime: 99.94
- Tech stack: Node.js, Kafka, PostgreSQL
- Description: Manages end-to-end order lifecycle — creation, validation, fulfillment tracking, and payment confirmation for all Ksolves e-commerce clients.

Return ONLY the raw JavaScript object literal (no const, no semicolon at end, no explanation, no markdown).
The object must match this exact shape:
{
  id: 5,
  name: '...',
  category: '...',
  status: 'running',
  version: APP_VERSION,
  replicas: N,
  uptime: N,
  team: '...',
  port: N,
  description: '...',
  deployedAt: new Date().toISOString(),
  tech: ['...'],
}" 2>/dev/null)

echo -e "${GREEN}[Claude output]:${RESET}"
echo -e "${BOLD}$GENERATED${RESET}\n"

# Write the generated object to a temp file for inspection
TMPFILE=$(mktemp /tmp/ai-service-XXXX.js)
echo "$GENERATED" > "$TMPFILE"

echo -e "${CYAN}Preview saved to: $TMPFILE${RESET}"
echo -e "Inspect with: ${YELLOW}cat $TMPFILE${RESET}\n"

read -p "$(echo -e ${BOLD}"Add this service to index.js and deploy via GitOps? [y/N]: "${RESET})" CONFIRM

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  # Insert generated object before the closing ]; of the services array
  # Find the line with ]; that closes the array and insert before it
  python3 - <<PYEOF
import re

with open('$INDEX_JS', 'r') as f:
    content = f.read()

new_service = """$GENERATED"""

# Insert before the closing ]; nextId line
insert_point = content.rfind('];\nlet nextId')
if insert_point == -1:
    print("ERROR: Could not find insertion point in index.js")
    exit(1)

# Insert new service before closing ]; (last entry already has trailing comma)
updated = content[:insert_point] + '  ' + new_service.strip() + ',\n' + content[insert_point:]

# Also bump nextId from 4 to 5 (or whatever it currently is)
updated = re.sub(r'let nextId = (\d+);', lambda m: f'let nextId = {int(m.group(1))+1};', updated)

with open('$INDEX_JS', 'w') as f:
    f.write(updated)

print("✓ Service added to index.js")
PYEOF

  echo ""
  echo -e "${GREEN}✓ index.js updated with AI-generated service${RESET}"
  echo -e "\n${BOLD}Now committing and pushing to trigger the GitOps pipeline:${RESET}"
  echo ""

  cd "$DEMO_DIR"
  git add src/index.js
  git diff --staged --stat
  git commit -m "feat: add Order Processing Service — AI-generated via Claude"

  # Retry push up to 5 times (CI bot may push a tag-update commit between our commit and push)
  PUSHED=0
  for attempt in 1 2 3 4 5; do
    if git push origin main 2>&1; then
      PUSHED=1
      break
    fi
    echo -e "${YELLOW}  Push rejected (CI bot updated remote) — rebasing and retrying ($attempt/5)...${RESET}"
    git pull --rebase origin main 2>/dev/null
  done

  if [ "$PUSHED" = "1" ]; then
    echo -e "\n${GREEN}✓ Pushed! Pipeline is running.${RESET}"
    echo -e "Watch: ${CYAN}https://github.com/namdeo-ksolves/gitops-demo-api/actions${RESET}"
    echo -e "Live:  ${CYAN}http://15.206.153.218:31000${RESET}"
    echo -e "\nIn ~4 minutes, the Order Processing Service card will appear in the dashboard.\n"
  else
    echo -e "\n${YELLOW}⚠ Push failed after 5 attempts. Run: git pull --rebase origin main && git push origin main${RESET}\n"
  fi
else
  echo -e "\n${YELLOW}Skipped. Run again when ready to deploy.${RESET}\n"
  rm -f "$TMPFILE"
fi
