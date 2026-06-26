---
name: pr-review-cycle
description: PR作成・コミット追加後に @claude にレビューを依頼し、フィードバックに基づいてPRを改善するサイクルを自動実行します。最大5回繰り返し。
argument-hint: "[PR番号 (省略時は現在のブランチのPR)]"
---

# PR Review Cycle with @claude

PR上で `@claude` にレビューを依頼し、フィードバックに基づいてコードを改善するサイクルを自動で繰り返します。
十分な承認が得られるか、最大5回の繰り返しに達したら終了します。

## 引数

```
/pr-review-cycle [PR番号]
```

- `[PR番号]`: 対象のPR番号（省略時は現在のブランチに紐づくPRを自動検出）

## 手順

### 0. 前提確認

#### リポジトリで @claude が有効か確認

```bash
# GitHub Appとして claude が有効かを確認（collaboratorsやapp installationsで推定）
# PRにコメントを投稿して反応を見る方法で確認する
gh api repos/{owner}/{repo}/collaborators --jq '.[].login' 2>/dev/null | grep -i claude || true
```

**注意**: @claude の有効性を完全に事前確認する手段は限られるため、コメント投稿後にレスポンスが返ってこない場合は「@claude がこのリポジトリで有効でない可能性があります」とユーザーに報告して終了してください。

#### PR番号の特定

引数でPR番号が指定されていない場合：

```bash
# 現在のブランチに紐づくPRを検索
gh pr view --json number,title,state --jq '.number'
```

PR が見つからない場合はエラーを表示して終了してください。

### 1. 既存レビューコメントの確認（初回のみ）

サイクル開始前に、PRに既存の未対応レビューコメントがないか確認します。@claude に限らず、人間のレビュアーを含むすべてのレビューコメントが対象です。既存のフィードバックがあれば、新たなレビュー依頼を投稿せずに、まずそのフィードバックへの対応から始めます。

```bash
# 既存の PR review（CHANGES_REQUESTED）を確認（全レビュアー対象）
EXISTING_REVIEWS=$(gh api repos/{owner}/{repo}/pulls/<PR番号>/reviews \
  --jq '[.[] | select(.state == "CHANGES_REQUESTED")] | map({user: .user.login, state: .state, body: .body, submitted_at: .submitted_at})')

# PR review comments（インラインコメント）を確認
EXISTING_REVIEW_COMMENTS=$(gh api repos/{owner}/{repo}/pulls/<PR番号>/comments \
  --jq '[.[] | {user: .user.login, body: .body, path: .path, created_at: .created_at}]')

# PR の通常コメントも確認（@claude の finished コメント等）
EXISTING_PR_COMMENTS=$(gh pr view <PR番号> --json comments \
  --jq '[.comments[] | {author: .author.login, body: .body, createdAt: .createdAt}]')
```

#### 判定

- **既存の未対応フィードバックがある場合**（`CHANGES_REQUESTED` のレビューがある、未解決のインラインコメントがある、または修正指摘を含むコメントがある）:
  - 「既存のレビューコメントが見つかりました。まずこのフィードバックに対応します。」とユーザーに報告し、指摘内容を要約して表示
  - `iteration = 1` として、**Step 2・3 をスキップし、Step 4（レビュー結果の確認と判定）から開始**する。既存コメントの内容を Step 4 のレビュー結果として扱う
- **既存フィードバックがない場合**: 通常通り Step 1 から開始

### 2. レビュー依頼サイクル（最大5回）

以下のサイクルを**最大5回**繰り返します。カウンター変数 `iteration` を 1 から開始してください。
初回で既存フィードバックへの対応から始めた場合も、イテレーション回数に含めます。

---

#### Step 1: 最新の変更をプッシュ

ローカルに未プッシュのコミットがある場合はプッシュしてください：

```bash
# 未プッシュのコミット確認
git log origin/$(git branch --show-current)..HEAD --oneline

# 未プッシュのコミットがあればプッシュ
git push
```

#### Step 2: @claude にレビューを依頼し、依頼時刻を記録

PRにコメントを投稿してレビューを依頼します。**投稿直後にそのコメントの `createdAt` を記録**してください。この時刻が後続のポーリングで「新しいレビュー」を判別する基準になります。

```bash
# レビュー依頼コメントを投稿
gh pr comment <PR番号> --body "@claude レビューして"

# 投稿したコメントの createdAt を取得（自分の最新コメント）
REVIEW_REQ_TIME=$(gh pr view <PR番号> --json comments \
  --jq '[.comments[] | select(.author.login != "claude[bot]" and .author.login != "claude")] | last | .createdAt')
echo "Review requested at: $REVIEW_REQ_TIME"
```

#### Step 3: @claude のレビュー結果を待機

@claude がレビューコメントを返すまでポーリングして待機します。
**ポーリング間隔: 30秒**、**最大待機時間: 10分**

##### 重要: @claude の動作パターン

@claude はレビュー依頼を受けると以下の流れで動作します：

1. **即座に「作業中」コメントを投稿**（チェックリスト付き、例: `- [x] コンテキスト収集 - [ ] レビュー`）
2. **レビュー完了後にそのコメントを編集**して最終結果に差し替え（本文の先頭に `**Claude finished**` が付く）

つまり `createdAt` タイムスタンプだけでは完了を判定できません。**コメント本文に `finished` が含まれているか**を確認する必要があります。

##### ポーリング手順

**重要: レビュー依頼時刻 (`REVIEW_REQ_TIME`) より後に作成された @claude コメントのみを対象にする。** これにより、前回のレビューコメントに含まれる `finished` を誤検出することを防ぎ、また @claude の応答が速くてポーリング開始前に完了していても確実に検出できます。

