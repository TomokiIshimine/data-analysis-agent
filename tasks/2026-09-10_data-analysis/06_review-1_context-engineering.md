# レビューレポート（観点: context-engineering）

対象: 以下の 14 ファイル

- /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-workdir-initializer.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/data-ingestion-profiler.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-requirements-designer.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-planner.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-executor.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-evaluator.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-report-author.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/reproduction-verifier.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-report-stylist.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/data-analysis/SKILL.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/analysis-design-cycle/SKILL.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/html-deliverable-design/SKILL.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/analysis-run-recording/SKILL.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/analysis-data-handling/SKILL.md

レビュー観点: context-engineering（DRY／最小コンテキスト／疎結合の 3 原則準拠）
レビュー日時: 2026-09-10T00:00:00+09:00

## 前提（判定根拠の優先順位）

- 設計書 `/Users/tishimine/Workspace/data-analysis-agent/tasks/2026-09-10_data-analysis/02_workflow-design.md` を第一の判定根拠とし、設計書に明示された記述に忠実な箇所は、`/context-engineering` から見て重複に見えても指摘対象としない。
- 設計書 `## ⚠️ /context-engineering からの逸脱` の逸脱 1（プラグイン資産を流用せずプロジェクト内で自己完結する）は承認済みの逸脱であり、生成 SKILL.md が `/workflow-orchestration` `/design-cycle` ではなくプロジェクト内 How スキルを参照していることは指摘対象としない。
- 以下の指摘はすべて、**設計書に根拠がなく、生成時に独自に追加された** 重複・結合に限定している。

