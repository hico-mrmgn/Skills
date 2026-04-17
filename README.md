# Skills

個人用 Claude Code スキル・プラグインのマーケットプレイス。

## プラグイン一覧

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

## インストール方法

Claude Code で以下を実行:

```
/plugin install plugin-name@my-skills
```

## ディレクトリ構造

```
Skills/
└── plugins/
    └── plugin-name/
        ├── .claude-plugin/
        │   └── plugin.json     # プラグインのマニフェスト
        └── skills/
            └── skill-name/
                └── SKILL.md    # スキル定義
```

## マーケットプレイス登録設定

`~/.claude/settings.json` に以下を追加済み:

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
