# レビューレポート（観点: machine-readable）

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
- /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/analysis-run-recording/SKILL.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/analysis-data-handling/SKILL.md
- /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/html-deliverable-design/SKILL.md

レビュー観点: machine-readable
レビュー日時: 2026-09-10T19:25:38+09:00

## 確認して問題なかった項目

- 設計書 `## 作成対象サブエージェント` の `- name: <…>` 列挙は 9 件すべて行頭の `- name: ` 形式で、`/create-workflow` の「`## 作成対象サブエージェント` から各 `- name: <…>` を抽出」に適合する。`## 生成されるワークフロースキル` 直下の最初の `- name: data-analysis` も同様に抽出可能で、生成された 9 ファイルの `name` frontmatter と 1 対 1 で一致する。
- 全 9 サブエージェントが `## 出力` に「最終メッセージは `<…>` の絶対パス 1 行のみ」を明示し、SKILL.md 各 Step の「期待する戻り値」と引数名・パスが完全に一致している（`workflow-name` / `analysis-request` / `data-dir` / `profile-output-path` / `run-dir` / `data-source` / `mode` / `modification-request` / `requirements-path` / `iteration` / `plan-output-path` / `previous-evaluation-path` / `plan-path` / `manifest-path` / `execution-output-path` / `evaluation-output-path` / `iteration-dir` / `runs-dir` / `report-output-path` / `verification-report-path` / `report-path` / `verification-output-path` / `html-output-path`）。
- メインの限定 Read 契約 4 行の固定見出しが、いずれも生成側の宣言と字句レベルで一致する。`## データソース`（`data-ingestion-profiler`）／`<section id="design-summary">`（`analysis-requirements-designer`）／`## 判定` に `SATISFIED` / `CONTINUE` 1 語（`analysis-evaluator`）／`## 判定` に `REPRODUCED` / `MISMATCH` 1 語（`reproduction-verifier`）。
- サブエージェント間の機械的な受け渡しも整合している。`analysis-evaluator` が書く 4 見出しは `analysis-planner` が `previous-evaluation-path` に期待する内容を満たし、`analysis-run-recording` の `<NN>_<slug>` 対応づけと `run-manifest.md` の列定義は `analysis-report-author` が索引として辿る前提と一致し、`analysis-data-handling` §2 の台帳項目は `analysis-executor` の照合項目・§7 のレポート転記項目・`reproduction-verifier` の突き合わせ項目をすべて充足する。
- 中間生成物の番号接頭辞（`01_`〜`06_`、`03_iterations/` / `05_reproduction/`）と `<run-id>`（`profile` / `analysis-<n>` / `repro-<m>`）の規約が、設計書・SKILL.md・`analysis-run-recording` の 3 者で一致している。

