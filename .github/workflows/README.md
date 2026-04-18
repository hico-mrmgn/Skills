# Workflows

Reusable Workflowの置き場。各プロジェクトからこのワークフローを参照することで、
ワークフロー本体を1箇所で管理できる。改善すれば全プロジェクトに即反映される。

## ワークフロー一覧

| ファイル | 用途 |
|---|---|
| [nightly-review.yml](./nightly-review.yml) | 夜間コードレビュー → Issue起票 → Slack通知 |

## 使い方

各プロジェクトの `.github/workflows/nightly.yml` に以下を追加：

```yaml
name: Nightly Review

on:
  schedule:
    - cron: '0 20 * * *'  # 毎日5:00 JST
  workflow_dispatch:

jobs:
  review:
    uses: hico-mrmgn/Skills/.github/workflows/nightly-review.yml@main
    with:
      target_paths: "src/**"
      base_branch: "main"
      notify_slack: true
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
      SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

## 必要なSecrets

プロジェクト側のGitHub Secrets に以下を設定すること：

| Secret名 | 説明 |
|---|---|
| `ANTHROPIC_API_KEY` | Anthropic APIキー（必須） |
| `SLACK_WEBHOOK_URL` | Slack Incoming Webhook URL（任意） |
