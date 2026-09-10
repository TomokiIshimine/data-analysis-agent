# レビューレポート（観点: prompt-engineering）

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

レビュー観点: prompt-engineering（`/prompt-engineering` の 3 原則「簡潔・明快・一意」。衝突時は 一意 > 明快 > 簡潔）
レビュー日時: 2026-09-10T12:18:44Z
周回: 3（差分レビューモード。前周回レポート: `/Users/tishimine/Workspace/data-analysis-agent/tasks/2026-09-10_data-analysis/06_review-2_prompt-engineering.md`）

## 解消済みの前回指摘

- 中 / `/Users/tishimine/Workspace/data-analysis-agent/.claude/skills/analysis-data-handling/SKILL.md` — `## 5. 機密区分` の集約要件に数値の閾値が入った。85 行目が「**1 グループの構成件数が 5 件未満のセルは掲載しない**。該当セルは上位グループへ併合したうえで掲載するか、非掲載とする。この下限件数（既定 5 件）は要件シートで上書きできる。実データに対して下限を満たすか判定できない場合は掲載しない。」となり、「十分な件数」「少数の個体」といった判断委ね語が消えた。二重記載も解消され、区分表の「社内限定」行（80 行目）は「下記「集約の下限件数」を満たすこと」への参照に留まっている。

