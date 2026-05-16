---
name: data-analysis
description: CSV・ExcelファイルをPython/Pandasで分析するスキル。「CSVを分析して」「データを集計したい」「Excelを読み込んで」「グラフを作って」「データを可視化したい」「外れ値を検出して」「データを結合して」「集計表を作りたい」など、表形式データの分析・集計・可視化が絡む作業では必ずこのスキルを参照すること。
---

# CSV/Excelデータ分析スキル

Python + Pandas + Matplotlib/Seaborn を使って、表形式データを分析・可視化するスキル。

## まず確認すること

1. **データの形式** — CSV / Excel / 複数ファイル結合など
2. **何を知りたいか** — 集計・可視化・異常検出・予測など
3. **出力形式** — スクリプト / Jupyter Notebook / グラフ画像 / レポート
4. **環境** — Python + 必要ライブラリがインストール済みか

---

## セットアップ

```bash
pip install pandas openpyxl matplotlib seaborn japanize-matplotlib
```

日本語フォントを使う場合は `japanize-matplotlib` を入れると簡単。

---

## データ読み込み

```python
import pandas as pd

# CSV（文字コードが不明な場合は chardet で自動検出）
df = pd.read_csv('data.csv', encoding='utf-8')
df = pd.read_csv('data.csv', encoding='shift-jis')  # 日本語CSV

# Excel
df = pd.read_excel('data.xlsx', sheet_name='Sheet1')

# 複数ファイルを結合
import glob
files = glob.glob('data/*.csv')
df = pd.concat([pd.read_csv(f) for f in files], ignore_index=True)
```

---

## 最初に必ずやること（データ把握）

```python
# 形状・型・欠損値を一気に確認
print(df.shape)         # (行数, 列数)
print(df.dtypes)        # 各列の型
print(df.head())        # 先頭5行
print(df.describe())    # 数値列の基本統計量
print(df.isnull().sum())  # 欠損値の数
```

---

## データクレンジング

```python
# 欠損値の処理
df = df.dropna()                          # 欠損行を削除
df['列名'] = df['列名'].fillna(0)         # 数値で埋める
df['列名'] = df['列名'].fillna('不明')    # 文字列で埋める

# 型変換
df['日付'] = pd.to_datetime(df['日付'])
df['金額'] = pd.to_numeric(df['金額'], errors='coerce')

# 文字列の前後空白を除去
df['列名'] = df['列名'].str.strip()

# 重複行を削除
df = df.drop_duplicates()

# 列名をわかりやすくリネーム
df = df.rename(columns={'old_name': 'new_name'})
```

---

## 集計・グループ集計

```python
# 基本集計
df['売上'].sum()
df['売上'].mean()
df.groupby('地域')['売上'].sum()

# 複数集計をまとめて
summary = df.groupby('地域').agg(
    売上合計=('売上', 'sum'),
    件数=('売上', 'count'),
    平均単価=('売上', 'mean'),
)

# ピボットテーブル
pivot = df.pivot_table(
    values='売上',
    index='月',
    columns='商品カテゴリ',
    aggfunc='sum',
    fill_value=0,
)

# 月次集計（日付列がdatetime型のとき）
df['月'] = df['日付'].dt.to_period('M')
monthly = df.groupby('月')['売上'].sum()
```

---

## フィルタリング・結合

```python
# 条件フィルタ
df_filtered = df[df['売上'] > 100000]
df_filtered = df[(df['地域'] == '東京') & (df['月'] == '2024-01')]

# 文字列部分一致
df_filtered = df[df['商品名'].str.contains('プレミアム')]

# 上位N件
top10 = df.nlargest(10, '売上')

# 2つのDataFrameを結合（SQLのJOINに相当）
merged = pd.merge(df_sales, df_master, on='商品ID', how='left')
```

---

## 可視化

