# Skills

個人用 Claude Code スキル・プラグインのマーケットプレイス。

## 構造

```
Skills/
└── plugins/
    └── plugin-name/
        ├── .claude-plugin/
        │   └── plugin.json     # プラグインのマニフェスト
        ├── skills/
        │   └── skill-name/
        │       └── SKILL.md    # スキル定義
        └── commands/
            └── command.md      # スラッシュコマンド定義
```

## インストール方法

Claude Code で以下を実行:

```
/plugin install plugin-name@my-skills
```

## 登録されたマーケットプレイス

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
