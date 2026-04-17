---
name: report-generator
description: 自治体向け実施報告書（Word/.docx）とスライド（PowerPoint/.pptx）を自動生成するスキル。「〇〇町の報告書を作って」「スライドを生成して」「新しい自治体の報告書を作りたい」「create_report.jsを修正して」「docxやpptxを出力したい」など、自治体向け文書の自動生成が絡む作業では必ずこのスキルを参照すること。
---

# 自治体向け報告書・スライド自動生成スキル

Node.js で `.docx`（Word報告書）と `.pptx`（PowerPointスライド）を自動生成するワークフロー。

**プロジェクトルート:** `/Users/katotomohico/Desktop/移住のすゝめ/`
**報告書スクリプト:** `create_report.js`（`docx` ライブラリ使用）
**スライドスクリプト:** `create_slides.js`（`pptxgenjs` ライブラリ使用）

---

## 新しい自治体の報告書・スライドを作るときの手順

### Step 1: ディレクトリと画像を用意する

```bash
mkdir -p /Users/katotomohico/Desktop/移住のすゝめ/{自治体名}/
# 例: mkdir -p /Users/katotomohico/Desktop/移住のすゝめ/音威子府/
```

画像ファイルをそのディレクトリに配置する：
- **形式:** JPEG（`.jpg`）
- **推奨サイズ:** 4032×2268px（16:9）
- **枚数:** 報告書は最大9枚、スライドは内容に合わせて

### Step 2: config.json でデータを定義する

スクリプトを直接書き換えるのではなく、`config.json` に自治体情報を外出しして読み込む方式が保守しやすい。

```json
{
  "municipality": {
    "name": "音威子府村",
    "prefecture": "北海道",
    "reportTitle": "地域おこし協力隊募集及びお試し移住ツアー実施報告書",
    "submittedTo": "音威子府村役場",
    "reportDate": "令和7年3月",
    "imageDir": "/Users/katotomohico/Desktop/移住のすゝめ/音威子府/",
    "images": {
      "photo1": "IMG_0001.jpg",
      "photo2": "IMG_0002.jpg",
      "photo3": "IMG_0003.jpg",
      "photo4": "IMG_0004.jpg",
      "photo5": "IMG_0005.jpg",
      "photo6": "IMG_0006.jpg"
    }
  },
  "stats": {
    "totalInquiries": 12,
    "interviews": 4,
    "hired": 1
  },
  "tours": [
    {
      "round": 1,
      "date": "令和6年10月〇〇日〜〇〇日",
      "participants": 2,
      "schedule": [
        { "time": "1日目", "content": "現地視察・移住相談" },
        { "time": "2日目", "content": "体験プログラム" },
        { "time": "3日目", "content": "まとめ・帰路" }
      ],
      "photos": ["photo1", "photo2", "photo3", "photo4"]
    }
  ],
  "smout": [
    { "no": 1, "profile": "40代女性（〇〇市）", "interest": "農業体験", "result": "面談実施" }
  ]
}
```

スクリプト側でこう読み込む：
```javascript
const config = require('./config.json');
const { name, imageDir, images } = config.municipality;
```

### Step 3: スクリプトを実行する

```bash
cd /Users/katotomohico/Desktop/移住のすゝめ
npm install          # 初回のみ
node create_report.js
node create_slides.js
```

出力ファイル：
- `{自治体名}_協力隊募集及びお試し移住ツアー実施報告書.docx`
- `{自治体名}_実施報告書.pptx`

---

## 既存スクリプトの修正箇所チェックリスト

config.json 方式を使わず既存スクリプトを直接編集する場合、以下の箇所を差し替える。

### create_report.js

- [ ] `imgDir` — 画像ディレクトリパス
- [ ] 表紙テキスト（自治体名・事業タイトル・提出先・報告日）
- [ ] 事業概要表（事業名・対象地域・事業期間・委託元）
- [ ] SMOUT問い合わせ実績表の行データ
- [ ] その他チャネル実績表の行データ
- [ ] 第1回・第2回ツアーの基本情報表とスケジュール表
- [ ] `photoPair()` / `photoSingle()` の画像ファイル名とキャプション
- [ ] 参加実績・採用実績表
- [ ] Meta広告・Google広告の数値
- [ ] 総括の成果・課題リスト

