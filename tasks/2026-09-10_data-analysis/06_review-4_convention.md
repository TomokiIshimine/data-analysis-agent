# レビューレポート（観点: convention）

対象:
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

レビュー観点: convention
レビュー日時: 2026-09-10T00:00:00+09:00

## 解消済みの前回指摘

なし。前回レポート（`06_review-3_convention.md`）の 2 件はいずれも軽微であり、いずれも今周回時点で該当箇所が前回のままである。

## 未解消の指摘 / 新規指摘

- 重大度: 軽微
  対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/data-analysis/SKILL.md
  箇所: `### 設計サイクル契約への準拠`（44 行目）
  問題: 「本 SKILL.md では以下を**再掲しない**」と宣言した直下の箇条書きで、`- 承認ゲートの手順（要約セクションの限定 Read → メッセージ提示 → `AskUserQuestion` 1 通で `承認` / `修正要望あり` → 修正要望時は自由記述 1 件を取得して revise 再起動 → 反復上限なし）` と、括弧内に手順そのものを書き下している。`analysis-design-cycle` の `### 承認ゲートの手順`（1〜6 の手順）と内容が重複しており、宣言に反して契約本文の要約が再掲されている。契約が更新された際に片側だけが古くなる。
  期待される状態: 括弧内の手順詳細を削り、委譲対象の項目名だけを列挙する（例: `- 承認ゲートの手順`）。手順の実体は `analysis-design-cycle` の `### 承認ゲートの手順` を唯一の情報源とする。

- 重大度: 軽微
  対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-planner.md
  箇所: 本文の見出し構成（`# 責務` / `# 判断基準` / `# 使用するスキル` の 3 節、35 行目以降）
  問題: 生成された 9 体のうち本ファイルだけが `# 作業手順` 節を持たない（他 8 体はいずれも持つ）。また `analysis-workdir-initializer.md`（30 行目）だけが `# 作業手順（このエージェント固有の How）` と括弧書きの異なる見出し文言を使い、`analysis-requirements-designer.md` は `# 作業手順`（49 行目）→ `# 使用するスキル`（59 行目）の順で、他 7 体（`# 使用するスキル` → `# 作業手順`）と節順が逆になっている。定義群としての見出し規約が揃っていない。
  期待される状態: 9 体で見出しの語（`# 作業手順`）と節順（`# 責務` → `# 判断基準` → `# 使用するスキル` → `# 作業手順`）を統一する。`analysis-planner.md` にも `# 作業手順` を設け、責務・判断基準に対応する実行手順を記述する。

## 判定: PASS

---

補足（指摘ではない確認済み事項。今周回で再確認済み）:

- 上記 1 件目は今周回でも未解消である。`data-analysis/SKILL.md` の 44 行目で「以下を**再掲しない**」と宣言した直下、47 行目の `- 承認ゲートの手順（…）` に手順の書き下しが前回のまま残っている。
- 上記 2 件目は一部のみ解消している。`analysis-planner.md` は `# 使用するスキル`（41 行目）→ `# 作業手順`（45 行目）を持ち、9 体すべてが `# 作業手順` 節を備える状態になった。一方、`analysis-workdir-initializer.md`（30 行目）の `# 作業手順（このエージェント固有の How）` という括弧書きの見出し文言と、同ファイルの節順（`# 作業手順` 30 行目 → `# 使用するスキル` 39 行目）、および `analysis-requirements-designer.md` の節順（`# 作業手順` 49 行目 → `# 使用するスキル` 59 行目）の逆転は残っている。指摘全体としては未解消のため、`/multi-aspect-review` の差分レビュー契約に従い指摘文をそのまま再掲した。
- frontmatter の 4 キー（`name` / `description` / `model` / `color`）は 9 体すべてに揃っている。設計書 `## 作成対象サブエージェント` は `model` の値を指定していないため値の一致確認は行わない。
- `allowed-tools` / `tools` は 9 体のサブエージェントおよび 5 本の SKILL.md のいずれの frontmatter にも存在しない（規約どおり。設計書 `## 生成されるワークフロースキル` の「`allowed-tools` は指定しない」とも一致）。
- `data-analysis/SKILL.md` の frontmatter は `disable-model-invocation: true`（5 行目）を持ち、設計書 `## 生成されるワークフロースキル`（380 行目）と一致する。`argument-hint`（4 行目）も設計書（382 行目）と文字列一致。How スキル 4 本（`analysis-design-cycle` / `html-deliverable-design` / `analysis-run-recording` / `analysis-data-handling`）はいずれも frontmatter が `name` と `description` の 2 キーのみで `disable-model-invocation` キーを持たず、設計書の「未指定」（390 / 396 / 411 / 428 / 447 行目）と一致する。
- `data-analysis/SKILL.md` は `## 共通契約への準拠` 節（22 行目）を持ち、設計書の自己完結方針どおりメインの作法を `### メインの作法` に直接記述し、設計サイクル契約のみプロジェクト内 How スキル `analysis-design-cycle` に委譲している。外部プラグイン（`/workflow-orchestration` / `/design-cycle` / `claude-code-workflow-kit`）への参照は生成物のいずれにも存在しない。
- 設計書 `## 生成されるワークフロースキル` の「本文に含める節」8 項目（前提 / メインの作法 / 設計サイクル契約への準拠 / 限定 Read 契約の固定見出しテーブル / 中間生成物の命名規約 / 実行手順 / 最終報告 / 失敗時のリカバリ）は、`data-analysis/SKILL.md` の `## 実行前提`・`### メインの作法`・`### 設計サイクル契約への準拠`・`## 限定 Read 契約（固定見出しテーブル）`・`## 中間生成物の命名規約`・`## 実行手順`・`## 最終報告`・`## 失敗時のリカバリ` として全て存在する。
- 最終出力規約は 9 体すべてが「最終メッセージは `<…-output-path>` の絶対パス 1 行のみ」と明記しており、説明文の混入を許す記述はない。
- 命名規約は設計書 `## 作成対象サブエージェント` の `- name:` 9 件（238〜302 行目）および `## 生成される How スキル` の 4 件と、ファイル名・ディレクトリ名・frontmatter の `name` がすべて一致し、いずれもケバブケースである。
