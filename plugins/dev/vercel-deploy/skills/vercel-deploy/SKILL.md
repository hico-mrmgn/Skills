---
name: vercel-deploy
description: Vercel のデプロイ管理・状態確認・ログ調査を行うスキル。「デプロイして」「デプロイの状態を確認して」「ビルドが失敗した」「ログを見せて」「どのプロジェクトがある？」「本番に反映して」など、Vercel のデプロイ操作・確認・トラブルシュートが絡む作業では必ずこのスキルを参照すること。Vercel MCP が接続されている前提で動作する。
---

# Vercel デプロイ管理スキル

Vercel MCP ツール（`mcp__*__vercel` 系）を使ってデプロイの管理・確認・トラブルシュートを行う。

## チーム・プロジェクト情報の初期化

このスキルは Vercel チーム ID とプロジェクト一覧を**ユーザー固有の値で**動作する。初回利用時、または対象チームが変わったときに次の手順で取得する。

```
1. list_teams() でアクセス可能なチーム一覧を取得
2. 対象チームの id（"team_..." 形式）を控える
3. list_projects(teamId: "team_...") でそのチームのプロジェクト名・ID を取得
```

以降の操作では取得した `teamId` を `teamId` パラメータに、プロジェクト名（slug）または `id` を `projectId` に渡す。

> **メモ:** よく使うチーム ID・プロジェクト名は、利用側のプロジェクトの `CLAUDE.md` か個人メモにキャッシュしておくと毎回 `list_*` を叩かなくて済む。このスキル本体には書き込まない（共有を前提とするため）。

---

## 操作フロー

### プロジェクトを確認する

```
ユーザー: 「〇〇プロジェクトの状態を教えて」
→ get_project(projectId: "プロジェクト名またはID", teamId: "<your-team-id>")
```

プロジェクトIDが不明なら先に `list_projects` で探す。プロジェクト名（slug）をそのまま `projectId` に渡せることが多い。

### デプロイ履歴を確認する

```
ユーザー: 「最近のデプロイを見せて」「いつデプロイしたっけ」
→ list_deployments(projectId: "...", teamId: "<your-team-id>")
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
→ get_deployment_build_logs(deploymentId: "...", teamId: "<your-team-id>")
```

ログから `ERROR` や `FAILED` を探してエラー箇所を特定し、原因と対処を伝える。

### ランタイムログを調査する

```
ユーザー: 「本番でエラーが出ている」「APIが動いていない」
→ get_runtime_logs(deploymentId: "...", teamId: "<your-team-id>")
```

ランタイムエラー（500系・未キャッチ例外など）を確認する。

### デプロイを実行する

```
ユーザー: 「デプロイして」「本番に反映して」
→ deploy_to_vercel(projectId: "...", teamId: "<your-team-id>")
```

実行前に「〇〇プロジェクトをデプロイします。よいですか？」と確認を取る。デプロイは本番に影響するため確認必須。

### デプロイ結果を確認する

```
→ get_deployment(deploymentId: "...", teamId: "<your-team-id>")
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
- **似た名前のプロジェクト群** — 同一コードベースから派生した類似プロジェクトが並ぶことがある（モック / 本番 / モバイル等）。操作対象を間違えないよう名前を確認する
- **本番デプロイ前は必ずユーザーに確認** — `deploy_to_vercel` は本番反映のため、確認なしに実行しない