### create_slides.js

- [ ] `pres.title` — プレゼンタイトル
- [ ] `imgDir` — 画像ディレクトリパス
- [ ] `imgs` オブジェクトの各画像ファイル名マッピング
- [ ] スライド1（表紙）のテキスト全般
- [ ] スライド2（事業概要）のテーブル内容
- [ ] スライド3〜5（問い合わせ関連）のテーブル行
- [ ] スライド6（まとめ）の統計数値（14名・3名・1名 等）
- [ ] スライド7・10（ツアー情報）の日程・参加者情報
- [ ] スライド8・9・11（写真スライド）の画像パスとキャプション
- [ ] スライド12（実績）の数値
- [ ] スライド13（広報）の数値とリスト
- [ ] スライド14（総括）の箇条書き

---

## docx ライブラリのパターン集

### 基本セットアップ

```javascript
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
        WidthType, AlignmentType, ImageRun, BorderStyle } = require('docx');
const fs = require('fs');

// スタイル定数
const COLORS = {
  primary: "2E5C8A",   // 青（見出し・テーブルヘッダ）
  bg: "E8EEF4",        // 薄青（背景セル）
};
const FONT = "Yu Gothic";

// 最終的な出力
const doc = new Document({ sections: [{ children: [...sections] }] });
const buf = await Packer.toBuffer(doc);
fs.writeFileSync('出力ファイル.docx', buf);
```

### よく使うヘルパー関数

```javascript
// セクション見出し（青・下線付き）
function sectionTitle(text) {
  return new Paragraph({
    children: [new TextRun({ text, font: FONT, size: 28, bold: true, color: COLORS.primary })],
    border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: COLORS.primary } },
    spacing: { before: 300, after: 150 },
  });
}

// 本文段落
function bodyText(text) {
  return new Paragraph({
    children: [new TextRun({ text, font: FONT, size: 19 })],
    spacing: { after: 100 },
  });
}

// 空白スペーサー
function spacer(size = 200) {
  return new Paragraph({ spacing: { before: size } });
}

// テーブルのヘッダセル（青背景・白文字）
function headerCell(text, width) {
  return new TableCell({
    children: [new Paragraph({
      children: [new TextRun({ text, font: FONT, size: 19, bold: true, color: "FFFFFF" })],
      alignment: AlignmentType.CENTER,
    })],
    shading: { fill: COLORS.primary },
    width: { size: width, type: WidthType.DXA },
  });
}

// 通常セル
function cell(text, width, opts = {}) {
  return new TableCell({
    children: [new Paragraph({
      children: [new TextRun({ text, font: FONT, size: 19, bold: opts.bold })],
    })],
    shading: opts.bg ? { fill: opts.bg } : undefined,
    width: { size: width, type: WidthType.DXA },
  });
}

// ラベル・値の2列行（情報表用）
function labelValueRow(label, value) {
  return new TableRow({
    children: [
      cell(label, 2500, { bg: COLORS.bg, bold: true }),
      cell(value, 6526),
    ],
  });
}

// 写真2枚横並び
function photoPair(img1, cap1, img2, cap2) {
  const W = 220, H = 124;
  return new Table({
    rows: [new TableRow({ children: [
      new TableCell({ children: [
        new Paragraph({ children: [new ImageRun({
          data: fs.readFileSync(imgDir + img1),
          transformation: { width: W, height: H },
          type: "jpg",
        })] }),
        new Paragraph({ children: [new TextRun({ text: cap1, font: FONT, size: 16 })] }),
      ]}),
      new TableCell({ children: [
        new Paragraph({ children: [new ImageRun({
          data: fs.readFileSync(imgDir + img2),
          transformation: { width: W, height: H },
          type: "jpg",
        })] }),
        new Paragraph({ children: [new TextRun({ text: cap2, font: FONT, size: 16 })] }),
      ]}),
    ]}],
  });
}

// 写真1枚（大）
function photoSingle(imgFile, cap) {
  return new Paragraph({ children: [
    new ImageRun({
      data: fs.readFileSync(imgDir + imgFile),
      transformation: { width: 400, height: 225 },
      type: "jpg",
    }),
    new TextRun({ text: "\n" + cap, font: FONT, size: 16, break: 1 }),
  ]});
}
```

