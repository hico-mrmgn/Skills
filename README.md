# Skills

Claude Code のスキル・エージェント・Hook 設定をまとめたマーケットプレイス。

「どのシチュエーションで使うか」で分類している。

---

## 構造

```
Skills/
├── .claude-plugin/
│   └── marketplace.json   # プラグイン一覧（カテゴリ付き）
├── plugins/
│   ├── pdm/               # PdM・上流（仕様・調査・コミュニケーション・Issue起票）
│   ├── regional/          # 地方創生・自治体向け（データ収集・納品物生成）
│   └── dev/               # 開発・エンジニアリング（実装・テスト・デプロイ・レビュー）
├── agents/                # 並行レビュー型エージェント（観点ごとに分担）
├── hooks/                 # Hook設定テンプレート（ファイル保存時・応答終了時）
├── templates/             # 新規プロジェクト初期化用の雛形
│   ├── CLAUDE.md.template       # 軽量な分岐表 + R1〜R5 のみ
│   ├── rules/                   # ドメイン別の恒常ルール（必要時に参照）
│   └── settings.json.template
└── .github/
    └── workflows/         # Reusable Workflow（夜間レビュー・PR自動レビュー）
```

### 使い分け

| 種類 | 場所 | 動き方 | 使う場面 |
|---|---|---|---|
| Skills | `plugins/<category>/` | 明示的に呼び出す | 「〇〇して」と指示したとき |
| Rules | `templates/rules/` | 関連作業のとき参照 | コーディング・Git・セキュリティ等 |
| Hooks | `hooks/`, `workflows/` | 自動実行 | ファイル保存時・会話終了時・夜間 |
| Agents | `agents/` | 並行実行 | コードレビューを観点ごとに分担させたいとき |

