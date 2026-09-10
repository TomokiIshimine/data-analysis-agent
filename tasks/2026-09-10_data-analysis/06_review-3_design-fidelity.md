# レビューレポート（観点: design-fidelity）

対象:

- `/Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-workdir-initializer.md`
- `/Users/tishimine/Workspace/data-analysis-agent/.claude/agents/data-ingestion-profiler.md`
- `/Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-requirements-designer.md`
- `/Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-planner.md`
- `/Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-executor.md`
- `/Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-evaluator.md`
- `/Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-report-author.md`
- `/Users/tishimine/Workspace/data-analysis-agent/.claude/agents/reproduction-verifier.md`
- `/Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-report-stylist.md`
- `/Users/tishimine/Workspace/data-analysis-agent/.claude/skills/data-analysis/SKILL.md`
- `/Users/tishimine/Workspace/data-analysis-agent/.claude/skills/analysis-design-cycle/SKILL.md`
- `/Users/tishimine/Workspace/data-analysis-agent/.claude/skills/html-deliverable-design/SKILL.md`
- `/Users/tishimine/Workspace/data-analysis-agent/.claude/skills/analysis-run-recording/SKILL.md`
- `/Users/tishimine/Workspace/data-analysis-agent/.claude/skills/analysis-data-handling/SKILL.md`

設計書: `/Users/tishimine/Workspace/data-analysis-agent/tasks/2026-09-10_data-analysis/02_workflow-design.md`
前周レポート: `/Users/tishimine/Workspace/data-analysis-agent/tasks/2026-09-10_data-analysis/06_review-2_design-fidelity.md`
レビュー観点: design-fidelity
レビュー日時: 2026-09-10T19:40:00+09:00
モード: 差分レビュー（3 周目）

## 解消済みの前回指摘

**なし。** 前周の指摘 2 件（いずれも軽微）は本周回でも該当箇所が変更されておらず、下記に前周の記述のまま再掲する。

## 照合結果の要約

前周と同じ照合基準（設計書 `## 後続工程への引き継ぎ事項` の「レビュー工程」）で再点検した。本周回に再生成された範囲（`analysis-executor.md` / `analysis-planner.md` / `analysis-report-author.md` / `data-ingestion-profiler.md` / `skills/analysis-data-handling/SKILL.md` / `skills/data-analysis/SKILL.md`）を含め、以下は設計書どおりである。

- **サブエージェントの網羅**: 設計書 `## 作成対象サブエージェント` の `- name:` 9 件がすべて `.claude/agents/<agent-name>.md` として存在し、余剰なし。`## 流用する既存サブエージェント` は 0 件で除外は発生しない。
- **シーケンス図との一致**: `participant` 名（`User` / `Main` を除く 9 件）が `- name:` 集合と完全一致。Step 1〜7 の直列、Step 3 の承認ループ、Step 4 の最大 `N` 周ループ、Step 6 の最大 `M` 周ループ、承認後のデータソース再解決の分岐も `## 全体手順` の記述と矛盾しない。
- **各エージェントの責務・判断基準・入出力・戻り値**: 9 体すべてで設計書の記述が反映されている。今周回に再生成された 4 体のうち、`analysis-report-author` に加わった相対パス基準の明示（`runs-dir` の親＝作業ディレクトリ）は設計書 Step 5 の「`<workdir>` からの相対パス」と一致し、`data-ingestion-profiler` に加わった「取得に失敗したソースも `UNRESOLVED` として記録する」は設計書 `## データソース` の 2 値（`RESOLVED` / `UNRESOLVED`）の枠内にある拡張で、設計書と矛盾しない。
- **使用スキル宣言**: 9 体すべて設計書の `使用スキル` と一致（`analysis-workdir-initializer` / `analysis-planner` / `analysis-evaluator` は「なし」、他 6 体は指定の How スキルを `Skill` ツールで明示呼び出し）。外部プラグイン提供のスキル・サブエージェントへの参照は生成物のいずれからも検出されず、設計書の自己完結方針どおり。
- **ワークフロースキル**: `disable-model-invocation: true` / `argument-hint` / 配置パス / `allowed-tools` 不指定が `## 生成されるワークフロースキル` の記載どおり。`本文に含める節` の 8 節がすべて存在する。
- **Step の入出力パス**: `## 全体手順` の各 Step の引数と、`## 中間生成物の配置とファイル名規約` の表・`runs/<run-id>/` の系統・`### メインの限定 Read 契約` の 4 行が、生成 SKILL.md の対応箇所と一致する（下記の指摘を除く）。
- **How スキル 4 本**: `analysis-design-cycle` / `html-deliverable-design` / `analysis-run-recording` / `analysis-data-handling` がすべて存在し、各スキルの `定めるもの` の項目が見出しとして漏れなく反映され、`定めないもの` も明記されている。`disable-model-invocation` はいずれも未指定で設計書どおり。
- **逸脱の扱い**: 設計書 `## ⚠️ /context-engineering からの逸脱` に明示された逸脱 1 件（プラグイン資産を流用せずプロジェクト内で自己完結する）に沿った実装である。ただし、同セクションに明示のない逸脱を 1 件新たに検出した（下記「新規指摘」）。

