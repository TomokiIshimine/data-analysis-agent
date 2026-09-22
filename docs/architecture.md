# アーキテクチャ — 資産の地図

このリポジトリにアプリケーションコードはない。資産は `.claude/` 配下の Claude Code 定義ファイルだけであり、それらが真実の源泉である。本書はそれらを毎回全読せずに全体像を掴み、目的の定義ファイルへ辿り着くための地図であり、定義の内容を再掲しない。

## 3 層構造

| 層 | 場所 | 責務 |
|---|---|---|
| ワークフロースキル | `.claude/skills/data-analysis/SKILL.md` | 人間が `/data-analysis` で起動する定型作業の手順。7 ステップの順序・各ステップで呼ぶサブエージェントと引数・ループ制御・中間生成物の命名規約・失敗時のリカバリを一元保持する。メインエージェントだけが読む |
| サブエージェント | `.claude/agents/*.md`（9 体） | 各ステップの実作業。独立したコンテキストで動き、結果ファイルの絶対パス 1 行だけをメインに返す。命名規約を知らず、出力先は引数で受け取る |
| How スキル | `.claude/skills/{analysis-data-handling,analysis-design-cycle,analysis-run-recording,html-deliverable-design}/SKILL.md`（4 本） | 複数のサブエージェントが共有する「どうやるか」。各サブエージェントが `# 使用するスキル` で名指しして読み込む。プロジェクト固有のドキュメントには依存しない |

すべて `.claude/` 配下に閉じており、外部プラグインのサブエージェント・スキルは参照しない。

## 7 ステップの概観

各ステップの引数・戻り値・分岐は SKILL.md の同名 Step 節が正である。

| Step | 目的 | 委譲先 | 反復 |
|---|---|---|---|
| 1 | 日付付き作業ディレクトリと、引数で渡された骨格サブディレクトリを作る | `analysis-workdir-initializer` | なし |
| 2 | データソースを解決し、台帳とデータプロファイルを作る | `data-ingestion-profiler` | なし（Step 3 承認後に再解決あり） |
| 3 | 分析要件シート（HTML）を起草し、ユーザー承認を得る | `analysis-requirements-designer` ＋ メインの承認ゲート | 承認まで無制限 |
| 4 | プラン立案 → 実行 → 評価の分析ループ。評価は分析ループ群（`AC-L-*`）の完了条件だけを判定し、レポート工程群（`AC-R-*`）は Step 5 へ引き渡す | `analysis-planner` → `analysis-executor` → `analysis-evaluator` | 最大 N 周（既定 5） |
| 5 | 全周回を統合した再現可能レポート（Markdown）を書く | `analysis-report-author` | なし |
| 6 | レポートだけを情報源に追試し、不一致ならレポートへ反映する | `reproduction-verifier`（→ 不一致時 `analysis-report-author`） | 最大 M 周（既定 3） |
| 7 | 単一ファイル HTML に清書する | `analysis-report-stylist` | なし |

## サブエージェント 9 体

| 名前 | 責務（1 行） | 粒度 | 使用する How スキル |
|---|---|---|---|
| `analysis-workdir-initializer` | `tasks/<日付>_<名前>/` と、引数で渡された骨格サブディレクトリを作り絶対パスを返す。骨格の名前を自分では持たない | 1 体 | なし |
| `data-ingestion-profiler` | データソースを解決し、引数で渡された出力先に台帳とプロファイルレポートを作る。依頼文中の相対パスは `target-project-root` を基点に解決する | 1 体 | `analysis-data-handling` `analysis-run-recording` |
| `analysis-requirements-designer` | draft / revise の 2 モードで分析要件シート（HTML）を作る設計係 | 1 体 | `analysis-design-cycle` `html-deliverable-design` `analysis-data-handling` |
| `analysis-planner` | 要件と前周のフィードバックから当該周回の分析プランを書く | 1 インスタンス = 1 周回 | なし |
| `analysis-executor` | 台帳とデータのハッシュを照合してからプランを実行し、実行資産を再実行可能な形で保存する | 1 インスタンス = 1 周回 | `analysis-run-recording` `analysis-data-handling` |
| `analysis-evaluator` | 分析ループ群（`AC-L-*`）の充足を判定し、要件逸脱を点検し、レポート工程群（`AC-R-*`）を固定見出しでレポート工程へ引き渡し、次周へのフィードバックを書く | 1 インスタンス = 1 周回 | なし |
| `analysis-report-author` | 全周回の記録を統合して再現可能レポートを書き、レポート工程群（`AC-R-*`）の充足を自己点検して記載する。再現検証レポートを渡されると既存レポートへ反映する | 1 体 | `analysis-run-recording` `analysis-data-handling` |
| `reproduction-verifier` | レポートのみを情報源に追試し、同じ結果が得られるかを検証する第三者役 | 1 インスタンス = 1 周回 | `analysis-run-recording` `analysis-data-handling` |
| `analysis-report-stylist` | Markdown レポートを単一ファイル HTML に清書する | 1 体 | `html-deliverable-design` `analysis-data-handling` |

