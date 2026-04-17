---
name: vercel-deploy
description: Vercel のデプロイ管理・状態確認・ログ調査を行うスキル。「デプロイして」「デプロイの状態を確認して」「ビルドが失敗した」「ログを見せて」「どのプロジェクトがある？」「本番に反映して」など、Vercel のデプロイ操作・確認・トラブルシュートが絡む作業では必ずこのスキルを参照すること。Vercel MCP が接続されている前提で動作する。
---

# Vercel デプロイ管理スキル

Vercel MCP ツール（`mcp__*__vercel` 系）を使ってデプロイの管理・確認・トラブルシュートを行う。

## チーム情報（固定値）

```
チーム名:  mrmgn
チームID:  team_iLTiN3DoDVLQPsRN7GFsC7dt
```

`teamId` を要求するツールには常にこの値を渡す。

---

## プロジェクト一覧（主要なもの）

| プロジェクト名 | 用途 |
|---|---|
| `lipass-mock-up` | Lipass モックアップ（保険営業SaaS） |
| `lipass-pro` | Lipass 本番 |
| `lipass-mobile` | Lipass モバイル |
| `lipass-agent-app` | Lipass エージェントアプリ |
| `mb-application` | Manaable アプリ |
| `mb-core-user` | Manaable コアユーザー |
| `mb-core-mock` | Manaable コアモック |
| `mb-side-session` | Manaable サイドセッション |
| `iju-susume` | 移住のすゝめ |
| `iju-jissen` | 移住CD実践 |
| `mukashi-mukashi` | むかしむかし |
| `pdm-playbook` | PdM Playbook |
| `localsuccess` | LocalSuccess（LP系） |

プロジェクトIDが不明なときは `list_projects` で確認する。

---

## 操作フロー

### プロジェクトを確認する

```
ユーザー: 「〇〇プロジェクトの状態を教えて」
→ get_project(projectId: "プロジェクト名またはID", teamId: "team_iLTiN3DoDVLQPsRN7GFsC7dt")
```

プロジェクトIDが不明なら先に `list_projects` で探す。プロジェクト名（slug）をそのまま `projectId` に渡せることが多い。

### デプロイ履歴を確認する

```
ユーザー: 「最近のデプロイを見せて」「いつデプロイしたっけ」
→ list_deployments(projectId: "...", teamId: "team_iLTiN3DoDVLQPsRN7GFsC7dt")
```

返ってきた deployments から `state`・`url`・`createdAt` を読み取って伝える。

| state | 意味 |
|---|---|
| `READY` | デプロイ成功・公開中 |
| `ERROR` | ビルド失敗 |
| `BUILDING` | ビルド中 |
| `CANCELED` | キャンセル済み |

### ビルドログを調査する

```
ユーザー: 「ビルドが失敗した」「エラーの原因を教えて」
→ list_deployments で直近のデプロイIDを取得
→ get_deployment_build_logs(deploymentId: "...", teamId: "team_iLTiN3DoDVLQPsRN7GFsC7dt")
```

ログから `ERROR` や `FAILED` を探してエラー箇所を特定し、原因と対処を伝える。

### ランタイムログを調査する

```
ユーザー: 「本番でエラーが出ている」「APIが動いていない」
→ get_runtime_logs(deploymentId: "...", teamId: "team_iLTiN3DoDVLQPsRN7GFsC7dt")
```

ランタイムエラー（500系・未キャッチ例外など）を確認する。

### デプロイを実行する

```
ユーザー: 「デプロイして」「本番に反映して」
→ deploy_to_vercel(projectId: "...", teamId: "team_iLTiN3DoDVLQPsRN7GFsC7dt")
```

実行前に「〇〇プロジェクトをデプロイします。よいですか？」と確認を取る。デプロイは本番に影響するため確認必須。

### デプロイ結果を確認する

```
→ get_deployment(deploymentId: "...", teamId: "team_iLTiN3DoDVLQPsRN7GFsC7dt")
```

`state: READY` になったら成功。URLを取り出してユーザーに伝える。

### デプロイ済みURLの動作確認

```
→ get_access_to_vercel_url(url: "https://xxx.vercel.app")
→ web_fetch_vercel_url(url: "https://xxx.vercel.app")
```

ページが正しく返ってくるか、リダイレクトが起きていないかを確認できる。

---

## トラブルシュートの手順

### ビルドエラーの場合

1. `list_deployments` で直近の失敗デプロイを特定
2. `get_deployment_build_logs` でログを取得
3. `ERROR:` や `Failed` を含む行を探す
4. よくある原因：
   - **型エラー** → TypeScript の型不整合
   - **import エラー** → 存在しないモジュールの参照
   - **環境変数不足** → Vercel の Environment Variables に設定されていない
   - **メモリ不足** → ビルドの最大メモリを超過

### 本番エラーの場合

1. `get_runtime_logs` でランタイムログを取得
2. スタックトレースから原因を特定
3. 環境変数・API エンドポイント・データソースの接続を疑う

---

## 環境変数の管理

Vercel の Environment Variables は3種類：
- **Production** — 本番デプロイ（main ブランチ）
- **Preview** — PRプレビューデプロイ
- **Development** — `vercel dev` のローカル開発

`get_project` の返り値に `env` フィールドがあれば確認できる。ただし値は取得できない（名前のみ）。

---

## Gotchas

- **プロジェクト名 = slug** — `list_projects` の `name` フィールドをそのまま `projectId` に使えることが多い
- **デプロイID の形式** — `dpl_` で始まる文字列。`list_deployments` の `uid` フィールドがそれ
- **デプロイは Git push と連動** — 通常は GitHub にプッシュすれば自動デプロイされる。手動デプロイは追加ビルド消費に注意
- **`localsuccess-*` プロジェクト群** — 同一コードベースのLP系プロジェクトが多数ある。操作対象を間違えないよう名前を確認する
- **本番デプロイ前は必ずユーザーに確認** — `deploy_to_vercel` は本番反映のため、確認なしに実行しない
