Scale.fx ver0.0.5
Scale_MMM.fxm ver0.0.5

ただモデルのスケールを変更するだけです。
コントロールモデルのボーン操作･表情設定で全てのパラメータ変更が出来ます。


・使用方法
[MMD･MME版の場合]
(1)PMD,またはアクセサリにScale.fxを適用してください。
    GUIの場合：｢MMEffect｣→｢エフェクト割当｣のメインタブより適用したいオブジェクトにScale.fxを割り当てる.
    ファイル名設定の場合：XXXXX.pmd から XXXXX[Scale.fx].pmd に変更，または Scale.fx を XXXXX.fx に変更してロード。
(2)ScaleControl.pmdをMMDにロードします。
(3)モデル描画順序は適用したオブジェクトの直前にScaleControl.pmdを置く。
(4)ScaleControl.pmdのボーンと表情スライダで以下の制御が可能です。
    ボーン
      ｽｹｰﾙ原点：この座標を中心にスケール変更が行われます。
      ｽｹｰﾙ変更：座標位置がXYZそれぞれ-20〜+20で0.01〜100倍に指数関数的にスケール変更されます。
    表情スライダ
      拡大：XYZ等倍で1〜10倍にスケール変更
      縮小：XYZ等倍で1〜0.1倍にスケール変更

[MikuMikuMoving版の場合]
(1)Scale_MMM.fxmをMMMにロードしてください。
(2)MMMメニューの｢ファイル｣→｢エフェクト割当｣より適用したいモデルを選択して、Scale_MMMを割り当てる.
(3)ScaleControl.pmdをMMMにロードします。あとはMMD･MME版と同じです。


・更新履歴
v0.0.5  2013/07/04   MMEシェーダを新しいバージョン(v0.33以降)仕様にした(PMXの材質モーフ､サブTex等に対応)
                     MikuMikuMoving版の追加
v0.0.4  2011/07/01   スフィアマップ使用材質でα値が正しく描画できない不具合を修正
v0.0.3  2011/01/15   コントロールモデルの追加，コントロールモデルのボーンと表情スライダで制御可に
                     アクセサリにも適用可に
v0.0.2  2010/12/15   MMEv0.2でエラーになる不具合修正，エッジ色をMMD操作で変更可に
v0.0.1  2010/10/27   初回版公開


・免責事項
ご利用・改変・二次配布は自由にやっていただいてかまいません。連絡も不要です。
ただしこれらの行為は全て自己責任でやってください。
このプログラム使用により、いかなる損害が生じた場合でも当方は一切の責任を負いません。


by 針金P
Twitter : @HariganeP



