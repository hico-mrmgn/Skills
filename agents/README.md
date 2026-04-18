# Agents

並行レビュー型エージェント（Level 5）。各エージェントは**1つの観点だけ**を担当し、独立して並行実行される。

## エージェント一覧

| エージェント | 観点 | 主なチェック内容 |
|---|---|---|
| [yagni-reviewer](./yagni-reviewer.md) | スコープ遵守・YAGNI | 依頼外機能・将来のための追加・未使用引数 |
| [abstraction-reviewer](./abstraction-reviewer.md) | 抽象化の適切さ | 早すぎる抽象化・3箇所以上の繰り返し |
| [comment-reviewer](./comment-reviewer.md) | コメントの品質 | WHATコメント・腐るコメント |
| [error-handling-reviewer](./error-handling-reviewer.md) | エラーハンドリング | 過剰防御・境界の無防備 |
| [security-reviewer](./security-reviewer.md) | セキュリティ | OWASP Top 10・秘密情報露出 |
| [naming-reviewer](./naming-reviewer.md) | 命名・可読性 | 型情報混入・意味のない名前・動詞なし関数名 |
| [dead-code-reviewer](./dead-code-reviewer.md) | デッドコード | _リネーム・コメントアウト・未使用import |
| [type-safety-reviewer](./type-safety-reviewer.md) | 型安全性 | `any`・型アサーション・非null assertion・網羅性 |

## 使い方

プロジェクトの `.claude/agents/` にコピーして使う。

```bash
cp /path/to/Skills/agents/*.md .claude/agents/
```

または `/init-project` スキルを使えば自動でコピーされる。

## 並行実行の原則

各エージェントは「この観点だけを見る」と明記されている。
これにより、Claude Code が並行でエージェントを実行しても観点が重複しない。

全観点をまとめてレビューしたい場合は `plugins/code-review` のスキルを使う。
