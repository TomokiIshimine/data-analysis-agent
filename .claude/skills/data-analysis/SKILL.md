---
name: data-analysis
description: 分析要件の定義から反復分析、再現可能な Markdown レポート化、第三者視点の再現検証、HTML 清書までを一気通貫で行うワークフロー。手元のデータについて分析目的はあるが手順が固まっていないとき、または分析結果を他者に共有するために「同じ手順で同じ結果が出る」ことの担保が必要なときに、ユーザーが `/data-analysis` と明示的に打って起動する。単発の集計やグラフ 1 枚の作成には使わない。
argument-hint: "<analysis-request — 分析の目的・対象データの所在（ファイルパス／ディレクトリ／DB 接続／URL）・知りたいことを自然文で>"
disable-model-invocation: true
---

# data-analysis — 再現性重視のデータ分析ワークフロー

## 目的

分析対象と目的が決まっていないところから、第三者が再現できるレポートまでを一気通貫で作る。分析の「やりっぱなし」を防ぐために、**入力データの姿と所在を先に押さえたうえで** 要件をユーザーと合意し、試行ごとに要件充足度と要件逸脱を判定し、最後に第三者視点の再現検証を通したうえで、読みやすい HTML レポートに落とす。

## 実行前提

- **起動方法**: ユーザーが `/data-analysis "<analysis-request>"` と明示的に呼び出す。引数は自然文 1 本。構造化引数（`--data` 等）は取らない。
- **`disable-model-invocation: true`（明示呼び出し専用）**。根拠: コード実行・多数のファイル生成・複数の承認ゲートを伴う重量級ワークフローであり、会話中の「データ分析」という語での誤発火コストが利便性を上回るため。Claude Code の自主判断では起動しない。
- **引数が空でも中断しない**。データの所在が書かれていない場合は Step 2 が `UNRESOLVED` として扱い、Step 3 の承認ゲートでユーザーが確定する。
- **`<target-project-root>`** は本スキル発火時の `pwd` を 1 度スナップショットし、以後固定値として扱う（ループ中の `pwd` 変化に追随しない）。
- **外部依存を持たない**。本ワークフローが参照するサブエージェント 9 体と How スキル 4 本はすべて `<target-project-root>/.claude/` 配下に存在する。外部プラグインが提供するサブエージェント・スキルは一切参照しない。

## 共通契約への準拠

本ワークフローはプロジェクト内で自己完結する。メインの作法は本節に直接書き（1 箇所にしか現れないためスキルへ切り出さない）、設計サイクルの契約のみプロジェクト内 How スキル `analysis-design-cycle` に委譲する。

### メインの作法

