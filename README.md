read me
# 🤖 AutoDrop — Dropshipping 100% Autonome (Node.js + SQLite)
> Plateforme de dropshipping auto-gérée, zéro intervention humaine, zéro coût d'API.
## 🚀 Stack Technique
| Couche | Technologie |
|--------|-------------|
| Backend | Node.js + Express |
| Base de données | SQLite (better-sqlite3) |
| IA / LLM | Mistral AI (free tier) |
| Génération images | Pollinations.ai (gratuit, sans clé) |
| Fournisseur principal | CJDropshipping API |
| Tendances marché | Google Trends API (npm, gratuit) |
| Scraping | Puppeteer Extra + Stealth Plugin |
| Emails | Nodemailer (Gmail SMTP gratuit) |
| Scheduler | node-cron |
| Auth | JWT |
| Logs | Winston + rotation quotidienne |
## 📦 Installation
```bash
git clone https://github.com/ton-user/autodrop.git
cd autodrop
npm install
cp .env.example .env
# Remplir les clés dans .env
node scripts/init-db.js
node server.js


***
## Points Critiques Anti-Erreurs
Voici les pièges à éviter quand tu codes avec ce prompt :
- **Mistral Free = 2 req/min**  — dans `cron.js`, ajoute un délai de 500ms entre chaque appel Mistral pour ne pas dépasser la limite[1]
- **Pollinations.ai est sans clé**  — l'endpoint est un simple GET HTTP : `https://image.pollinations.ai/prompt/white sneakers product photo&width=1024&height=1024`[2]
- **CJDropshipping API est gratuite** mais nécessite un compte marchand vérifié  — crée le compte avant de commencer[3]
- **better-sqlite3 est synchrone** — ne pas le mélanger avec `async/await` sauf dans des workers ; utilise-le directement dans les fonctions Express pour les performances
- **Puppeteer sur Railway/Render** nécessite d'installer Chromium via la variable d'env `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false` dans le Dockerfile
