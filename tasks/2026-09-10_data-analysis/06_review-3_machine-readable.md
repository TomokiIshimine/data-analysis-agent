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
レビュー日時: 2026-09-10T19:37:45+09:00

## 解消済みの前回指摘

- （中 / `data-analysis/SKILL.md`）ハッシュ不一致の検知経路が機械可読でない — **SKILL.md 側は解消**。前回の期待される状態 (A) のとおり、`## 限定 Read 契約（固定見出しテーブル）` は 4 行のまま据え置かれ、`## 共通契約への準拠` の「整合チェック失敗時の中断ポリシー」に「不整合の検知経路は本プロトコルに一本化し、成果物ファイルへの記録を介した検知経路は持たない」が追記され、「サブエージェント戻り値の形式」にも「唯一の例外は…このときサブエージェントは**絶対パスを返さず**、不整合内容の報告のみを返す。メインは戻り値が絶対パス 1 行でないことをもって中断を検知する」が明記された。`## 失敗時のリカバリ` の Step 4-2 行も「`analysis-executor` は実行ログを書かず絶対パスも返さないため、メインは戻り値が絶対パス 1 行でないことで検知する。…`analysis-executor` が戻り値として報告した不整合内容（対象・期待値・実測値）をそのままユーザーに提示し」に書き換えられている。ただし (A) が同時に求めていたサブエージェント側・How スキル側の整合は未達であり、下記 2 件として再掲する。
- （中 / `data-ingestion-profiler.md`）取得失敗ソースの記録先が未定義 — 解消。`# 責務` の `## データソース` 仕様に「`RESOLVED` は台帳エントリを作れたソースだけを指す語である。所在は特定できたが取得（オープン・接続・ダウンロード）に失敗したソースも本セクションに `UNRESOLVED` として記録し、対象ソースの所在・失敗理由・再指定に必要な情報を併記する」が追加され、`# 判断基準`「推測でデータを選ばない」と `# 作業手順` 3・6 にも同じ扱いが反映された。SKILL.md `## 失敗時のリカバリ` の「Step 2 でデータの取得自体に失敗」行も「`## データソース` に `UNRESOLVED` として失敗理由付きで記録するため、メインは同セクションの限定 Read で検知する」に揃っており、メインは限定 Read 契約（`## データソース` のみ）を破らずに両分岐を判定できる。
- （軽微 / `analysis-report-author.md`）レポート本文の相対パス基準が入力から導出できない — 解消。`## 入力` の `runs-dir` に「**その親ディレクトリが作業ディレクトリであり、レポート本文に書く相対パスの基準はこの親ディレクトリとする**」＋具体例が追記され、`## レポートに必ず含める要素` と `# 判断基準` の「コードは全文掲載し、保存済みスクリプトのパスを併記する」も同じ基準を明示している。`analysis-report-stylist` の「`report-path` の本文が用いているのと同じ基準の相対パスを…独自に決め直さない」が機械的に成立する状態になった。