- **責務の集約**: メインが担うのは、サブエージェント呼び出し（並列／直列の判断）、絶対パスの引き回し、全 `AskUserQuestion` の発火と回答収集、限定 Read によるユーザー概要提示、ステップ遷移とループ制御のみ。
- **責務の委譲**: 成果物本文の Write / Edit、本文全体の Read、分析の実行、判定レポートの作成はすべてサブエージェントに任せる。
- **絶対パスの引き回し**: ステップ間で受け渡す中間値は `<workdir>` のように `<…>` 記法で内部保持し、後続サブエージェントへ `Agent` 引数として **絶対パスで** 渡す。サブエージェントに命名規約を推測させない（命名規約を知るのは本 SKILL.md だけ）。
- **限定 Read の遵守**: サブエージェントの生成物の Read は後述の `## 限定 Read 契約（固定見出しテーブル）` に従う。
- **ユーザー対話の一本化**: `AskUserQuestion` はメインだけが発火する。サブエージェントは `AskUserQuestion` を呼ばない。サブエージェントの出力に「ユーザーに問うべき論点」が含まれる場合、サブエージェントは推奨値と根拠を固定見出しに列挙するだけで、自ら問わない。メインは作業開始前に **1 回だけ** `ToolSearch` を `query: "select:AskUserQuestion"`、`max_results: 1` で呼び出してスキーマをロードし、以降はその結果を再利用する。
- **サブエージェント実行モード**: `AskUserQuestion` をメインに集約しているため、サブエージェントは背景実行可否に依存しない。`run_in_background: true` で起動してよい。本ワークフローに並列実行するステップはなく、全ステップを直列に実行する。
- **サブエージェント戻り値の形式**: 正常終了時は絶対パス 1 行のみ。パス以外の要約・説明を戻り値として期待しない。判定結果は戻り値ではなくファイル内の固定見出しから限定 Read で取得する。例外は次の「整合チェック失敗時の中断ポリシー」のうち **成果物を書かずに中断する経路** で、このときサブエージェントは**絶対パスを返さず**、不整合内容の報告のみを返す。メインは戻り値が絶対パス 1 行でないことをもってその中断を検知する。
- **整合チェック失敗時の中断ポリシー**: サブエージェントが入力の不整合（渡されたパスが存在しない、引数の前提が崩れている等）を検出した場合、そのサブエージェントは編集系ツールを一切呼ばず、成果物ファイルも書かず、**絶対パスを返さずに** 不整合内容（対象・期待値・実測値を含む）を報告して終了する。メインは自動補正・自動進行せず、報告された内容をそのまま「失敗時のリカバリ」の対応に用いる。
- **不整合を成果物に記録して終了する経路（上記の例外）**: 次の 2 つは、サブエージェントが後続処理を進めない点は同じだが、不整合の事実を **自分の成果物ファイルに記録したうえで、その絶対パス 1 行を返して** 終了する。メインは戻り値からこれらを判別せず、限定 Read 契約または「失敗時のリカバリ」に定めた経路で扱う。
  - `analysis-executor` のハッシュ不一致 — 分析を進めず、不一致の事実（期待値・実測値・対象パス）を `<workdir>/03_iterations/<n>_execution.md` に記録して終了し、同絶対パスを返す。
  - `data-ingestion-profiler` のデータソース未解決・取得失敗 — 推測でデータを選ばず、`<workdir>/01_data-profile.md` の `## データソース` に `UNRESOLVED`（取得失敗の場合は失敗理由付き）として記録して終了し、同絶対パスを返す。
- **メインがしないこと**: 成果物本文の Write / Edit、サブエージェントが扱うべき `Write` / `Edit` の直接実行、限定 Read 契約に反する Read、サブエージェントの内部処理手順への介入（渡すのは引数のみ）、承認ゲートでのユーザー承認なしの自動進行。

### 設計サイクル契約への準拠

Step 3（分析要件定義）の設計サイクルと承認ゲートの作法は、プロジェクト内 How スキル `analysis-design-cycle` の契約に従う。本 SKILL.md では以下を**再掲しない**。

- 設計係の 2 モード（`draft` / `revise`）の責務と入出力
- 設計係が `AskUserQuestion` を呼ばないこと、決められない論点を推奨値で埋めること
- 承認ゲートの手順
- revise で本文と要約セクションを同一実行内で同期させること

本ワークフロー固有の差分（要約セクションの実体が `<section id="design-summary">` であること、承認時に取り出す値、承認後のデータソース再解決の分岐）は Step 3 に記載する。

## 限定 Read 契約（固定見出しテーブル）

メインは下表の見出し・セクションのみ Read する。本文全読は禁止。テーブル外の本文を読みたくなった場合は、サブエージェント側が「メインに渡すべき情報を固定見出しに整形していない」ことを意味する。整形をサブエージェント側の責務として扱い、メインは限定 Read を破らない。

| 用途 | 対象ファイル | 抜粋する箇所 |
|---|---|---|
| Step 3 のデータソース再解決要否の判定 | `<workdir>/01_data-profile.md` | `## データソース` |
| Step 3 承認ゲートのユーザー概要提示、および確定データソース・機密区分・完了条件・`N`・`M` の取得 | `<workdir>/02_analysis-requirements.html` | `<section id="design-summary">` |
| Step 4 のループ制御 | `<workdir>/03_iterations/<n>_evaluation.md` | `## 判定` |
| Step 6 のループ制御 | `<workdir>/05_reproduction/<m>_verification.md` | `## 判定` |

