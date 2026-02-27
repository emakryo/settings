---
name: update-readme
description: README.md 更新。最新のコードベースの変更に基づいてREADME.mdを更新します。ルートだけでなくサブディレクトリも対象。
disable-model-invocation: true
---

# README.md 更新

README.md を最新のコードベースの変更に基づいて更新してください。
ルートの README.md だけでなく、サブディレクトリの README.md も対象とします。

## 手順

1. **対象のREADME.mdファイルを特定**
   ```bash
   find . -name "README.md" -not -path "./node_modules/*" -not -path "./.git/*"
   ```

2. **各README.mdの最終更新コミットを特定**
   ```bash
   git log -1 --format="%H %ad" -- <README.mdのパス>
   ```

3. **最終更新以降のコミット履歴を調査**
   - 各README.mdについて、最終更新コミットから現在のHEADまでのコミット履歴を取得
   - 以下のような変更がないか確認：
     - 新しい機能の追加
     - 技術スタックの変更
     - プロジェクト構成の変更
     - 開発環境セットアップ手順の変更
     - デプロイ方法の変更
     - 新しいスクリプトやコマンドの追加

4. **関連ファイルの変更を確認**
   - package.json の変更（依存関係、スクリプト）
   - ディレクトリ構造の変更
   - 設定ファイルの変更
   - CLAUDE.md や他のドキュメントの変更

5. **README.mdを更新**
   - 変更が必要な箇所を特定
   - 既存のスタイルと一貫性を保ちながら更新
   - 不要な情報は削除し、最新の状態を反映

## 対象ファイル

以下の順序で処理してください：
1. ルートの `README.md`
2. サブディレクトリの `README.md`（例: `webapp/README.md`, `operation/README.md`, `lambda/README.md` など）

## 注意事項

- 各 README.md のフォーマットとスタイルを維持してください
- ルートの README.md には概要を、サブディレクトリの README.md には詳細を記載
- 重複した情報は避け、詳細は各サブディレクトリのREADMEへのリンクで対応
- 変更がない場合は「README.mdは最新の状態です」と報告してください
- サブディレクトリの README.md が存在しない場合でも、新規作成は不要です（既存ファイルの更新のみ）