**重要: `gh --jq` は jq の `--arg` オプションをサポートしないため、シェル変数はダブルクォート内に直接埋め込む。**

```bash
# ポーリングループ（30秒間隔、最大20回 = 10分）
for i in $(seq 1 20); do
  echo "--- Poll attempt $i ---"

  # REVIEW_REQ_TIME より後に作成された @claude コメントのうち、最新のものを取得
  LATEST_BODY=$(gh pr view <PR番号> --json comments \
    --jq "[.comments[] | select(
      (.author.login == \"claude[bot]\" or .author.login == \"claude\") and
      .createdAt > \"$REVIEW_REQ_TIME\"
    )] | last | .body // \"\"")

  # 完了判定: 新しいコメントが存在し、"finished" が本文に含まれているか
  if [ -n "$LATEST_BODY" ] && echo "$LATEST_BODY" | grep -qi "finished"; then
    echo "Review completed"
    break
  fi

  # PR review (APPROVED等) も確認
  REVIEW_STATE=$(gh api repos/{owner}/{repo}/pulls/<PR番号>/reviews \
    --jq "[.[] | select(
      (.user.login == \"claude[bot]\" or .user.login == \"claude\") and
      .submitted_at > \"$REVIEW_REQ_TIME\"
    )] | last | .state // \"\"")
  if [ "$REVIEW_STATE" = "APPROVED" ] || [ "$REVIEW_STATE" = "CHANGES_REQUESTED" ]; then
    echo "Review state: $REVIEW_STATE"
    break
  fi

  echo "Waiting..."
  sleep 30
done
```

##### 完了の検出条件

以下のいずれかで @claude のレスポンス完了を検出します：

1. **レビュー依頼時刻より後に作成された @claude の PR comment の本文に `finished` が含まれる** — @claude がコメントを編集して結果を反映した状態
2. **レビュー依頼時刻より後の PR review の `state` が `APPROVED` や `CHANGES_REQUESTED`** — 正式なPRレビューとして投稿された場合

**タイムアウトした場合**: 「@claude からのレスポンスがタイムアウトしました。リポジトリで @claude が有効化されているか確認してください。」と報告して終了。

#### Step 4: レビュー結果の確認と判定

@claude のレビューコメントの内容を取得・分析します：

```bash
# PRの全コメントを取得（レビュー依頼時刻以降のもの）
gh pr view <PR番号> --json comments \
  --jq "[.comments[] | select(
    (.author.login == \"claude[bot]\" or .author.login == \"claude\") and
    .createdAt > \"$REVIEW_REQ_TIME\"
  )] | last | {body: .body, createdAt: .createdAt}"

# PRレビュー（review comments）も確認
gh api repos/{owner}/{repo}/pulls/<PR番号>/reviews \
  --jq "[.[] | select(
    (.user.login == \"claude[bot]\" or .user.login == \"claude\") and
    .submitted_at > \"$REVIEW_REQ_TIME\"
  )] | last | {state: .state, body: .body, submitted_at: .submitted_at}"
```

#### 判定基準 - 承認されたか？

以下のいずれかに該当する場合、**承認済み**と判断してサイクルを終了します：

1. PRレビューの `state` が `APPROVED` である
2. コメント内容に明確な承認の表現が含まれる（例：「LGTM」「問題ありません」「承認します」「approve」など）
3. 修正を求める具体的な指摘が含まれていない

**承認された場合**: 「@claude からの承認を確認しました（iteration回目）。PRは改善完了です。」と報告して終了。

#### Step 5: フィードバックに基づく改善

承認されていない場合、@claude のフィードバック内容を分析し、コードを改善します。

1. **フィードバックの要約**: @claude が指摘した内容をユーザーに簡潔に報告
2. **コードの修正**: 指摘に基づいてコードを修正
3. **テストの実行**: 修正後、関連するテストを実行して問題がないことを確認
4. **コミット作成**: 修正内容をコミット

```bash
# 修正をステージング
git add <修正したファイル>

# コミット（レビュー指摘への対応であることを明記）
git commit -m "fix: address @claude review feedback (iteration N)"
```

5. **次のイテレーションへ**: `iteration` をインクリメントして Step 1 に戻る

---

### 3. サイクル終了条件

以下のいずれかでサイクルを終了します：

| 条件 | メッセージ |
|------|-----------|
| 承認された | `✅ @claude からの承認を確認しました（N回目のイテレーション）。` |
| 最大5回に到達 | `⚠️ 最大イテレーション回数（5回）に達しました。最新のレビューコメントを確認してください。` |
| @claude が無応答 | `❌ @claude からのレスポンスがありません。リポジトリでの有効化を確認してください。` |
| エラー発生 | `❌ エラーが発生しました: [詳細]` |

### 4. 最終レポート

サイクル終了後、以下のサマリーをユーザーに報告してください：

```
## PR Review Cycle 完了レポート

- **PR**: #<番号> <タイトル>
- **イテレーション回数**: N / 5
- **結果**: [承認 / 最大回数到達 / タイムアウト / エラー]
- **修正コミット一覧**:
  - `<hash>`: <コミットメッセージ>
  - ...
```

## 注意事項

- レビュー依頼コメントを投稿する前に、必ず最新のコミットがプッシュされていることを確認してください
- @claude のレビューコメントには PR comments と PR review comments の両方がありえます。両方を確認してください
- コード修正時は、指摘された内容に対してのみ最小限の修正を行ってください
- テストが失敗する修正はコミットしないでください
- 各イテレーションの開始時に「イテレーション N/5 を開始します」とユーザーに報告してください