## 中間生成物の命名規約

**この命名規約を知るのは本 SKILL.md だけ**。各サブエージェントは命名規約を知らず、出力先の絶対パスを引数として受け取る（疎結合）。

`<workdir>` = `<target-project-root>/tasks/<yyyy-mm-dd>_data-analysis/`

| パス | 内容 | 生成主体 |
|---|---|---|
| `<workdir>/data/manifest.md` | データソース台帳。**データの所在に関する唯一の情報源** | `data-ingestion-profiler` |
| `<workdir>/01_data-profile.md` | データプロファイル（`## データソース` に `RESOLVED` / `UNRESOLVED`、列・型・欠損・分布・期間・異常値） | `data-ingestion-profiler` |
| `<workdir>/02_analysis-requirements.html` | 分析要件シート。分析要件の唯一の情報源 | `analysis-requirements-designer` |
| `<workdir>/03_iterations/<n>_plan.md` | 第 `n` 周の分析プラン | `analysis-planner` |
| `<workdir>/03_iterations/<n>_execution.md` | 第 `n` 周の実行ログ（ハッシュ照合結果・コード全文・出力・図表参照） | `analysis-executor` |
| `<workdir>/03_iterations/<n>_evaluation.md` | 第 `n` 周の評価（`## 判定`（分析ループ群のみに対する判定）＋ 完了条件の充足状況 ＋ 逸脱点検 ＋ `## レポート工程への引き継ぎ事項` ＋ 次周フィードバック） | `analysis-evaluator` |
| `<workdir>/04_analysis-report.md` | 再現可能レポート（Markdown） | `analysis-report-author` |
| `<workdir>/05_reproduction/<m>_verification.md` | 第 `m` 周の再現検証レポート（`## 判定` を含む） | `reproduction-verifier` |
| `<workdir>/06_analysis-report.html` | 清書レポート（単一ファイル HTML） | `analysis-report-stylist` |
| `<workdir>/runs/profile/` | プロファイリングの実行資産 | `data-ingestion-profiler` |
| `<workdir>/runs/analysis-<n>/` | 第 `n` 周の分析実行資産 | `analysis-executor` |
| `<workdir>/runs/repro-<m>/` | 第 `m` 周の再現追試資産 | `reproduction-verifier` |

### 実行資産ディレクトリ（`runs/<run-id>/`）

`<run-id>` は `profile`（Step 2）／ `analysis-<n>`（Step 4）／ `repro-<m>`（Step 6）。メインが組み立てるのはこの 3 系統のディレクトリ絶対パスまでで、上表に記載した `runs/profile/` `runs/analysis-<n>/` `runs/repro-<m>/` がその全体である。

配下の内訳（スクリプト・再実行エントリポイント・実行環境記録・派生データ・標準出力・図表・実行索引）と、その命名規約・要件は **How スキル `analysis-run-recording` が唯一の情報源として定める**。3 系統で構成を共通化し、同じ手順で読み・再実行できるようにする責務も同スキルが負う。メインは `run-dir` の絶対パスを渡すだけで、内部構成には介入しない。

規約:

- 番号接頭辞は成果物の生成順に一致させる（Step 1 は成果物を持たないため、Step 2 の成果物が `01_` から始まる）。反復する生成物のみサブディレクトリ（`03_iterations/` / `05_reproduction/` / `runs/`）に束ねる。
- `data/` は番号を持たない。特定 Step の成果物ではなく、Step 2 以降の全工程が参照する台帳だからである。
- 中間生成物はすべて `tasks/` 配下に閉じる。`src/` や `docs/` を汚さない。
- 元データは既定では複製しない。複製・スナップショットを作る条件と、`<workdir>/data/` 配下の内部構成（台帳以外の複製・スナップショットをどの名前でどこに置くか）は **How スキル `analysis-data-handling` が唯一の情報源として定める**。メインは `data-dir` と `manifest-output-path` の絶対パスを渡すだけで、配下の内部構成には介入しない。