## 未解消の指摘 / 新規指摘

  - 重大度: 重大
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/data-analysis/SKILL.md
    箇所: `## 失敗時のリカバリ` の「Step 4-2 で台帳とデータのハッシュが不一致」行、および `## 共通契約への準拠` → `### メインの作法` の「整合チェック失敗時の中断ポリシー」
    問題: 設計書 `## 作成対象サブエージェント` の `analysis-executor` は、判断基準で「ハッシュが台帳と一致しない場合は分析を進めず、不一致の事実（期待値・実測値・対象パス）を **実行ログに記録して終了する**」と定め、`出力` 欄でも `<execution-output-path>` の Write と絶対パス 1 行の戻り値を規定している。設計書 `## 生成される How スキル` の `analysis-data-handling` も「不一致時は処理を進めず、期待値・実測値・対象を **記録して停止すること**」を定めるものとして挙げている。しかし本 SKILL.md は「`analysis-executor` は **実行ログを書かず** 絶対パスも返さないため、メインは戻り値が絶対パス 1 行でないことで検知する」とし、あわせて「整合チェック失敗時は成果物ファイルも書かず」「不整合の検知経路は本プロトコルに一本化し、成果物ファイルへの記録を介した検知経路は持たない」と一般規約化している。これは設計書が `analysis-executor` について明示した振る舞いと正面から矛盾する変更であり、設計書 `## ⚠️ /context-engineering からの逸脱` には記載がない（明示なき逸脱）。結果として、設計書どおりに書かれている `analysis-executor.md`（判断基準「ハッシュ不一致は停止条件」＋ 作業手順 3「不一致の事実を `<execution-output-path>` に記録して終了する」＋ 手順 7 で絶対パスを出力）および `analysis-data-handling` の `## 4. 同一性の検証`（「実行ログ／検証レポートに記録して終了する」）と、生成物どうしが同一の失敗経路について排他的な振る舞いを規定している。実行時には `analysis-executor` が実行ログを書いて絶対パスを返すため、SKILL.md が用意した中断検知（戻り値が絶対パス 1 行でないこと）は発火せず、`## 失敗時のリカバリ` の当該行に定めた `AskUserQuestion` による復旧は到達不能になる。
    期待される状態: 設計書を正として、本 SKILL.md の記述を設計書どおりに戻す。すなわち (1)「Step 4-2 で台帳とデータのハッシュが不一致」行は、`analysis-executor` が不一致の事実（期待値・実測値・対象パス）を `<workdir>/03_iterations/<n>_execution.md` に記録して終了し、絶対パスを返す前提で書き直す。(2)「整合チェック失敗時の中断ポリシー」の一般規約から、`analysis-executor` のハッシュ不一致を含む「成果物ファイルも書かない」「成果物ファイルへの記録を介した検知経路は持たない」という言い切りを外し、設計書が成果物への記録を明示している経路（`analysis-executor` のハッシュ不一致、`data-ingestion-profiler` の `UNRESOLVED`）を例外として認める形にする。設計書が定める `analysis-executor` の振る舞い自体を変える必要があると判断する場合は、SKILL.md を先に変えるのではなく、設計書 `## 作成対象サブエージェント` の `analysis-executor` 項と `## ⚠️ /context-engineering からの逸脱` を更新して逸脱として明示し、そのうえで SKILL.md・`analysis-executor.md`・`analysis-data-handling` の 3 者を同時に揃える。いずれにせよ、SKILL.md 単独が設計書と他の生成物の双方に反する現状を解消すること。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/data-analysis/SKILL.md
    箇所: `### Step 6 — 再現実験ループ（最大 `M` 周）` の `**6-2. ループ制御**` 第 3 分岐
    問題: `MISMATCH` かつ `m = M` の分岐で「6-3 を実行し、ループを抜けて Step 7 へ」としているが、設計書 `## 全体手順` Step 6 の項番 2 は「`m = M` に達したら上限到達として Step 7 へ進み」とだけ書いており、6-3（レポートへの反映）の実行を指示していない。設計書の項番 3 が「`MISMATCH` 時のみ」としか書いていないため解釈の余地はあるが、設計書の記述をそのまま読むと最終周では反映を行わない流れになり、生成物が 1 手順多い。
    期待される状態: 上限到達時に 6-3 を実行するのが意図であれば、その解釈を採る根拠（最終周の検証で判明した差異もレポートに残すため）を SKILL.md 側に 1 行添えるか、設計書 Step 6 の項番 2・3 の関係を明示して両者の記述を一致させる。実害はないため、他の指摘と併せて修正する場合のみでよい。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/data-analysis/SKILL.md
    箇所: `**3-4. データソース再解決（分岐）**` の `**引数**`
    問題: 再解決時に渡す引数を「Step 2 と同一の `data-dir` / `profile-output-path` / `run-dir` に加えて `data-source`」としており、設計書 Step 2 の入力欄に常時含まれる `analysis-request` が列挙されていない。`data-ingestion-profiler` は `data-source` を唯一の正として扱う契約のため動作上の実害はないが、設計書の入力一覧との対応が 1 項目欠けている。
    期待される状態: 再起動時にも `analysis-request` を渡す（`data-source` 優先の契約は変わらない）か、設計書 Step 2 の入力欄で `analysis-request` が初回起動時のみであることを明記して、どちらか一方に揃える。

## 判定: FAIL
