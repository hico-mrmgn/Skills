# Skills

個人用 Claude Code スキル・エージェント・Hook設定のマーケットプレイス。

---

## 構造

```
Skills/
├── plugins/             # 明示呼び出し型スキル（/skill-name で使う）
├── agents/              # 並行レビュー型エージェント（観点ごとに分担）
├── hooks/               # Hook設定テンプレート（ファイル保存時・応答終了時）
├── templates/           # 新規プロジェクト初期化用の雛形
│   ├── CLAUDE.md.template      # 軽量な分岐表 + R1〜R5 のみ
│   ├── rules/                  # ドメイン別の恒常ルール（必要時に参照）
│   └── settings.json.template
└── .github/
    └── workflows/       # Reusable Workflow（夜間レビュー・PR自動レビュー）
```

### 使い分け

| 種類 | 場所 | 動き方 | 使う場面 |
|---|---|---|---|
| Skills | `plugins/` | 明示的に呼び出す | 「〇〇して」と指示したとき |
| Rules | `templates/rules/` | 関連作業のとき参照 | コーディング・Git・セキュリティ等 |
| Hooks | `hooks/`, `workflows/` | 自動実行 | ファイル保存時・会話終了時・夜間 |
| Agents | `agents/` | 並行実行 | コードレビューを観点ごとに分担させたいとき |