## 実行手順

### Step 1 — 作業ディレクトリ準備

`analysis-workdir-initializer` を起動する。

- **引数**:
  - `workflow-name`: `data-analysis`
  - `subdirs`: 作成する骨格サブディレクトリの相対名を改行区切りで列挙したもの。本ワークフローでは `data` / `03_iterations` / `05_reproduction` / `runs` の 4 つ。
- **期待する戻り値**: 作成された作業ディレクトリの絶対パス 1 行。これを `<workdir>` として保持する。
- 以降のすべてのパスは `<workdir>` を基点に組み立て、絶対パスでサブエージェントに渡す。

### Step 2 — データ取り込みとプロファイリング

`data-ingestion-profiler` を起動する。

- **引数**:
  - `target-project-root`: `<target-project-root>`
  - `analysis-request`: スキル起動時の引数全文（空でもそのまま渡す）
  - `data-dir`: `<workdir>/data`
  - `manifest-output-path`: `<workdir>/data/manifest.md`
  - `profile-output-path`: `<workdir>/01_data-profile.md`
  - `run-dir`: `<workdir>/runs/profile`
- **期待する戻り値**: `<workdir>/01_data-profile.md` の絶対パス 1 行。
- `analysis-request` にプロジェクトルート相対のパス（`datasets/foo/bar.csv` 等）が含まれる場合、`data-ingestion-profiler` は `target-project-root` を基点としてそれを解決する。メインは基点を補足する自然文を `analysis-request` に付け足さない——基点は引数で渡すものであり、自然文で補うと係ごとに解釈が割れるため。
- **データソースが未確定の場合も中断しない**。`01_data-profile.md` の `## データソース` に `UNRESOLVED` と候補一覧が記録された状態で Step 3 に進む。確定は Step 3 の承認ゲートで行う。

### Step 3 — 分析要件定義（draft → 承認ゲート → revise 反復）

設計サイクルと承認ゲートの作法は `analysis-design-cycle` の契約に従う。設計係は `analysis-requirements-designer`（`draft` / `revise` の 2 モード）。

**3-1. draft** — `analysis-requirements-designer` を起動する。

- **引数**:
  - `mode`: `"draft"`
  - `analysis-request`: 起動時の引数全文
  - `profile-path`: `<workdir>/01_data-profile.md`
  - `requirements-path`: `<workdir>/02_analysis-requirements.html`
- **期待する戻り値**: `<workdir>/02_analysis-requirements.html` の絶対パス 1 行。

**3-2. 承認ゲート** — `analysis-design-cycle` の承認ゲート手順を適用する。本ワークフロー固有の差分は次のとおり。

- 限定 Read の対象は `<workdir>/02_analysis-requirements.html` の `<section id="design-summary">` のみ（Markdown の `## 設計サマリ` ではなく、HTML の当該セクション）。
- `AskUserQuestion` の質問文には `<workdir>/02_analysis-requirements.html` の絶対パスを必ず含め、ユーザーがブラウザで開いてレビューできる状態にする。
- 「修正要望あり」の場合、取得した自由記述を `modification-request` として `analysis-requirements-designer` を `mode: "revise"` で再起動する。引数の残り（`analysis-request`、`profile-path`、`requirements-path`）は draft と同一の値を再利用する。戻り値を受け取ったら限定 Read からやり直す。反復上限なし。

**3-3. 承認時に取り出す値** — `<section id="design-summary">` から以下を取得して保持する。

- **確定データソース**
- **機密区分**
- **完了条件（受け入れ基準）** — 分析ループ群（`AC-L-*`）とレポート工程群（`AC-R-*`）の内訳（各群の件数と ID 一覧）を含む
- **最大試行回数 `N`**（記載がなければ既定 5）
- **最大再現試行回数 `M`**（記載がなければ既定 3）

