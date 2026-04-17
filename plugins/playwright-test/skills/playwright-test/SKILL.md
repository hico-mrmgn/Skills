---
name: playwright-test
description: Playwright を使った E2E テストを書くスキル。「Playwrightでテストを書いて」「E2Eテストを追加したい」「ブラウザテストを書いて」「テストシナリオを実装して」「Playwright の設定をしたい」「Page Object を作って」「テストが落ちている」など、Playwright を使ったテスト作成・修正・デバッグが絡む作業では必ずこのスキルを参照すること。
---

# Playwright E2Eテスト作成スキル

## まず確認すること

テストを書く前に以下を把握する（会話から読み取れる場合は省略可）：

1. **対象アプリ** — Next.js / React / 静的サイトなど
2. **テスト対象のシナリオ** — 何の動作を検証したいか
3. **セットアップ済みか** — `playwright.config.ts` が既にあるか
4. **認証の有無** — ログインが必要なページか
5. **テストデータ** — fixtureやモックが必要か

---

## ディレクトリ構成

```
project/
├── playwright.config.ts
├── e2e/
│   ├── fixtures/          # カスタムfixture
│   │   └── index.ts
│   ├── pages/             # Page Object Model
│   │   ├── LoginPage.ts
│   │   └── DashboardPage.ts
│   └── tests/             # テストファイル
│       ├── auth.spec.ts
│       └── dashboard.spec.ts
```

テストファイルは `*.spec.ts` で統一する。

---

## 設定ファイル（playwright.config.ts）

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e/tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html', { open: 'never' }], ['list']],
  use: {
    baseURL: process.env.BASE_URL ?? 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    // 必要に応じて追加
    // { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    // { name: 'Mobile Safari', use: { ...devices['iPhone 14'] } },
  ],
  // ローカル開発時にdev serverを自動起動する場合
  // webServer: {
  //   command: 'npm run dev',
  //   url: 'http://localhost:3000',
  //   reuseExistingServer: !process.env.CI,
  // },
});
```

---

## テストの書き方

### 基本構造

```typescript
import { test, expect } from '@playwright/test';

test.describe('機能名', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('ユーザーが〇〇できる', async ({ page }) => {
    // Arrange: 前提状態を作る
    // Act: 操作する
    // Assert: 結果を検証する
  });
});
```

### ロケーター優先順位

1. `getByRole` — アクセシビリティロールで取得（最優先）
2. `getByLabel` — フォームラベルで取得
3. `getByPlaceholder` — プレースホルダーで取得
4. `getByText` — テキストで取得
5. `getByTestId` — `data-testid` で取得（最終手段）

```typescript
// 良い例
await page.getByRole('button', { name: '送信' }).click();
await page.getByLabel('メールアドレス').fill('test@example.com');

// 避ける例（壊れやすい）
await page.locator('.btn-submit').click();
await page.locator('#email').fill('test@example.com');
```

### アサーション

```typescript
// テキスト検証
await expect(page.getByRole('heading')).toHaveText('ダッシュボード');
await expect(page.getByText('成功しました')).toBeVisible();

// URL検証
await expect(page).toHaveURL('/dashboard');

// 要素の存在
await expect(page.getByRole('alert')).toBeVisible();
await expect(page.getByRole('progressbar')).not.toBeVisible();

// フォームの値
await expect(page.getByLabel('名前')).toHaveValue('山田太郎');
```

---

## Page Object Model（POM）

複数テストで同じページを使う場合は必ずPOMに切り出す。

```typescript
// e2e/pages/LoginPage.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByLabel('メールアドレス');
    this.passwordInput = page.getByLabel('パスワード');
    this.submitButton = page.getByRole('button', { name: 'ログイン' });
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
}
```

```typescript
// e2e/tests/auth.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';

test('ログインできる', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password123');
  await expect(page).toHaveURL('/dashboard');
});
```

---

## 認証フィクスチャ

ログインが必要なテストはfixture化して使い回す。

```typescript
// e2e/fixtures/index.ts
import { test as base } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';

type Fixtures = {
  authenticatedPage: void;
};

export const test = base.extend<Fixtures>({
  authenticatedPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(
      process.env.TEST_EMAIL ?? 'test@example.com',
      process.env.TEST_PASSWORD ?? 'password',
    );
    await page.waitForURL('/dashboard');
    await use();
  },
});

export { expect } from '@playwright/test';
```

```typescript
// e2e/tests/dashboard.spec.ts
import { test, expect } from '../fixtures';

test('ログイン後のダッシュボードが表示される', async ({ page, authenticatedPage }) => {
  await expect(page.getByRole('heading', { name: 'ダッシュボード' })).toBeVisible();
});
```

### storageState を使った高速認証

毎回UIログインをすると遅い。`storageState`でセッションを使い回す。

```typescript
// e2e/fixtures/auth.setup.ts
import { test as setup } from '@playwright/test';

