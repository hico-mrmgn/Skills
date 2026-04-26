# Security Rules

セキュリティ関連の恒常ルール。違反は最優先で報告する（CLAUDE.md の R3 参照）。

---

## S1. 秘密情報をクライアント側に出さない

`*_SECRET` / `*_KEY` / `SERVICE_ROLE` などのキーは、Server Action / Server Component / API Route の中だけで使う。
`'use client'` のファイルや `NEXT_PUBLIC_*` 環境変数として絶対に出さない。

## S2. 認可チェックを省略しない

「テストのために一時的に認可を切ろう」という提案はしない。
RLS / ミドルウェア / ガードを切らず、ポリシーやルールを直して解決する。

## S3. ユーザー入力を信用しない

外部入力は必ずバリデーションしてから DB / API / OS コマンドに渡す。
SQL は ORM / プリペアドステートメント経由でのみ実行する。

## S4. 秘密情報をコミットしない

`.env` / `credentials.json` / `*.pem` などはコミットしない。
`git add -A` / `git add .` を使わず、ファイルを名指しでステージする。

## S5. `security-guidance` の警告を無視しない

公式プラグイン `security-guidance` が `Write/Edit` 時に出す警告（XSS・`eval`・`pickle`・command injection など）は必ず確認する。「警告は出たが動くからそのまま」を選ばない。修正アドバイスに従うか、安全な代替手段に置き換える。

<!-- TODO: プロジェクト固有のセキュリティルールを追加する（S6 以降に追記）

例（Supabase を使っている場合）:
## S6. RLS を無効化する提案をしない
RLS で詰まったら、ポリシーの書き方を直して解決する。

例（外部API を呼ぶ場合）:
## S7. APIキーは環境変数経由でのみ参照する
ハードコードしない。ログに出さない。
-->