```python
import matplotlib.pyplot as plt
import japanize_matplotlib  # 日本語フォント対応

# 棒グラフ
fig, ax = plt.subplots(figsize=(10, 6))
summary['売上合計'].plot(kind='bar', ax=ax)
ax.set_title('地域別売上合計')
ax.set_xlabel('地域')
ax.set_ylabel('売上（円）')
plt.tight_layout()
plt.savefig('sales_by_region.png', dpi=150)
plt.show()

# 折れ線グラフ（時系列）
fig, ax = plt.subplots(figsize=(12, 5))
monthly.plot(ax=ax, marker='o')
ax.set_title('月次売上推移')
plt.tight_layout()
plt.savefig('monthly_trend.png', dpi=150)
plt.show()

# 円グラフ
fig, ax = plt.subplots()
df.groupby('カテゴリ')['売上'].sum().plot(kind='pie', ax=ax, autopct='%1.1f%%')
ax.set_ylabel('')
plt.tight_layout()
plt.show()

# 散布図
import seaborn as sns
fig, ax = plt.subplots()
sns.scatterplot(data=df, x='単価', y='販売数', hue='カテゴリ', ax=ax)
plt.tight_layout()
plt.show()
```

---

## 異常値・外れ値の検出

```python
# IQR法
Q1 = df['売上'].quantile(0.25)
Q3 = df['売上'].quantile(0.75)
IQR = Q3 - Q1
outliers = df[(df['売上'] < Q1 - 1.5 * IQR) | (df['売上'] > Q3 + 1.5 * IQR)]
print(f"外れ値: {len(outliers)}件")
print(outliers)

# ボックスプロットで可視化
fig, ax = plt.subplots()
df.boxplot(column='売上', by='地域', ax=ax)
plt.tight_layout()
plt.show()
```

---

## 結果をExcel/CSVに出力

```python
# CSV出力
df.to_csv('result.csv', index=False, encoding='utf-8-sig')  # BOM付きでExcelが文字化けしない

# Excel出力（複数シート）
with pd.ExcelWriter('report.xlsx', engine='openpyxl') as writer:
    df.to_excel(writer, sheet_name='生データ', index=False)
    summary.to_excel(writer, sheet_name='集計', index=True)
    pivot.to_excel(writer, sheet_name='ピボット', index=True)
```

---

## スクリプトのテンプレート

```python
import pandas as pd
import matplotlib.pyplot as plt
import japanize_matplotlib

def load_data(path: str) -> pd.DataFrame:
    df = pd.read_csv(path, encoding='utf-8-sig')
    df.columns = df.columns.str.strip()
    return df

def clean(df: pd.DataFrame) -> pd.DataFrame:
    df = df.drop_duplicates()
    df = df.dropna(subset=['必須列名'])
    df['日付'] = pd.to_datetime(df['日付'])
    return df

def analyze(df: pd.DataFrame) -> pd.DataFrame:
    return df.groupby('グループ列').agg(
        合計=('数値列', 'sum'),
        件数=('数値列', 'count'),
    )

def plot(summary: pd.DataFrame) -> None:
    fig, ax = plt.subplots(figsize=(10, 6))
    summary['合計'].plot(kind='bar', ax=ax)
    ax.set_title('分析結果')
    plt.tight_layout()
    plt.savefig('output.png', dpi=150)

def main():
    df = load_data('data.csv')
    df = clean(df)
    summary = analyze(df)
    plot(summary)
    summary.to_csv('summary.csv', encoding='utf-8-sig')
    print(summary)

if __name__ == '__main__':
    main()
```

---

## よくある失敗パターン

| 失敗パターン | 対処 |
|---|---|
| 日本語CSVが文字化け | `encoding='shift-jis'` または `encoding='utf-8-sig'` を試す |
| 日付列が文字列のまま | `pd.to_datetime()` で変換 |
| 数値列に `,` や `¥` が混入 | `str.replace(',', '').replace('¥', '')` してから `pd.to_numeric()` |
| グラフの日本語が豆腐になる | `japanize_matplotlib` をインポート |
| Excel出力でExcelが文字化け | CSV保存時は `encoding='utf-8-sig'`（BOM付き） |
| `groupby` 後の列名が扱いにくい | `agg()` で `新列名=('元列名', '関数')` 形式を使う |
