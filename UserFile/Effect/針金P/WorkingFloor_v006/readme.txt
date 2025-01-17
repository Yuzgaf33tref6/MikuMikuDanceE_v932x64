WorkingFloor.fx ver0.0.6
WorkingFloor_MMM.fxm ver0.0.6

モデルを複製して地面に対して鏡像描画します。地面に半透明の板ポリを置くことで床に仕事をさせます。


・使用方法
[MMD･MME版の場合]
(1)PMD･PMX,またはアクセサリにWorkingFloor.fxを適用してください。
    GUIの場合｢MMEffect｣→｢エフェクト割当｣のメインタブより適用したいオブジェクトにWorkingFloor.fxを割り当てる.
    ファイル名設定の場合：XXXXX.pmd から XXXXX[WorkingFloor.fx].pmd に変更，または WorkingFloor.fx を XXXXX.fx に変更してロード。
(2)WorkingFloor.fxの先頭パラメータを適宜変更してください。
(3)地面となる半透明アクセはモデルより後に描画設定してください。

[MikuMikuMoving版の場合]
(1)WorkingFloor_MMM.fxmをMMMにロードしてください。
(2)MMMメニューの｢ファイル｣→｢エフェクト割当｣より適用したいモデルを選択して、WorkingFloor_MMMを割り当てる.
(3)必要に応じてWorkingFloor_MMM.fxmの先頭パラメータを適宜変更してください。


・注意点
描画順序の問題で非セルフシャドウ地面影は描画しないようになっています。セルフシャドウ使用時は
非セルフシャドウ地面影はoff設定にしてください。

デフォルトでは鏡像モデルは全て片面描画になっています。α値0.999等で両面描画させている材質がある場合は
PMDEditorで材質のα値を確認してからWorkingFloor.fxの先頭パラメータで両面描画する材質を指定してください。
材質指定方法は以下のように記述します。<MMEffectのREFERENCE.txtより抜粋>
　　"0,3,5"のように、カンマ区切りで番号を列挙することで、複数の番号を指定できる。
　　また、"6-10"などのように、番号をハイフンでつなぐことで、範囲指定ができる。
　　"12-"のように、範囲の開始番号のみを指定した場合は、それ以降の全ての番号が対象となる。

例  初音ミク@ネギ焼き ver2.2.pmd
#define BothSidesMat  "10-21"        // α値0.999等で両面描画している材質リスト


・更新履歴
v0.0.6  2013/07/05   MMEシェーダを新しいバージョン(v0.33以降)仕様にした(PMXの材質モーフ､サブTex等に対応)
                     MikuMikuMoving版の追加
v0.0.5  2011/07/01   スフィアマップ使用材質でα値が正しく描画できない不具合を修正
v0.0.4  2010/12/16   MMEv0.22のエッジ不具合解消に伴い，鏡像モデルのエッジを独自描画からMMD標準シェーダに変更
v0.0.3  2010/12/15   MMEv0.2でエラーになる不具合修正，エッジ色をMMD操作で変更可に
v0.0.2  2010/11/21   鏡像の両面描画材質指定追加，両面描画で鏡像がエッジで塗りつぶされる不具合修正
v0.0.1  2010/11/16   初回版公開


・免責事項
ご利用・改変・二次配布は自由にやっていただいてかまいません。連絡も不要です。
ただしこれらの行為は全て自己責任でやってください。
このプログラム使用により、いかなる損害が生じた場合でも当方は一切の責任を負いません。


by 針金P
Twitter : @HariganeP