**3-4. データソース再解決（分岐）** — 次のいずれかに該当する場合に限り `data-ingestion-profiler` を再起動してから Step 4 へ進む。いずれにも該当しない場合は再起動せず Step 4 へ進む。

1. `01_data-profile.md` の `## データソース` が `UNRESOLVED` である。
2. 承認された確定データソースが Step 2 で解決されたソースと異なる。

- **引数**:
  - `target-project-root`: Step 2 と同一の値
  - `analysis-request`: Step 2 と同一の値
  - `data-dir`: Step 2 と同一の値
  - `manifest-output-path`: Step 2 と同一の値
  - `profile-output-path`: Step 2 と同一の値（`<workdir>/01_data-profile.md`。同一パスへ上書きさせ、再解決後のプロファイルで置き換える）
  - `run-dir`: Step 2 と同一の値
  - `data-source`: 承認済み要件シートの確定データソースの記述。`data-ingestion-profiler` は `data-source` が渡された起動ではそれを唯一の正として扱うため、`analysis-request` は文脈として渡すに留まる。
- Step 2 と 3-4 の引数集合の差分は `data-source` の有無だけである。それ以外の 6 引数は Step 2 と同一の値を渡す。
- **期待する戻り値**: 上記 `profile-output-path` に渡した絶対パス（`<workdir>/01_data-profile.md`）1 行（`manifest-output-path` の台帳も更新される）。

### Step 4 — 分析ループ（plan → execute → evaluate、最大 `N` 周）

第 `n` 周（`n` = 1..`N`）で以下を **直列に** 実行する。

**4-1. プラン構築** — `analysis-planner` を起動する。

- **引数**:
  - `requirements-path`: `<workdir>/02_analysis-requirements.html`
  - `profile-path`: `<workdir>/01_data-profile.md`
  - `iteration`: `n`
  - `plan-output-path`: `<workdir>/03_iterations/<n>_plan.md`
  - **2 周目以降のみ** `previous-evaluation-path`: `<workdir>/03_iterations/<n-1>_evaluation.md`（1 周目では渡さない）
- **期待する戻り値**: `<workdir>/03_iterations/<n>_plan.md` の絶対パス 1 行。

**4-2. プラン実行** — `analysis-executor` を起動する。

- **引数**:
  - `plan-path`: `<workdir>/03_iterations/<n>_plan.md`
  - `requirements-path`: `<workdir>/02_analysis-requirements.html`
  - `manifest-path`: `<workdir>/data/manifest.md`
  - `execution-output-path`: `<workdir>/03_iterations/<n>_execution.md`
  - `run-dir`: `<workdir>/runs/analysis-<n>`
- **期待する戻り値**: `<workdir>/03_iterations/<n>_execution.md` の絶対パス 1 行。

**4-3. 評価** — `analysis-evaluator` を起動する。

- **引数**:
  - `requirements-path`: `<workdir>/02_analysis-requirements.html`
  - `plan-path`: `<workdir>/03_iterations/<n>_plan.md`
  - `execution-path`: `<workdir>/03_iterations/<n>_execution.md`
  - `evaluation-output-path`: `<workdir>/03_iterations/<n>_evaluation.md`
- **期待する戻り値**: `<workdir>/03_iterations/<n>_evaluation.md` の絶対パス 1 行。

**4-4. ループ制御** — `<workdir>/03_iterations/<n>_evaluation.md` の `## 判定` のみを限定 Read する。

`analysis-evaluator` の `## 判定` は **分析ループ群（`AC-L-*`）のみ** に対する判定である。レポート工程群（`AC-R-*`）は Step 5 のレポート作成で充足する条件であり、`CONTINUE` の理由にならない。

- `SATISFIED` → ループを抜けて Step 5 へ。終了理由は「充足」。
- `CONTINUE` かつ `n < N` → `n+1` 周へ。
- `CONTINUE` かつ `n = N` → ループを抜けて Step 5 へ。終了理由は「上限到達」。最終報告でその旨を伝える。

