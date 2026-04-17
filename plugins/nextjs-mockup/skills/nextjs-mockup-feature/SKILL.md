---
name: nextjs-mockup-feature
description: Next.js App Router + Ports & Adapters アーキテクチャのモックアップに新機能を追加するワークフロースキル。「〇〇機能を追加して」「〇〇画面を作って」「モックデータを追加して」「新しいページを作りたい」など、Lipassやその他の Next.js モックアップへの機能追加・画面追加・モックデータ追加が絡む作業では必ずこのスキルを参照すること。
---

# Next.js モックアップ 機能追加スキル

このスキルは **Next.js 14 App Router + TypeScript + Tailwind CSS + shadcn/ui + Ports & Adapters** 構成のモックアップに新機能を追加するための実装ワークフローを定義する。

## プロジェクト構成の前提

作業前に必ず `CLAUDE.md` を確認してプロジェクト固有のルール・ドメイン用語を把握する。典型的な構成：

```
app/
  (main)/              # PC向けメインレイアウト（RSC）
  sp/                  # スマートフォン向け
  api/                 # APIエンドポイント
src/
  core/                # ドメインロジック（Ports & Adapters）
  features/            # 機能モジュール（DDD）
  types/               # グローバル型定義
  mocks/               # モックデータ一元管理
    fixtures/          # 複数featureで再利用する固定データ（TS/JSON）
    data/              # feature固有データ（TypeScript）
    adapters/          # アダプター層のMock実装
    repositories/      # リポジトリ層のMock実装
  lib/repo/            # Repositoryの抽象層（getRepo()）
components/            # ルートレベル共有コンポーネント
```

## 実装の順序

機能追加は必ずこの順序で進める。後工程が前工程の型・データに依存しているため、逆順にすると手戻りが多い。

### Step 1: 型定義

グローバルに使う型は `src/types/{feature}.ts`、feature固有なら `src/features/{feature}/types/` に置く。

```typescript
// src/types/{feature}.ts の例
export type RecordStatus = 'draft' | 'pending' | 'approved' | 'rejected';

export type {Feature} = {
  id: string;
  // ... フィールド定義
};
```

**判断基準：**
- 複数のfeatureが参照する → `src/types/`
- そのfeatureだけが使う → `src/features/{feature}/types/`

### Step 2: モックデータ作成

`src/mocks/` の下に配置する。配置先の判断：

| 条件 | 配置先 |
|---|---|
| 複数featureで再利用する | `src/mocks/fixtures/{feature}/` |
| そのfeature固有のデータ | `src/mocks/data/{feature}.ts` |
| Repositoryのアダプター実装 | `src/mocks/repositories/` |
| LLM/STT等の外部アダプター | `src/mocks/adapters/` |

モックデータの典型パターン：

```typescript
// src/mocks/data/{feature}.ts
import type { {Feature} } from "@/types/{feature}";

export const mock{Feature}List: {Feature}[] = [
  {
    id: "{FEAT}-001",
    // ... リアルなダミーデータを入れる
  },
];

// IDで引くヘルパーも用意しておくと便利
export function get{Feature}ById(id: string): {Feature} | undefined {
  return mock{Feature}List.find((item) => item.id === id);
}
```

モックデータは `src/mocks/index.ts` からre-exportする。

### Step 3: ViewModel定義

ページが受け取るデータ構造を定義する。Repositoryが返す「表示用に整形されたデータ」。

```typescript
// src/features/{feature}/viewmodels/{Feature}ViewModel.ts
export type {Feature}ListViewModel = {
  items: {Feature}ListItem[];
  // toolbar, filters など表示に必要な付加情報
};

export type {Feature}DetailViewModel = {
  id: string;
  // ... 詳細表示に必要なフィールド
};
```

### Step 4: Repository実装

ViewModelを組み立てるロジック。モックデータを取得して整形する。

```typescript
// src/features/{feature}/repositories/{feature}Repository.ts
import { mock{Feature}List } from "@/mocks";

export async function get{Feature}ListViewModel(): Promise<{Feature}ListViewModel> {
  // モックデータを取得
  const items = mock{Feature}List;

  // ビジネスロジック（ソート・フィルタ・join等）を適用
  const sorted = [...items].sort((a, b) => ...);

  return {
    items: sorted.map((item) => ({
      // ViewModel形式に変換
    })),
  };
}
```

`getRepo()` を使う場合（中央リポジトリに統合されているとき）：