CLAUDE.md / rules / skills の3層分離方針は [zenn: CLAUDE.md の肥大化を 3 層構造で 83% 軽くした](https://zenn.dev/pepabo/articles/claude-code-rules-skills-split) を参照。

---

## プラグイン（Skills）一覧

| プラグイン | 説明 | トリガーワード例 |
|---|---|---|
| [nextjs-mockup](./plugins/nextjs-mockup/) | Next.js App Router + Ports & Adapters モックアップへの機能追加 | 「機能を追加して」「画面を作って」「モックデータを追加して」 |
| [pdm-voice-to-problem](./plugins/pdm-voice-to-problem/) | ユーザーの声→問題定義サマリー（Playbook Skill 1） | 「ユーザーの声を整理したい」「CSチケットから問題を抽出」「VoCを分析」 |
| [pdm-design-doc](./plugins/pdm-design-doc/) | Design Doc・仕様書の作成（Playbook Skill 2-3） | 「Design Docを作りたい」「仕様書を書きたい」「何を作るか整理したい」 |
| [pdm-spec-to-prompt](./plugins/pdm-spec-to-prompt/) | 仕様書→AI実装プロンプト（Playbook Skill 4） | 「仕様書からプロンプトを作って」「Cursor/v0に渡す指示が欲しい」 |
| [pdm-priority-matrix](./plugins/pdm-priority-matrix/) | Impact×Effort×戦略整合性で優先順位（Playbook Skill 5） | 「優先順位を決めて」「どれから手を付ける？」「ロードマップを組みたい」 |
| [pdm-scope-management](./plugins/pdm-scope-management/) | MoSCoW法でリリーススコープ管理（Playbook Skill 6） | 「スコープを整理したい」「Won't リストを作りたい」「期日に間に合わない」 |
| [municipality-data](./plugins/municipality-data/) | 市区町村の窓口情報（担当課・電話・メール）収集 | 「市区町村のデータを集めたい」「自治体の連絡先を取得したい」 |
| [report-generator](./plugins/report-generator/) | 自治体向け実施報告書（.docx）・スライド（.pptx）の自動生成 | 「〇〇町の報告書を作って」「スライドを生成して」 |
| [lp-creator](./plugins/lp-creator/) | スタンドアロンLP（HTML/CSS/JS）の作成 | 「LPを作って」「〇〇のサイトを作って」「企業サイトを作りたい」 |
| [vercel-deploy](./plugins/vercel-deploy/) | Vercel デプロイ管理・ログ確認・トラブルシュート | 「デプロイして」「ビルドが失敗した」「ログを見せて」 |
| [playwright-test](./plugins/playwright-test/) | Playwright E2Eテスト作成・デバッグ | 「Playwrightでテストを書いて」「E2Eテストを追加したい」「テストが落ちている」 |
| [dom-explorer](./plugins/dom-explorer/) | DOM 探索・セレクタ特定・要素デバッグ（Playwright + 静的HTML） | 「セレクタが見つからない」「DOM構造を調べて」「Shadow DOMを調査」「HTMLをパースして抽出」 |
| [data-analysis](./plugins/data-analysis/) | CSV/ExcelデータをPython/Pandasで分析・可視化 | 「CSVを分析して」「データを集計したい」「グラフを作って」 |
| [business-email](./plugins/business-email/) | ビジネスメール・提案書・議事録などの文書作成 | 「メールを書いて」「提案書のドラフトを作りたい」「議事録を整理して」 |
| [competitor-research](./plugins/competitor-research/) | 競合調査・比較表・市場分析レポートの作成 | 「競合を調査して」「他社と比較したい」「競合比較表を作って」 |
| [code-review](./plugins/code-review/) | コードを7軸で採点・分析しフィードバック | 「コードをレビューして」「採点して」「改善点を教えて」 |
| [claude-code-workflow](./plugins/claude-code-workflow/) | Claude Code 自動コード分析・夜間リファクタリングパイプラインの設計 | 「自動リファクタリング」「GitHub Actions で夜間分析」「Issue 自動作成」「Slack 通知」 |

### PdM スキル群のフロー

[PdM-Playbook](https://github.com/hico-mrmgn/PdM-Playbook) の Skill 1〜6 を上記5つのプラグインでカバー。
だいたいこの順に呼ぶ：

```
ユーザーの声         問題定義          Design Doc       仕様書           実装プロンプト
──────────────  →  ──────────  →  ──────────  →  ──────────  →  ──────────────
pdm-voice-           pdm-design-doc                                 pdm-spec-
to-problem           （Skill 2-3 を統合）                           to-prompt
(Skill 1)                                                           (Skill 4)

                         ↓ 並走
        pdm-priority-matrix（優先順位 / Skill 5）
        pdm-scope-management（リリーススコープ / Skill 6）
```

途中から始めても良い。声が整理済みなら `pdm-design-doc` から、仕様書があるなら `pdm-spec-to-prompt` から呼べる。

---

## 推奨される Anthropic 公式プラグイン

当リポのスキル群と組み合わせて使うと効果的な、Anthropic 公式マーケットプレイス（`anthropics-claude-code`）のプラグイン。公式マーケットプレイスは Claude Code 起動時に自動で利用可能。

| プラグイン | 役割 | 当リポとの関係 |
|---|---|---|
| [`commit-commands`](https://claude.com/plugins/commit-commands) | `/commit` `/commit-push-pr` `/clean_gone` で Git コミット・PR 作成・ブランチ掃除を自動化 | 当リポに無い機能を補完。`templates/rules/git.md` のメッセージ規約と整合 |
| [`security-guidance`](https://claude.com/plugins/security-guidance) | `Write` / `Edit` / `MultiEdit` 時に XSS・eval・pickle・command injection 等の脆弱パターンを `PreToolUse` フックで検出・警告 | 当リポの `hooks/common.json`（コマンド単位のブロック）とは別レイヤー。コード**内容**の即時警告を担当 |

### インストール

Claude Code で：

```
/plugin install commit-commands@anthropics-claude-code
/plugin install security-guidance@anthropics-claude-code
```

両方ともコマンド/フックは自動で有効化される。`security-guidance` は警告がセッション単位で1回のみ表示されるので疲労感が少ない。

### 当リポのスキル群との使い分け

- **コミット**: 通常は `/commit`（公式）。`templates/rules/git.md` の G2〜G5 を破らない範囲で使う
- **セキュリティ**:
  - 実装中の即時検知 → `security-guidance`（公式・自動）
  - PR 段階のレビュー → `agents/security-reviewer.md`（並行レビュー）
  - 恒常ルール → `templates/rules/security.md`
  - コマンドブロック（rm -rf 等） → `hooks/common.json`

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

- 同じ手順を2回書いたら → `plugins/` にSkillを追加
- 同じレビュー指摘を2回したら → `agents/` にAgentを追加
- 同じ手動チェックを2回したら → `hooks/` か `workflows/` に自動化を追加
- 同じ恒常ルールを2回書いたら → `templates/rules/<topic>.md` に追加（CLAUDE.mdに直書きしない）
