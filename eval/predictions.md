# 編集前に固定した予測 — 2026-09-18

対象: upstream `1b173430390e2b8a5121e341679b4f22ac561fce`。このファイル、request set、入力fixture、before判定をcanonical編集前にコミットする。後の観測を理由に予測・oracleを変更しない。

## 方法と判定限界

これは本レビュー担当による、非盲検のsource-level adversarial replayである。独立agentや実ユーザーを実行した比較試験ではない。入力と期待挙動を固定し、現行文面が許す／強制する反例と修正文面が許す挙動を比較する。手書きの会話traceは合成データと明記する。アンカリング、離脱率、下流実装の誤読率の実測値は得ていない。

false positive/negativeはdescription-only listingの曖昧なselection exposureとして記録し、実際のhost router誤動作と呼ばない。`planning-plan`の実definitionは検索で確認できなかったため、その境界だけ明示的なstubを使う。その他6つの隣接skillは取得したdescriptionを固定する。

## P1 — 発散時の推薦を収束へ移す

**Prediction:** D11の推薦必須をconvergence-onlyに条件化すると、20シナリオのEXPAND初回反応より前に推薦が現れず、探索が続く間も推薦しない。一方、同じ実在選択肢とトレードオフを提示でき、CHALLENGEでは理由付き推薦を維持できる。選択肢数・checkpoint数・user sign-offは変わらない。

**Falsifier:** 推薦文だけ消して同等の順位・優劣ラベルで先導する、比較情報を隠す、CHALLENGEでも判断支援を失う、またはD4/D11の優先関係が残る。人間のアンカリング低下は別途実験が必要。

**Failure / scenario:** 検索案の初回反応前に「Aがおすすめ」と表示（R003/R012、D01–D20）。
**Cause:** D4の中立性 vs D11の推薦必須。
**Existing check miss:** 参照・lens/gate数を数えるだけで、会話の順序を実行しない。
**Smallest change:** D11の推薦タイミングだけ条件化し、EXPANDの既存D4参照へ同期。選択肢quotaや新phaseは変更しない。
**Regression fixture:** recommendation suiteの20×4提示条件と、選択肢・比較情報の保持。

## P2 — fact verificationをdecision approvalから分ける

**Prediction:** D16に証拠と適用範囲を持つ`grounded`経路を設け、D2/D9を同じ区別に従わせると、読めるcode/API/規約/測定の事実をuser ratificationに変換せず持ち込める。ユーザーしか知らない事実は短いfree-text入力を求め、選択肢を発明しない。user preference、agent default、根拠不明なclaimは`grounded`へ逃げない。

**Falsifier:** 同意だけで事実検証を完了する、sourceの版・観測範囲を落とす、単にコードにある振る舞いを将来のproduct決定にする、または`derived from ID`が追跡不能な新決定の免罪符になる。

**Failure / scenario:** API定義の必須ヘッダーをユーザーに「決めて」もらう／知らない法人名を3択にする（R023/R026/PV）。
**Cause:** D16の全要素user由来3分類と、D2の無条件candidate、D9の全gap扱い。
**Existing check miss:** source evidenceの読解・適用性・decision ownerを検証しない。
**Smallest change:** 既存Source列に1つの経路を追加。新ID・新台帳・新gateなし。D2とD9のfact/decision境界だけ同期し、一般的なdelegation制度の再設計はしない。
**Regression fixture:** provenance 24件、未知のentity/segment/date入力、同意した偽事実と測定値→targetのすり替え。

## P3 — CFRは客観的検証可能、必ずしもnumericではない

**Prediction:** numericをquantitativeなCFRに限定し、categorical/normative条件にも具体的oracleを要求すると、固定30件のうち23件は架空の比率を足さず表現でき、7件のquantitative要件では元の根拠付き閾値と測定条件を維持できる。

**Falsifier:** 「安全」「アクセシブル」の形容詞だけで通す、規格名だけで適用criterionを特定しない、数値性能条件を曖昧にする、またはacceptance側がnumeric-onlyのままになる。

**Failure / scenario:** auditor以外拒否を「99%拒否」と書く、WCAG適合を独自スコアへ変換（R028/R029/CF）。
**Cause:** SPECIFYとspec-templateのEvery CFR carries a number、および受け入れ側のmetric-only表現。
**Existing check miss:** 数字の根拠・型・妥当性を見ない。
**Smallest change:** CFRの既存列をmetric/condition・target・verified howとして条件化し、同じ契約をacceptance手順まで同期。ACのGWT制度はこの変更で置き換えない。
**Regression fixture:** cfr 30件。数字を含むcriterion IDは数値thresholdではない。fixture中の数値は入力として供給された仮想要件であり、本レビューの推奨値ではない。