---

## pptxgenjs のパターン集

### 基本セットアップ

```javascript
const PptxGenJS = require('pptxgenjs');
const fs = require('fs');

const pres = new PptxGenJS();
pres.layout = 'LAYOUT_WIDE';  // 16:9
pres.title = '〇〇町 実施報告書';

const C = {
  dark: "1B3A4B",      // 深紺（背景）
  primary: "2E5C8A",   // 青（見出し・テーブルヘッダ）
  accent: "3D8B6E",    // 緑（アクセント）
  light: "EDF2F7",     // 薄灰
  white: "FFFFFF",
  text: "2D3748",
  tablealt: "F0F5FA",  // テーブル交互背景
};
const FONT = 'Yu Gothic';

pres.writeFile({ fileName: '〇〇町_実施報告書.pptx' });
```

### スライドのレイアウトパターン

```javascript
// タイトルスライド（表紙）
const s = pres.addSlide();
s.background = { color: C.dark };
// 上部アクセントバー
s.addShape(pres.ShapeType.rect, { x: 0, y: 0, w: '100%', h: 0.15, fill: { color: C.accent } });
// タイトルテキスト
s.addText('自治体名', { x: 1, y: 1.5, w: 8, h: 0.8, fontSize: 28, color: C.white, fontFace: FONT, bold: true });
s.addText('報告書タイトル', { x: 1, y: 2.3, w: 8, h: 1.2, fontSize: 36, color: C.white, fontFace: FONT, bold: true });
// サブテキスト
s.addText([
  { text: '実施主体：一般社団法人移住のすゝめ', options: { breakLine: true } },
  { text: '提出先：〇〇役場', options: { breakLine: true } },
  { text: '報告日：令和〇年〇月', options: {} },
], { x: 1, y: 4.0, w: 8, h: 1.0, fontSize: 14, color: C.white, fontFace: FONT });

// コンテンツスライド（共通パーツ）
function addContentSlide(title) {
  const s = pres.addSlide();
  s.background = { color: C.white };
  // 左サイドバー
  s.addShape(pres.ShapeType.rect, { x: 0, y: 0, w: 0.15, h: '100%', fill: { color: C.primary } });
  // タイトル
  s.addText(title, { x: 0.3, y: 0.15, w: 9.5, h: 0.6, fontSize: 22, color: C.primary, fontFace: FONT, bold: true });
  return s;
}
```

### テーブルの定義

```javascript
// 基本テーブル
s.addTable(
  [
    // ヘッダ行
    [
      { text: '列1', options: { bold: true, color: C.white, fill: { color: C.primary } } },
      { text: '列2', options: { bold: true, color: C.white, fill: { color: C.primary } } },
    ],
    // データ行（交互背景）
    [
      { text: '値A', options: { fill: { color: C.tablealt } } },
      { text: '値B', options: { fill: { color: C.tablealt } } },
    ],
    [
      { text: '値C' },
      { text: '値D' },
    ],
  ],
  {
    x: 0.3, y: 0.9, w: 9.4,
    fontSize: 11, fontFace: FONT, color: C.text,
    border: { type: 'solid', pt: 0.5, color: 'CBD5E0' },
    colW: [2.0, 7.4],  // 列幅（インチ）
    rowH: 0.4,
  }
);
```

### 写真グリッド（2×2）

