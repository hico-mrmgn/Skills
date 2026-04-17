---
name: claude-code-workflow
description: >
  Claude Code を使った日次コード分析・自動リファクタリングパイプラインの設計・構築・改善を行うスキル。
  GitHub Actions による夜間スケジュール実行、GitHub Issues への自動起票（発見事項1件=1 Issue）、
  Slack への朝サマリー通知、CLAUDE.md によるルール管理、allowedTools 設定による無人実行まで網羅。
  次のキーワードが出たら必ず参照すること：「Claude Code」「CLAUDE.md」「自動リファクタリング」
  「GitHub Actions」「夜間分析」「日次パイプライン」「Slack通知」「Issue自動作成」「無人実行」。
---

# Claude Code Workflow Skill

Tomoさん（manaable / Lipass / LIMS）のプロジェクトで蓄積された、
Claude Code を使った自動コード品質改善パイプラインのベストプラクティス集。

---

## パイプライン全体像

```
【夜間】GitHub Actions (cron)
  └─ Claude Code 起動（CLAUDE.md を自動読み込み）
        ↓
  git diff で前日差分を取得・解析
        ↓
  改善点を発見事項ごとに分類
  （TypeScript型安全性 / 責務分離 / UIレイヤー / API・データレイヤー）
        ↓
  GitHub Issues API で1件=1 Issue 自動作成
  ラベル: claude-refactor / priority/high・medium・low
        ↓
【翌朝8時】Slack Incoming Webhook でサマリー投稿
        ↓
【チーム】出社後30分でIssue仕分け → 週次リリーストレイン（火曜）
```

---

## GitHub Actions ワークフロー

```yaml
# .github/workflows/nightly-analysis.yml
name: Claude Code 夜間分析

on:
  schedule:
    - cron: '0 21 * * 1-5'   # 平日夜10時 JST（UTC 21:00 = JST 06:00 翌朝）
  workflow_dispatch:           # 手動テスト用

jobs:
  nightly-analysis:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      issues: write

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0        # git log / git diff に全履歴が必要

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - name: Claude Code 分析
        uses: anthropics/claude-code-action@beta
        with:
          prompt: "CLAUDE.mdの指示に従って、前日の差分を解析し発見事項をJSON形式で出力してください。"
          allowed_tools: "Read,Bash"
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}

      - name: GitHub Issues 作成
        run: python scripts/create_github_issues.py
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITHUB_REPOSITORY: ${{ github.repository }}

      - name: Slack 通知（8時予約 or 即時）
        run: python scripts/slack_notify.py
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### スケジュール時刻の目安

| 目的 | cron (UTC) | JST |
|------|-----------|-----|
| 深夜3時分析・朝8時通知 | `0 18 * * 1-5` | 翌朝3:00 |
| 夜10時分析・翌朝通知 | `0 13 * * 1-5` | 22:00 |
| 手動テスト | `workflow_dispatch` | — |

---

## 無人実行の設定

### 方法A: claude-code-action（推奨）

```yaml
- uses: anthropics/claude-code-action@beta
  with:
    allowed_tools: "Read,Bash"           # 書き込み権限を与えない（分析のみ）
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### 方法B: CLIで直接実行

```bash
claude -p "CLAUDE.mdの指示に従い分析を実行" \
  --allowedTools "Read,Bash" \
  --no-interactive
```

### allowedTools の使い分け

| モード | allowed_tools | 用途 |
|--------|--------------|------|
| 分析のみ（推奨） | `Read,Bash` | Issue起票・Slack通知 |
| リファクタリングまで | `Read,Edit,Bash` | PRまで自動作成 |
| 危険（非推奨） | `--dangerously-skip-permissions` | 緊急時のみ |

**重要**: `git add -p` は非対話型環境でハングする。代わりに `git add -A` または `git add <filepath>` を使うこと。

---

## CLAUDE.md の構造

CLAUDE.md はリポジトリルートに置き、Claude Code が起動時に自動読み込みする。