## P4 — OQとgate waiverを依存関係で決める

**Prediction:** Resolve-byを依存関係から導き、lock precondition欠落をnon-waivableにすると、固定OQ20件中12件のbuild/architecture/acceptance blockerはラベル引き下げとuser同意だけではLOCKできない。実装・受け入れ意味を変えない残り8件はownerと依存理由付きで保持できる。gate finding8件では6件をblock、意味不変の誤記と任意告知日の2件だけpark可能にする。

**Falsifier:** unresolved dependencyを`before-ship`へ改名しただけで通す、priorityをnice-to-haveにしただけで義務を外す、非依存の告知日や実buildの識別子まで事前に作らせる、または署名をbuildabilityの代替にする。

**Failure / scenario:** 保持期間・tenant境界・oracleが未決なのにdeadlineを後ろへ移す（R032/R033/R061/R064）。
**Cause:** templateの明示的なdowngrade escape hatchとQuality Gateの全finding park許可。
**Existing check miss:** OQの実装依存・acceptance依存を意味的に調べない。
**Smallest change:** 既存Blocks/Resolve-byに依存対象と理由を書く。新column・gate・phaseは作らない。未解決のまま進める既存文は「依存しない作業だけ」に限定。既存traceability/sign-offは維持。
**Regression fixture:** open-questions、gate-findings、anti-gaming relabel/waiver例。受け入れ手順の実行時環境bindingと、受け入れ意味の未決を分ける。

## P5 — revision/resumeは最初に壊れたdecisionへ戻す

**Prediction:** 一律SPECIFYをearliest-invalidated-decisionに替えると、AC誤記はSPECIFY、changed need/problemはFRAME、option space変化はEXPAND、pickの実現不能はCHALLENGE、scope境界はSHAPEへ戻る。resume時は変更が関係するgrounded factsだけ再確認し、同じ契約の無関係なコード変更では再FRAMEしない。無効化された子だけを再検証し、意味不変IDは保持する。

**Falsifier:** タイポでFRAMEをやり直す、need変更をAC編集だけで済ませる、すべての子を捨てる、古いsourceをmarkerだけでfreshと判定する、または下流handoffが旧SPECIFY固定のままになる。

**Failure / scenario:** 通知対象がadminからend-userに変わったlocked spec、廃止APIに依存するdraft（R037/R038/R065–R070）。
**Cause:** Invocation、Resume、Handoff、refutation return edgeの固定戻り先。
**Existing check miss:** phaseの戻り先や依存子の意味を検証しない。
**Smallest change:** 既存resume段落内に共通return ruleと小さなfreshness確認を置き、重複する戻り先を参照へ変更。新状態機械・新artifactなし。
**Regression fixture:** revision 14件と元の80件。re-lockのgateとuser sign-offは残す。

## 候補の選択（ordinal triage、実測頻度・確率ではない）

| Candidate | impact | frequency assumption | confidence | product | decision |
|---|---:|---:|---:|---:|---|
| P4 dependency/waiver | 5 | 5 | 5 | 125 | implement |
| P2 fact/decision ownership | 5 | 5 | 5 | 125 | implement |
| P3 numeric CFR | 4 | 5 | 5 | 100 | implement |
| P5 revision freshness/return | 5 | 4 | 5 | 100 | implement |
| P1 recommendation timing | 4 | 4 | 5 | 80 | implement |
| Refutation vote/confidence/authority redesign | 5 | 3 | 5 | 75 | separate coherent change; defer under cap |
| Routing description | 5 | 5 | 3 | 75 | selection harness not available; report exposures, defer |
| Light artifact applicability | 4 | 5 | 3 | 60 | broad contract/consumer compatibility change; defer |
| Genuine option cardinality | 4 | 3 | 5 | 60 | real counterexample; defer under cap |
| Protected-term paraphrase | 4 | 3 | 5 | 60 | real counterexample; defer under cap |

頻度は対象setの件数をpopulation推定に転用せず、日常的な該当範囲を相対評価したもの。高リスクの未修正findingが残るため、この5件をもってskill全体の品質保証とはしない。
