$ErrorActionPreference = "Stop"

Write-Host "=== M4B SAFE CHECK ==="

dart format `
  lib\local_social\auth\cidendb_login_bridge.dart `
  lib\local_social\auth\cidentia_session_scope.dart `
  lib\local_social\widgets\cidentia_ecosystem_entry_page.dart `
  lib\local_social\local_social_app.dart

flutter analyze `
  lib\local_social\auth\cidendb_login_bridge.dart `
  lib\local_social\auth\cidentia_session_scope.dart `
  lib\local_social\widgets\cidentia_ecosystem_entry_page.dart `
  lib\local_social\local_social_app.dart

git diff --check

Write-Host ""
Write-Host "Git status:"
git status --short

Write-Host ""
Write-Host "Latest commits:"
git log --oneline -8
