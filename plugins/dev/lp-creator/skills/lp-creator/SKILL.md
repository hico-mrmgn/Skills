---
name: lp-creator
description: スタンドアロンLP（HTML/CSS/JS）を作成するスキル。「LPを作って」「ランディングページを作りたい」「〇〇のサイトを作って」「企業サイトを作りたい」「紹介ページを作って」など、ビルドツールなしの静的HTMLサイト・LPの作成が絡む作業では必ずこのスキルを参照すること。Next.jsやReactを使わない、シンプルなHTML/CSS/JSで完結するサイト全般に適用する。
---

# スタンドアロンLP作成スキル

ビルドツール不要。HTML + CSS + Vanilla JS だけで完結するLPを作るスキル。

## まず確認すること

作り始める前に以下を聞く（または会話から読み取る）：

1. **目的・ターゲット** — 誰に何を伝えるサイトか
2. **雰囲気・トーン** — 和モダン／スタートアップ系／ナチュラル系など
3. **セクション構成** — 何を伝えたいか（機能・実績・料金・代表紹介など）
4. **CTA** — 最終的にユーザーに何をしてほしいか（問い合わせ・資料DL・登録）
5. **ページ数** — 1ページ完結か、複数ページか

---

## ファイル構成

### 1ページ完結（標準）

```
project-name/
├── index.html
├── styles.css
└── main.js
```

### 複数ページ（6ページ以上）

```
project-name/
├── index.html
├── about.html
├── contact.html
├── assets/
│   ├── css/
│   │   ├── base.css   # リセット + CSS変数定義
│   │   └── main.css   # コンポーネント
│   └── images/
└── main.js
```

---

## セクション構成の型

### 企業・サービス系（標準）

```
Header（固定ナビ）
↓
Hero（キャッチコピー + CTA）
↓
Mission / Why（存在意義・背景）
↓
What We Do（サービス・機能紹介）
↓
How（プロセス・使い方）
↓
Works / Results（実績・事例）
↓
About（代表・チーム紹介）
↓
FAQ
↓
Contact（CTA）
↓
Footer
```

### 地域・コミュニティ系

```
Hero（場所の空気感を伝える）
↓
Issues（課題・背景）
↓
Programs（取り組み・活動）
↓
Stories（人・エピソード）
↓
Contact
↓
Footer
```

全セクションが必要とは限らない。「3セクション＋フッター」でも十分なことが多い。

---

## HTML テンプレート