## 未解消の指摘 / 新規指摘

  - 重大度: 中
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/data-ingestion-profiler.md
    箇所: `# 使用するスキル` — `analysis-run-recording` の項
    問題: 使用スキルの宣言に留まらず、`analysis-run-recording` が唯一の情報源として定めている内容を転写している。具体的には `<run-dir>` 配下の構成（`scripts/` / `run.sh` / `environment.md` / `derived/` / `outputs/` / `figures/` / `run-manifest.md`）を全列挙し、さらに「実行するコードは必ずスクリプトファイルとして保存してから実行する」という原則の文言をそのまま持ち込んでいる。設計書の当該ブロック（`## 作成対象サブエージェント` の `data-ingestion-profiler`）は `使用スキル: [analysis-data-handling, analysis-run-recording]` としか規定しておらず、この列挙は生成時に独自に追加されたものである。同じ構成情報が `analysis-run-recording/SKILL.md` の構成テーブルと二重に存在するため、スキル側の構成を変更した際にサブエージェント定義側が古いまま取り残される（DRY 違反）。また、本エージェント自身が判断基準で「規約の本文を転写しない」と宣言している内容とも矛盾している。
    期待される状態: 呼び出し理由を主題名のレベルに留め、規約の中身を書かない。同じワークフロー内の `analysis-executor.md` の書き方（「`run-dir` 配下の構成・命名規約・`run.sh` の要件・`environment.md` の記録項目・失敗時の残し方を確認するため」）が到達点であり、ディレクトリ名の全列挙と原則の文言引用をこれに置き換える。

  - 重大度: 中
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-report-author.md
    箇所: `## 入力（すべて絶対パス。呼び出し元から渡される）` — `runs-dir` の項
    問題: `runs-dir` の説明として `analysis-run-recording` が定める実行資産の構成（`scripts/` / `run.sh` / `environment.md` / `derived/` / `outputs/` / `figures/` / `run-manifest.md`）を全列挙している。設計書の当該ブロックは入力を `runs-dir` としか規定しておらず、この内訳は生成時に独自に追加されたものである。本エージェントは同ファイルの `# 使用するスキル` で `analysis-run-recording` を読み手として呼び出すことを宣言済みであり、構成の実体はそちらが唯一の情報源である。同じ列挙が `data-ingestion-profiler.md` と `data-analysis/SKILL.md` にも存在するため、`analysis-run-recording` の構成を変更すると 4 箇所を同期する必要が生じる（DRY 違反）。
    期待される状態: `runs-dir` の説明を「実行資産ディレクトリ群のルート。配下の構成と命名規約は `analysis-run-recording` が定める」の水準に留め、ディレクトリ名の列挙を削る。

  - 重大度: 中
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/analysis-data-handling/SKILL.md
    箇所: `## 5. 機密区分` の箇条書き（「掲載可否の判断に迷う場合は載せない」の項）および `## 7. レポートへの転記` の冒頭
    問題: How スキルが本ワークフロー固有の成果物ファイル名 `04_analysis-report.md` / `06_analysis-report.html` を直書きしている。設計書の `## 生成される How スキル` の `analysis-data-handling` 「定めるもの」には具体ファイル名の指定はなく、これは生成時に独自に追加された結合である。生成 SKILL.md は `## 中間生成物の命名規約` の冒頭で「**この命名規約を知るのは本 SKILL.md だけ**」と宣言しており、その契約に直接反する。番号接頭辞を含むファイル名規約を変更した場合、SKILL.md だけでなく本 How スキルの修正も必要になり、スキルがワークフロー構成に従属する（疎結合違反）。
    期待される状態: 具体ファイル名を使わず、役割名で書く（「再現可能レポート（Markdown）と清書レポート（HTML）」）。同ファイル `## 7. レポートへの転記` 冒頭は既に役割名で書けているため、その表現に揃える。なお `data/manifest.md` / `data/raw/` / `data/snapshot/` は設計書が本スキルの「定めるもの」として明示的に規定しているため、変更対象に含めない。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-executor.md
    箇所: `# 作業手順` の手順 5
    問題: `analysis-run-recording` が定める `<NN>_<slug>` の対応づけ規約を作業手順に持ち込んでいる。設計書の当該ブロックにこの記法の指定はない。同ファイルの `# 使用するスキル` で当該スキルの「命名規約」を確認すると宣言済みであり、記法の実体はスキル側にある。
    期待される状態: 「`analysis-run-recording` の規約どおりの配置と対応づけで保存する」に留め、`<NN>_<slug>` という具体的な記法をサブエージェント定義に持ち込まない。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-report-stylist.md
    箇所: `# 判断基準` — 「保存済みスクリプトの相対パスを併記する」の項
    問題: 「`runs-dir` の親ディレクトリ（作業ディレクトリ）を基準とした相対パス」と書き、`runs-dir` の親が作業ディレクトリであるというディレクトリ構造の知識をサブエージェント側に持たせている。設計書の当該ブロックは「`<workdir>` からの相対パス」とだけ規定しており、構造の導出方法までは求めていない。SKILL.md が「命名規約を知るのは本 SKILL.md だけ」としている契約から見ると、階層構造の推測がサブエージェント側に漏れている。
    期待される状態: 相対パスの基準を構造から導出させず、SKILL.md 側で基準ディレクトリを引数として渡す形にするか、本ファイルの記述を「レポート本文が用いているのと同じ基準の相対パスを併記する」に改め、階層構造への依存を持たせない。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-planner.md
    箇所: `# 使用するスキル`（末尾の括弧書き）
    問題: 「（設計書の `使用スキル: なし` に従う）」と、生成元の設計書を実行時のサブエージェント定義から参照している。設計書は `tasks/` 配下の揮発系コンテキストであり、本エージェントの実行時には存在も参照もされない。読み手にとって行動を変えない情報がプロンプトに残っている（最小コンテキスト）うえ、生成物が生成元文書に結合している（疎結合）。
    期待される状態: 括弧書きを削り、「なし」であることとその理由（他のサブエージェントと共有する How を持たないこと）だけを残す。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/data-analysis/SKILL.md
    箇所: `### 実行資産ディレクトリ（`runs/<run-id>/`）の内訳` のテーブル（7 行）
    問題: 直前の本文で「内訳の規約本体は How スキル `analysis-run-recording` が定める。メインは `run-dir` の絶対パスを渡すだけで、内部構成には介入しない」と述べながら、内訳テーブルを全行再掲している。メインが介入しない情報がメインのスキルに載っており、最小コンテキストの観点で不要である。ただし設計書 `## 生成されるワークフロースキル` の「本文に含める節」が「中間生成物の命名規約（`data/` と `runs/` の構成を含む）」と明示しているため、設計書優先の原則により軽微に留める。
    期待される状態: メインが実際に組み立てる `runs/profile/` `runs/analysis-<n>/` `runs/repro-<m>/` の 3 パス（上のテーブルに記載済み）のみを残し、`<run-id>` 配下の 7 行の内訳は `analysis-run-recording` への委譲に置き換える。設計書の指示との整合を優先して現状を維持する判断も許容する。

## 判定: FAIL
