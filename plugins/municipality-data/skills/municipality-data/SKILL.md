---
name: municipality-data
description: 市区町村の窓口情報（担当課・電話・メール・移住促進URL）を収集・整備するスクレイピングワークフロースキル。「市区町村のデータを集めたい」「自治体の連絡先を取得したい」「移住窓口の情報を更新したい」「スクレイピングスクリプトを書きたい」「municipalities_master.csvを更新したい」など、自治体データ収集・整備が絡む作業では必ずこのスキルを参照すること。
---

# 市区町村データ収集スキル

自治体の公式サイトや外部ポータルから、移住相談窓口の担当課・電話番号・メールアドレス・移住促進URLを収集・整備するワークフロー。

**プロジェクトルート:** `/Users/katotomohico/Desktop/移住のすゝめ/`
**スクリプト:** `scripts/`
**データ:** `data/municipalities_master.csv`

---

## データ構造

`municipalities_master.csv` の15フィールド：

| # | フィールド | 説明 |
|---|---|---|
| 1 | 団体コード | 総務省コード（8桁） |
| 2 | 都道府県コード | 01〜47 |
| 3 | 都道府県名 | |
| 4 | 市区町村名 | |
| 5 | 担当課名 | 移住担当窓口の課名 |
| 6 | 担当係名 | （未活用） |
| 7 | 電話番号 | `0XX-XXXX-XXXX` 形式 |
| 8 | メールアドレス | `.lg.jp` 優先、個人メール除外済み |
| 9 | 担当者名 | JOINから部分的に取得 |
| 10 | 移住促進サイトURL | 移住専用ページ |
| 11 | 公式サイトURL | e-gov または公開リスト |
| 12 | SMOUT登録 | （フラグ、未活用） |
| 13 | JOIN加盟 | （フラグ、未活用） |
| 14 | 備考 | データソース記録 |
| 15 | 更新日 | `YYYY-MM-DD` |

---

## 全件更新フロー（6フェーズ）

データを最初から作り直す場合はこの順番で実行する。各フェーズは前フェーズの出力に依存している。

### Phase 1: 基盤構築

```bash
node scripts/fetch_municipalities.js
```

- 入力: `data/municipalities_raw.xlsx`（総務省最新版）+ `data/egov_websites.csv`（e-gov公式URL）
- 出力: `data/municipalities_master.csv`（団体コード + 公式URL のみ）

### Phase 2: 基本スクレイピング（並列実行可）

```bash
node scripts/run_by_prefecture.js   # 移住担当課名・電話・メール・移住促進URLを取得
node scripts/scrape_org_pages.js    # 組織案内ページから課名を補完
node scripts/scrape_phones.js       # 電話番号を取得・フォーマット標準化
```

`run_by_prefecture.js` は途中中断しても再開できる（`data/scrape_progress.json` で進捗管理）。最初からやり直すときは `--reset` フラグを付ける。

### Phase 3: 深掘り補完

```bash
node scripts/scrape_deep.js              # メール未取得の自治体を最大8ページ探索
node scripts/cleanup_and_scrape_missing.js  # 個人名メールを削除 → 課名有りの自治体からメール再取得
node scripts/scrape_emails_deep2.js      # 課名+電話有・メール無しを最大10ページ探索
```

### Phase 4: 推定・補完

```bash
node scripts/infer_departments.js   # メールアドレスのプレフィックスから課名を推定
```

### Phase 5: 外部ポータル統合（優先度順に実行）

ポータルデータは自治体ホームページより最新・正確なため、上書き優先で統合する。

```bash
node scripts/merge_hokkaido.js    # 北海道（くらそ北海道）237件
node scripts/merge_portals.js     # 福岡・山形・島根・山口・和歌山・千葉の各県ポータル
node scripts/scrape_join.js       # ニッポン移住・交流ナビ（JOIN）全47都道府県
node scripts/merge_portals2.js    # 埼玉・神奈川・京都・東京の第2弾ポータル
```

### Phase 6: 最終クリーニング

```bash
node scripts/final_cleanup.js
```

残存する個人名メール・ゴミ課名を除外し、完成度の統計を表示する。

---

## 部分更新（特定都道府県だけ再取得したいとき）

```bash
# 例: 北海道だけ再実行
node scripts/run_by_prefecture.js --prefecture 北海道

# 例: メール未取得の自治体だけ補完
node scripts/scrape_deep.js

# 例: 外部ポータルだけ再統合
node scripts/scrape_join.js
```

---

## 新しいスクレイピングスクリプトを書くとき

既存のパターンに合わせて実装する。

### 基本構造

```javascript
const fs = require('fs');
const axios = require('axios');
const cheerio = require('cheerio');

const DATA_FILE = '../data/municipalities_master.csv';
const LOG_FILE = '../data/xxx_log.txt';
const REQUEST_DELAY = 1500;  // サーバ負荷軽減のため1.5秒待機
const TIMEOUT = 10000;

// ページ取得
async function fetchPage(url) {
  const res = await axios.get(url, {
    timeout: TIMEOUT,
    headers: {
      'User-Agent': 'Mozilla/5.0 (compatible; ResearchBot/1.0)'
    },
    maxRedirects: 5
  });
  return res.data;
}

// Shift_JIS対応が必要な場合
const iconv = require('iconv-lite');
const res = await axios.get(url, { responseType: 'arraybuffer' });
const html = iconv.decode(Buffer.from(res.data), 'Shift_JIS');
```

### メールアドレス抽出