## 未解消の指摘 / 新規指摘

  - 重大度: 中
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/data-analysis/SKILL.md
    箇所: `## 限定 Read 契約（固定見出しテーブル）` ／ `## 共通契約への準拠` の「整合チェック失敗時の中断ポリシー」 ／ `## 失敗時のリカバリ` の「Step 4-2 で台帳とデータのハッシュが不一致」行
    問題: ハッシュ不一致をメインが検知する機械可読な経路が存在しない。リカバリ表はメインに「分析を続行しない。不一致の対象・期待値・実測値をユーザーに提示し、`AskUserQuestion` で選ばせる」という分岐を要求しているが、(1) 限定 Read 契約テーブルに `<workdir>/03_iterations/<n>_execution.md` の行がなく、(2) `analysis-executor` の戻り値は成功時と同じ「`<execution-output-path>` の絶対パス 1 行」であるため、メインは不一致の発生も期待値・実測値も取得できない。さらに「整合チェック失敗時の中断ポリシー」は「編集系ツールを一切呼ばずに不整合内容を報告して終了する」と定めているのに対し、`analysis-executor`（判断基準「ハッシュ不一致は停止条件」・作業手順 3）と `analysis-data-handling` §4 はいずれも「実行ログに記録して終了する」＝ Write を伴う挙動を定めており、同一事象に対して 2 通りの戻り値プロトコルが並立している。
    期待される状態: 限定 Read 契約テーブルに「Step 4-2 のハッシュ照合結果の判定」用の行（対象ファイル `<workdir>/03_iterations/<n>_execution.md`、抜粋する箇所は `## ハッシュ照合` のような固定見出し 1 つ）を追加し、`analysis-executor` が同見出しへ照合結果を 1 語（例: `MATCHED` / `MISMATCH`）＋期待値・実測値・対象で書く前提に揃える。あわせて「整合チェック失敗時の中断ポリシー」に、ハッシュ不一致のように成果物ファイルへ事実を記録してから終了する事象を例外として明記し、「編集系ツールを一切呼ばない」対象を「渡されたパスが存在しない・引数の前提が崩れている」等の入力不整合に限定する。`## 失敗時のリカバリ` の Step 4-2 行には、メインがこの固定見出しの限定 Read で不一致を検知する旨を書く。

  - 重大度: 中
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/data-ingestion-profiler.md
    箇所: `# 責務` の「プロファイルレポートの作成」 ／ `# 判断基準` の「推測でデータを選ばない」 ／ `# 作業手順` の手順 6
    問題: `## データソース` セクションが取り得る状態として `RESOLVED` / `UNRESOLVED` の 2 値しか宣言されておらず、いずれも「所在を特定できたか」だけを表す。一方 SKILL.md の `## 失敗時のリカバリ` は「Step 2 でデータの取得自体に失敗（接続不可・ファイル不在）」という別事象に対して「`01_data-profile.md` に記録された失敗内容を提示し、`AskUserQuestion` でデータソースの再指定を求める」ようメインに要求している。メインの限定 Read は同ファイルの `## データソース` のみに制限されているため、所在は特定できたが取得に失敗したケースの記録先が定義されておらず、メインは限定 Read 契約を破らない限りこの分岐に必要な情報を取得できない。
    期待される状態: `## データソース` の仕様に「所在は特定できたが取得（オープン・接続・ダウンロード）に失敗したソースも本セクションに `UNRESOLVED` として記録し、対象ソースの所在・失敗理由・再指定に必要な情報を併記する」ことを明記する。`RESOLVED` は「台帳エントリを作れたソースのみ」を指す語であることも 1 行で明示し、メインが `## データソース` の限定 Read だけで Step 3 の再解決分岐と Step 2 の取得失敗分岐の両方を判断できる状態にする。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-workdir-initializer.md
    箇所: `# 判断基準` の「失敗したら黙って続行しない」（`ERROR:` で始まる 1 行を返す規約）
    問題: 本係だけが `ERROR:` という戻り値センチネルを独自に定義しているが、消費側の SKILL.md（Step 1 の「期待する戻り値」および `## 共通契約への準拠` の「サブエージェント戻り値の形式」「整合チェック失敗時の中断ポリシー」）にはこのセンチネルの記載がなく、他の 8 体も同じ規約を持たない。メインが「絶対パス 1 行」だけを期待して `ERROR: …` をそのまま `<workdir>` として保持する余地が残る。
    期待される状態: `ERROR:` センチネルを廃して他 8 体と同じ「不整合内容を報告して終了する」形に揃えるか、SKILL.md の「サブエージェント戻り値の形式」に失敗時の戻り値書式として `ERROR:` を明記し、両側で同じプロトコルを宣言する。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-report-author.md
    箇所: `## レポートに必ず含める要素` の「対応する保存済みスクリプトの `<workdir>` からの相対パス」 ／ `## 入力（すべて絶対パス。呼び出し元から渡される）`
    問題: レポートに書く相対パスの基準を `<workdir>` と定めているが、入力引数に `<workdir>` はなく、基準の導出方法も書かれていない。同じ相対パスを読む `analysis-report-stylist` は「`runs-dir` の親ディレクトリ（作業ディレクトリ）を基準とした相対パス」と導出方法まで明示しており、書き手側だけが基準の求め方を宣言していない。基準がずれると、清書 HTML に併記される相対パスとレポートの相対パスが食い違う。
    期待される状態: `analysis-report-stylist` と同じ表現で導出方法を明記する（例: 「`runs-dir` の親ディレクトリ（作業ディレクトリ）を基準とした相対パス」）。

## 判定: FAIL