```typescript
import { getRepo } from "@/lib/repo";

export async function get{Feature}ListViewModel() {
  const repo = await getRepo();
  return repo.get{Feature}List();
}
```

### Step 5: コンポーネント実装

RSC（Server Component）とクライアントコンポーネントを適切に分離する。

**ページコンポーネント（RSC）— `app/(main)/{feature}/page.tsx`**
```typescript
import type { Metadata } from "next";
import { PageShell } from "@/components/layout/PageShell";
import { PageHeader } from "@/components/layout/PageHeader";
import { {Feature}Content } from "@/features/{feature}/components/{Feature}Content";
import { get{Feature}ListViewModel } from "@/features/{feature}/repositories/{feature}Repository";

export const metadata: Metadata = {
  title: "ページ名",
};

export default async function {Feature}Page() {
  const viewModel = await get{Feature}ListViewModel();

  return (
    <PageShell>
      <PageHeader title="ページ名" />
      <{Feature}Content {...viewModel} />
    </PageShell>
  );
}
```

**機能コンポーネント — `src/features/{feature}/components/{Feature}Content.tsx`**
```typescript
"use client"; // インタラクションがある場合のみ

import type { {Feature}ListViewModel } from "../viewmodels/{Feature}ViewModel";

type Props = {Feature}ListViewModel;

export function {Feature}Content({ items }: Props) {
  return (
    <div className="p-6">
      {/* shadcn/ui + Tailwind CSS で実装 */}
    </div>
  );
}
```

**コンポーネントの分割指針：**

```
src/features/{feature}/components/
├── {Feature}Content.tsx       # ページに直接置くルートコンポーネント
├── sections/                  # ページを構成するセクション単位
│   ├── {Feature}Header.tsx
│   └── {Feature}List.tsx
└── components/                # セクション内で使うUI部品
    ├── {Feature}Card.tsx
    └── {Feature}Badge.tsx
```

### Step 6: ルーティング登録

```
app/(main)/{feature}/
├── page.tsx           # 一覧
├── [id]/
│   └── page.tsx       # 詳細
└── new/
    └── page.tsx       # 新規作成（必要な場合）
```

ファイル名はkebab-caseで、ドメイン用語はCLAUDE.mdのマッピングに従う（例：「意向確認」→ `intent-confirmation`）。

## Ports & Adapters パターンの実装

コアドメインに新しいアダプターが必要な場合：

```typescript
// Port（インターフェース） — src/core/{domain}/ports/{domain}Repo.ts
export interface {Domain}Repo {
  create(data: {Domain}): Promise<{Domain}>;
  get(id: string): Promise<{Domain} | null>;
  list(): Promise<{Domain}[]>;
}

// Mock実装 — src/mocks/adapters/{domain}/mock{Domain}Repo.ts
export class Mock{Domain}Repo implements {Domain}Repo {
  private store = new Map<string, {Domain}>();

  constructor() {
    // シードデータを投入
    const seeds: {Domain}[] = [ /* ... */ ];
    seeds.forEach((item) => this.store.set(item.id, item));
  }

  async create(data: {Domain}): Promise<{Domain}> {
    this.store.set(data.id, { ...data });
    return { ...data };
  }

  async get(id: string): Promise<{Domain} | null> {
    return this.store.get(id) ?? null;
  }

  async list(): Promise<{Domain}[]> {
    return Array.from(this.store.values());
  }
}
```

## shadcn/ui の使い方

```typescript
// インポートは @/components/ui/ から
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

// cn() ユーティリティで条件付きクラスを合成
import { cn } from "@/lib/utils";

<Button variant="outline" size="sm" className={cn("...", condition && "...")}>
  ラベル
</Button>
```

## よくあるGotchas

- **`app/` からの非ルートimport禁止** — `app/` 内のコードは `src/` や `components/` をimportする。`app/` 内で別の `app/` ファイルをimportしない（`check-no-app-imports` リントで検出される）
- **Path alias** — `@/*` はプロジェクトルートを指す
- **RSC vs Client** — データ取得はRSCで行い、インタラクション（useState/useEffect）がある部分だけ `"use client"` を付ける
- **モックデータのID形式** — 既存データのID命名規則に合わせる（例：`CUST-00001`、`IC-001`）
- **ドメイン用語** — CLAUDE.mdのマッピング表を必ず確認する

## 実装後の確認

```bash
npm run typecheck   # TypeScript型チェック
npm run lint        # ESLint + カスタムチェック
npm run dev         # 動作確認
```

型エラーが出たら修正してからlintを通す。
