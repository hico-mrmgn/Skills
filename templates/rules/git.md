# Git Rules

Git 操作の恒常ルール。

---

## G1. 破壊的操作の前に確認する

以下は実行前に必ずオーナーに確認する：

- `git push --force` / `--force-with-lease`
- `git reset --hard`
- `git checkout -- <file>` / `git restore .`
- `git clean -f`
- `git branch -D`

## G2. 既存コミットを amend しない

新しいコミットを積む。published commit の amend / rebase はしない（オーナー指示があれば例外）。

## G3. hook をスキップしない

`--no-verify` / `--no-gpg-sign` を使わない。hook が落ちたら原因を調べて直す。

## G4. ステージは名指しで行う

`git add -A` / `git add .` を避ける。`.env` などの混入リスクを下げるためファイル名を指定する。

## G5. コミットメッセージは「なぜ」を書く

「何をしたか」は diff に書いてある。「なぜそれをしたか」を1〜2文で書く。

## G6. `/commit` を優先する（commit-commands プラグイン）

公式プラグイン `commit-commands` が入っていれば、`/commit` でリポのコミットスタイルに合わせたメッセージを自動生成できる。手書きコミットより一貫性が出るのでこちらを優先する。
ただし G1〜G5（破壊的操作の確認・amend 禁止・hook 非スキップ・名指しステージ・WHY を書く）は同じく守る。

<!-- TODO: プロジェクト固有のGitルールを追加する

例:
## G6. main への直 push 禁止
すべての変更は PR 経由でレビューする。
-->
