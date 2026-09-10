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
レビュー日時: 2026-09-10T20:12:44+09:00

## 解消済みの前回指摘

- （軽微 / `analysis-workdir-initializer.md`）`ERROR:` 戻り値センチネルの片側定義 — `ERROR:` センチネルは削除され、`## 出力` は「作成に失敗した場合は絶対パスを返さず、失敗内容の報告のみを返して終了する」、`# 判断基準` の「失敗したら黙って続行しない」も「**絶対パスを返さない**」＋「何がどう失敗したか（対象パスとエラー内容）を報告して終了する」に統一された。他 8 体の「不整合内容を報告して終了する」および SKILL.md `## 共通契約への準拠` の「整合チェック失敗時の中断ポリシー」と同一プロトコルになっている。プロジェクト全体で `ERROR` 文字列は残存しない。

## 未解消の指摘 / 新規指摘

  - 重大度: 中
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/data-analysis/SKILL.md
    箇所: `## 限定 Read 契約（固定見出しテーブル）` ／ `## 共通契約への準拠` の「整合チェック失敗時の中断ポリシー」 ／ `## 失敗時のリカバリ` の「Step 4-2 で台帳とデータのハッシュが不一致」行
    問題: 【未解消】ハッシュ不一致をメインが検知する機械可読な経路が存在しない。リカバリ表はメインに「分析を続行しない。不一致の対象・期待値・実測値をユーザーに提示し、`AskUserQuestion` で選ばせる」という分岐を要求しているが、(1) 限定 Read 契約テーブルは依然 4 行で `<workdir>/03_iterations/<n>_execution.md` の行がなく、(2) `analysis-executor` の戻り値は成功時と同じ「`<execution-output-path>` の絶対パス 1 行」であるため、メインは不一致の発生も期待値・実測値も取得できない。さらに「整合チェック失敗時の中断ポリシー」は「台帳とデータのハッシュが一致しない」を明示的に列挙したうえで「編集系ツールを一切呼ばずに不整合内容を報告して終了する」と定めているのに対し、`analysis-executor`（判断基準「ハッシュ不一致は停止条件」・作業手順 3「不一致の事実を `<execution-output-path>` に記録して終了する」）と `analysis-data-handling` §4（「期待値・実測値・対象パス…を実行ログ／検証レポートに記録して終了する」）はいずれも Write を伴う挙動を定めており、同一事象に対して 2 通りの戻り値プロトコルが並立したままである。
    期待される状態: 次のいずれかで、メインが必要とする情報の取得経路とサブエージェント側の挙動を一致させる。設計書 `### メインの限定 Read 契約` のテーブルが 4 行で固定されている点を踏まえ、(A) を優先する。
      (A) 限定 Read 契約テーブルを設計書どおり 4 行に保ったまま、`## 失敗時のリカバリ` の Step 4-2 行を「`analysis-executor` が戻り値として報告した不整合内容（対象・期待値・実測値）をそのままユーザーに提示し、`AskUserQuestion` で選ばせる」と書き換える。あわせて `analysis-executor` の判断基準「ハッシュ不一致は停止条件」と作業手順 3、および `analysis-data-handling` §4 を「実行ログを Write せず、期待値・実測値・対象を報告して終了する」に揃え、「整合チェック失敗時の中断ポリシー」と単一のプロトコルにする。
      (B) (A) を採らない場合は、限定 Read 契約テーブルに「Step 4-2 のハッシュ照合結果の判定」用の行（対象ファイル `<workdir>/03_iterations/<n>_execution.md`、抜粋する箇所は `## ハッシュ照合` のような固定見出し 1 つ）を追加し、`analysis-executor` が同見出しへ照合結果を 1 語（例: `MATCHED` / `MISMATCH`）＋期待値・実測値・対象で書く前提に揃える。あわせて「整合チェック失敗時の中断ポリシー」に、ハッシュ不一致のように成果物ファイルへ事実を記録してから終了する事象を例外として明記し、「編集系ツールを一切呼ばない」対象を「渡されたパスが存在しない・引数の前提が崩れている」等の入力不整合に限定する。`## 失敗時のリカバリ` の Step 4-2 行には、メインがこの固定見出しの限定 Read で不一致を検知する旨を書く。

  - 重大度: 中
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/data-ingestion-profiler.md
    箇所: `# 責務` の「プロファイルレポートの作成」 ／ `# 判断基準` の「推測でデータを選ばない」 ／ `# 作業手順` の手順 6
    問題: 【未解消】`## データソース` セクションが取り得る状態として `RESOLVED` / `UNRESOLVED` の 2 値しか宣言されておらず、いずれも「所在を特定できたか」だけを表す（責務「解決状態を `RESOLVED` または `UNRESOLVED` の 1 語で明示する」、判断基準「データソースが特定できない場合…`UNRESOLVED` と候補一覧…を記録して終了し」、手順 6「`RESOLVED` / `UNRESOLVED` ＋ 台帳エントリの識別子、`UNRESOLVED` の場合は候補一覧」）。一方 SKILL.md の `## 失敗時のリカバリ` は「Step 2 でデータの取得自体に失敗（接続不可・ファイル不在）」という別事象に対して「`01_data-profile.md` に記録された失敗内容を提示し、`AskUserQuestion` でデータソースの再指定を求める」ようメインに要求している。メインの限定 Read は同ファイルの `## データソース` のみに制限されているため、所在は特定できたが取得に失敗したケースの記録先が定義されておらず、メインは限定 Read 契約を破らない限りこの分岐に必要な情報を取得できない。
    期待される状態: `## データソース` の仕様に「所在は特定できたが取得（オープン・接続・ダウンロード）に失敗したソースも本セクションに `UNRESOLVED` として記録し、対象ソースの所在・失敗理由・再指定に必要な情報を併記する」ことを明記する。`RESOLVED` は「台帳エントリを作れたソースのみ」を指す語であることも 1 行で明示し、メインが `## データソース` の限定 Read だけで Step 3 の再解決分岐と Step 2 の取得失敗分岐の両方を判断できる状態にする。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-report-author.md
    箇所: `## レポートに必ず含める要素` の「対応する保存済みスクリプトの `<workdir>` からの相対パス」 ／ `## 入力（すべて絶対パス。呼び出し元から渡される）`
    問題: 【未解消】レポートに書く相対パスの基準を `<workdir>` と定めているが、入力引数に `<workdir>` はなく、基準の導出方法も書かれていない。今周回で `analysis-report-stylist` は「`report-path` の本文が用いているのと同じ基準の相対パスを…基準を独自に決め直したり、ディレクトリ階層から導出したりしない」と書き手側に基準を委ねる形へ変わったため、相対パスの基準を導出できる記述がどちらにも存在しない状態になった。基準がずれる／算出できない場合、清書 HTML に併記される相対パスとレポートの相対パスが食い違う。
    期待される状態: `analysis-report-author` 側に、入力引数から一意に導ける形で基準を明記する（例: 「`runs-dir` の親ディレクトリ（作業ディレクトリ）を基準とした相対パス」）。`analysis-report-stylist` の「同じ基準を使う」という記述は、書き手側に導出方法があって初めて機械的に成立する。

## 判定: FAIL