```html
<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="description" content="サイトの説明文（120文字程度）" />
  <title>サイト名 | キャッチコピー</title>

  <!-- OGP -->
  <meta property="og:title" content="サイト名" />
  <meta property="og:description" content="説明文" />
  <meta property="og:type" content="website" />

  <!-- Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;500;600;700&family=Noto+Serif+JP:wght@500;600&display=swap" rel="stylesheet" />

  <link rel="stylesheet" href="./styles.css" />
</head>
<body>

  <a class="skip-link" href="#main">本文へスキップ</a>

  <!-- Header -->
  <header class="header" id="header">
    <div class="container header__inner">
      <a class="header__logo" href="./index.html">ロゴ / サイト名</a>
      <nav class="header__nav" aria-label="メインナビゲーション">
        <a href="#about">About</a>
        <a href="#service">Service</a>
        <a href="#contact">Contact</a>
      </nav>
      <button class="header__burger" aria-label="メニューを開く" aria-expanded="false">
        <span></span><span></span><span></span>
      </button>
    </div>
  </header>

  <!-- Mobile Nav -->
  <div class="mobile-nav" aria-hidden="true">
    <nav>
      <a href="#about">About</a>
      <a href="#service">Service</a>
      <a href="#contact">Contact</a>
    </nav>
  </div>

  <main id="main">

    <!-- Hero -->
    <section class="hero" id="hero">
      <div class="container">
        <p class="hero__label" data-anim="fade">ラベル・タグライン</p>
        <h1 class="hero__title" data-anim="fade">メインキャッチコピー</h1>
        <p class="hero__sub" data-anim="fade">サブコピー。ターゲットに刺さる一文。</p>
        <a class="btn btn--primary" href="#contact" data-anim="fade">お問い合わせ</a>
      </div>
    </section>

    <!-- Mission -->
    <section class="section" id="mission">
      <div class="container">
        <h2 class="section__title" data-anim="fade">Mission</h2>
        <p class="section__lead" data-anim="fade">ミッションテキスト。</p>
      </div>
    </section>

    <!-- Service -->
    <section class="section section--alt" id="service">
      <div class="container">
        <h2 class="section__title" data-anim="fade">Service</h2>
        <div class="card-grid">
          <div class="card" data-anim="fade">
            <h3 class="card__title">サービス1</h3>
            <p class="card__body">説明テキスト。</p>
          </div>
          <div class="card" data-anim="fade">
            <h3 class="card__title">サービス2</h3>
            <p class="card__body">説明テキスト。</p>
          </div>
          <div class="card" data-anim="fade">
            <h3 class="card__title">サービス3</h3>
            <p class="card__body">説明テキスト。</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Contact -->
    <section class="section section--cta" id="contact">
      <div class="container" data-anim="fade">
        <h2 class="section__title">お問い合わせ</h2>
        <p class="section__lead">お気軽にご連絡ください。</p>
        <a class="btn btn--primary" href="mailto:info@example.com">メールで問い合わせる</a>
      </div>
    </section>

  </main>

  <footer class="footer">
    <div class="container">
      <p class="footer__copy">&copy; 2026 サイト名</p>
    </div>
  </footer>

  <script src="./main.js"></script>
</body>
</html>
```

---

## CSS テンプレート

