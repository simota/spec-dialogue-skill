# PR評価資料 — 仕様対話の5契約修正

このディレクトリは、先に作成したレビュー一式から、固定80件・変更前予測・前後判定を取り出したレビュー用の抜粋です。仕様の新しい必須artifactではなく、インストールされるskillの外に置いています。

| ファイル | 内容 |
|---|---|
| [requests.md](requests.md) | 編集前に固定した80 requestと文脈、期待owner/depth/phase。日本語40件 |
| [predictions.md](predictions.md) | 編集前の反証可能な予測P1–P5、反例、変更理由、選択しなかった候補 |
| [results.md](results.md) | 同じ80件の変更前後判定。主たる反例ごとの結果 |
| [followup.md](followup.md) | 後続変更: 下記「今回変更していないもの」の大半への対応と、still-ambiguous 24件の後続判定 |

3ファイルは、依頼者へ渡したレビュー成果物とbyte単位で同じです。本文に登場するrequests.jsonl、専門suite、全362専門fixture行、集計・データ検査script、詳細ログ、Git bundleは元のレビューアーカイブ側の資料であり、このPRには含めていません。この抜粋だけで元の集計scriptを実行できるとはしていません。

## 履歴と評価方法

対象はupstream `1b173430390e2b8a5121e341679b4f22ac561fce`。元のローカルレビューでは、入力・予測を`646c29fd2ea9925a67b8d997df9444267428c80e`に固定した後、policyを`b9a51d7ca0e409fac9aa9138ab476a3d10460bc4`で変更しました。これらは依頼者に提供したbundle内のローカル履歴です。このPRの公開コミット順を、編集前の新たな事前登録と呼ぶものではありません。

評価は同一担当者による非盲検のsource-level adversarial replayです。独立agentを80回動かした試験、人間のA/B試験、実際の離脱率・anchoring・downstream誤読率の測定ではありません。

結果はfixed 34、unchanged-correct 22、regressed 0、still-ambiguous 24。fixedは指定した規則衝突を閉じた意味で、case全体の正しさを保証しません。regressed 0も、このレビューで発見しなかったという意味です。

## 手動で再評価する正負の挙動例

以下は測定ログではなく、元の合成continuationが検査する差をまとめたものです。規則に禁止文があるかではなく、出力された質問・記録・戻り先を比較します。

| 対象と入力 | 受け入れる挙動 | 拒否する挙動 | 保持すべき対照 |
|---|---|---|---|
| P1 / R003・R025: 検索案をEXPAND中。最初の反応後も探索を続けたい | genuine optionsとtrade-offを中立に示し、収束後に根拠付き推薦 | 初回反応前の「Aがおすすめ」、または初回反応を得ただけで発散中に順位付け | 事実上の制約や比較情報まで隠さない |
| P2 / R023・R026・R054: 正式法人名は不明、API制約には版付きsourceがある | 不明な法人名を短いfree-textで尋ね、API制約はsource・版・適用範囲付きgrounded | 法人名を発明して3択にする、同意だけで外部claimをgroundedにする | 現状の観測値を将来targetとして勝手に採用しない |
| P3 / R028・R030: auditor以外は禁止。別件の性能閾値は要確認 | 権限の許可集合と保護payloadの観測でpass/fail。性能には根拠付き数値と負荷条件 | 「非auditorの99%を拒否」、規格名だけ、性能を「十分速い」に置換 | categoricalの許可例外を捏造せず、quantitativeの精度を落とさない |
| P4 / R032・R033・R034: 移行の重複winnerが未決。告知日は別の未決事項 | 変換・損失意味に依存するOQはbefore-buildとしてLOCKを止め、告知日は非依存理由付きで残せる | 同じ依存をbefore-shipへ改名、must-haveを改名、TC欠落を同意で免除 | 意味と必要能力が確定した実build IDの後日bindingは捏造せず許す |
| P5 / R005・R037・R038・R070: 誤記、need変更、API廃止、契約不変のdependency更新 | 順にSPECIFY、FRAME、CHALLENGE、有効な保存marker。無効化された子だけ再検証 | need変更をACの文言修正だけでLOCK、誤記で全FRAME再実行、markerをfreshnessの証明にする | 無関係な決定と意味不変IDを保存し、再LOCKはuser sign-offを要求 |

再評価時は各requestの文脈を残し、出力の根拠と反例を記録してください。expected ownerやphase自体への異論も残し、結果に合わせて元の入力・予測を上書きしないでください。

## 実行した検証と限界

PR作成時に変更済みローカルtreeで`make check`と`make test`を再実行し、後者は39 passed / 0 failedでした。runtime9ファイルと上記3評価ファイルはGit blob hashを照合しています。

元の完全アーカイブではデータ完全性検査とそのmutation testも再実行し、28固定ファイル不変、80 IDs、362専門fixture行、mutation testは7 passed / 0 failedでした。これはこのPRに追加したテストではありません。

既存makeは参照・lens/gate数・link動作の検査です。対話品質、sourceの真偽、anchoring、fake options、gate severity、revision routingの意味的正しさを保証しません。合成挙動例にも独立性はありません。

## 今回変更していないもの

> 後続変更で、ここに挙げた項目の大半を扱った。結果は[followup.md](followup.md)を参照。この節は当時の記録として残す。

routing frontmatterとclarify後の反復FRAME、lightの必須section・別acceptance document・build-path、3–5案とONE direction、D6の別語強制、全ACのGWT、固定Behavior matrix、scopeのexhaustiveness、refutationの多数決・60%・owner authorityには反例が残ります。README/siteのagy install path driftも別件として残しています。

このPRは5つの契約修正に限定し、新phase・gate・lens・ID typeを追加しません。ユーザーの明示LOCK、REQ/CFR → AC → TC、must-haveの具体的手順、未実行結果のNOT_RUNは保持します。