立案・実行・評価・再現検証を別エージェントに分けているのは、自分の結果を自分で採点させないためである（根拠は `docs/design-decisions.md`）。

## How スキル 4 本

| 名前 | 要旨 | 利用するサブエージェント |
|---|---|---|
| `analysis-data-handling` | データソースの解決、台帳の記録項目、取り込み方式（参照／コピー／スナップショット）、SHA-256 による同一性検証、機密区分ごとの保存・掲載可否、認証情報の扱い | 5 体（profiler / executor / report-author / stylist / verifier） |
| `analysis-run-recording` | `run-dir` 配下の構成、必ずファイルに保存してから実行する原則、`run.sh` と `environment.md` の要件、派生データ、失敗の記録、確定済み `run-dir` の不変性、スクリプトのパラメータ化（周回番号・`run-dir` パスをハードコードしない） | 書き手 3 体（profiler / executor / verifier）、読み手 1 体（report-author） |
| `analysis-design-cycle` | draft → 要約セクションの限定 Read → 承認ゲート → revise の設計サイクル契約。設計係とメインの 2 役を規定 | `analysis-requirements-designer`（設計係）、メイン（オーケストレーター） |
| `html-deliverable-design` | 単一ファイル HTML の情報設計・タイポグラフィ・配色・表と図表の提示規約・アクセシビリティ下限。テンプレートは提供しない | `analysis-requirements-designer`、`analysis-report-stylist` |

### 依存マトリクス

| サブエージェント | data-handling | run-recording | design-cycle | html-design |
|---|:-:|:-:|:-:|:-:|
| `analysis-workdir-initializer` | | | | |
| `data-ingestion-profiler` | ● | ● | | |
| `analysis-requirements-designer` | ● | | ● | ● |
| `analysis-planner` | | | | |
| `analysis-executor` | ● | ● | | |
| `analysis-evaluator` | | | | |
| `analysis-report-author` | ● | ● | | |
| `reproduction-verifier` | ● | ● | | |
| `analysis-report-stylist` | ● | | | ● |

2 体以上が共有する How はすべて How スキルに集約されており、サブエージェント定義に同じ規約は書かれていない。

## 成果物の流れ

1 回の実行につき `tasks/<yyyy-mm-dd>_data-analysis/` が 1 つ作られ、すべての中間生成物と成果物がその中に閉じる。`src/` や `docs/` には何も書かれない。配下に生まれるものをカテゴリで示す。個々のファイル名・配置の規約は SKILL.md の `## 中間生成物の命名規約` が唯一の情報源であり、ここには写さない。

| カテゴリ | 内容 | 生成ステップ |
|---|---|---|
| データ台帳と複製 | 所在・取得方法・SHA-256・件数・スキーマ・機密区分の台帳。条件を満たす場合のみ元データのコピーまたはスナップショット | 2 |
| データプロファイル | 列・型・欠損・分布・期間・異常値と、データソースの解決状態（RESOLVED / UNRESOLVED） | 2 |
| 分析要件シート | HTML 1 本。分析要件の唯一の情報源。承認ゲートで確定 | 3 |
| 周回記録 | 周回ごとのプラン・実行ログ・評価。評価の `## 判定` がループ制御の入力 | 4 |
| 再現可能レポート | Markdown。第三者がゼロから同じ結果を出せる情報を含む | 5、6 で更新 |
| 再現検証記録 | 周回ごとの検証レポート。`## 判定` がループ制御の入力 | 6 |
| 清書レポート | 単一ファイル HTML | 7 |
| 実行資産 | プロファイリング・分析各周回・再現追試ごとの、スクリプト・再実行エントリポイント・環境記録・派生データ・出力・図表 | 2、4、6 |

`tasks/` は Git 管理外である（`.gitignore`）。理由は `docs/design-decisions.md` を参照。

## メインとサブの分離

メインエージェントはオーケストレーションに専念し、作業の詳細を自分のコンテキストに乗せない。要点は 3 つ。

- **限定 Read**: メインは各生成物の固定見出し（評価と検証の `## 判定`、要件シートの `<section id="design-summary">` など）だけを読み、本文は読まない。
- **絶対パスの引き回し**: 中間生成物のパスはメインが組み立て、サブエージェントに絶対パスで渡す。サブエージェントは命名規約を推測しない。
- **戻り値 1 行**: サブエージェントは成果物の絶対パス 1 行だけを返し、要約・説明・英語の補足を付けない。入力の不整合を検出したときは成果物を書かず、パスを返さずに報告して終わる。

契約の全文は SKILL.md の `## 共通契約への準拠` と `## 限定 Read 契約（固定見出しテーブル）`、設計サイクル部分は `.claude/skills/analysis-design-cycle/SKILL.md` を参照。

## 関連ドキュメント

- `docs/design-decisions.md` — この構造を選んだ理由と捨てた代替案
- `docs/conventions.md` — 資産を追加・改修するときの規約と、本書の更新義務