```css
/* =====================
   CSS 変数（必ずここで定義）
   ===================== */
:root {
  /* Colors — プロジェクトごとに変更する */
  --color-bg:      #FAFAF7;
  --color-bg-alt:  #F2EDE4;
  --color-text:    #1a1a1a;
  --color-muted:   #6b6b6b;
  --color-primary: #3E5944;   /* アクセント（和モダン系：深緑） */
  --color-border:  rgba(26, 26, 26, 0.12);

  /* Typography */
  --ff-heading: 'Noto Serif JP', 'Yu Mincho', serif;
  --ff-body:    'Noto Sans JP', 'Hiragino Sans', sans-serif;

  /* Layout */
  --container:  min(900px, 100% - 48px);
  --sp-section: clamp(72px, 9vw, 128px);
  --sp-block:   clamp(32px, 4vw, 56px);
  --sp-gap:     clamp(16px, 2vw, 24px);

  /* Transition */
  --transition: 0.3s ease;
}

/* =====================
   Reset
   ===================== */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
img, video { max-width: 100%; display: block; }
a { color: inherit; text-decoration: none; }

body {
  font-family: var(--ff-body);
  font-size: 1rem;
  line-height: 1.8;
  color: var(--color-text);
  background: var(--color-bg);
  -webkit-font-smoothing: antialiased;
  font-feature-settings: "palt";  /* 日本語字間調整 */
}

/* =====================
   Layout
   ===================== */
.container { width: var(--container); margin: 0 auto; }

.section {
  padding: var(--sp-section) 0;
}

.section--alt {
  background: var(--color-bg-alt);
}

.section--cta {
  background: var(--color-primary);
  color: #fff;
  text-align: center;
}

/* =====================
   Header
   ===================== */
.header {
  position: fixed;
  top: 0; left: 0; right: 0;
  z-index: 100;
  background: rgba(250, 250, 247, 0.92);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--color-border);
  transition: transform var(--transition);
}

.header.is-hidden { transform: translateY(-100%); }

.header__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 64px;
}

.header__logo {
  font-family: var(--ff-heading);
  font-weight: 600;
  font-size: 1.1rem;
}

.header__nav {
  display: none;
  gap: 2rem;
  font-size: 0.875rem;
}

.header__nav a {
  position: relative;
  padding-bottom: 2px;
}

.header__nav a::after {
  content: '';
  position: absolute;
  bottom: 0; left: 0;
  width: 0; height: 1px;
  background: var(--color-primary);
  transition: width var(--transition);
}

.header__nav a:hover::after { width: 100%; }

.header__burger {
  display: flex;
  flex-direction: column;
  gap: 5px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
}

.header__burger span {
  display: block;
  width: 22px; height: 1.5px;
  background: var(--color-text);
  transition: transform var(--transition), opacity var(--transition);
}

.header__burger.is-open span:nth-child(1) { transform: translateY(6.5px) rotate(45deg); }
.header__burger.is-open span:nth-child(2) { opacity: 0; }
.header__burger.is-open span:nth-child(3) { transform: translateY(-6.5px) rotate(-45deg); }

@media (min-width: 769px) {
  .header__nav   { display: flex; }
  .header__burger { display: none; }
}

/* =====================
   Mobile Nav
   ===================== */
.mobile-nav {
  position: fixed;
  inset: 0;
  background: var(--color-bg);
  z-index: 90;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  pointer-events: none;
  transition: opacity var(--transition);
}

.mobile-nav.is-open {
  opacity: 1;
  pointer-events: auto;
}

.mobile-nav nav {
  display: flex;
  flex-direction: column;
  gap: 2rem;
  text-align: center;
  font-size: 1.5rem;
  font-family: var(--ff-heading);
}

/* =====================
   Hero
   ===================== */
.hero {
  min-height: 100svh;
  display: flex;
  align-items: center;
  padding-top: 80px;
}

.hero__label {
  font-size: 0.8rem;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  color: var(--color-primary);
  margin-bottom: 1rem;
}

.hero__title {
  font-family: var(--ff-heading);
  font-size: clamp(2rem, 5vw, 3.75rem);
  line-height: 1.3;
  margin-bottom: 1.5rem;
}

.hero__sub {
  font-size: clamp(1rem, 1.5vw, 1.125rem);
  color: var(--color-muted);
  max-width: 540px;
  margin-bottom: 2.5rem;
}

/* =====================
   Section Typography
   ===================== */
.section__title {
  font-family: var(--ff-heading);
  font-size: clamp(1.5rem, 3vw, 2.25rem);
  margin-bottom: var(--sp-block);
}

.section__lead {
  font-size: clamp(1rem, 1.5vw, 1.125rem);
  color: var(--color-muted);
  max-width: 640px;
  margin-bottom: var(--sp-block);
}

/* =====================
   Card Grid
   ===================== */
.card-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--sp-gap);
}

@media (min-width: 600px) {
  .card-grid { grid-template-columns: 1fr 1fr; }
}

@media (min-width: 900px) {
  .card-grid { grid-template-columns: repeat(3, 1fr); }
}

.card {
  padding: 2rem;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background: var(--color-bg);
}

.card__title {
  font-family: var(--ff-heading);
  font-size: 1.1rem;
  margin-bottom: 0.75rem;
}

.card__body {
  font-size: 0.9375rem;
  color: var(--color-muted);
  line-height: 1.7;
}

/* =====================
   Button
   ===================== */
.btn {
  display: inline-block;
  padding: 0.875rem 2rem;
  border-radius: 4px;
  font-size: 0.9375rem;
  font-weight: 500;
  transition: opacity var(--transition), transform var(--transition);
  cursor: pointer;
}

.btn:hover { opacity: 0.85; transform: translateY(-1px); }

.btn--primary {
  background: var(--color-primary);
  color: #fff;
}

.btn--outline {
  border: 1.5px solid currentColor;
}

/* =====================
   Animations
   ===================== */
[data-anim="fade"] {
  opacity: 0;
  transform: translateY(20px);
  transition: opacity 0.7s ease, transform 0.7s ease;
}

[data-anim="fade"].is-visible {
  opacity: 1;
  transform: none;
}

/* =====================
   Footer
   ===================== */
.footer {
  padding: 2rem 0;
  text-align: center;
  border-top: 1px solid var(--color-border);
}

.footer__copy {
  font-size: 0.8125rem;
  color: var(--color-muted);
}

/* =====================
   Skip Link（アクセシビリティ）
   ===================== */
.skip-link {
  position: absolute;
  top: -100%;
  left: 1rem;
  background: var(--color-primary);
  color: #fff;
  padding: 0.5rem 1rem;
  z-index: 999;
}

.skip-link:focus { top: 1rem; }
```

