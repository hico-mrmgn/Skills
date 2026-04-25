---
name: dom-explorer
description: Webページの DOM 探索・セレクタ特定・要素デバッグを行うスキル。「セレクタが見つからない」「要素を特定したい」「DOM構造を調べて」「getByRole で取れない」「Shadow DOM を調査」「iframe の中を見たい」「アクセシビリティツリーを確認」「スクレイピング前に構造を解析」「HTML をパースして要素を抽出」「動的に追加される要素を待つ」など、DOM の探索・解析・セレクタ発掘が絡む作業では必ずこのスキルを参照すること。Playwright 優先・静的 HTML（cheerio/jsdom）にも対応。
---

# DOM 探索スキル

セレクタ探し・構造把握・要素デバッグを最短で済ませる。
**E2E テスト（Playwright）と静的 HTML 解析の両方** をカバーする。

---

## まず確認すること

1. **何のために DOM を探すか** — テストのセレクタ／スクレイピング前調査／UI バグ再現／アクセシビリティ確認
2. **対象がどんなページか** — ログイン要否・SPA か静的 HTML か・JS で動的生成されるか
3. **既存環境** — Playwright 入っているか／Node のみか／ブラウザを開ける環境か

これに応じて下のアプローチ表からルートを選ぶ。

---

## アプローチの選択

| 状況 | 使うもの |
|---|---|
| E2E テストのセレクタを探したい | **Playwright codegen** + Inspector |
| 動的 SPA の状態を調べたい | **Playwright** で `page.evaluate` / `accessibility.snapshot` |
| 静的 HTML を解析したい（軽量・速い） | **cheerio**（jQuery 風 API） |
| 静的 HTML を DOM API で扱いたい | **jsdom** |
| 手動でブラウザ越しに確認したい | **Chrome DevTools** + Console API |
| Shadow DOM / iframe が絡む | **Playwright**（自動でピアース／フレーム切り替え） |

「とりあえず Playwright」が最も汎用。静的 HTML だけで済むなら cheerio が圧倒的に速い。

---

## ロケーター戦略（Playwright）

セレクタは以下の順で探す。**上ほど壊れにくい**：

1. `getByRole('button', { name: '送信' })` — アクセシビリティロール（最優先）
2. `getByLabel('メールアドレス')` — フォームラベル
3. `getByPlaceholder('検索...')` — プレースホルダー
4. `getByText('続きを読む')` — 表示テキスト
5. `getByTestId('submit-btn')` — `data-testid`（最終手段）
6. `locator('css=...')` / `locator('xpath=...')` — CSS / XPath（最終手段の最終手段）

CSS セレクタや `nth-child` に頼ると DOM 構造変更で即壊れる。アクセシブルでない UI なら `data-testid` を**プロダクトコード側に追加してから**テストを書く。

---

## Playwright で DOM を調べる

### codegen で操作を録画 → セレクタを得る

```bash
# ブラウザを起動して操作 → コードが自動生成される
npx playwright codegen http://localhost:3000

# 認証が必要なページなら storageState を渡す
npx playwright codegen --load-storage e2e/.auth/user.json http://localhost:3000/dashboard
```

生成されたロケーターをそのまま使うのではなく、`getByRole` 優先順に整理してからテストに反映する。

### Inspector で要素を hover してロケーター候補を見る

```bash
PWDEBUG=1 npx playwright test
# または
npx playwright test --ui
```

Pick locator ボタンで要素クリック → 推奨ロケーターが表示される。

### アクセシビリティツリーをダンプ

`getByRole` で取れない要素は、ロール構造そのものを確認する：

```typescript
test('a11y tree を確認', async ({ page }) => {
  await page.goto('/');
  const snapshot = await page.accessibility.snapshot();
  console.log(JSON.stringify(snapshot, null, 2));
});
```

ロールが `generic` ばかりなら、HTML がセマンティックでないサイン（`<div>` だらけ）。

### 任意の JS で DOM を直接調べる

```typescript
// 全 a タグの href を抜く
const hrefs = await page.$$eval('a', (anchors) => anchors.map((a) => a.href));

// 特定要素の属性をすべて見る
const attrs = await page.locator('button.submit').evaluate((el) =>
  Object.fromEntries([...el.attributes].map((a) => [a.name, a.value]))
);

// 計算済みスタイルを見る（display:none チェックなど）
const display = await page.locator('#target').evaluate(
  (el) => getComputedStyle(el).display
);
```

### ロケーターが 0 件 / 複数ヒットのとき