```javascript
const EMAIL_PATTERN = /[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}/g;

function extractEmails(html) {
  const $ = cheerio.load(html);
  const emails = new Set();

  // mailto: リンクから抽出（最優先）
  $('a[href^="mailto:"]').each((_, el) => {
    const href = $(el).attr('href');
    const email = href.replace('mailto:', '').split('?')[0].trim();
    if (email) emails.add(email);
  });

  // テキストから正規表現で抽出
  const bodyText = $('body').text();
  const matches = bodyText.match(EMAIL_PATTERN) || [];
  matches.forEach(e => emails.add(e));

  return [...emails];
}

// .lg.jp を優先して選ぶ
function pickBestEmail(emails) {
  const lgjp = emails.filter(e => e.endsWith('.lg.jp'));
  if (lgjp.length > 0) return lgjp[0];
  const gojp = emails.filter(e => e.endsWith('.go.jp'));
  if (gojp.length > 0) return gojp[0];
  return emails[0] || '';
}
```

### 電話番号抽出

```javascript
function extractPhone(html) {
  const $ = cheerio.load(html);
  const text = $('body').text();
  const matches = text.match(/0\d{1,4}[-－ー]\d{1,4}[-－ー]\d{3,4}/g) || [];
  // 最初に見つかったものを標準フォーマットに変換
  return matches[0]?.replace(/[－ー]/g, '-') || '';
}
```

### 課名抽出

```javascript
const DEPT_KEYWORDS = ['移住', '定住', '地方創生', '地域振興', 'まちづくり', '企画'];
const DEPT_SUFFIXES = ['課', '室', '局', '部', 'センター', '係'];

function extractDeptName($) {
  let bestMatch = '';
  let bestScore = 0;

  $('*').each((_, el) => {
    const text = $(el).text().trim();
    if (text.length > 20 || text.length < 3) return;

    const hasSuffix = DEPT_SUFFIXES.some(s => text.endsWith(s));
    if (!hasSuffix) return;

    const score = DEPT_KEYWORDS.filter(k => text.includes(k)).length;
    if (score > bestScore) {
      bestScore = score;
      bestMatch = text;
    }
  });

  return bestMatch;
}
```

### リンクのスコアリング（移住関連ページを優先探索）

```javascript
function scoreLinkForMigration(href, text) {
  let score = 0;
  const url = href.toLowerCase();
  const label = text.toLowerCase();

  if (/iju|teiju|ijuu/.test(url)) score += 10;
  if (/kurasu|sumu|sumai/.test(url)) score += 8;
  if (/soshiki|organization/.test(url)) score += 7;
  if (/contact|toiawase|inquiry/.test(url)) score += 6;
  if (label.includes('移住') || label.includes('定住')) score += 3;
  if (label.includes('組織') || label.includes('部署')) score += 2;

  return score;
}

// スコア上位N件だけ訪問
const links = $('a[href]').toArray()
  .map(el => ({
    href: $(el).attr('href'),
    text: $(el).text().trim(),
    score: scoreLinkForMigration($(el).attr('href'), $(el).text())
  }))
  .filter(l => l.score > 0)
  .sort((a, b) => b.score - a.score)
  .slice(0, 6);
```

### 個人名メール判定

```javascript
function isPersonalEmail(email) {
  const local = email.split('@')[0].toLowerCase();

  // 部署キーワードが含まれていれば部署メール
  const deptKeywords = ['iju', 'kikaku', 'chiiki', 'machi', 'sousei', 'soumu', 'kanko'];
  if (deptKeywords.some(k => local.includes(k))) return false;

  // フリーメール
  if (/@(gmail|yahoo|hotmail)/.test(email)) return true;

  // 名.姓パターン
  if (/^[a-z]{2,10}\.[a-z]{3,12}$/.test(local)) return true;

  // 姓-イニシャル / イニシャル-姓
  if (/^[a-z]{4,12}-[a-z]$/.test(local)) return true;
  if (/^[a-z]-[a-z]{3,12}$/.test(local)) return true;

  return false;
}
```

### CSV操作

```javascript
// BOM付きUTF-8で読み書き（Excelで文字化けしないように）
const content = fs.readFileSync(DATA_FILE, 'utf-8').replace(/^\uFEFF/, '');

function escapeCSV(val) {
  const s = String(val ?? '');
  if (s.includes(',') || s.includes('"') || s.includes('\n')) {
    return '"' + s.replace(/"/g, '""') + '"';
  }
  return s;
}

function writeCSV(rows, headers) {
  const lines = [
    headers.map(escapeCSV).join(','),
    ...rows.map(r => headers.map(h => escapeCSV(r[h])).join(','))
  ];
  fs.writeFileSync(DATA_FILE, '\uFEFF' + lines.join('\n'), 'utf-8');
}
```

### 途中保存（大量処理時の損失防止）

```javascript
let processedCount = 0;

for (const municipality of municipalities) {
  // ... 処理 ...
  processedCount++;

  // 10件ごとに保存
  if (processedCount % 10 === 0) {
    writeCSV(municipalities, HEADERS);
    console.log(`${processedCount}件処理済み、保存しました`);
  }

  await sleep(REQUEST_DELAY);
}

// 最終保存
writeCSV(municipalities, HEADERS);

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
```

---

## よくあるGotchas

- **文字コード**: 古い自治体サイトは Shift_JIS または EUC-JP。`iconv-lite` で変換する
- **リクエスト間隔**: 最低1.5秒待機。自治体サーバはリソースが限られている
- **途中保存**: 1,741件を一気に処理すると数時間かかる。10〜30件ごとに保存して中断に備える
- **ポータル優先**: 都道府県ポータルやJOINのデータはスクレイピングより信頼度が高い。必ず上書き優先で統合する
- **メールの信頼度順位**: `.lg.jp` > `.go.jp` > その他。個人名判定は必ずかける
- **ゴミ課名**: 地域名（「北部」「南部」）、施設名（「スポーツセンター」）、住所（「丁目」「番地」含む）は除外する