setup('認証セットアップ', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('メールアドレス').fill(process.env.TEST_EMAIL!);
  await page.getByLabel('パスワード').fill(process.env.TEST_PASSWORD!);
  await page.getByRole('button', { name: 'ログイン' }).click();
  await page.waitForURL('/dashboard');
  await page.context().storageState({ path: 'e2e/.auth/user.json' });
});
```

```typescript
// playwright.config.ts に追加
projects: [
  {
    name: 'setup',
    testMatch: /auth\.setup\.ts/,
  },
  {
    name: 'chromium',
    use: {
      ...devices['Desktop Chrome'],
      storageState: 'e2e/.auth/user.json',
    },
    dependencies: ['setup'],
  },
],
```

---

## よく使うパターン

### フォーム送信

```typescript
test('フォームを送信できる', async ({ page }) => {
  await page.goto('/contact');
  await page.getByLabel('名前').fill('山田太郎');
  await page.getByLabel('メール').fill('yamada@example.com');
  await page.getByLabel('メッセージ').fill('お問い合わせ内容');
  await page.getByRole('button', { name: '送信' }).click();
  await expect(page.getByText('送信が完了しました')).toBeVisible();
});
```

### API モック（msw不要でPlaywrightだけで完結）

```typescript
test('APIエラー時にエラーメッセージが表示される', async ({ page }) => {
  await page.route('**/api/users', (route) =>
    route.fulfill({ status: 500, body: 'Internal Server Error' })
  );
  await page.goto('/users');
  await expect(page.getByRole('alert')).toContainText('エラーが発生しました');
});
```

### ファイルアップロード

```typescript
test('ファイルをアップロードできる', async ({ page }) => {
  await page.goto('/upload');
  await page.getByLabel('ファイルを選択').setInputFiles('path/to/file.pdf');
  await page.getByRole('button', { name: 'アップロード' }).click();
  await expect(page.getByText('アップロード完了')).toBeVisible();
});
```

### ダイアログ（confirm/alert）

```typescript
test('削除確認ダイアログでキャンセルできる', async ({ page }) => {
  page.on('dialog', (dialog) => dialog.dismiss());
  await page.goto('/items');
  await page.getByRole('button', { name: '削除' }).click();
  await expect(page.getByText('削除されました')).not.toBeVisible();
});
```

### ナビゲーション待機

```typescript
// ページ遷移を待つ
await Promise.all([
  page.waitForURL('/success'),
  page.getByRole('button', { name: '確定' }).click(),
]);

// ネットワークリクエストを待つ
await Promise.all([
  page.waitForResponse('**/api/submit'),
  page.getByRole('button', { name: '送信' }).click(),
]);
```

---

## テスト実行コマンド

```bash
# 全テスト実行
npx playwright test

# 特定ファイルのみ
npx playwright test e2e/tests/auth.spec.ts

# UIモードで実行（デバッグ向き）
npx playwright test --ui

# ヘッドありで実行（ブラウザが見える状態）
npx playwright test --headed

# テストを1つだけ実行
npx playwright test -k "ログインできる"

# デバッグモード（ステップ実行）
npx playwright test --debug

# レポートを開く
npx playwright show-report
```

---

## デバッグ方法

### `page.pause()` でステップ実行

```typescript
test('デバッグ中のテスト', async ({ page }) => {
  await page.goto('/');
  await page.pause(); // ここで一時停止 → Playwright Inspector が開く
  await page.getByRole('button', { name: '送信' }).click();
});
```

### `--ui` モードを使う

`npx playwright test --ui` で実行するとタイムトラベルデバッグが使える。スクリーンショットとDOMのスナップショットを確認しながら原因を特定する。

### ロケーターが見つからないとき

```typescript
// console.log でHTML確認
console.log(await page.content());

// locatorが何を指しているか確認
const button = page.getByRole('button', { name: '送信' });
console.log(await button.count()); // 0なら見つかっていない
```

---

## よくある失敗パターン

| 失敗パターン | 対処 |
|---|---|
| `strict mode violation`: 複数要素がヒット | `locator.first()` か条件を絞る |
| タイムアウト: 要素が見つからない | ロケーターを `getByRole` に変更。`page.waitForSelector` は使わない |
| フラキーテスト（不定期に落ちる） | `waitForURL` / `waitForResponse` で明示的に待機 |
| テスト間でデータが汚染される | `beforeEach` でデータをリセット or APIでクリーンアップ |
| CIで動かない | `CI=true` 環境変数とheadlessモードを確認 |

---

## セットアップ（未導入プロジェクト向け）

```bash
npm init playwright@latest

# または
npm install -D @playwright/test
npx playwright install chromium
```

`package.json` に追加：

```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui"
  }
}
```

`.gitignore` に追加：

```
/playwright-report/
/e2e/.auth/
```
