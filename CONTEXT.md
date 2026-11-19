# CONTEXT.md — Contexto completo para ai-job-search

> **Para que tu modelo en OpenCode entienda el proyecto de inmediato.**  
> Léelo al iniciar la sesión en tu laptop.

---

## 1. Qué es este repo

Un **workspace de búsqueda de empleo** automatizado para **Moisés Guevara** (Fullstack Developer, remoto desde Venezuela). Incluye:

- **Job Scraper** (`/scrape`): busca ofertas en LinkedIn, freehire.me y otros portales via CLIs propios (bun/TypeScript), deduplica, filtra por tus skills y presenta matches con fit assessment.
- **Job Application Assistant**: evalúa fit real contra tu perfil, genera CV y cover letter en LaTeX (moderncv), prepara entrevistas.
- **CVs en LaTeX**: plantillas moderncv/banking, compilables con `lualatex`.
- **Tracker CSV**: `job_search_tracker.csv` para seguimiento de aplicaciones.

---

## 2. Tu perfil (fuente de verdad: `CLAUDE.md`)

| Campo | Valor |
|-------|-------|
| **Nombre** | Moisés Guevara |
| **Ubicación** | Anzoátegui, Venezuela — **solo remoto**, cualquier país/horario, **no relocation** |
| **Idiomas** | Español nativo, Inglés **básico (muy limitado)** |
| **CV language** | Español |
| **Estado** | Buscando activamente (último rol ago 2026) |
| **Headline** | "Fullstack Developer \| NestJS · Node.js · React · Angular · TypeScript \| Multi-tenant SaaS & Real-Time APIs \| Remoto LatAm" |

### Experiencia clave
- **VR Academy** (2026, remoto): SaaS multi-tenant VR, NestJS + React/Vite en Nx, Colyseus/Socket.IO tiempo real, Elasticsearch, AWS S3, IA 360°.
- **ASSIT TI · Puerto Aguadulce** (2022–2025): Migración **AngularJS → Angular 15** (–90% carga), NgRx, Spring Boot/WildFly 99.9% uptime.
- **ASSIT TI · Caring Data** (2023–2025, concurrente): Plataforma geriátrica React + Laravel + MySQL.
- **IEH Electricidad** (2020–2021): Dashboards SVG tiempo real React, Express REST, Linux deploy.

### Stack principal
- **Frontend**: Angular (15/22), NgRx, React 19, Next.js, Zustand, Vite, Three.js, Electron, Tailwind, MUI, **Figma**
- **Backend**: Node.js, **NestJS**, Express, REST, WebSockets, JWT/Passport, Laravel, Spring Boot, **Colyseus**, Socket.IO, **Gin (Go)**, WildFly, Elasticsearch
- **Data**: PostgreSQL, MySQL, MongoDB, Redis, Elasticsearch, TypeORM
- **Infra**: Docker, Podman, AWS S3, Linux, Nginx, Nx, GitHub Actions, CI/CD, Vercel, Astro
- **Python/IA**: LangGraph, LangChain, Ollama, CLIP (visión), pipelines multiagente
- **Mobile/Desktop**: Android (Java, Material 3), Electron, Godot 4 (GDScript)
- **Testing**: Jest, Vitest, Playwright (170+ tests), Clean Architecture, code review

### Deal-breakers
- ❌ Presencial / híbrido / relocation
- ❌ Inglés fluido requerido (tu nivel: básico)

---

## 3. CV actualizado — `cv/main_moises_guevara_frontend.tex`

**Generado en esta sesión** con estos cambios sobre el original:

| Cambio | Detalle |
|--------|---------|
| ❌ **Educación eliminada** | Se quitó sección completa |
| ✅ **Angular 22 en Competencias** | Última versión estable (nov 2026) |
| ✅ **Angular 15 solo en experiencia** | Migración ASSIT TI (real) |
| ❌ **Quitado "sistema multiagente con LangGraph"** | Del resumen profesional |
| ✅ **Agregado Figma** | En Competencias → Frontend |
| ✅ **Backend: Go → Gin** | Framework real más popular |
| ✅ **Competencias expandidas** | Todas las techs de experiencias + proyectos (ver archivo) |
| ✅ **Resumen profesional reescrito** | Lenguaje natural, narrativo, keyword-rich |
| ✅ **2 páginas exactas** | Verificado con `pdftotext` |

**Compilar:**
```bash
cd cv
lualatex main_moises_guevara_frontend.tex
```

---

## 4. Job Scraper — cómo funciona

### Comando principal
```
/scrape
# o con foco:
/scrape backend
/scrape angular
/scrape broad     # todas las categorías
/scrape health    # solo health check de portales
```

### Flujo interno (skill `.claude/skills/job-scraper/SKILL.md`)

1. **Carga queries** desde `.claude/skills/job-scraper/search-queries.md` (tus queries en español, remote, LatAm)
2. **Ejecuta CLIs** en paralelo (linkedin-search, freehire-search, etc.) — requieren `bun`
3. **Deduplica** contra `job_scraper/seen_jobs.json` + `job_search_tracker.csv` (via `tools/scrape_state.py`)
4. **Quick fit assessment** (High/Medium/Low) + Language Gate (inglés requerido = Low automático)
5. **Guarda** nuevos en `job_scraper/seen_jobs.json` con clave canónica (`tools/job_key.py`)
6. **Genera links de referral** LinkedIn (recruiters + peers) para High/Medium
7. **Presenta tabla** ordenada por fit + highlights + contact links

