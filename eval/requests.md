# 固定request set — 80件（日本語40件）

文脈も入力の一部。should-fireは評価oracleであって、現行descriptionの実行結果ではない。

| ID | request / context | spec-dialogue should fire? | depth | first phase needed | phases that can be skipped | user decisions required | likely failure / owner |
| --- | --- | --- | --- | --- | --- | --- | --- |
| R001 | 通知機能を作りたい — 成果物がコードか仕様か未指定。既存サービスあり。 | conditional | standard | FRAME | none | まず成果物、対象者、通知目的 | routing / clarify |
| R002 | 通知設定にSlackを追加したい。Webhook URLを保存してON/OFFできればいい — 実装依頼。既存の保存・暗号化・設定パターンがある。 | no | none | none | all | 既存契約で決まらない権限差分のみ | light-ceremony / coding-implement |
| R003 | 新しい検索体験を考えたい — 探す人の課題と探索範囲から一緒に仕様を決めたい。 | yes | standard | FRAME | none | 検索対象、成功、選択軸 | recommendation / spec-dialogue |
| R004 | この仕様を固めたい — 共有カレンダーの編集権限・競合解決・招待失効が未決。 | yes | standard | CHALLENGE | FRAME,EXPAND | 既知の案間の権限と競合方針 | oq / spec-dialogue |
| R005 | このACを直したい — locked spec。must-haveを維持し、同義の誤記だけ直す。 | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | 意味が変わらないことと再LOCK | revision-wording / spec-dialogue |
| R006 | 既存specのDB前提が変わった — 採用案の前提だった複数行トランザクションを新DBが提供しない。 | yes | deep | CHALLENGE | FRAME,EXPAND unless alternatives invalid | 整合性を維持する代替方向 | revision / spec-dialogue |
| R007 | このfeatureの仕様だけ作って。実装方法は後で決める — 対象と方向は合意済み。公開APIの振る舞いを対話で確定する。 | yes | standard | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | エラーと互換性の契約、LOCK | buildpath / spec-dialogue |
| R008 | 決済フローに3DSを追加する仕様を作りたい — 加盟店契約とPSPの提供資料を証拠として同梱。適用対象は要確認。 | yes | deep | FRAME | EXPAND if mandated route | 対象取引、失敗時の体験、責任者 | grounded / spec-dialogue |
| R009 | このボタンを追加するだけ — ラベル・クリック先・既存コンポーネントが全指定。コードを変更。 | no | none | none | all | なし | correct / coding-implement |
| R010 | まずコードを書いて — 完成したAPI契約とテスト例が添付。 | no | none | none | all | なし | correct / coding-implement |
| R011 | このAPIのresponse fieldを1つ追加したい — 型・nullability・権限・互換性を指定し、実装を依頼。 | no | none | none | all | なし | correct / coding-implement |
| R012 | ユーザーにどっちがいいかまだ分からない — 検索の候補体験を比較し、まず自分の評価軸を言語化したい。 | yes | standard | EXPAND | FRAME | 評価軸と未知のユーザー仮説の区別 | recommendation / spec-dialogue |
| R013 | ちゃんと仕様を決めたい — チーム招待の期限と既存アカウント統合が未決。 | yes | standard | FRAME | none | 期限と統合の振る舞い | correct / spec-dialogue |
| R014 | このfeatureの要件を整理して — 確定済みの議事録を既存フォーマットに転記。意思決定はしない。 | no | none | none | all | なし | routing / writing |
| R015 | 何を作るべきか相談したい — 通知・検索・分析のどれを今期投資対象にするか。 | no | none | none | all | 投資目的と優先順位 | correct / planning-frame |
| R016 | この仕様の技術設計をして — locked specの振る舞いを変えずデータ構造と実装順を決める。 | no | none | none | all | 技術的制約の確認だけ | correct / coding-plan |
| R017 | このfeatureを実装までやって — 高リスクの組織間データ共有。ACは未定、仕様から出荷まで依頼。 | no | none | none | all at top-level; delegate spec when needed | 責任分界と出荷条件 | routing / feature-lifecycle |
| R018 | この曖昧な1文だけ明確にして — 「見やすく表示」を既存画面の幅と情報優先度で限定。 | no | none | none | all | この一文の達成条件 | correct / clarify |
| R019 | 管理画面を落ち着いた見た目にしたい — 機能仕様は不変。タイポグラフィ・色・密度の探索。 | no | none | none | all | 見た目の方向 | correct / design-direction |
| R020 | 通知の不満が本当に多いか調べたい — 調査質問、データ源、終了条件だけ決めたい。 | no | none | none | all | 調査でどの決定を支えるか | correct / research-scope |
| R021 | 今ある仕様で実装計画を作って — 機能の判断は完了。作業分割と依存順と見積りが成果物。 | no | none | none | all | 資源・期限の制約 | routing / planning-plan |
| R022 | 二重請求防止機能を追加して — 二重請求は現行契約違反。再現ログがある不具合修正。 | no | none | none | all | 既存契約の変更がない限りなし | correct / coding-debug |
| R023 | 利用企業の法人名をspecに入れて — 法人名は未提供。agentが知る手段はなく、ユーザーだけが知る。 | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | 正式法人名という事実の入力 | factual-input / spec-dialogue |
| R024 | 対象顧客とローンチ日を埋めたい — 承認済みだが会話・repoにない社内計画の事実。 | yes | standard | FRAME | EXPAND if plan settled | 確定済み計画の出典・値 | factual-input / spec-dialogue |
| R025 | メールよりアプリ内通知が好みです — 最初のEXPAND反応。まだ頻度や一覧の構成は探索中。 | yes | standard | EXPAND | FRAME | 未探索の体験と理由 | recommendation / spec-dialogue |
| R026 | 外部APIの必須ヘッダーをこのspecに反映して — バージョン固定のAPI定義ファイルに必須条件がある。 | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | 新たなproduct choiceなし、差分LOCK | grounded / spec-dialogue |
| R027 | 設定画面は既存design tokenに合わせたい — repoのtoken定義を読める。darkとdimは別概念。 | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | 既存規約を変える意図があるかだけ | grounded / spec-dialogue |
| R028 | 認可条件を測定可能なCFRにして — 閲覧はrole=auditorのみ。数値的な成功率は要件ではない。 | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | 権限表の承認は既に済み | numeric / spec-dialogue |
| R029 | アクセシビリティのACを固めたい — 契約で指定されたWCAG版とcriterion一覧を添付。 | yes | standard | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | 未決の利用支援条件のみ | numeric / spec-dialogue |
| R030 | 応答は十分速くして — 既知のAPI。許容待ち時間・負荷条件は未定。 | yes | standard | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | 許容遅延、代表負荷の根拠 | numeric-positive / spec-dialogue |
| R031 | 個人データを国内リージョンから出さない仕様にしたい — 対象データと指定regionは決定済み。バックアップも対象。 | yes | deep | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | 例外を追加するか、証拠の範囲 | numeric / spec-dialogue |
| R032 | must-haveのテスト手順は後で考えてLOCKして — ACはあるが観測方法もTCも未定。 | yes | standard | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | 受け入れ契約を決める。単なる免除は不可 | oq / spec-dialogue |
| R033 | 保持期間はbefore-shipにして先に実装して — 削除方式・バックアップ・課金容量が保持期間で変わる。 | yes | deep | SHAPE | FRAME,EXPAND,CHALLENGE | 保持期間と不可逆削除の境界 | oq / spec-dialogue |
| R034 | 告知日だけ未定だけど仕様をLOCKしたい — 機能・配布能力・受け入れ基準は確定、カレンダー日だけ未定。 | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | 告知担当、公開前に決める根拠 | oq-positive / spec-dialogue |
| R035 | 移行で重複データをどう扱うかは任せる — 不可逆の統合。重複時の優先権は業務ownerのみ決められる。 | yes | deep | CHALLENGE | FRAME,EXPAND | 生存レコードと権利の帰属 | assume / spec-dialogue |
| R036 | 今は答えられないから、法的保存義務は仮定で進めて — 確認できない適用法・契約が保存設計を左右する。 | yes | deep | FRAME | none | 適用範囲を専門ownerへ確認 | oq / spec-dialogue |
| R037 | 既存locked specの対象ユーザーが変わった — 管理者の一括操作から一般利用者の個別操作へ目的変更。 | yes | standard | FRAME | unaffected descendants only | 新しいjobと成功条件 | revision / spec-dialogue |
| R038 | draftを再開して。昨日APIが廃止された — SPECIFY marker。採用案の唯一の依存APIが廃止。 | yes | standard | CHALLENGE | FRAME if intent unchanged | 代替方向と依存契約 | freshness / spec-dialogue |
| R039 | draftの続き。コードも意図も変わっていない — 保存した証拠の参照と版が同じ。SPECIFY marker。 | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | 未決ACだけ | freshness-positive / spec-dialogue |
| R040 | この仕様書をRFPに使うので仕様だけ完成させたい — 実装方式は別会社が提案。振る舞いと受け入れだけ決める。 | yes | standard | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | 調達境界、受け入れ、LOCK | buildpath / spec-dialogue |
| R041 | Add a CSV download button using the attached contract. — All fields, ordering, escaping, permissions and tests specified; code requested. | no | none | none | all | none | correct / coding-implement |
| R042 | Help us agree the invitation workflow before implementation. — Expired invites, account collisions and ownership unresolved; spec pair wanted. | yes | standard | FRAME | none | Expiry, collision behavior, owner | correct / spec-dialogue |
| R043 | Turn these settled meeting notes into a specification document. — Do not reopen decisions; formatting and linking only. | no | none | none | all | none | routing / writing |
| R044 | Make collaboration better. — No desired deliverable specified; could be workflow research or coding. | conditional | standard | FRAME | none until intent known | Desired output and problem | routing / clarify |
| R045 | Explore three search experiences with me, without picking yet. — Problem agreed. Three genuine shapes: facets, command palette, conversational. | yes | standard | EXPAND | FRAME | Reaction and distinctions | recommendation / spec-dialogue |
| R046 | We must integrate the contracted provider, not choose a vendor. — Provider contract leaves retry and recovery choices but no vendor choice. | yes | deep | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE if direction settled | Recovery semantics | options / spec-dialogue |
| R047 | Add a feature flag; enabled and disabled are the only product states. — A small contract is requested, not a menu of new features. | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Default and authorized switch owner | options / spec-dialogue |
| R048 | Plan the rollout work for this approved specification. — Work breakdown only. No feature behavior open. | no | none | none | all | Sequencing and staffing | correct / planning-plan |
| R049 | Design a calmer visual direction for our dashboard. — Aesthetic brief only; no acceptance contract needed. | no | none | none | all | Visual intent | correct / design-direction |
| R050 | Scope research on whether offline sync is technically feasible. — Evidence brief and prototype questions, not a feature promise. | no | none | none | all | Evidence bar and stopping rule | correct / research-scope |
| R051 | Build and ship cross-tenant sharing, starting from this idea. — High-stakes and cross-team; autonomous end-to-end deliverable. | no | none | none | all at top-level | Product intent and rollout authority | routing / feature-lifecycle |
| R052 | The delete flow needs a new safeguard: it currently ignores cancel. — Reproduction shows bug against current documented behavior. | no | none | none | all | No behavior change requested | correct / coding-debug |
| R053 | Use the API rate limit from the supplied versioned contract. — The contract explicitly fixes 100 requests per minute for this endpoint. | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | No vote on provider limit | grounded / spec-dialogue |
| R054 | Carry the measured import limit into the spec. — Supplied benchmark shows failure above a particular fixture size, not a universal capacity. | yes | standard | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Product target separately from observed bound | grounded / spec-dialogue |
| R055 | Follow the repository convention for event names. — A documented convention exists at a pinned commit; payload semantics still open. | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Payload semantics, not naming fact | grounded / spec-dialogue |
| R056 | Which legal entity signs the processing agreement? — Internal factual input absent from every provided source. | yes | standard | FRAME | none | Actual entity/source; no invented entity menu | factual-input / spec-dialogue |
| R057 | Write objectively checkable browser-support requirements. — Supported browser/version set is supplied by the product owner. | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | No arbitrary support percentage | numeric / spec-dialogue |
| R058 | Specify auditability for administrator exports. — Required event fields and authorized reader roles already settled. | yes | standard | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | No invented auditability score | numeric / spec-dialogue |
| R059 | Require encrypted storage using the approved key policy. — Versioned internal policy names the allowed algorithm and key ownership. | yes | deep | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Exceptions only, not a numeric encryption score | numeric / spec-dialogue |
| R060 | Set a p95 latency target for imports. — No workload or acceptable waiting cost supplied. | yes | standard | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Workload and justified target | numeric-positive / spec-dialogue |
| R061 | Lock the spec; we can decide cross-tenant access later. — That decision changes authorization architecture and must-have outcomes. | yes | deep | CHALLENGE | FRAME,EXPAND | Permission boundaries before dependent design | oq / spec-dialogue |
| R062 | Mark the contradictory acceptance criteria as deferred. — One AC requires immediate deletion; another retains readable content. | yes | deep | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Resolve incompatible behavior | oq / spec-dialogue |
| R063 | Choose an acceptance environment even though nothing is built yet. — No infrastructure evidence supplied; reproducible capability contract possible. | yes | standard | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Required environment capabilities and owner | fake-fixtures / spec-dialogue |
| R064 | Rename the unresolved oracle question to before-ship so we can lock. — No observation or pass/fail rule exists for a must-have AC. | yes | standard | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Acceptance meaning now; actual execution later | oq / spec-dialogue |
| R065 | The selected mobile push direction is impossible under the new platform constraint. — Locked spec; original problem still valid, provider evidence invalidates the pick. | yes | standard | CHALLENGE | FRAME if intact; EXPAND if old options remain | New feasible direction | revision / spec-dialogue |
| R066 | Reopen the spec: the problem is now legal evidence preservation, not storage saving. — Locked destructive-deletion spec has a changed job and success definition. | yes | deep | FRAME | Keep only unaffected artifacts | New intent and scope | revision / spec-dialogue |
| R067 | The old API limitation is gone; reopen our rejected alternatives. — A new option is feasible; no currently chosen direction is yet refuted. | yes | standard | EXPAND | FRAME | Whether reopened option space changes pick | revision / spec-dialogue |
| R068 | Only change the rollout paragraph to include a staged coexistence period. — Direction remains; in/out scope and proposal change, AC descendants affected. | yes | standard | SHAPE | FRAME,EXPAND,CHALLENGE | Coexistence boundary and exit condition | revision / spec-dialogue |
| R069 | Resume the draft; a new storage regulation now applies. — Supplied authoritative notice changes purpose limitation in FRAME constraints. | yes | deep | FRAME | Unchanged descendants retained | Applicability from authority; new product bounds | freshness / spec-dialogue |
| R070 | Resume after a dependency update, but the used contract did not change. — Pinned relevant signatures verified unchanged, unrelated implementation changed. | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Remaining decisions only | freshness-positive / spec-dialogue |
| R071 | Preserve the term “delete marker”; it does not mean permanent deletion. — Domain distinction must survive paraphrase-back. | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Meaning confirmation with protected term | paraphrase / spec-dialogue |
| R072 | Both approaches should coexist behind a customer setting. — Configured product behavior is the chosen mechanism, not indecision. | yes | standard | CHALLENGE | FRAME,EXPAND | Setting ownership, branch behavior, exit if any | hybrid / spec-dialogue |
| R073 | We can only resolve this choice with a prototype. — Unknown algorithm quality determines feasibility; no honest final performance oracle yet. | yes | standard | CHALLENGE | FRAME | Experiment scope and decision mechanism; hold dependent promise | hybrid / spec-dialogue |
| R074 | The schema must reject nulls at build time. — Type/schema invariant; no meaningful runtime user action. | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Invariant and proof method | gwt / spec-dialogue |
| R075 | Use “QA reviewer” as the oracle for this must-have criterion. — No observation or adjudication criteria provided. | yes | standard | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Observable outcome and pass/fail boundary | oracle / spec-dialogue |
| R076 | Three reviewers say the provider supports retries, but the contract forbids them. — Three use same outdated blog; fourth has current primary contract. | yes | deep | CHALLENGE | FRAME,EXPAND | No vote on contract fact | voting / spec-dialogue |
| R077 | I own this product; I have changed my mind and now want dark mode. — Prior empirical churn claim is still unsupported; preference itself changed. | yes | standard | FRAME | Unchanged evidence stays unchanged | New intent, not new empirical fact | user-authority / spec-dialogue |
| R078 | Walk the behavior checklist for a static copyright notice. — No input, dependency, mutation, authentication or rate surface; content supplied. | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Exact text and intended audience | matrix / spec-dialogue |
| R079 | Write a specification for an offline-only command-line formatter. — Known problem; newline fidelity and local encoding matter more than network failures. | yes | light | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE | Encoding and destructive overwrite policy | matrix / spec-dialogue |
| R080 | Clarify already confirmed who this is for and why; now settle delivery semantics. — Confirmed instruction supplied with provenance; do not ask same intent question again. | yes | standard | SPECIFY | FRAME,EXPAND,CHALLENGE,SHAPE if direction agreed | Delivery guarantee and failure behavior only | repeat-frame / spec-dialogue |