## 未解消の指摘 / 新規指摘

  - 重大度: 中
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-executor.md
    箇所: `## 出力` の 2 項目目（`<execution-output-path>` を Write）と 3 項目目（最終メッセージ） ／ `# 判断基準` の「ハッシュ不一致は停止条件」 ／ `# 作業手順` の手順 3
    問題: 【未解消】ハッシュ不一致時の戻り値プロトコルが SKILL.md と食い違ったままで、メインの検知経路が機械的に成立しない。SKILL.md は前回指摘の (A) を採り、「整合チェック失敗時の中断ポリシー」で「台帳とデータのハッシュが一致しない」を明示的に列挙したうえで「編集系ツールを一切呼ばず、成果物ファイルも書かず、**絶対パスを返さずに** 不整合内容（対象・期待値・実測値を含む）を報告して終了する」「不整合の検知経路は本プロトコルに一本化し、成果物ファイルへの記録を介した検知経路は持たない」と定め、`## 失敗時のリカバリ` の Step 4-2 行も「`analysis-executor` は実行ログを書かず絶対パスも返さないため、メインは戻り値が絶対パス 1 行でないことで検知する」としている。一方 `analysis-executor.md` は依然として `# 判断基準`「ハッシュ不一致は停止条件」が「不一致の事実（期待値・実測値・対象パス）を実行ログに記録して終了する」、`# 作業手順` 3 が「不一致なら以降を実行せず、不一致の事実を `<execution-output-path>` に記録して終了する」と Write を伴う挙動を定めており、`## 出力` の「最終メッセージは `<execution-output-path>` の絶対パス 1 行のみ」にも不一致時の例外条項がない（`analysis-workdir-initializer.md` の `## 出力` が持つ「作成に失敗した場合は絶対パスを返さず」に相当する記述が欠けている）。この定義どおりに動くと、不一致時もメインには通常どおり絶対パス 1 行が返るため「戻り値が絶対パス 1 行でないこと」による検知は発火せず、メインは限定 Read 契約上 `<n>_execution.md` を読めないまま Step 4-3 の評価へ進む。同一事象に対して 2 通りの戻り値プロトコルが並立したままである。
    期待される状態: SKILL.md の中断ポリシーに揃え、`# 判断基準`「ハッシュ不一致は停止条件」と `# 作業手順` 3 を「不一致の場合は `<execution-output-path>` を Write せず、実行資産も残さず、期待値・実測値・対象（パスまたはソース識別子）を報告して終了する」に書き換える。あわせて `## 出力` に「台帳とデータのハッシュが一致しない場合は `<execution-output-path>` を書かず、絶対パスも返さず、不整合内容の報告のみを返して終了する」旨の例外条項を 1 行加え、戻り値が「絶対パス 1 行 or 不整合報告」の 2 値であることを明示する。`## 出力` 2 項目目の「ハッシュ照合結果」の記載は、照合を通過した場合の実行ログ内容として残してよい。
  - 重大度: 中
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/analysis-data-handling/SKILL.md
    箇所: `## 4. 同一性の検証` の 2 番目の箇条書き（「**不一致の場合は処理を進めない。** 期待値・実測値・対象パス（またはソース識別子）を実行ログ／検証レポートに記録して終了する。」）
    問題: 【未解消】唯一の情報源であるべき照合手順が、`analysis-executor`（分析実行直前の照合）と `reproduction-verifier`（再現追試での照合）という戻り値プロトコルの異なる 2 者に対して、「実行ログ／検証レポートに記録して終了する」という同一の挙動を課している。SKILL.md の中断ポリシーでは前者は「成果物ファイルも書かず、絶対パスを返さずに報告して終了」であり、後者は `## 判定` に `MISMATCH` を書いた検証レポートを Write して絶対パスを返す通常フロー（`reproduction-verifier.md` の `# 判断基準`「データに辿り着けなければ、分析結果が一致していても `MISMATCH`」および `## 出力`）である。本節が両者を区別せず「実行ログ…に記録して終了する」と書いている限り、`analysis-executor` を修正しても、スキル本文が旧プロトコルの根拠として残り、再生成のたびに揺り戻る。呼び出し元（メイン）から見て、同一の「ハッシュ不一致」事象に対する戻り値が 2 通りのままである。
    期待される状態: 当該箇条書きを利用者ごとに分岐させ、(1) 分析実行直前の照合（`analysis-executor`）では成果物ファイルを書かず、期待値・実測値・対象を **戻り値として報告して終了** する、(2) 再現追試での照合（`reproduction-verifier`）では検証レポートに `MISMATCH` として記録し、通常どおり検証レポートの絶対パスを返す、と明記する。`## 適用場面` の利用者テーブルにある 2 行（`analysis-executor` / `reproduction-verifier`）と対応づけて書くこと。

## 判定: FAIL