### Portales configurados (CLIs en `.agents/skills/`)

| Portal | CLI | Status |
|--------|-----|--------|
| LinkedIn | `linkedin-search` | ✅ Funcional |
| freehire.me | `freehire-search` | ✅ Funcional |
| Jobindex (DK) | `jobindex-search` | ✅ Instalado |
| Jobnet (DK) | `jobnet-search` | ✅ Instalado |
| Jobbank (US) | `jobbank-search` | ✅ Instalado |

> **Agregar más**: `/add-portal` crea skill en `.agents/skills/` y `/scrape` lo detecta auto.

### Queries activas (`search-queries.md`)

Todas en **español**, con `remoto`, sin ubicación fija:
- **Priority 1**: Fullstack/Backend NestJS/TypeScript
- **Priority 2**: Frontend React/Angular
- **Priority 3**: IA/LLM (LangGraph, LangChain)
- **Priority 4**: Broader (PHP/Laravel, contratos)

---

## 5. Comandos útiles en OpenCode

| Comando | Qué hace |
|---------|----------|
| `/scrape` | Busca ofertas nuevas (top 3 categorías) |
| `/scrape broad` | Todas las categorías |
| `/scrape health` | Health check de portales |
| `/rank` | Batch-scorea todas las ofertas nuevas (0–100) y devuelve shortlist |
| `/apply <url>` | Evalúa fit → si apruebas, genera CV + cover letter LaTeX |
| `/interview <url|#>` | Prepara talking points, preguntas, respuestas STAR |
| `/outcome <url|#> <status>` | Actualiza tracker (applied/interview/offer/rejected) |

---

## 6. Arquitectura de skills (single source of truth)

```
.claude/skills/
├── job-scraper/           # Orquestador de búsqueda
│   ├── SKILL.md
│   └── search-queries.md  # TUS queries personalizadas
├── job-application-assistant/  # Workflow aplicación
│   ├── SKILL.md
│   ├── 01-candidate-profile.md
│   ├── 02-behavioral-profile.md
│   ├── 04-job-evaluation.md
│   ├── 05-cv-templates.md
│   ├── 06-cover-letter-templates.md
│   ├── 07-interview-prep.md
│   ├── 08-application-forms.md
│   └── 09-web-research.md
└── upskill/               # Plan de estudio

.agents/skills/            # CLIs portables (bun/TypeScript)
├── linkedin-search/
├── freehire-search/
├── jobindex-search/
├── jobnet-search/
└── jobbank-search/
```

> **Regla de oro**: No dupliques lógica. `.claude/` = especificación canónica. Los agents (Codex, Antigravity, etc.) leen `.agents/skills/*/SKILL.md`.

---

## 7. Archivos de datos (ignoran git por privacidad)

| Archivo | Qué guarda | Ubicación |
|---------|------------|-----------|
| `job_scraper/seen_jobs.json` | Historial de ofertas vistas (dedup) | `.gitignore` |
| `job_search_tracker.csv` | Tus aplicaciones (estado, fecha, notas) | `.gitignore` |
| `salary_data.json` | Research de salarios | `.gitignore` |
| `company_research/*.json` | Research por empresa | `.gitignore` |

---

## 8. Setup en laptop nueva (ya incluido)

```bash
git clone https://github.com/MguevaraJ/ai-job-search.git
cd ai-job-search
bash setup_laptop.sh
```

El script instala: **bun, python3, pypdf, pdftotext, lualatex (opcional), deps de CLIs** y hace test de integración.

---

## 9. Qué NO hacer / Gotchas

| ❌ No hagas | ✅ Haz esto |
|-------------|-------------|
| Editar `search-queries.md` sin saber | Tus queries ya están afinadas (español, remote, LatAm) |
| Compilar CV con `pdflatex` | Usa **`lualatex`** (evita errores fontawesome5) |
| Confiar en fit "High" sin revisar | Es quick assessment; `/rank` o `/apply` hacen evaluación real |
| Aplicar a ofertas con inglés requerido | Language Gate te avisará; tu inglés es básico |
| Subir `seen_jobs.json` o `tracker.csv` | Están en `.gitignore` por privacidad |
| Usar `WebSearch` como fuente primaria | CLIs son primarios; WebSearch = fallback only |

---

## 10. Próximos pasos sugeridos

1. **Clona y corre `setup_laptop.sh`** en tu laptop
2. **Ejecuta `/scrape`** — verás ofertas nuevas con fit assessment
3. **Si ves una interesante**: `/apply <url>` → evalúa fit real → genera CV + cover letter
4. **Para entrevista**: `/interview <url|#>` → talking points STAR
5. **Trackea**: `/outcome <url|#> applied`

---

## 11. Contacto / Referencias

- **GitHub**: https://github.com/MguevaraJ
- **LinkedIn**: https://linkedin.com/in/moisesguevara
- **Email**: mguevaraj27@gmail.com
- **Tel**: +58 412-0239940

---

> **Este archivo es contexto vivo.** Si cambias queries, perfil, o CV, actualízalo para que tu modelo en la laptop siga alineado.