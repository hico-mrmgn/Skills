# Workflows

Reusable Workflowの置き場。各プロジェクトからこのワークフローを参照することで、
ワークフロー本体を1箇所で管理できる。改善すれば全プロジェクトに即反映される。

## ワークフロー一覧

| ファイル | 用途 |
|---|---|
| [nightly-refactor.yml](./nightly-refactor.yml) | 夜間自律リファクタリング → ブランチ作成 → PR起票 → Slack通知 |

## 動作の流れ

1. 直近の変更ファイルを確認し、リファクタリング対象を1〜3件選定
2. 型安全性・責務分離の観点でスキャン
3. `refactor/daily-YYYYMMDD` ブランチを作成してリファクタリング実施
4. `tsc --noEmit` とテストで動作確認
5. 変更がなければ正常終了（PR不作成）
6. 変更があればコミット → Pull Request 作成 → Slack通知

## 使い方

各プロジェクトの `.github/workflows/nightly.yml` に以下を追加：

```yaml
name: Nightly Refactoring

on:
  schedule:
    - cron: '0 20 * * *'  # 毎日 05:00 JST
  workflow_dispatch:       # 手動実行も可

jobs:
  refactor:
    uses: hico-mrmgn/Skills/.github/workflows/nightly-refactor.yml@main
    with:
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

## 必要なPermissions

ワークフロー側で `contents: write` と `pull-requests: write` が必要。
Reusable Workflowの中で設定済みなので、呼び出し側での設定は不要。
