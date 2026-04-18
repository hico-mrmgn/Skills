# Templates

新規プロジェクト初期化用の雛形。

## ファイル一覧

| ファイル | 用途 |
|---|---|
| [CLAUDE.md.template](./CLAUDE.md.template) | プロジェクトCLAUDE.mdの雛形 |
| [settings.json.template](./settings.json.template) | `.claude/settings.json`の雛形 |

## 使い方

`/init-project` スキルを使うと自動で展開される。

手動で使う場合：
```bash
# CLAUDE.md を雛形からコピー
cp /path/to/Skills/templates/CLAUDE.md.template CLAUDE.md
# プレースホルダーを置換する
sed -i 's/{{PROJECT_NAME}}/my-project/g' CLAUDE.md

# settings.json を雛形からコピー
mkdir -p .claude
cp /path/to/Skills/templates/settings.json.template .claude/settings.json
```

## プレースホルダー一覧

| プレースホルダー | 説明 |
|---|---|
| `{{PROJECT_NAME}}` | プロジェクト名 |
| `{{TECH_STACK}}` | 技術スタック（例：Next.js + Supabase） |
| `{{REPO_URL}}` | GitHubリポジトリURL |
| `{{TECH_SPECIFIC_RULES}}` | 技術スタック固有のルール |
| `{{NAMING_CONVENTIONS}}` | 命名規則 |
| `{{DIRECTORY_STRUCTURE}}` | ディレクトリ構造の説明 |
| `{{INSTALL_CMD}}` | 依存インストールコマンド（例：`pnpm install`） |
| `{{DEV_CMD}}` | 開発サーバー起動コマンド |
| `{{TEST_CMD}}` | テスト実行コマンド |
| `{{LINT_CMD}}` | Lint / Format コマンド |
| `{{TYPECHECK_CMD}}` | 型チェックコマンド |
| `{{BUILD_CMD}}` | ビルドコマンド |
| `{{CUSTOM_SKILLS}}` | プロジェクト固有のスキル |
| `{{PROJECT_NOTES}}` | プロジェクト固有のメモ |
