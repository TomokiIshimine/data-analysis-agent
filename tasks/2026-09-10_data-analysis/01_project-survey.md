# プロジェクト調査レポート: data-analysis-agent

- 調査対象: `/Users/tishimine/Workspace/data-analysis-agent`
- 調査日: 2026-09-10
- 調査方法: 読み取り専用（`ls` / `find` / `git` / `Read`）。ソース・ドキュメントの変更は一切していない。

## プロジェクト概要

- **状態**: 実質的に空の新規リポジトリ。コミット履歴は 0 件（`main` にコミットなし、ブランチ一覧も空）。
- **目的（推定）**: リポジトリ名 `data-analysis-agent` から「データ分析を行うエージェント」の構築が目的と推測できる。ただし README・ソースコード・パッケージマニフェスト・設定ファイルのいずれも存在せず、**裏付けはない**。目的・スコープは後続のヒアリングで確定させる必要がある。
- **主要言語**: 判定不能（ソースファイル・依存定義・ビルド設定が 1 つもない）。
- **主要構成**: なし。存在するのはワークフロー実行用の作業ディレクトリ `tasks/` と、Claude Code のローカル設定 `.claude/settings.local.json` のみ。
- **Git 情報**:
  - リモート `origin`: `https://github.com/TomokiIshimine/data-analysis-agent.git`
  - コミット履歴: なし（`git log` は "does not have any commits yet"）
  - 作業ツリー: 未追跡は `tasks/2026-09-10_pending/01_project-survey.md`（前回ワークフロー実行の中間生成物）のみ。`.claude/settings.local.json` は Git 上 ignored 扱い（プロジェクト内に `.gitignore` は無いため、グローバルの除外設定によるものと見られる）。

### 前回調査（`tasks/2026-09-10_pending/01_project-survey.md`）からの差分

- `.claude/` ディレクトリと `.claude/settings.local.json` が新たに作成されている（内容は Bash 権限の allow リスト 1 件のみ。エージェント／スキル資産ではない）。
- それ以外の実態は前回調査時点と同じ（コード・ドキュメント・スキル・サブエージェントはいずれも未作成）。

## ディレクトリ構成（主要2階層）

```
data-analysis-agent/
├── .claude/
│   └── settings.local.json     # permissions.allow に Bash 1 件のみ。agents/ skills/ は無し
├── .git/                       # コミット 0 件。origin は GitHub の同名リポジトリ
└── tasks/                      # ワークフロー作業ディレクトリ（揮発系コンテキスト）
    ├── 2026-09-10_pending/     # 前回実行分（01_project-survey.md 1 本）
    └── 2026-09-10_pending_2/   # 今回実行分（本レポートの出力先）
```

- `src/`・`docs/`・`tests/`・`.claude/agents/`・`.claude/skills/` はいずれも**存在しない**。
- ルート直下のドットファイルは `.claude` と `.git` のみ（`.gitignore` も無い）。

## 既存の CLAUDE.md

**なし。** プロジェクトルートに `CLAUDE.md` は存在しない。全エージェント共通コンテキストは未整備。

## 既存スキル一覧

**なし。** `.claude/skills/` ディレクトリ自体が存在しないため、プロジェクト内に流用可能なスキルは 0 件。

## 既存サブエージェント一覧

**なし。** `.claude/agents/` ディレクトリ自体が存在しないため、プロジェクト内に**流用候補**となるサブエージェントは 0 件。新規ワークフローを組む場合、サブエージェント定義はすべて新規作成となる。

### 参考: プロジェクト外で利用可能な資産（ターゲットプロジェクトの資産ではない）

本調査を実行したセッションでは、ユーザーレベルにプラグイン `claude-code-workflow-kit`（v0.14.0）が導入されている。プロジェクト内の資産ではないが、同じ役割のファイルをプロジェクト側に重複作成しない判断材料として記録する（DRY 原則）。

- **How スキル**: `context-engineering` / `prompt-engineering` / `user-hearing` / `design-cycle` / `multi-aspect-review` / `workflow-orchestration`
- **ワークフロースキル**: `bootstrap-docs` / `create-workflow` / `create-develop-workflow` / `create-e2e-workflow`
- **汎用サブエージェント**: `workflow-init`（日付付き作業ディレクトリ作成）/ `project-surveyor`（本調査係）ほか、設計係・author 係・レビュアー係一式

注意: プラグイン資産はユーザー環境に依存する。ターゲットプロジェクトを他の利用者がクローンした環境に同じ資産があるとは限らないため、プロジェクトの自己完結性を要求する場合は `.claude/` 配下への配置が必要になる。

## 既存ドキュメント主要ファイル

**なし。** `README.md`・`docs/`・その他の Markdown ドキュメントはいずれも存在しない。

唯一の Markdown ファイルは `tasks/2026-09-10_pending/01_project-survey.md`（前回ワークフロー実行の中間生成物であり、恒久ドキュメントではない）。

## 後続工程への引き継ぎ事項

プロジェクト内に情報源が皆無のため、以下はすべてユーザーへのヒアリングで確定させる必要がある。

- **プロジェクトの目的とスコープ**: 何を分析するのか（対象データの種類・ドメイン）、誰が使うのか、どんな形態で提供するのか（CLI / Claude Code ワークフロー / アプリケーション / ライブラリ）。
- **成果物の種類**: 作りたいのは Claude Code 上のワークフロー（スキル＋サブエージェント）だけか、実行コード（分析スクリプト・アプリ）も含むのか。両方なら着手順序。
- **技術スタック**: 主要言語・分析ライブラリ・実行環境（例: Python / Jupyter / SQL / DB 接続の有無）。未定なら決定方法。
- **データソースと接続方法**: 分析対象データの所在（ローカルファイル / DB / API）、認証情報の扱い、機密データの有無。
- **基礎ドキュメントを先に整えるか**: CLAUDE.md・README.md・docs/ がすべて未整備のため、ワークフロー作成より先に基礎ドキュメント整備工程（`bootstrap-docs` 相当）を挟むかどうか。
- **プラグイン資産の扱い**: ユーザーレベルの `claude-code-workflow-kit` を前提にしてよいか、プロジェクト内で自己完結させる必要があるか。
- **`tasks/` の Git 管理方針**: 作業ディレクトリをコミット対象にするか、`.gitignore` で除外するか（`.gitignore` は未作成）。
- **初回コミットの方針**: 空の `main` に最初にコミットする内容とタイミング。
- **`.claude/settings.local.json` の位置づけ**: 現状 Git 上は ignored。プロジェクト共通の `settings.json` を別途用意するかどうか。
