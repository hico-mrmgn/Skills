# Skills

個人用 Claude Code スキル・エージェント・Hook設定のマーケットプレイス。

Level 3（Skills）・Level 4（Hooks/Workflows）・Level 5（Agents）の3層構造で育てる。

---

## 構造

```
Skills/
├── plugins/       # Level 3: 明示呼び出し型スキル（/skill-name で使う）
├── agents/        # Level 5: 並行レビュー型エージェント（観点ごとに分担）
├── hooks/         # Level 4: Hook設定テンプレート（ファイル保存時・応答終了時）
├── templates/     # 新規プロジェクト初期化用の雛形
└── .github/
    └── workflows/ # Level 4: Reusable Workflow（夜間レビュー・PR自動レビュー）
```

### 3層の使い分け

| 層 | 場所 | 動き方 | 使う場面 |
|---|---|---|---|
| Skills（Level 3） | `plugins/` | 明示的に呼び出す | 「〇〇して」と指示したとき |
| Hooks（Level 4） | `hooks/`, `workflows/` | 自動実行 | ファイル保存時・会話終了時・夜間 |
| Agents（Level 5） | `agents/` | 並行実行 | コードレビューを観点ごとに分担させたいとき |

---

## プラグイン（Skills）一覧

| プラグイン | 説明 | トリガーワード例 |
|---|---|---|
| [nextjs-mockup](./plugins/nextjs-mockup/) | Next.js App Router + Ports & Adapters モックアップへの機能追加 | 「機能を追加して」「画面を作って」「モックデータを追加して」 |
| [pdm-design-doc](./plugins/pdm-design-doc/) | PdM Design Doc・仕様書の作成 | 「Design Docを作りたい」「機能の仕様を整理したい」「何を作るか整理したい」 |
| [municipality-data](./plugins/municipality-data/) | 市区町村の窓口情報（担当課・電話・メール）収集 | 「市区町村のデータを集めたい」「自治体の連絡先を取得したい」 |
| [report-generator](./plugins/report-generator/) | 自治体向け実施報告書（.docx）・スライド（.pptx）の自動生成 | 「〇〇町の報告書を作って」「スライドを生成して」 |
| [lp-creator](./plugins/lp-creator/) | スタンドアロンLP（HTML/CSS/JS）の作成 | 「LPを作って」「〇〇のサイトを作って」「企業サイトを作りたい」 |
| [vercel-deploy](./plugins/vercel-deploy/) | Vercel デプロイ管理・ログ確認・トラブルシュート | 「デプロイして」「ビルドが失敗した」「ログを見せて」 |
| [playwright-test](./plugins/playwright-test/) | Playwright E2Eテスト作成・デバッグ | 「Playwrightでテストを書いて」「E2Eテストを追加したい」「テストが落ちている」 |
| [data-analysis](./plugins/data-analysis/) | CSV/ExcelデータをPython/Pandasで分析・可視化 | 「CSVを分析して」「データを集計したい」「グラフを作って」 |
| [business-email](./plugins/business-email/) | ビジネスメール・提案書・議事録などの文書作成 | 「メールを書いて」「提案書のドラフトを作りたい」「議事録を整理して」 |
| [competitor-research](./plugins/competitor-research/) | 競合調査・比較表・市場分析レポートの作成 | 「競合を調査して」「他社と比較したい」「競合比較表を作って」 |
| [code-review](./plugins/code-review/) | コードを7軸で採点・分析しフィードバック | 「コードをレビューして」「採点して」「改善点を教えて」 |

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
    uses: hico-mrmgn/Skills/.github/workflows/nightly-review.yml@main
    with:
      target_paths: "src/**"
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
      SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## 育て方のルール

- 同じ手順を2回書いたら → `plugins/` にSkillを追加
- 同じレビュー指摘を2回したら → `agents/` にAgentを追加
- 同じ手動チェックを2回したら → `hooks/` か `workflows/` に自動化を追加
