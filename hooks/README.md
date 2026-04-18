# Hooks

自動実行型のHook設定テンプレート（Level 4）。
プロジェクトの `.claude/settings.json` にコピーして使う。

## ファイル一覧

| ファイル | 用途 |
|---|---|
| [nextjs-supabase.json](./nextjs-supabase.json) | Next.js + Supabase プロジェクト向け |
| [common.json](./common.json) | 技術スタック非依存の共通Hook |

## Hookの種類

| タイミング | 用途 |
|---|---|
| `PreToolUse` | ツール実行前（例：危険なコマンドのブロック） |
| `PostToolUse` | ツール実行後（例：ファイル保存後のフォーマット） |
| `Stop` | Claude応答終了時（例：テスト自動実行） |
| `SubagentStop` | サブエージェント終了時 |
