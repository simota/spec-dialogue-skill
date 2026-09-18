# 80件の変更前後評価

入力・文脈・期待するowner/phaseは編集前に固定したrequests.jsonlのまま。結果は各ケースの主たる反例に関する、同一レビュー担当者の非盲検・source-level評価であり、agentを80回実行した結果ではない。fixedはその規則衝突を修正した意味で、ケース全体の仕様品質保証ではない。still-ambiguousには、未修正の反例が明らかに残るケースも含める。

集計: fixed 34 / unchanged-correct 22 / regressed 0 / still-ambiguous 24。

| ID | request | before（主たる反例） | after | 変更 | 必要な最初のphase | 評価理由 |
|---|---|---|---|---|---|---|
| R001 | 通知機能を作りたい | counterexample | still-ambiguous | — | FRAME | descriptionはrough idea中心で、成果物と依頼ownerの境界を単独で決め切れない。 |
| R002 | 通知設定にSlackを追加したい。Webhook URLを保存してON/OFFできればいい | counterexample | still-ambiguous | — | none | lightにも全artifactとbuild-pathが残り、明確なコード変更を捕まえると過剰対話になる。 |
| R003 | 新しい検索体験を考えたい | counterexample | fixed | P1 | FRAME | D4/D11/EXPANDが初回反応および発散中の推薦を禁止し、収束時の比較・理由付き推薦を保持。実際の人間のanchoring低下は未測定。 |
| R004 | この仕様を固めたい | counterexample | fixed | P4 | CHALLENGE | Blocksの依存理由がResolve-byを決める。未解決build/acceptance dependencyは同意・deadline/priority変更だけでLOCK不可。 |
| R005 | このACを直したい | pass | unchanged-correct | — | SPECIFY | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R006 | 既存specのDB前提が変わった | counterexample | fixed | P5 | CHALLENGE | 最初に無効化されたdecisionのphaseへ戻り、grounded premisesを必要範囲だけ再検証。無関係な決定・IDは保持。 |
| R007 | このfeatureの仕様だけ作って。実装方法は後で決める | counterexample | still-ambiguous | — | SPECIFY | spec-only/RFPにも実装path選択を要求する。 |
| R008 | 決済フローに3DSを追加する仕様を作りたい | counterexample | fixed | P2 | FRAME | D2は未知のfactual menuを作らず、D9/D16は根拠・版・適用範囲付きgroundedを許す。product choiceやsource不明claimは同経路で通らない。 |
| R009 | このボタンを追加するだけ | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R010 | まずコードを書いて | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R011 | このAPIのresponse fieldを1つ追加したい | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R012 | ユーザーにどっちがいいかまだ分からない | counterexample | fixed | P1 | EXPAND | D4/D11/EXPANDが初回反応および発散中の推薦を禁止し、収束時の比較・理由付き推薦を保持。実際の人間のanchoring低下は未測定。 |
| R013 | ちゃんと仕様を決めたい | pass | unchanged-correct | — | FRAME | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R014 | このfeatureの要件を整理して | counterexample | still-ambiguous | — | none | descriptionはrough idea中心で、成果物と依頼ownerの境界を単独で決め切れない。 |
| R015 | 何を作るべきか相談したい | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R016 | この仕様の技術設計をして | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R017 | このfeatureを実装までやって | counterexample | still-ambiguous | — | none | descriptionはrough idea中心で、成果物と依頼ownerの境界を単独で決め切れない。 |
| R018 | この曖昧な1文だけ明確にして | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R019 | 管理画面を落ち着いた見た目にしたい | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R020 | 通知の不満が本当に多いか調べたい | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R021 | 今ある仕様で実装計画を作って | counterexample | still-ambiguous | — | none | descriptionはrough idea中心で、成果物と依頼ownerの境界を単独で決め切れない。 |
| R022 | 二重請求防止機能を追加して | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R023 | 利用企業の法人名をspecに入れて | counterexample | fixed | P2 | SPECIFY | D2は未知のfactual menuを作らず、D9/D16は根拠・版・適用範囲付きgroundedを許す。product choiceやsource不明claimは同経路で通らない。 |
| R024 | 対象顧客とローンチ日を埋めたい | counterexample | fixed | P2 | FRAME | D2は未知のfactual menuを作らず、D9/D16は根拠・版・適用範囲付きgroundedを許す。product choiceやsource不明claimは同経路で通らない。 |
| R025 | メールよりアプリ内通知が好みです | counterexample | fixed | P1 | EXPAND | D4/D11/EXPANDが初回反応および発散中の推薦を禁止し、収束時の比較・理由付き推薦を保持。実際の人間のanchoring低下は未測定。 |
| R026 | 外部APIの必須ヘッダーをこのspecに反映して | counterexample | fixed | P2 | SPECIFY | D2は未知のfactual menuを作らず、D9/D16は根拠・版・適用範囲付きgroundedを許す。product choiceやsource不明claimは同経路で通らない。 |
| R027 | 設定画面は既存design tokenに合わせたい | counterexample | fixed | P2 | SPECIFY | D2は未知のfactual menuを作らず、D9/D16は根拠・版・適用範囲付きgroundedを許す。product choiceやsource不明claimは同経路で通らない。 |
| R028 | 認可条件を測定可能なCFRにして | counterexample | fixed | P3 | SPECIFY | CFRをnumeric/ categorical/normativeに条件化。指定conditionと観測・判定証拠が必要で、数値の捏造を要しない。 |
| R029 | アクセシビリティのACを固めたい | counterexample | fixed | P3 | SPECIFY | CFRをnumeric/ categorical/normativeに条件化。指定conditionと観測・判定証拠が必要で、数値の捏造を要しない。 |
| R030 | 応答は十分速くして | pass | unchanged-correct | — | SPECIFY | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R031 | 個人データを国内リージョンから出さない仕様にしたい | counterexample | fixed | P3 | SPECIFY | CFRをnumeric/ categorical/normativeに条件化。指定conditionと観測・判定証拠が必要で、数値の捏造を要しない。 |
| R032 | must-haveのテスト手順は後で考えてLOCKして | counterexample | fixed | P4 | SPECIFY | Blocksの依存理由がResolve-byを決める。未解決build/acceptance dependencyは同意・deadline/priority変更だけでLOCK不可。 |
| R033 | 保持期間はbefore-shipにして先に実装して | counterexample | fixed | P4 | SHAPE | Blocksの依存理由がResolve-byを決める。未解決build/acceptance dependencyは同意・deadline/priority変更だけでLOCK不可。 |
| R034 | 告知日だけ未定だけど仕様をLOCKしたい | pass | unchanged-correct | — | SPECIFY | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R035 | 移行で重複データをどう扱うかは任せる | counterexample | still-ambiguous | — | CHALLENGE | D7/D9/D15にauthority・reversal cost境界がなく、不可逆なuser-only決定も仮置きできる。 |
| R036 | 今は答えられないから、法的保存義務は仮定で進めて | counterexample | fixed | P4 | FRAME | Blocksの依存理由がResolve-byを決める。未解決build/acceptance dependencyは同意・deadline/priority変更だけでLOCK不可。 |
| R037 | 既存locked specの対象ユーザーが変わった | counterexample | fixed | P5 | FRAME | 最初に無効化されたdecisionのphaseへ戻り、grounded premisesを必要範囲だけ再検証。無関係な決定・IDは保持。 |
| R038 | draftを再開して。昨日APIが廃止された | counterexample | fixed | P5 | CHALLENGE | 最初に無効化されたdecisionのphaseへ戻り、grounded premisesを必要範囲だけ再検証。無関係な決定・IDは保持。 |
| R039 | draftの続き。コードも意図も変わっていない | pass | unchanged-correct | — | SPECIFY | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R040 | この仕様書をRFPに使うので仕様だけ完成させたい | counterexample | still-ambiguous | — | SPECIFY | spec-only/RFPにも実装path選択を要求する。 |
| R041 | Add a CSV download button using the attached contract. | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R042 | Help us agree the invitation workflow before implementation. | pass | unchanged-correct | — | FRAME | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R043 | Turn these settled meeting notes into a specification document. | counterexample | still-ambiguous | — | none | descriptionはrough idea中心で、成果物と依頼ownerの境界を単独で決め切れない。 |
| R044 | Make collaboration better. | counterexample | still-ambiguous | — | FRAME | descriptionはrough idea中心で、成果物と依頼ownerの境界を単独で決め切れない。 |
| R045 | Explore three search experiences with me, without picking yet. | counterexample | fixed | P1 | EXPAND | D4/D11/EXPANDが初回反応および発散中の推薦を禁止し、収束時の比較・理由付き推薦を保持。実際の人間のanchoring低下は未測定。 |
| R046 | We must integrate the contracted provider, not choose a vendor. | counterexample | still-ambiguous | — | SPECIFY | 本当に1–2案しかないのに3–5方向とrejected listを埋める圧力がある。 |
| R047 | Add a feature flag; enabled and disabled are the only product states. | counterexample | still-ambiguous | — | SPECIFY | 本当に1–2案しかないのに3–5方向とrejected listを埋める圧力がある。 |
| R048 | Plan the rollout work for this approved specification. | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R049 | Design a calmer visual direction for our dashboard. | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R050 | Scope research on whether offline sync is technically feasible. | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R051 | Build and ship cross-tenant sharing, starting from this idea. | counterexample | still-ambiguous | — | none | descriptionはrough idea中心で、成果物と依頼ownerの境界を単独で決め切れない。 |
| R052 | The delete flow needs a new safeguard: it currently ignores cancel. | pass | unchanged-correct | — | none | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R053 | Use the API rate limit from the supplied versioned contract. | counterexample | fixed | P2 | SPECIFY | D2は未知のfactual menuを作らず、D9/D16は根拠・版・適用範囲付きgroundedを許す。product choiceやsource不明claimは同経路で通らない。 |
| R054 | Carry the measured import limit into the spec. | counterexample | fixed | P2 | SPECIFY | D2は未知のfactual menuを作らず、D9/D16は根拠・版・適用範囲付きgroundedを許す。product choiceやsource不明claimは同経路で通らない。 |
| R055 | Follow the repository convention for event names. | counterexample | fixed | P2 | SPECIFY | D2は未知のfactual menuを作らず、D9/D16は根拠・版・適用範囲付きgroundedを許す。product choiceやsource不明claimは同経路で通らない。 |
| R056 | Which legal entity signs the processing agreement? | counterexample | fixed | P2 | FRAME | D2は未知のfactual menuを作らず、D9/D16は根拠・版・適用範囲付きgroundedを許す。product choiceやsource不明claimは同経路で通らない。 |
| R057 | Write objectively checkable browser-support requirements. | counterexample | fixed | P3 | SPECIFY | CFRをnumeric/ categorical/normativeに条件化。指定conditionと観測・判定証拠が必要で、数値の捏造を要しない。 |
| R058 | Specify auditability for administrator exports. | counterexample | fixed | P3 | SPECIFY | CFRをnumeric/ categorical/normativeに条件化。指定conditionと観測・判定証拠が必要で、数値の捏造を要しない。 |
| R059 | Require encrypted storage using the approved key policy. | counterexample | fixed | P3 | SPECIFY | CFRをnumeric/ categorical/normativeに条件化。指定conditionと観測・判定証拠が必要で、数値の捏造を要しない。 |
| R060 | Set a p95 latency target for imports. | pass | unchanged-correct | — | SPECIFY | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R061 | Lock the spec; we can decide cross-tenant access later. | counterexample | fixed | P4 | CHALLENGE | Blocksの依存理由がResolve-byを決める。未解決build/acceptance dependencyは同意・deadline/priority変更だけでLOCK不可。 |
| R062 | Mark the contradictory acceptance criteria as deferred. | counterexample | fixed | P4 | SPECIFY | Blocksの依存理由がResolve-byを決める。未解決build/acceptance dependencyは同意・deadline/priority変更だけでLOCK不可。 |
| R063 | Choose an acceptance environment even though nothing is built yet. | counterexample | still-ambiguous | — | SPECIFY | 環境未構築でもnamed env/fixture/resetを要求し、fictional detailsの誘惑がある。 |
| R064 | Rename the unresolved oracle question to before-ship so we can lock. | counterexample | fixed | P4 | SPECIFY | Blocksの依存理由がResolve-byを決める。未解決build/acceptance dependencyは同意・deadline/priority変更だけでLOCK不可。 |
| R065 | The selected mobile push direction is impossible under the new platform constraint. | counterexample | fixed | P5 | CHALLENGE | 最初に無効化されたdecisionのphaseへ戻り、grounded premisesを必要範囲だけ再検証。無関係な決定・IDは保持。 |
| R066 | Reopen the spec: the problem is now legal evidence preservation, not storage saving. | counterexample | fixed | P5 | FRAME | 最初に無効化されたdecisionのphaseへ戻り、grounded premisesを必要範囲だけ再検証。無関係な決定・IDは保持。 |
| R067 | The old API limitation is gone; reopen our rejected alternatives. | counterexample | fixed | P5 | EXPAND | 最初に無効化されたdecisionのphaseへ戻り、grounded premisesを必要範囲だけ再検証。無関係な決定・IDは保持。 |
| R068 | Only change the rollout paragraph to include a staged coexistence period. | counterexample | fixed | P5 | SHAPE | 最初に無効化されたdecisionのphaseへ戻り、grounded premisesを必要範囲だけ再検証。無関係な決定・IDは保持。 |
| R069 | Resume the draft; a new storage regulation now applies. | counterexample | fixed | P5 | FRAME | 最初に無効化されたdecisionのphaseへ戻り、grounded premisesを必要範囲だけ再検証。無関係な決定・IDは保持。 |
| R070 | Resume after a dependency update, but the used contract did not change. | pass | unchanged-correct | — | SPECIFY | 既存ルールで目的の分離・停止・保持を表現できる。 |
| R071 | Preserve the term “delete marker”; it does not mean permanent deletion. | counterexample | still-ambiguous | — | SPECIFY | D6 different words強制が保護すべきdomain termの意味を変える。 |
| R072 | Both approaches should coexist behind a customer setting. | counterexample | still-ambiguous | — | CHALLENGE | ONE directionを単一実装に誤読すると、選ばれたdecision mechanismまで潰す。 |
| R073 | We can only resolve this choice with a prototype. | counterexample | still-ambiguous | — | CHALLENGE | ONE directionを単一実装に誤読すると、選ばれたdecision mechanismまで潰す。 |
| R074 | The schema must reject nulls at build time. | counterexample | still-ambiguous | — | SPECIFY | invariantに架空のWhenを付ける形式適合になる。 |
| R075 | Use “QA reviewer” as the oracle for this must-have criterion. | counterexample | still-ambiguous | — | SPECIFY | named reviewerだけでもoracleを名乗れて、観測と判定規則が残る。 |
| R076 | Three reviewers say the provider supports retries, but the contract forbids them. | counterexample | still-ambiguous | — | CHALLENGE | 同じ派生前提の3票が一次証拠1件を上回る。 |
| R077 | I own this product; I have changed my mind and now want dark mode. | counterexample | still-ambiguous | — | FRAME | new evidence onlyがproduct ownerのintent変更を事実の争いとして却下する。 |
| R078 | Walk the behavior checklist for a static copyright notice. | counterexample | still-ambiguous | — | SPECIFY | 6つのN/A walkはdomain固有の失敗を埋めず、completeness錯覚と負担を作る。 |
| R079 | Write a specification for an offline-only command-line formatter. | counterexample | still-ambiguous | — | SPECIFY | 6つのN/A walkはdomain固有の失敗を埋めず、completeness錯覚と負担を作る。 |
| R080 | Clarify already confirmed who this is for and why; now settle delivery semantics. | counterexample | still-ambiguous | — | SPECIFY | clarifyの確認済みintentをFRAMEで再度尋ねる。 |