```javascript
const photos = [
  { path: imgDir + 'IMG_0001.jpg', caption: 'キャプション1', x: 0.3, y: 0.9 },
  { path: imgDir + 'IMG_0002.jpg', caption: 'キャプション2', x: 4.5, y: 0.9 },
  { path: imgDir + 'IMG_0003.jpg', caption: 'キャプション3', x: 0.3, y: 3.3 },
  { path: imgDir + 'IMG_0004.jpg', caption: 'キャプション4', x: 4.5, y: 3.3 },
];
const W = 4.1, H = 2.3;

photos.forEach(p => {
  s.addImage({ path: p.path, x: p.x, y: p.y, w: W, h: H,
    sizing: { type: 'cover', w: W, h: H } });
  s.addText(p.caption, { x: p.x, y: p.y + H + 0.05, w: W, h: 0.25,
    fontSize: 9, fontFace: FONT, color: C.text, align: 'center' });
});
```

### 統計ボックス（数値を強調）

```javascript
const stats = [
  { label: '総問い合わせ', value: '14名', x: 0.5 },
  { label: '面談実施',     value: '3名',  x: 3.5 },
  { label: '採用決定',     value: '1名',  x: 6.5 },
];
stats.forEach(st => {
  s.addShape(pres.ShapeType.rect, { x: st.x, y: 1.5, w: 2.5, h: 1.5,
    fill: { color: C.light }, line: { color: C.primary, pt: 1 } });
  s.addText(st.value, { x: st.x, y: 1.6, w: 2.5, h: 0.8,
    fontSize: 32, color: C.primary, fontFace: FONT, bold: true, align: 'center' });
  s.addText(st.label, { x: st.x, y: 2.5, w: 2.5, h: 0.4,
    fontSize: 12, color: C.text, fontFace: FONT, align: 'center' });
});
```

---

## 文書の構成（テンプレート）

### 報告書（create_report.js）6セクション

| セクション | 内容 |
|---|---|
| 表紙 | 自治体名・事業タイトル・提出先・報告日 |
| 1. 事業概要 | 事業名・実施主体・対象地域・期間・委託元（5行表） |
| 2. 協力隊募集 | 職種・条件・媒体・SMOUT問い合わせ・その他チャネル・まとめ |
| 3. ツアー実施報告 | 第1回・第2回の基本情報・スケジュール・写真 |
| 4. 成果 | ツアー参加実績・採用実績 |
| 5. 広報・広告 | Meta広告・Google広告の数値・広報媒体 |
| 6. 総括 | 成果・課題と展望 |

### スライド（create_slides.js）15スライド

| # | タイトル |
|---|---|
| 1 | 表紙（深紺背景） |
| 2 | 事業概要 |
| 3 | 協力隊募集（職種・条件） |
| 4 | SMOUT問い合わせ |
| 5 | その他チャネル |
| 6 | 問い合わせ全体まとめ（統計ボックス） |
| 7 | 第1回ツアー（日程・スケジュール） |
| 8〜9 | 第1回ツアー写真（2×2グリッド） |
| 10 | 第2回ツアー |
| 11 | 第2回ツアー写真 |
| 12 | 実施結果・成果 |
| 13 | 広報・広告 |
| 14 | 総括 |
| 15 | 裏表紙 |

---

## Gotchas

- **フォント依存:** `Yu Gothic` は macOS/Windows 標準。Linux では別途インストールが必要
- **画像パス:** `fs.readFileSync()` は絶対パスで指定する。相対パスは実行ディレクトリに依存して壊れやすい
- **画像サイズ:** `docx` の `transformation` はピクセル単位、`pptxgenjs` の `w/h` はインチ単位
- **pptx の `sizing: { type: "cover" }`:** 画像が指定サイズを覆うようにトリミングされる。縦横比が異なる画像でも枠に収まる
- **BOM不要:** docx/pptx はバイナリ出力なのでBOM処理は不要。CSVを読む場合だけ注意
- **非同期:** `Packer.toBuffer()` は Promise。`await` を忘れずに
