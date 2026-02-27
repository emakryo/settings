---
name: worktree
description: Worktree 作成。プロジェクト内の .worktrees/<branch-name> にgit worktreeを作成し、以降の作業をそのworktreeで行います。
argument-hint: "<branch-name>"
disable-model-invocation: true
---

# Worktree 作成

プロジェクト内の `.worktrees/<branch-name>` ディレクトリにgit worktreeを作成し、以降の作業を全てそのworktreeで行うようにします。

## 引数

```
/worktree <branch-name>
```

- `<branch-name>`: 作成または使用するブランチ名

## 手順

### 1. ブランチの存在確認

指定されたブランチが既に存在するか確認してください：

```bash
# ローカルブランチの確認
git branch --list <branch-name>

# リモートブランチも含めて確認
git branch -a --list "*<branch-name>"
```

### 2. Worktreeディレクトリの存在確認

`.worktrees/<branch-name>` が既に存在しないか確認してください：

```bash
ls -la .worktrees/<branch-name>
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

### 4. 作業ディレクトリの切り替え

以降の全てのファイル操作とコマンド実行は、作成したworktreeディレクトリで行ってください：

```bash
cd .worktrees/<branch-name>
```

**重要**: この時点から、以下の操作は全て `.worktrees/<branch-name>` ディレクトリを基準に実行してください：
- ファイルの読み取り・編集・作成
- Bashコマンドの実行
- Globやgrepでの検索

### 5. Submoduleの初期化と更新

Worktree作成後、submoduleを初期化・更新してください：

```bash
# submoduleの状態確認
git submodule status

# submoduleが初期化されていない場合（先頭に - マークがある場合）、初期化と更新を実行
git submodule update --init --recursive

# 更新後の状態を再確認
git submodule status
```

**確認ポイント:**
- submoduleのステータスで先頭に `-` マークがある場合は初期化が必要
- 更新後は `-` が消えてスペースまたは `+` になることを確認

### 6. 作業環境の確認

Worktree作成後、以下を確認してユーザーに報告してください：

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

- **全ての操作はworktreeディレクトリ内で実行**: ファイルパスは全て `.worktrees/<branch-name>` を基準とする
- **セッション全体で一貫性を保つ**: 一度worktreeを作成したら、セッション終了までそのworktreeで作業を続ける
- **相対パスに注意**: コマンド実行時は必ず `.worktrees/<branch-name>` ディレクトリをカレントディレクトリとして使用

### エラー処理

以下の場合はエラーメッセージを表示してください：

- **Worktreeが既に存在**: `.worktrees/<branch-name>` が既に存在する場合
  - 「Worktree `.worktrees/<branch-name>` は既に存在します。」
  - 既存のworktreeを削除する場合: `git worktree remove .worktrees/<branch-name>`

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
2. `.worktrees/feature/new-api` を作成
3. HEADから新規ブランチ `feature/new-api` を作成
4. 作業ディレクトリを `.worktrees/feature/new-api` に切り替え
5. Submoduleの初期化と更新 → 完了
6. ステータス確認 → 準備完了

以降の作業は全て `.worktrees/feature/new-api` で行います。
```

### 例2: 既存のブランチをチェックアウト

```
User: /worktree fix/bug-123
Assistant:
1. ブランチ確認 → ローカルに存在
2. `.worktrees/fix/bug-123` を作成
3. 既存のブランチ `fix/bug-123` をチェックアウト
4. 作業ディレクトリを `.worktrees/fix/bug-123` に切り替え
5. Submoduleの初期化と更新 → 完了
6. ステータス確認 → 準備完了

以降の作業は全て `.worktrees/fix/bug-123` で行います。
```
