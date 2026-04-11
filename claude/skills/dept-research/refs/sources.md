# 一次情報の当て先

「どこを見れば一次情報か」の地図。**記憶で答えず、ここから当たる。**

記載の URL は、このファイルを書いた時点で実際にアクセスして到達を確認したもの(リダイレクトは追跡し最終 URL を記載)。それでも移転・改廃はあるので、**開いて中身を確認してから引用する**。

## 情報源の信頼度の階層

| 階層 | 何か | 扱い |
|---|---|---|
| **S: 一次資料** | 当事者が公式に出した原典。条文、仕様書、公式ドキュメント(バージョン付き)、公式料金ページ、有価証券報告書、統計の原表 | **数字・仕様・価格・要件はここからしか取らない** |
| **A: 当事者による公式解説** | 所管官庁のガイドライン / Q&A / 通達、公式ブログ、リリースノート、マイグレーションガイド、RFC・標準化文書 | 解釈が入るが発行者は当事者。S と食い違ったら S が勝つ |
| **B: 検証可能な第三者** | 手法が公開された実測ベンチマーク、査読論文、複数社の公開導入事例、標準化団体の調査 | **手順が再現可能なものだけ**。「速い」しか書いていないベンチマークは C |
| **C: 二次情報** | 個人ブログ、比較まとめサイト、SNS、ニュース記事、そして**自分(LLM)の記憶** | 「そう主張している人がいる」の証拠にはなるが、**事実の証拠にはならない** |

**運用ルール**

- C で見つけた事実は、S か A で裏を取るまで報告書の本文に書かない。裏が取れなければ「未確認」欄に置く
- **自分の記憶は C。** 特にバージョン番号・価格・制限値・API シグネチャ・法令の要件は、記憶で書いた時点で誤りとして扱う
- 出典は **URL + 参照日 + 版(バージョン / 施行日 / 統計年)** をセットで書く。URL だけの出典は半年で価値を失う
- 一次情報に到達できなかったときは、**到達できなかったと書く。** C の情報を S の顔をさせて書かない

> **アクセスできない ≠ 存在しない。** WebFetch が 403 / 空を返すのは bot 遮断や SPA が原因のことが多い。「取得できなかった」と「存在しない」を報告で混同しない。

---

## ライブラリ・フレームワーク

**最優先は context7 MCP**(`mcp__plugin_context7_context7__resolve-library-id` → `mcp__plugin_context7_context7__query-docs`)。API・設定・移行手順は記憶で答えず、まずここを引く。

context7 に無い / 情報が古い場合は、そのライブラリの**公式ドキュメントとリポジトリ**を直接。見る場所は決まっている:

- **リリースノート / CHANGELOG** — 破壊的変更と非推奨はここにしか書かれていない
- **マイグレーションガイド** — メジャー更新のコストはこの厚さで測れる
- **issue / discussion の検索** — 「壊れたときに情報が出るか」の実測。放置期間はバス係数の代理指標

| 用途 | 当て先 |
|---|---|
| Web 標準・ブラウザ API のリファレンス | https://developer.mozilla.org/ |
| ブラウザ対応状況 | https://caniuse.com/ |
| W3C の標準・草案 | https://www.w3.org/TR/ |
| インターネット標準(RFC) | https://www.rfc-editor.org/ |
| JavaScript 言語仕様(最新ドラフト) | https://tc39.es/ecma262/ |
| クラウドネイティブ領域の製品カタログ | https://landscape.cncf.io/ |

## 依存・脆弱性・サポート期限

| 用途 | 当て先 |
|---|---|
| 依存関係・ライセンス・脆弱性の横断調査 | https://deps.dev/ |
| OSS 脆弱性データベース(横断) | https://osv.dev/ |
| GitHub Advisory Database | https://github.com/advisories |
| CVE の詳細・CVSS | https://nvd.nist.gov/ |
| Snyk の脆弱性 DB | https://security.snyk.io/ |
| 製品の EOL / サポート期限 | https://endoflife.date/ |
| OSS のセキュリティ実践度スコア | https://scorecard.dev/ |
| バンドルサイズの実測 | https://bundlephobia.com/ |
| ディストリ横断のパッケージバージョン比較 | https://repology.org/ |