```markdown
# CLAUDE.md — [プロダクト名] リファクタリングルール

## 実行モード
このタスクは完全自律実行モードで動作する。
- 全ツール実行・Bash操作を確認なしで実施する
- ユーザーへの質問・中断は行わない
- 判断に迷う場合は保守的な変更（小さいスコープ）を選択して進める

## STEP 1｜スコープ確認
以下で本日のリファクタリング対象ファイルを1〜3件に絞る。
\`\`\`bash
git log --since="yesterday" --name-only --pretty=format: | sort | uniq
git diff --stat HEAD~1
\`\`\`
変更がない場合の優先順：
1. src/features/ 配下のドメインロジック
2. src/components/ 配下の大型コンポーネント（200行超）
3. src/hooks/ 配下のカスタムフック

## STEP 2｜解析チェックリスト

### TypeScript 型安全性
- [ ] any 型の使用（→ unknown + 型ガードに置換）
- [ ] as キャスト（→ 型推論 or 型ガードに置換）
- [ ] Props・戻り値の型未定義
- [ ] type より interface が使われている（→ type に統一）

### 責務分離
- [ ] 1関数が複数責務を持つ（50行超えたら分割検討）
- [ ] API呼び出しがコンポーネント内に直書き（→ services/ に移動）
- [ ] カスタムフックが hooks/ 外にある（→ 移動）
- [ ] ユーティリティに副作用がある（→ 分離）

### その他
- [ ] console.log が本番コードに残存（→ 削除）
- [ ] TODO コメントは残す（削除しない）

## STEP 3｜リファクタリング制約
- ビジネスロジックは変更しない
- テストファイルは変更しない
- 1ファイルあたりの変更行数は100行以内
- 型エラーが増える変更はしない
- `npx tsc --noEmit` でエラーがないことを確認してから次へ

## STEP 4｜出力形式（JSON）
発見事項を以下のJSON形式で stdout に出力する。
スクリプトがこのJSONを受け取りIssueを作成する。

\`\`\`json
{
  "findings": [
    {
      "priority": "high",
      "file": "src/features/auth/login.ts",
      "category": "typescript",
      "title": "[refactor] login.ts - any型の除去",
      "description": "## 問題\\n...",
      "before": "const data: any = ...",
      "after": "const data: LoginResponse = ..."
    }
  ]
}
\`\`\`

priority: "high" | "medium" | "low"
category: "typescript" | "separation" | "ui" | "api"
```

---

## GitHub Issues フォーマット

```
Title: [refactor] {ファイル名} - {改善カテゴリ}
Labels: claude-refactor, priority/high (or medium / low)

Body:
## 対象ファイル
`src/features/auth/login.ts`

## 問題の概要
{説明}

## Before
\`\`\`typescript
{before_code}
\`\`\`

## After（提案）
\`\`\`typescript
{after_code}
\`\`\`

## 影響範囲
{影響範囲の説明}

---
*このIssueはClaude Codeによって自動生成されました*
```

### 事前に作成するラベル

```bash
gh label create "claude-refactor" --color "0075ca"
gh label create "priority/high"   --color "d73a4a"
gh label create "priority/medium" --color "e4e669"
gh label create "priority/low"    --color "0e8a16"
```

---

## Slack 通知フォーマット

```
🔍 *Claude Code 日次レポート（YYYY-MM-DD）*
昨日の差分：{n}ファイル変更
新規 Issue：{total}件（高{h} / 中{m} / 低{l}）

┌ 🔴 高優先度
│ • #{num} {title}
│ • #{num} {title}
│
├ 🟡 中優先度
│ • #{num} {title}
│
└ ⚪ 低優先度
  • #{num} {title}

👉 https://github.com/{org}/{repo}/issues?q=label:claude-refactor
```

---

## 週次リリーストレイン

| タイミング | アクション |
|-----------|-----------|
| 月〜金（朝） | Slack確認・GitHub Issues仕分け（今週やる/バックログ/クローズ） |
| 月〜月（日中） | 選択したIssueをClaude Codeに実施させ、PRレビュー・Approve |
| 月曜 午後 | 承認済みPRを `refactor/weekly` ブランチにまとめてマージ |
| **火曜** | 通常の機能リリースと同じトレインに乗せてリリース |

---

## Issue の3分類

| 分類 | 操作 |
|------|------|
| 今週やる | Projectの今スプリント列に移動 |
| 後回し | バックログへ（Milestoneを変更） |
| スキップ | クローズ。繰り返す提案はCLAUDE.mdに除外ルールを追記 |

---

## モデル選択指針

| タスク | モデル |
|--------|--------|
| 日次分析・Issue起票（通常） | claude-sonnet（デフォルト） |
| 複雑なアーキテクチャ判断・深いリファクタリング | claude-opus |

---

## よくあるトラブル

| 症状 | 原因 | 対策 |
|------|------|------|
| Actions がハングする | `git add -p` が対話を待っている | `git add -A` に変更 |
| 途中で止まる | プロンプトが曖昧で判断できない | CLAUDE.md の指示を具体化・スコープを絞る |
| 型エラーが増える | 変更が広すぎる | 対象ファイル数を1〜2に制限 |
| Issue が重複する | 前回のものがクローズされていない | クローズ済みIssueを除外するフィルタをスクリプトに追加 |
| Slack 通知が届かない | Webhook URL が未設定 or 無効 | GitHub Secrets の `SLACK_WEBHOOK_URL` を確認 |

---

## プロダクト別メモ

- **manaable**: Next.js App Router + TypeScript。src/features/ ドメイン構造。リリースは火曜。
- **Lipass**: 保険コンプライアンス向け。src/types/ に型を集約、カスタムフックは `use{FeatureName}.ts` 命名。
- **LIMS**: 検査情報管理。（随時追記）
