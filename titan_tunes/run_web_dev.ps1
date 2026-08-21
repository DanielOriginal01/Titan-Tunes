# ─────────────────────────────────────────────────────────────────────────────
# run_web_dev.ps1 — Lanceur de développement web Titan Tunes
#
# Pourquoi ce script ?
# Sur Flutter Web, les appels HTTP vers localhost:8080 sont bloqués par le
# navigateur (politique CORS / Same-Origin Policy).
# Ce script lance Chrome avec --disable-web-security pour contourner le CORS
# en développement local UNIQUEMENT.
#
# ⚠️  NE PAS utiliser ce flag en production ni pour naviguer sur d'autres sites.
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "🚀 Lancement Titan Tunes en mode développement web..." -ForegroundColor Cyan
Write-Host "⚠️  CORS désactivé dans Chrome (dev uniquement)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Assurez-vous que le backend Spring Boot tourne sur :" -ForegroundColor Green
Write-Host "  http://localhost:8080/api/v1" -ForegroundColor Green
Write-Host ""

flutter run -d chrome `
  --web-browser-flag "--disable-web-security" `
  --web-browser-flag "--user-data-dir=/tmp/chrome_dev_titan"