```typescript
const button = page.getByRole('button', { name: '送信' });
console.log(await button.count()); // 0 → 名前が違う / 表示前 / iframe 内
                                    // 2+ → strict mode 違反 → 条件を絞る

// 周辺 HTML を確認
console.log(await page.locator('form').innerHTML());
```

---

## 静的 HTML を解析する

### cheerio（jQuery 風・高速）

```typescript
import * as cheerio from 'cheerio';

const html = await fetch('https://example.com').then((r) => r.text());
const $ = cheerio.load(html);

// 全リンクのテキストと URL を抜く
$('a').each((_, el) => {
  console.log($(el).text(), $(el).attr('href'));
});

// 表をパース
const rows = $('table tr').map((_, tr) => ({
  cells: $(tr).find('td').map((_, td) => $(td).text().trim()).get(),
})).get();
```

JS で動的生成されるコンテンツは取れない（その場合は Playwright を使う）。

### jsdom（DOM API そのまま使いたいとき）

```typescript
import { JSDOM } from 'jsdom';

const dom = new JSDOM(html);
const doc = dom.window.document;

const titles = [...doc.querySelectorAll('h2')].map((h) => h.textContent);
```

cheerio より重いが `querySelector` / `getAttribute` 等の標準 API がそのまま使える。

---

## DevTools で手動探索

ブラウザで開いて Console から：

```javascript
// jQuery 風のショートカット
$('button.submit')        // 最初の1個
$$('button')              // 全部（配列）
$x('//button[text()="送信"]')  // XPath

// アクセシビリティロールで探す（実験的）
document.querySelector('button[aria-label="送信"]')

// 表示中の要素だけを抽出
$$('button').filter((b) => b.offsetParent !== null)

// イベントリスナーを確認
getEventListeners($('button.submit'))

// 要素を Elements パネルで開く
inspect($('button.submit'))
```

Elements パネルで要素を選択 → Console で `$0` で参照できる。

---

## Shadow DOM / iframe

### Shadow DOM

Playwright は自動でピアースする：

```typescript
// 通常通り書ける
await page.getByRole('button', { name: '送信' }).click();
```

DevTools Console は `>>>` セレクタで貫通：

```javascript
document.querySelector('my-component >>> button.submit');
```

cheerio / jsdom は Shadow DOM を扱えない（描画が必要）。

### iframe

```typescript
// Playwright
const frame = page.frameLocator('iframe[name="content"]');
await frame.getByRole('button').click();

// DevTools Console（フレーム選択ドロップダウンで切り替えてから操作）
```

---

## 動的に追加される要素

```typescript
// Playwright のロケーターは auto-wait（デフォルト 30s）
await page.getByText('読み込み完了').waitFor();

// ネットワーク完了を待つ
await page.waitForResponse('**/api/data');

// 特定の要素数を待つ
await expect(page.locator('.item')).toHaveCount(10);
```

`page.waitForTimeout(3000)` のような固定 sleep は **書かない**（フラキーの原因）。
要素・URL・レスポンスのいずれかで明示的に待つ。

---

## よくある詰まりパターン

| 症状 | 原因 / 対処 |
|---|---|
| `getByRole('button')` で 0 件 | `<div onClick>` で実装されている → `getByText` で取るか、プロダクト側に role 付与 |
| 同じ名前のボタンが複数 | `.first()` ではなくスコープを絞る（`page.getByRole('dialog').getByRole('button', ...)`) |
| `display:none` の要素を取りたい | `locator(...).evaluate(el => el.outerHTML)` で直接 DOM から取る |
| cheerio で取れない | JS 動的生成 → Playwright に切り替え |
| Shadow DOM で `querySelector` が無視される | Playwright を使う or `>>>` で貫通 |
| iframe 内が取れない | `frameLocator` でフレームに入る |
| codegen のセレクタが脆い | `nth-child` や CSS チェーン → `getByRole` 系に手動で書き直す |
| 表示されている文字で取れない | テキスト内に hidden な空白 / nbsp → `getByText(/送\s*信/)` で正規表現 |

---

## 探索の最短ルート（フローチャート）

```
何を取りたいか？
├── E2Eテストのセレクタ
│   └── codegen で当たり → getByRole 系に整理
├── スクレイピングの構造
│   ├── JS 不要 → cheerio で取得＆パース
│   └── JS 必要 → Playwright headless で取得 → cheerio に渡す
├── UIバグの再現
│   └── DevTools Elements + Console で $0 / getEventListeners
└── アクセシビリティ確認
    └── page.accessibility.snapshot() でツリーをダンプ
```

迷ったら **Playwright** を選ぶ。動的・静的どちらにも対応できる。