## 未解消の指摘 / 新規指摘

  - 重大度: 中
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/data-analysis/SKILL.md
    箇所: `### Step 3 — 分析要件定義` の `**3-4. データソース再解決（分岐）**`（141 行目および 145 行目。本文は前周回から未変更）
    問題: 再起動の発火条件が 1 ブロック内で 3 通りに書かれ、しかも相互に等価でない。141 行目は「確定データソースが Step 2 時点と異なる場合」と書いたうえで「**すなわち**」で「`## データソース` が `UNRESOLVED` だった場合、またはユーザーが承認ゲートでデータソースを変更した場合」と言い換えている。`UNRESOLVED` は「Step 2 に解決結果が存在しない」状態であって「異なる」の比較対象を持たないため、前段と後段は同じ条件を指していない。さらに 145 行目の「確定データソースが Step 2 の解決結果と一致する場合、この再起動は行わない」は、`UNRESOLVED` のときは比較対象が無く評価できない。読み手（メイン）は 3 つのどれを条件式として採るかを自分で決めることになり、解釈の余地が残っている。
    期待される状態: 言い換えと否定形の重複をやめ、発火条件を 1 度だけ、そのまま真偽判定できる形で列挙する。例: 「次のいずれかに該当する場合に限り `data-ingestion-profiler` を再起動する。(1) `01_data-profile.md` の `## データソース` が `UNRESOLVED` である。(2) 承認された確定データソースが Step 2 で解決されたソースと異なる。いずれにも該当しない場合は再起動せず Step 4 へ進む。」のように、「すなわち」による言い換えと 145 行目の否定形の再掲を削る。

  - 重大度: 中
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/data-analysis/SKILL.md
    箇所: 各ステップの `**引数**:` 行（124、153、158、163、176、185、197、204 行目。本文は前周回から未変更）
    問題: 前々周回で指摘し前周回でも未解消だった 8 箇所が、今周回も手つかずのままスラッシュ区切りの長い 1 行で書かれている。引数どうしの区切り記号 `/` とパス内の `/` が同一記号で混在している。たとえば 153 行目は「`requirements-path`: `<workdir>/02_analysis-requirements.html` / `profile-path`: `<workdir>/01_data-profile.md` / `iteration`: `n` / `plan-output-path`: `<workdir>/03_iterations/<n>_plan.md` / `previous-evaluation-path`: `<workdir>/03_iterations/<n-1>_evaluation.md`（**2 周目以降のみ**。1 周目では渡さない）」であり、5 引数と 1 つの条件付き引数が改行なしで連なっている。条件付き引数（`previous-evaluation-path` / `data-source` / `verification-report-path`）はその条件が行末に埋もれ、読み飛ばすと 1 周目に前周評価を渡す・毎回反映モードで起動するといった誤りに直結する。同じ SKILL.md の Step 2（110〜114 行目）は同じ内容を 1 引数 1 行の入れ子箇条書きで書いており、より読みやすい形が同一ファイル内に既に存在している。書式が 1 箇所だけ揃っていない状態が 2 周続いている。
    期待される状態: Step 2 と同じく、引数を 1 引数 1 行の入れ子箇条書きで書く。条件付きの引数は独立した行に置き、条件（「2 周目以降のみ」「`MISMATCH` 時のみ」等）を値の直後ではなくその行の先頭側に明示する。区切り記号としての `/` は使わない。対象は 124（Step 3-1）／153（4-1）／158（4-2）／163（4-3）／176（Step 5）／185（6-1）／197（6-3）／204（Step 7）行目の 8 箇所。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/data-analysis/SKILL.md
    箇所: `### メインの作法`「限定 Read の遵守」（31 行目）、同「メインがしないこと」（36 行目）、`## 限定 Read 契約（固定見出しテーブル）` 前文（51 行目）。本文は前周回から未変更。
    問題: 「固定見出しテーブル以外の本文を読まない」という同一の制約が、同一ファイル内で 3 回書かれている（31 行目「**本文全読は禁止**」、36 行目「固定見出しテーブル外の本文 Read」、51 行目「本文全読は禁止」）。強調が 3 度繰り返されることで、周囲にある他の制約（承認なしの自動進行をしない、成果物本文を Write / Edit しない）との重み付けの差が消えている。
    期待される状態: 制約の本体は `## 限定 Read 契約` に 1 度だけ置き、31 行目と 36 行目からは同節への参照に留める。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/skills/data-analysis/SKILL.md
    箇所: `**4-4. ループ制御**` の 3 番目の分岐（170 行目。本文は前周回から未変更）
    問題: 1 番目・2 番目の分岐は判定語を条件に含む（`SATISFIED` →、`CONTINUE` かつ `n < N` →）のに対し、3 番目だけ「`n = N` に達した（`CONTINUE` のまま上限）」と、判定語が条件式ではなく括弧内の補足に置かれている。条件式だけを読むと `SATISFIED` かつ `n = N` のケースが 1 番目と 3 番目の両方に該当し、報告すべき終了理由（「充足」か「上限到達」か）が一意に決まらない。同じファイルの Step 6-2（193 行目）は「`MISMATCH` かつ `m = M`」と正しい形で書かれており、書式が揃っていない。
    期待される状態: Step 6-2 と同じ形に揃え、「`CONTINUE` かつ `n = N` → ループを抜けて Step 5 へ。終了理由は「上限到達」」と条件式に判定語を含める。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-planner.md
    箇所: `# 責務`（10〜22 行目）。本文は前周回から未変更。
    問題: 入力一覧・プランに含める内容・出力仕様が、見出しを持たないまま `# 責務` の中に混在している。読み手は「入力は何か」「何を返すのか」を節見出しから辿れず、本文を順に読んで拾う必要がある。とくに出力仕様（22 行目「出力は `<plan-output-path>` を Write し、最終メッセージとして同ファイルの絶対パス 1 行のみを返す。」）は入力一覧とプラン内容の後ろに 1 文だけ置かれており、依頼・条件・期待出力の並び順が崩れている。
    期待される状態: 他の 8 体と同じく `## 入力` / `## 出力` の見出しを立て、`# 責務` には担当範囲の記述だけを残す。「プランに含める内容」は責務側か出力側のどちらに属するかを決めて 1 箇所に置く。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/data-ingestion-profiler.md
    箇所: `# 使用するスキル` 前文と 2 項目（42、44、45 行目）および `# 作業手順` 手順 1（49 行目）。本文は前周回から未変更。
    問題: スキル呼び出しの指示が同一ファイル内で 4 回書かれている。さらに呼び出し時期の表現が 3 通りに割れており（42 行目「作業開始前に」、44 行目「台帳作成の前に」、45 行目「最初のスクリプトを書く前に」）、読み手はどの時点で呼べばよいかを 3 つの記述から自分で統合することになる。
    期待される状態: 呼び出し時期を 1 つに決めて `# 作業手順` 手順 1 に置き、`# 使用するスキル` の各項目からは時期の記述を削って「何を確認するために使うか」だけを残す（同じ修正が `analysis-requirements-designer` では既に完了しており、その形に揃える）。

  - 重大度: 軽微
    対象ファイル: /Users/tishimine/Workspace/data-analysis-agent/.claude/agents/analysis-executor.md
    箇所: `# 責務`（12 行目）、`# 判断基準`「実行内容は必ずファイルとして残す」（33 行目）、`# 作業手順` 手順 4〜5（52〜53 行目）
    問題: 前周回から一部だけ手が入り、`# 判断基準`（33 行目）からは保存先の列挙が落ちたが、要求の本体は依然として `# 責務` 側（12 行目）に残っている。結果として「実行するコードは先にスクリプトファイルとして保存してから実行し、出力・派生データ・図表を所定の場所に残す」という同一の要求が、`# 責務`（12 行目、保存先の全列挙つき）・`# 判断基準`（33 行目、「その場限りのワンライナーや対話実行で済ませない」）・`# 作業手順` 手順 4〜5（52〜53 行目、「標準出力・標準エラー・図表・派生データ」の再列挙つき）の 3 節に分かれたまま残っている。読み手はどれが正本かを判断できず、`# 判断基準` は要求本体を欠いた注意書きだけの項目になっている。
    期待される状態: 要求の本体（保存してから実行すること＋保存先の対応）を `# 判断基準` に 1 度だけ置き、`# 責務` は担当範囲の記述に留め、`# 作業手順` は実行順序の指示に留める。保存先の列挙を 2 箇所以上で繰り返さない。

## 判定: FAIL