> EOL とバージョンは**必ず一次(公式のサポートポリシー)で確認する**。上記は当たりを付けるための集約サイトで、最終的な根拠は提供元の公式ページ。

## SaaS の料金・SLA・稼働実績

**まとめサイト・比較記事の料金表は使わない。** 料金は改定が速く、二次情報は高確率で古い。**必ず提供元の公式料金ページを直接開く**(例: https://vercel.com/pricing / https://github.com/pricing / https://www.notion.com/pricing / https://slack.com/intl/ja-jp/pricing)。

見るのは料金表だけではない:

| 調べること | どこを見るか |
|---|---|
| 実際にいくらになるか | 公式の見積もりツール。https://calculator.aws/ / https://cloud.google.com/products/calculator / https://azure.microsoft.com/en-us/pricing/calculator/ |
| SLA の数値と**補償の中身** | 提供元の SLA ページ(例: https://cloud.google.com/terms/sla)。料金ページには書かれていない |
| 過去に実際どれだけ落ちたか | ステータスページの履歴。例: https://health.aws.amazon.com/health/status / https://status.cloud.google.com/ |
| 第三者認証・監査報告 | 提供元のコンプライアンス / トラストページ(例: https://aws.amazon.com/compliance/programs/) |
| 政府調達水準の妥当性 | ISMAP クラウドサービスリスト https://www.ismap.go.jp/csm |

> 料金ページは**アクセス元の国・通貨・ログイン状態で表示が変わる**ことがある。取得した通貨と参照日を必ず記録する。年払い / 月払いの併記にも注意。
>
> AI モデル(Claude / GPT / Gemini 等)の料金・機能は `dept-ai` の領分。ここでは重複して持たない。

## 日本の法令・制度

**階層を意識して当てる。** 法律 → 政令 → 省令 → 告示 → ガイドライン → Q&A の順に規範力が落ちる。どの階層の記述を根拠にしているかを報告に明記する。

| 用途 | 当て先 |
|---|---|
| 現行法令の条文(まずここ) | https://laws.e-gov.go.jp/ |
| 法令データの API 取得 | https://laws.e-gov.go.jp/apitop/ |
| 公布の原典・官報 | https://www.kanpo.go.jp/ |
| 意見募集中 / 結果公示の政省令案 | https://public-comment.e-gov.go.jp/pcm/1050 |
| 裁判例の検索 | https://www.courts.go.jp/app/hanrei_jp/search1 |
| 個人情報保護法のガイドライン・Q&A | https://www.ppc.go.jp/ |
| 労働基準・労働時間・安全衛生 | https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/koyou_roudou/roudoukijun/index.html |
| 厚生労働行政全般 | https://www.mhlw.go.jp/ |
| 税務の一般的な取扱い | https://www.nta.go.jp/taxes/shiraberu/taxanswer/index2.htm |
| 独占禁止法・下請法 | https://www.jftc.go.jp/ |
| 中小企業の支援制度・補助金 | https://www.chusho.meti.go.jp/ |
| デジタル関連の制度・仕様 | https://www.digital.go.jp/ |
| 特許・商標・意匠の検索 | https://www.j-platpat.inpit.go.jp/ |

> 条文を引いたら、**その条文の施行日と、未施行の改正がないか**を必ず確認する。e-Gov 法令検索は版と施行日を表示する。ここを見ずに引用した条文は、正しく見えて古い。
>
> 旧ドメイン `elaws.e-gov.go.jp` は `https://laws.e-gov.go.jp/` へ恒久転送される。書くなら転送先を直接書く。

## 統計・公的データ

| 用途 | 当て先 |
|---|---|
| 政府統計の総合窓口(まずここ) | https://www.e-stat.go.jp/ |
| 統計データの API 取得 | https://www.e-stat.go.jp/api/ |
| 人口・労働力・家計などの原表 | https://www.stat.go.jp/ |
| 地域単位の経済データ | https://resas.go.jp/ |
| 金融・物価・資金循環の時系列 | https://www.stat-search.boj.or.jp/ |
| GDP・景気動向 | https://www.esri.cao.go.jp/ |
| 情報通信分野の統計・白書 | https://www.soumu.go.jp/johotsusintokei/whitepaper/ |
| 産業・商業・IT の統計 | https://www.meti.go.jp/statistics/ |
| 貿易統計 | https://www.customs.go.jp/toukei/info/ |
| 情報セキュリティ・IT 人材 | https://www.ipa.go.jp/ |
| 海外市場・各国ビジネス情報 | https://www.jetro.go.jp/ |
| 国際比較(開発指標) | https://data.worldbank.org/ |
| 国際比較(OECD 加盟国) | https://www.oecd.org/en/data.html |
| 米国の雇用・物価統計 | https://www.bls.gov/ |

> 統計は**白書やニュース記事の引用ではなく原表に当たる**。加工された図表は、定義・対象範囲・調査年が落ちていることが多い。報告には「調査名・調査年・対象範囲」を必ず書く。

## 企業・市場

| 用途 | 当て先 |
|---|---|
| 有価証券報告書・大量保有報告書 | https://disclosure2.edinet-fsa.go.jp/ |
| 上場企業の適時開示(決算短信・提携・買収) | https://www.release.tdnet.info/inbs/I_main_00.html |
| 法人の実在・所在地・法人番号 | https://www.houjin-bangou.nta.go.jp/ |
| 補助金採択・届出などの法人データ | https://info.gbiz.go.jp/ |

競合プロダクトの一次情報は、**その会社の公式サイトそのもの**:料金ページ、リリースノート、公式ブログ、採用ページ(投資領域が読める)、ステータスページ(規模と安定性が読める)。比較まとめサイトは、**候補を洗い出す用途にだけ**使う。

## 二次情報(ブログ・比較サイト・まとめ記事)の扱い方

使うなという意味ではない。**役割を間違えるなという意味。**

- **正しい使い道は「探索」** — 論点の洗い出し、候補の列挙、一次情報のありかを知る、踏まれた地雷を知る
- **やってはいけないのは「根拠」** — 数字・仕様・価格・法令要件の出典として引かない
- **一次情報へのリンクが無い記事は捨てる。** 出典を書かない記事は、その記事自身も出典にならない
- **日付を最初に見る。** 記事の日付、対象バージョン、更新履歴。日付が無い技術記事は使わない
- **利害を見る。** ベンダー自身の比較表は自社が勝つように軸が選ばれている。「軸の選び方」の材料としては有用、「結論」としては無価値
- **同じ主張が複数記事にあっても裏付けにならない。** 出所が同じ 1 つの記事のコピーであることが多い。**独立した出所か**を確認する
- **どうしても二次情報しかないとき**は、報告に「一次情報が確認できず、◯◯(URL・日付)の主張に基づく」と明記する。断定しない

## URL を書くときの規律

このスキル自身にも適用する。

1. **記憶で URL を書かない。** 実際にアクセスして到達を確認してから書く
2. **リダイレクトは追跡し、最終 URL を書く。** 転送元を書くと、転送が止まった日に切れる
3. **確認できなかった URL は書かない。** 「たぶんここ」を書くくらいなら、サイト名だけ書いて URL を省く
4. **深い階層の URL は壊れやすい。** 恒久性が疑わしければ、トップ or 検索ページを書いて「そこから ◯◯ を辿る」と手順で書く