---

## JavaScript テンプレート

```javascript
/* =====================
   Header: スクロール時に非表示
   ===================== */
const header = document.getElementById('header');
let lastY = 0;

window.addEventListener('scroll', () => {
  const y = window.scrollY;
  header.classList.toggle('is-hidden', y > 100 && y > lastY);
  lastY = y;
}, { passive: true });

/* =====================
   ハンバーガーメニュー
   ===================== */
const burger  = document.querySelector('.header__burger');
const mobileNav = document.querySelector('.mobile-nav');

burger?.addEventListener('click', () => {
  const isOpen = burger.getAttribute('aria-expanded') === 'true';
  burger.setAttribute('aria-expanded', String(!isOpen));
  burger.classList.toggle('is-open');
  mobileNav.classList.toggle('is-open');
  mobileNav.setAttribute('aria-hidden', String(isOpen));
  document.body.style.overflow = isOpen ? '' : 'hidden';
});

// モバイルナビのリンクをクリックしたら閉じる
mobileNav?.querySelectorAll('a').forEach(a => {
  a.addEventListener('click', () => {
    burger.setAttribute('aria-expanded', 'false');
    burger.classList.remove('is-open');
    mobileNav.classList.remove('is-open');
    mobileNav.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
  });
});

/* =====================
   スクロールアニメーション
   ===================== */
if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry, i) => {
      if (entry.isIntersecting) {
        // 複数要素が同時に入ったとき、少しずつずらして表示
        setTimeout(() => {
          entry.target.classList.add('is-visible');
        }, i * 80);
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });

  document.querySelectorAll('[data-anim]').forEach(el => observer.observe(el));
}
```

---

## カラーパレットの選び方

| 雰囲気 | bg | primary | 組み合わせ例 |
|---|---|---|---|
| 和モダン・地域系 | `#FAFAF7` | `#3E5944` | 深緑 + 焦茶 + ベージュ |
| 知的・コンサル系 | `#F5F1E8` | `#2A2520` | 墨色 + 和紙 + モス |
| スタートアップ系 | `#FFFFFF` | `#2563EB` | ブルー + グレー |
| ナチュラル・食系 | `#FFFDF7` | `#7A6652` | 土色 + クリーム |
| 高級・ラグジュアリー | `#0F0F0F` | `#C9A84C` | ゴールド + ブラック |

---

## Gotchas

- **`font-feature-settings: "palt"`** を `body` に設定する。日本語の字間が自然になる
- **`min-height: 100svh`** — iOS Safari でのビューポート高さ問題を回避（`100vh` より優先）
- **`scroll-behavior: smooth`** は `html` に設定する
- **`{ passive: true }`** — scroll イベントリスナーに必ず付ける。パフォーマンス改善
- **画像は `loading="lazy"`** を付ける — ファーストビュー以外の画像に適用
- **Google Fonts は `preconnect`** を必ずセットで入れる。ないと読み込みが遅い
- **モバイルナビを開いているとき `overflow: hidden`** を body に付けて背景スクロールを防ぐ
- **複数の `[data-anim]` 要素が画面に一度に入るとき**、`setTimeout` でずらして表示するとリズムが出る
