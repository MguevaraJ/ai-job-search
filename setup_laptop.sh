#!/usr/bin/env bash
# ============================================================
# Setup script for ai-job-search on a fresh laptop
# Run: bash setup_laptop.sh
# ============================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_err()   { echo -e "${RED}[ERR]${NC} $*"; }

# ------------------------------------------------------------------
# Detect OS
# ------------------------------------------------------------------
OS="$(uname -s)"
case "$OS" in
  Linux*)     DISTRO="linux" ;;
  Darwin*)    DISTRO="macos" ;;
  *)          DISTRO="unknown" ;;
esac
log_info "OS detectado: $OS ($DISTRO)"

# ------------------------------------------------------------------
# Helper: check if command exists
# ------------------------------------------------------------------
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# ------------------------------------------------------------------
# 1. bun (REQUERIDO para CLIs de portales)
# ------------------------------------------------------------------
if has_cmd bun; then
  log_ok "bun ya instalado: $(bun --version)"
else
  log_warn "bun NO encontrado. Instalando..."
  if has_cmd curl; then
    curl -fsSL https://bun.sh/install | bash
    # shellcheck source=/dev/null
    [[ -f "$HOME/.bun/_bun" ]] && export PATH="$HOME/.bun/bin:$PATH"
    # Recargar PATH para la sesión actual
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
  elif has_cmd wget; then
    wget -qO- https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
  else
    log_err "Ni curl ni wget disponibles. Instala bun manualmente: https://bun.sh"
    exit 1
  fi
  if has_cmd bun; then
    log_ok "bun instalado: $(bun --version)"
  else
    log_err "Falló la instalación de bun. Reinicia la terminal y re-ejecuta."
    exit 1
  fi
fi

# ------------------------------------------------------------------
# 2. Python 3 + pip
# ------------------------------------------------------------------
if has_cmd python3; then
  log_ok "python3: $(python3 --version)"
else
  log_err "python3 no encontrado. Instálalo con tu gestor de paquetes."
  exit 1
fi

if has_cmd pip3; then
  log_ok "pip3 disponible"
else
  log_warn "pip3 no encontrado. Instalando..."
  if [[ "$DISTRO" == "linux" ]]; then
    if has_cmd apt; then sudo apt update && sudo apt install -y python3-pip; fi
    if has_cmd dnf; then sudo dnf install -y python3-pip; fi
    if has_cmd pacman; then sudo pacman -S --noconfirm python-pip; fi
  elif [[ "$DISTRO" == "macos" ]]; then
    if has_cmd brew; then brew install python; fi
  fi
fi

# ------------------------------------------------------------------
# 3. Python deps para verify_pdf.py (pypdf + pdftotext)
# ------------------------------------------------------------------
log_info "Instalando dependencias Python..."
python3 -m pip install --user --quiet pypdf 2>/dev/null || true
# pdftotext es binario del sistema (poppler-utils), no pip
if ! has_cmd pdftotext; then
  log_warn "pdftotext (poppler-utils) no encontrado."
  if [[ "$DISTRO" == "linux" ]]; then
    if has_cmd apt; then sudo apt update && sudo apt install -y poppler-utils; fi
    if has_cmd dnf; then sudo dnf install -y poppler-utils; fi
    if has_cmd pacman; then sudo pacman -S --noconfirm poppler; fi
  elif [[ "$DISTRO" == "macos" ]]; then
    if has_cmd brew; then brew install poppler; fi
  fi
  if has_cmd pdftotext; then log_ok "pdftotext instalado"; else log_warn "pdftotext no instalado (verify_pdf.py usará fallback)"; fi
else
  log_ok "pdftotext disponible"
fi

# ------------------------------------------------------------------
# 4. LaTeX (OPCIONAL - solo para compilar CVs)
# ------------------------------------------------------------------
if has_cmd lualatex; then
  log_ok "lualatex: $(lualatex --version | head -1)"
else
  log_warn "lualatex NO instalado (solo necesario para compilar CVs .tex → PDF)."
  if [[ "$DISTRO" == "linux" ]]; then
    echo "  Ubuntu/Debian: sudo apt install texlive-luatex texlive-fonts-extra texlive-lang-spanish"
    echo "  Fedora:        sudo dnf install texlive-luatex texlive-collection-fontsextra"
    echo "  Arch:          sudo pacman -S texlive-core texlive-latexextra"
  elif [[ "$DISTRO" == "macos" ]]; then
    echo "  macOS:         brew install --cask mactex"
  fi
fi

# ------------------------------------------------------------------
# 5. Instalar deps de los CLIs (linkedin-search, freehire-search, etc.)
# ------------------------------------------------------------------
log_info "Instalando dependencias de CLIs de portales..."
for cli_dir in .agents/skills/*/cli; do
  if [[ -f "$cli_dir/package.json" ]]; then
    log_info "  $(basename "$(dirname "$cli_dir")") → bun install"
    (cd "$cli_dir" && bun install --quiet) || log_warn "    Falló bun install en $cli_dir"
  fi
done

# ------------------------------------------------------------------
# 6. Verificación rápida de que /scrape puede correr
# ------------------------------------------------------------------
log_info "=== VERIFICACIÓN RÁPIDA ==="

echo -n "bun:           " && bun --version
echo -n "python3:       " && python3 --version
echo -n "pdftotext:     " && (has_cmd pdftotext && pdftotext -v 2>&1 | head -1 || echo "NO (opcional)")
echo -n "lualatex:      " && (has_cmd lualatex && lualatex --version | head -1 || echo "NO (opcional, solo CVs)")

# Test linkedin-search CLI
log_info "Probando linkedin-search CLI (1 resultado, remote)..."
if timeout 30 bun run .agents/skills/linkedin-search/cli/src/cli.ts search -q "developer" -l "Remote" --limit 1 --format json >/dev/null 2>&1; then
  log_ok "linkedin-search CLI FUNCIONA"
else
  log_warn "linkedin-search CLI falló (puede ser rate-limit o red). Revisa manualmente:"
  echo "  bun run .agents/skills/linkedin-search/cli/src/cli.ts search -q \"developer\" -l \"Remote\" --limit 1 --format json"
fi

# ------------------------------------------------------------------
# 7. Git config (opcional pero recomendado)
# ------------------------------------------------------------------
if ! git config user.email >/dev/null 2>&1; then
  log_warn "Git user.email no configurado. Configúralo:"
  echo "  git config --global user.email \"tu@email.com\""
  echo "  git config --global user.name \"Tu Nombre\""
fi

# ------------------------------------------------------------------
# Done
# ------------------------------------------------------------------
echo
log_ok "Setup completado. Para usar:"
echo "  cd $(pwd)"
echo "  /scrape                    # en OpenCode / Claude Code"
echo "  # o manual:"
echo "  bun run .agents/skills/linkedin-search/cli/src/cli.ts search -q \"Desarrollador Fullstack\" -l \"Remote\" --jobage 14 --limit 20 --format json"
echo
echo "Archivos clave:"
echo "  .claude/skills/job-scraper/search-queries.md   # Tus queries personalizadas"
echo "  cv/main_moises_guevara_frontend.tex            # Tu CV frontend (compila con lualatex)"
echo "  job_search_tracker.csv                         # Tu tracker de aplicaciones"