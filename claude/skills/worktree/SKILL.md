---
name: worktree
description: Worktree 作成。プロジェクト内の .worktrees/<branch-name> にgit worktreeを作成し、EnterWorktree ツールでセッションを切り替えます。
argument-hint: "<branch-name>"
---

# Worktree 作成

プロジェクト内の `.worktrees/<branch-name>` ディレクトリに git worktree を作成し、`EnterWorktree` ツールで以降の作業をそのworktreeに切り替えます。

## 重要な方針

**`EnterWorktree` ツールをこのスキルを経由せず直接呼び出すことは禁止です。**

Worktree 作成は必ずこのスキル (`/worktree`) 経由で行ってください。理由：
- `EnterWorktree` 単体では `.claude/worktrees/` 固定の場所にしか作成できず、本方針 (`.worktrees/<branch-name>`) と矛盾する
- submodule 初期化や Husky フック設定が行われない
- このスキルは `git worktree add` で正しい場所に作成した後、`EnterWorktree(path=...)` で取り込むフローを使う

## 引数

```
/worktree <branch-name>
```

- `<branch-name>`: 作成または使用するブランチ名

## 手順

### 1. 既存worktreeの確認（存在すればそこに入る）

まず `git worktree list` で、指定ブランチまたは `.worktrees/<branch-name>` に対応する既存worktreeがあるか確認してください：

```bash
git worktree list
```

**以下のいずれかに該当する場合、新規作成はせず既存worktreeに入ること（ユーザーに選択肢を提示しない）:**

- `.worktrees/<branch-name>` が既にディレクトリとして存在する
- 指定ブランチ `<branch-name>` が別パスのworktreeで既に使用されている（例: ブランチ名 `worktree-add-entity-resolver-url` が `.worktrees/add-entity-resolver-url` で使われている等、パスとブランチ名が一致しないケース）

該当worktreeのパス（`git worktree list` の出力から取得）に対して `EnterWorktree(path="<既存worktreeのパス>")` を呼び出してセッションを切り替えてください。submodule / hooksPath 設定は既に済んでいる前提でスキップして構いません。最後に手順7の作業環境確認のみ行ってください。

既存worktreeに該当しない場合のみ、以降の手順2〜7を実行して新規作成してください。

### 2. ブランチの存在確認

指定されたブランチが既に存在するか確認してください：

```bash
# ローカルブランチの確認
git branch --list <branch-name>

# リモートブランチも含めて確認
git branch -a --list "*<branch-name>"
```

### 3. Worktreeの作成

以下のルールでworktreeを作成してください：

**既存のブランチの場合：**
```bash
# ローカルブランチが存在する場合
git worktree add .worktrees/<branch-name> <branch-name>

# リモートブランチのみ存在する場合
git worktree add .worktrees/<branch-name> -b <branch-name> origin/<branch-name>
```

**新規ブランチの場合：**
```bash
# HEADから新規ブランチを作成
git worktree add .worktrees/<branch-name> -b <branch-name>
```

### 4. Submoduleの初期化と更新

作成した worktree 内で submodule を初期化・更新します：

```bash
# submoduleの状態確認
git -C .worktrees/<branch-name> submodule status

# submoduleが初期化されていない場合（先頭に - マークがある場合）、初期化と更新
git -C .worktrees/<branch-name> submodule update --init --recursive

# 更新後の状態を再確認
git -C .worktrees/<branch-name> submodule status
```

**確認ポイント:**
- 先頭に `-` マークがある場合は初期化が必要
- 更新後は `-` が消えてスペースまたは `+` になることを確認

### 5. Husky (pre-commit hook) の設定

Worktreeでは `core.hooksPath` がメインリポジトリの `.husky` を指すように設定する必要があります。
設定しないと pre-commit フックが発火しません。

```bash
# メインリポジトリのルートパスを取得
MAIN_REPO=$(git rev-parse --git-common-dir | sed 's|/\.git$||')

# hooksPath をメインリポジトリの .husky に設定
git -C .worktrees/<branch-name> config core.hooksPath "$MAIN_REPO/.husky"

# 設定を確認
git -C .worktrees/<branch-name> config core.hooksPath
```

### 6. EnterWorktree でセッションを切り替え

`EnterWorktree` ツールを `path` パラメータ付きで呼び出し、セッションの作業ディレクトリを新しい worktree に切り替えます：

```
EnterWorktree(path=".worktrees/<branch-name>")
```

これにより以下が自動的に行われます：
- ハーネスレベルの CWD 切替（Read / Edit / Glob / Grep / Bash すべての基準パスが切り替わる）
- 新しい worktree の CLAUDE.md / memory / plans を再読込
- `ExitWorktree` で安全に離脱可能

**注意**: `path` で取り込んだ worktree は `ExitWorktree(action: "remove")` では削除されません。削除したい場合は `git worktree remove .worktrees/<branch-name>` を使用してください。

**重要**: このステップ以降、すべてのファイル操作・コマンド実行は新しい worktree 内で行われます。

### 7. 作業環境の確認

`EnterWorktree` 切替後、以下を確認してユーザーに報告してください：

```bash
# 現在のブランチ確認
git branch --show-current

# worktreeの一覧
git worktree list

# 作業ディレクトリのステータス
git status
```

## 注意事項

### 必須事項

- **`EnterWorktree` を直接呼び出さない**: 必ずこのスキル (`/worktree`) 経由で実行する
- **セッション全体で一貫性を保つ**: 一度worktreeを作成したら、セッション終了までそのworktreeで作業を続ける

### エラー処理

以下の場合はエラーメッセージを表示してください：

- **ブランチ名が不正**: 空文字列や不正な文字を含む場合
  - 「有効なブランチ名を指定してください。」

- **Gitリポジトリではない**: カレントディレクトリがgitリポジトリではない場合
  - 「カレントディレクトリはGitリポジトリではありません。」

### Worktreeの削除（参考）

作業完了後、worktreeを削除する場合は以下のコマンドを使用：

```bash
# worktreeを削除（ファイルも削除）
git worktree remove .worktrees/<branch-name>

# または、ディレクトリを削除してからprune
rm -rf .worktrees/<branch-name>
git worktree prune
```

## 実行例

### 例1: 新規ブランチで作業開始

```
User: /worktree feature/new-api
Assistant:
1. ブランチ確認 → 存在しない
2. `.worktrees/feature/new-api` 未存在を確認
3. `git worktree add .worktrees/feature/new-api -b feature/new-api` で作成
4. Submodule の初期化と更新 → 完了
5. `core.hooksPath` を メインリポジトリの .husky に設定 → 完了
6. `EnterWorktree(path=".worktrees/feature/new-api")` でセッション切替
7. ステータス確認 → 準備完了

以降の作業は全て `.worktrees/feature/new-api` で行います。
```

### 例2: 既存のブランチをチェックアウト

```
User: /worktree fix/bug-123
Assistant:
1. ブランチ確認 → ローカルに存在
2. `.worktrees/fix/bug-123` 未存在を確認
3. `git worktree add .worktrees/fix/bug-123 fix/bug-123` で作成
4. Submodule の初期化と更新 → 完了
5. `core.hooksPath` を メインリポジトリの .husky に設定 → 完了
6. `EnterWorktree(path=".worktrees/fix/bug-123")` でセッション切替
7. ステータス確認 → 準備完了

以降の作業は全て `.worktrees/fix/bug-123` で行います。
```