### Step 5 — 再現可能レポート作成（Markdown）

`analysis-report-author` を起動する。

- **引数**:
  - `requirements-path`: `<workdir>/02_analysis-requirements.html`
  - `profile-path`: `<workdir>/01_data-profile.md`
  - `manifest-path`: `<workdir>/data/manifest.md`
  - `iteration-dir`: `<workdir>/03_iterations`
  - `runs-dir`: `<workdir>/runs`
  - `report-output-path`: `<workdir>/04_analysis-report.md`
- **期待する戻り値**: `<workdir>/04_analysis-report.md` の絶対パス 1 行。
- `analysis-report-author` は、各周回の評価レポートの `## レポート工程への引き継ぎ事項` に挙がったレポート工程群（`AC-R-*`）の完了条件を本レポートで充足させ、その自己点検結果をレポート末尾に記す。追加の引数は渡さない（`iteration-dir` の中に引き継ぎ事項が含まれる）。

### Step 6 — 再現実験ループ（最大 `M` 周）

第 `m` 周（`m` = 1..`M`）で以下を **直列に** 実行する。

**6-1. 再現検証** — `reproduction-verifier` を起動する。

- **引数**:
  - `report-path`: `<workdir>/04_analysis-report.md`
  - `iteration`: `m`
  - `verification-output-path`: `<workdir>/05_reproduction/<m>_verification.md`
  - `run-dir`: `<workdir>/runs/repro-<m>`
- **期待する戻り値**: `<workdir>/05_reproduction/<m>_verification.md` の絶対パス 1 行。
- 検証は「レポートのみを情報源とする」契約で行われるため、メインは他の中間生成物のパスをこのサブエージェントに渡さない。

**6-2. ループ制御** — `<workdir>/05_reproduction/<m>_verification.md` の `## 判定` のみを限定 Read する。

- `REPRODUCED` → ループを抜けて Step 7 へ。終了理由は「再現一致」。
- `MISMATCH` かつ `m < M` → 6-3 を実行してから `m+1` 周へ。
- `MISMATCH` かつ `m = M` → 6-3 を実行し、ループを抜けて Step 7 へ進む。終了理由は「上限到達」。最終報告でその旨を伝える。最終周でも 6-3 を実行するのは、その周で判明した差異をレポートに反映してから清書へ渡すためである。

**6-3. レポートへの反映**（`MISMATCH` 時のみ） — `analysis-report-author` を再起動する。

- **引数**:
  - Step 5 の引数一式（`requirements-path`、`profile-path`、`manifest-path`、`iteration-dir`、`runs-dir`、`report-output-path`）を同一の値で渡す
  - **反映モードの指定** `verification-report-path`: `<workdir>/05_reproduction/<m>_verification.md`（Step 5 の初回起動では渡さない引数。これを渡した起動だけが既存レポートへの反映になる）
- **期待する戻り値**: `<workdir>/04_analysis-report.md` の絶対パス 1 行（既存レポートが Edit される）。

### Step 7 — レポート清書（HTML）

`analysis-report-stylist` を起動する。

- **引数**:
  - `report-path`: `<workdir>/04_analysis-report.md`
  - `requirements-path`: `<workdir>/02_analysis-requirements.html`
  - `runs-dir`: `<workdir>/runs`
  - `html-output-path`: `<workdir>/06_analysis-report.html`
- **期待する戻り値**: `<workdir>/06_analysis-report.html` の絶対パス 1 行。

## 最終報告

メインはユーザーに以下のみを返す。中間生成物の本文を要約して貼らない。

