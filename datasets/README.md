# datasets/ — ワークフロー試行用のオープンデータ

`/data-analysis` を試すためのサンプルデータ置き場。各データセットは `fetch.sh` で再取得でき、取得物（`raw/`）は Git 管理外。取得物の SHA-256 は `fetch.sh` に固定しており、再取得時に照合する。

## bike-sharing — Capital Bikeshare 利用数（2011–2012）

| 項目 | 内容 |
|---|---|
| 出典 | UCI Machine Learning Repository, "Bike Sharing Dataset" (ID 275) — https://archive.ics.uci.edu/dataset/275/bike+sharing+dataset |
| 内容 | ワシントン D.C. のシェアサイクル Capital Bikeshare の 2 年分の貸出台数に、天候・季節・祝日・曜日を付与した集計データ |
| ファイル | `raw/hour.csv`（時間別 17,379 行）、`raw/day.csv`（日別 731 行）、`raw/Readme.txt`（列定義） |
| 主な列 | `dteday` 日付、`hr` 時刻、`season` 季節、`holiday` / `workingday`、`weathersit` 天候区分（1–4）、`temp` / `atemp` / `hum` / `windspeed`（正規化済み）、`casual` / `registered` / `cnt` 貸出台数 |
| ライセンス | CC BY 4.0。出版物での利用は Fanaee-T & Gama (2013), doi:10.1007/s13748-013-0040-3 を引用 |
| 機密区分 | 公開可（個人を特定する列を含まない） |

取得:

```bash
bash datasets/bike-sharing/fetch.sh
```

`/data-analysis` に渡す自然文の例:

```
/data-analysis "datasets/bike-sharing/raw/hour.csv と day.csv を使って、シェアサイクルの貸出台数が季節・天候・曜日・時間帯でどう変わるかを把握し、非会員（casual）と会員（registered）で利用パターンの違いがあるかを知りたい。2011 年から 2012 年にかけての利用の伸びも定量化してほしい。データは公開データなので機密区分は公開可。"
```

## 実行環境

分析コードの実行にはプロジェクト直下の `.venv`（uv で作成、Git 管理外）を使う。

```bash
uv venv .venv --python 3.12 && uv pip install --python .venv/bin/python pandas matplotlib pyarrow scipy
```
