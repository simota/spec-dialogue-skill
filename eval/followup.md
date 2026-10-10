# 後続変更 — 残っていた反例への対応

[README.md](README.md)の「今回変更していないもの」と[results.md](results.md)の`still-ambiguous` 24件のうち、文面で閉じられるものをこの後続変更で扱った。`requests.md`・`predictions.md`・`results.md`は依頼者へ渡した成果物とbyte単位で同じまま残し、判定を書き換えない。下表はその上に重ねる後続判定である。

評価方法は前回と同じく、同一担当者による非盲検のsource-level replayに、別passの敵対的レビュー（作成文脈を持たないsubagent）を1回加えたもの。agentを実際に80回動かした試験ではなく、anchoring・離脱率・誤読率は測定していない。

| ID | 前回 | 今回 | 対応した規則 |
|---|---|---|---|
| R001, R044 | still-ambiguous | fixed | 成果物が未指定で、skill名の指定もspecの依頼もなければ、最初に成果物を1問で確認（SKILL.md Trigger Guidance） |
| R014, R043 | still-ambiguous | fixed | 決定済み事項の転記は対象外（description・Trigger Guidance） |
| R017, R051 | still-ambiguous | fixed | 出荷までのbuild lifecycleは対象外。仕様段階でこのskillを呼ぶのは可 |
| R021 | still-ambiguous | fixed | locked specの「どう作るか」は対象外 |
| R002 | still-ambiguous | fixed (routing) | 形の決まったコード変更はdescriptionで外す。light自体の儀式量は変更していない |
| R007, R040 | still-ambiguous | fixed | build pathに`spec-only`を追加。依頼文で述べた選択は再質問しない |
| R046, R047 | still-ambiguous | fixed | EXPANDは選択肢を水増ししない。制約のsourceを示し、中立に質問（D4） |
| R072 | still-ambiguous | fixed | 設定で両方を共存させるのは1つの方向として正当 |
| R073 | still-ambiguous | fixed | prototypeでしか決まらない選択は、実験自体を仕様化するかblocking OQ |
| R063 | still-ambiguous | fixed | 未構築の環境は確認可能なcapabilityで書き、bindingは`TBD(owner)`の`before-ship`（T10） |
| R071 | still-ambiguous | fixed | D6: userが保護するterm・確認済みGlossary termは原文のまま |
| R074 | still-ambiguous | fixed | invariantは`When`にcheck eventを書き、TCで「全件」をどう網羅するか示す |
| R075 | still-ambiguous | fixed | oracleは人名だけでなく、観測対象とpass/fail規則を持つ |
| R076 | still-ambiguous | fixed | 人数ではなく検証済みevidenceで判定。同じsourceに基づくskepticは1と数える |
| R077 | still-ambiguous | fixed | ownerの意図変更は事実の争いではなく新しい決定。旧来の経験的主張の裏付けは変わらず、必須controlも外せない |
| R078, R079 | still-ambiguous | fixed | Behavior matrixの6分類は最低限。理由が共通なら一括でstrike。domain固有の行を追加 |
| R080 | still-ambiguous | fixed | Entry point: 出典のある決定はFRAMEの1 checkpointで1件ずつratify。未決の最初のphaseから開始 |

前回の`fixed` 34件・`unchanged-correct` 22件について、今回のレビューでregressionは見つからなかった。発見しなかったという意味であり、ないことの保証ではない。

あわせて行った変更: scopeの網羅性は「対話で挙がった項目」に対するものへ限定。60% confidence閾値は「提示できるevidence」に置換。README・siteのagy install pathを`~/.gemini/antigravity-cli/skills`へ修正し、`make check`がinstall表と`make link`の書込先との一致を検査するようにした。`make test`は46 passed / 0 failed。