CLAUDE.md / rules / skills の3層分離方針は [zenn: CLAUDE.md の肥大化を 3 層構造で 83% 軽くした](https://zenn.dev/pepabo/articles/claude-code-rules-skills-split) を参照。

---

## シチュエーション別 Skill 一覧

### 🧭 PdM として使う（`plugins/pdm/`）

プロダクトの上流設計・ユーザー理解・社内外コミュニケーション・Issue起票を支える。

| プラグイン | 用途 | トリガーワード例 |
|---|---|---|
| [pdm-design-doc](./plugins/pdm/pdm-design-doc/) | Design Doc・仕様書の作成 | 「Design Docを作りたい」「仕様を整理したい」「何を作るか整理したい」 |
| [issue-intake](./plugins/pdm/issue-intake/) | As-Is / To-Be 形式の要望から重複チェック付きで Issue を起票 | 「Issue を作って」「As-Is To-Be で起票」「これチケットにして」 |
| [competitor-research](./plugins/pdm/competitor-research/) | 競合調査・比較表・市場分析 | 「競合を調査して」「他社と比較したい」「市場を調べて」 |
| [business-email](./plugins/pdm/business-email/) | ビジネスメール・提案書・議事録 | 「メールを書いて」「提案書を作りたい」「議事録を整理して」 |
| [data-analysis](./plugins/pdm/data-analysis/) | CSV/ExcelをPython/Pandasで分析 | 「CSVを分析して」「KPIを集計したい」「グラフを作って」 |

### 🌾 地方創生で使う（`plugins/regional/`）

自治体データ収集と納品物の生成。各 SKILL.md 内のプロジェクトルートパスや自治体名のサンプル値は、自分のプロジェクトに合わせて書き換えて使う。

| プラグイン | 用途 | トリガーワード例 |
|---|---|---|
| [municipality-data](./plugins/regional/municipality-data/) | 市区町村の窓口情報収集（担当課・電話・メール） | 「市区町村のデータを集めたい」「自治体の連絡先を取得したい」 |
| [report-generator](./plugins/regional/report-generator/) | 自治体向け実施報告書（.docx）・スライド（.pptx）の生成 | 「〇〇町の報告書を作って」「スライドを生成して」 |

### 💻 開発・エンジニアリングで使う（`plugins/dev/`）

実装・テスト・デプロイ・レビューの自動化、および Issue → PR の実装フロー。

| プラグイン | 用途 | トリガーワード例 |
|---|---|---|
| [github-issue-pr-flow](./plugins/dev/github-issue-pr-flow/) | 既存 Issue を Branch → 実装 → PR の順で消化 | 「#42 やって」「次の P1 やって」「○○を直して」 |
| [nextjs-mockup](./plugins/dev/nextjs-mockup/) | Next.js App Router + Ports & Adapters モックアップへの機能追加 | 「機能を追加して」「画面を作って」「モックデータを追加して」 |
| [lp-creator](./plugins/dev/lp-creator/) | スタンドアロンLP（HTML/CSS/JS）の作成 | 「LPを作って」「企業サイトを作りたい」 |
| [playwright-test](./plugins/dev/playwright-test/) | Playwright E2Eテスト作成・デバッグ | 「Playwrightでテストを書いて」「E2Eテストを追加したい」 |
| [vercel-deploy](./plugins/dev/vercel-deploy/) | Vercel デプロイ管理・ログ確認・トラブルシュート | 「デプロイして」「ビルドが失敗した」「ログを見せて」 |
| [code-review](./plugins/dev/code-review/) | コードを7軸で採点・分析しフィードバック | 「コードをレビューして」「採点して」「改善点を教えて」 |
| [claude-code-workflow](./plugins/dev/claude-code-workflow/) | Claude Code を使った日次コード分析・自動リファクタリングパイプライン設計 | 「夜間分析を組みたい」「Claude Codeで自動化したい」 |

#### 画面を作るとき、`nextjs-mockup` と `lp-creator` の選び方

| | `nextjs-mockup` | `lp-creator` |
|---|---|---|
| ビルドツール | あり（Next.js） | なし |
| 動的/静的 | 動的（API・状態管理あり） | 静的（HTML/CSS/JS のみ） |
| 用途 | プロダクトのモックアップ・プロトタイプ | LP・企業サイト・紹介ページ |

#### Issue → 実装の流れ

```
pdm-design-doc        (アイデア → Design Doc・仕様書)
       ↓
issue-intake          (As-Is/To-Be → Issue 起票)         ← plugins/pdm/
       ↓
github-issue-pr-flow  (Issue → ブランチ → 実装 → PR)    ← plugins/dev/
```

各スキルは一方向に渡すだけ。実装まで戻らない。

---

## エージェント（Agents）一覧

並行レビュー型。各エージェントは1つの観点だけを担当する。

| エージェント | 観点 |
|---|---|
| [yagni-reviewer](./agents/yagni-reviewer.md) | スコープ遵守・YAGNI |
| [abstraction-reviewer](./agents/abstraction-reviewer.md) | 抽象化の適切さ |
| [comment-reviewer](./agents/comment-reviewer.md) | コメントの品質 |
| [error-handling-reviewer](./agents/error-handling-reviewer.md) | エラーハンドリング |
| [security-reviewer](./agents/security-reviewer.md) | セキュリティ |
| [naming-reviewer](./agents/naming-reviewer.md) | 命名・可読性 |
| [dead-code-reviewer](./agents/dead-code-reviewer.md) | デッドコード |

---

## インストール方法

### Skills（プラグイン）

`~/.claude/settings.json` にマーケットプレイス登録を追加：

```json
"extraKnownMarketplaces": {
  "my-skills": {
    "source": {
      "source": "github",
      "repo": "hico-mrmgn/Skills"
    }
  }
}
```

その後、Claude Code で：

```
/plugin install plugin-name@my-skills
```

> **すでにインストール済みの場合**：プラグインのカテゴリ移動後、`/plugin marketplace update my-skills` で追従できる。それでも動かない場合は `/plugin uninstall <name>@my-skills` → `/plugin install <name>@my-skills` で入れ直し。

### Agents（エージェント）

プロジェクトの `.claude/agents/` にコピー：

```bash
cp /path/to/Skills/agents/*.md .claude/agents/
```

### Hooks

プロジェクトの `.claude/settings.json` に `hooks/common.json` の内容をマージ：

```bash
# 雛形からsettings.jsonを作成
cp /path/to/Skills/templates/settings.json.template .claude/settings.json
```

### Reusable Workflow（夜間レビュー）

プロジェクトの `.github/workflows/nightly.yml` に：

```yaml
jobs:
  review:
    uses: hico-mrmgn/Skills/.github/workflows/nightly-refactor.yml@main
    with:
      notify_slack: true
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
      SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## 育て方のルール

- 同じ手順を2回書いたら → `plugins/<category>/` にSkillを追加
- 同じレビュー指摘を2回したら → `agents/` にAgentを追加
- 同じ手動チェックを2回したら → `hooks/` か `workflows/` に自動化を追加
- 同じ恒常ルールを2回書いたら → `templates/rules/<topic>.md` に追加（CLAUDE.mdに直書きしない）

### 新しい Skill を追加するとき

1. **シチュエーションを先に決める**（PdM / regional / dev）
   - 該当カテゴリが無ければ新設してよい（例：`marketing/`, `sales/`）
2. `plugins/<category>/<plugin-name>/` を作成
3. `.claude-plugin/marketplace.json` の `plugins[]` にエントリを追加
   - `name`, `source`, `description`, `category` を埋める
