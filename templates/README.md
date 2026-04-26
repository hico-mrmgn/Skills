# Templates

新規プロジェクト初期化用の雛形。**3層構造**で CLAUDE.md の肥大化を防ぐ。

## 3層構造

[zenn: CLAUDE.md の肥大化を 3 層構造で 83% 軽くした](https://zenn.dev/pepabo/articles/claude-code-rules-skills-split) の原則に従う：

| 層 | 役割 | ロードタイミング |
|---|---|---|
| **CLAUDE.md** | 軽量な分岐表 + クリティカルなR1〜R5のみ | セッション開始時に毎回 |
| **rules/`<topic>`.md** | ドメイン別の恒常ルール | 関連作業に着手したとき参照 |
| **skills/`<name>`/SKILL.md** | 明示呼び出し型ワークフロー | スキル呼び出し時のみ |

「インデックスは軽く、中身は必要なときに読み込む」が原則。

## ファイル一覧

| ファイル | 配置先 | 用途 |
|---|---|---|
| [CLAUDE.md.template](./CLAUDE.md.template) | プロジェクトルート | プロジェクト CLAUDE.md の雛形（分岐表 + R1〜R5） |
| [rules/coding.md](./rules/coding.md) | `.claude/rules/` | コーディング恒常ルール |
| [rules/security.md](./rules/security.md) | `.claude/rules/` | セキュリティ恒常ルール |
| [rules/git.md](./rules/git.md) | `.claude/rules/` | Git 操作恒常ルール |
| [rules/process.md](./rules/process.md) | `.claude/rules/` | 作業プロセス恒常ルール |
| [rules/anti-patterns.md](./rules/anti-patterns.md) | `.claude/rules/` | やりがちな事故パターン集 |
| [settings.json.template](./settings.json.template) | `.claude/settings.json` | プロジェクト個別の Claude Code 設定 |
| [user-settings.json.template](./user-settings.json.template) | `~/.claude/settings.json` | user 全体の Claude Code 設定（marketplace 登録） |

## 使い方

### user 全体のセットアップ（1回だけ）

リポジトリのルートで：

```bash
bash bin/install.sh
```

これで `~/.claude/settings.json` への marketplace 登録と `~/.claude/agents/` への agents コピーが完了する。詳細はルートの [README.md「インストール方法」](../README.md#インストール方法) を参照。

### プロジェクト個別のセットアップ（新規プロジェクトごと）

```bash
# CLAUDE.md を雛形からコピー
cp /path/to/Skills/templates/CLAUDE.md.template ./CLAUDE.md

# rules/ 一式をコピー
mkdir -p .claude/rules
cp /path/to/Skills/templates/rules/*.md .claude/rules/
```

`settings.json.template` はプロジェクト固有の hook を入れたいときだけ使う（user 全体に同じ hook が入っているなら不要）：

```bash
mkdir -p .claude
cp /path/to/Skills/templates/settings.json.template .claude/settings.json
```

## カスタマイズ方針

- **CLAUDE.md.template** — `<!-- TODO -->` を埋める。**新ルールを直書きしない**（rules/ に追加する）
- **rules/`<topic>`.md** — 既存のドメインに合えば追記、合わなければ新規ファイルを足す
- 新しい rules ファイルを作ったら CLAUDE.md の「詳細ルール」表にも追加する

## プレースホルダー一覧

| プレースホルダー | 説明 |
|---|---|
| `{{PROJECT_NAME}}` | プロジェクト名 |
| `{{TECH_STACK}}` | 技術スタック（例：Next.js + Supabase） |
| `{{REPO_URL}}` | GitHubリポジトリURL |