- 作業ディレクトリの絶対パス（`<workdir>`）
- `<workdir>/01_data-profile.md` の絶対パス
- `<workdir>/02_analysis-requirements.html` の絶対パス
- `<workdir>/04_analysis-report.md` の絶対パス
- `<workdir>/06_analysis-report.html` の絶対パス
- `<workdir>/data/manifest.md` の絶対パス
- `<workdir>/runs/` の絶対パス
- 確定データソースと機密区分
- 分析ループの周回数と終了理由（充足 / 上限到達）
- 再現実験ループの周回数と終了理由（再現一致 / 上限到達）
- 分析ループが「上限到達」で終わった場合のみ、最後の `<workdir>/03_iterations/<n>_execution.md` と `<workdir>/03_iterations/<n>_evaluation.md` の絶対パス（「失敗時のリカバリ」の Step 4-2 の行に従う）
- 再現実験ループが「上限到達」で終わった場合のみ、最後の `<workdir>/05_reproduction/<m>_verification.md` の絶対パス

## 失敗時のリカバリ

サブエージェントが不整合を報告して中断した場合、メインは自動補正・自動進行せず、以下に従う。

| 事象 | メインの対応 |
|---|---|
| Step 1 で作業ディレクトリを作成できない（権限・パス不正） | 以降のステップを起動せず、原因をユーザーに報告して終了する。 |
| Step 2 でデータソースが `UNRESOLVED` | 中断ではない。そのまま Step 3 へ進み、承認ゲートでユーザーに確定させる。 |
| Step 2 でデータの取得自体に失敗（接続不可・ファイル不在） | 中断ではない。`data-ingestion-profiler` は所在を特定できても取得に失敗したソースを `01_data-profile.md` の `## データソース` に `UNRESOLVED` として失敗理由付きで記録するため、メインは同セクションの限定 Read で検知する。Step 3 の承認ゲートでその内容を提示し、確定データソースをユーザーに指定させたうえで 3-4 の再解決を行う。 |
| Step 3 で `analysis-requirements-designer` が対象ファイル不在等を報告 | `requirements-path` の値を確認し、パスが正しければ `mode: "draft"` から再実行する。設計係に Edit を強行させない。 |
| Step 4-2 で台帳とデータのハッシュが不一致 | 戻り値による中断報告ではない（`## 共通契約への準拠` の「不整合を成果物に記録して終了する経路」に該当する）。4-3 へ進む。ループ制御は 4-4 の規則に従う。上限到達で Step 5 へ進んだ場合は、最終報告に最後の `<n>_execution.md` と `<n>_evaluation.md` の絶対パスを含める。 |
| Step 4 の任意のサブエージェントがエラーで完走できない | 当該周回を成功として扱わない。同一引数で 1 回だけ再起動し、それでも失敗する場合は該当周回までの成果物のパスと失敗内容をユーザーに報告して終了する。 |
| Step 5 でレポートを組み立てられない（周回の成果物が欠落） | 欠落しているファイルの絶対パスを提示し、どの Step から再実行するかをユーザーに確認する。 |
| Step 6 で `M` 周を経ても `MISMATCH` | 中断ではない。Step 7 へ進み、最終報告で「上限到達」と最後の `<m>_verification.md` の絶対パスを伝える。 |
| Step 7 で HTML 生成に失敗 | `04_analysis-report.md` は完成しているため、その絶対パスを成果として報告したうえで、HTML 清書のみ再実行するか確認する。 |

ハッシュ不一致の行について補足する。`analysis-evaluator` が「ハッシュ不一致のまま進めた実行」を要件逸脱として点検し `## 判定` に `CONTINUE` を置くため、ループ制御を 4-4 の規則にそのまま委ねてよい。ただし台帳と元データが一致しない限り、周回を重ねても完了条件は充足しない。最終報告に実行ログと評価の絶対パスを含めるのは、そこに記録された期待値・実測値・対象パスをもとに、ユーザーが「元データを元に戻す」「新しいデータで台帳を作り直す（Step 2 から再実行）」のどちらを採るかを判断できるようにするためである。

いずれの場合も、途中で作成された成果物は削除しない。再開時は既存の `<workdir>` を再利用し、Step 1 をやり直さない。
