HgPointLight.fx v0.0.2

独自の点光源エフェクトです。


・動作環境
SM3.0対応グラフィックボードが必須になります。
MMEv0.37, MMEv0.37x64で動作確認を行っています。旧バージョンでは動作しない可能性があります。


・基本的な使用方法
(1)HgPointLight.pmxをMMDにロードしてください。
   MMMではHgPointLight.fxとHgPointLight.pmxを両方ロード、描画順を必ずHgPointLight.pmx→HgPointLight.fxとなるようにして下さい。
(2)HgPointLight.pmx に パラメータ初期化.vmd をロードして表情バーの位置を初期化します。
   (MMDでは一度フレーム移動しないと表情バーの位置が変化しません)
(3)HgPointLight.pmxのボーン・表情バーのそれぞれの項目で以下の制御が可能です(MMMもこれで調整)。
   [ボーン]
     光源位置：ボーン座標がライトの光源位置になります。
   [表情バー]
     目  ：光量 → 光源の明るさ調整
     ﾘｯﾌﾟ：照射距離 → 光の届く範囲の調整
     まゆ：赤色,緑色,青色 → 光源の色(RGBで調整)
     その他：散乱光 → 光の当たっていない部位の明るさ調整
             影ぼかし,影濃度 → セルフシャドウの調整
(4)HgPointLight.fxの先頭パラメータを必要に応じて適宜変更して下さい。
(5)HgPointLight.pmx(MMMはHgPointLight.fxも)は複数ロードしてそれぞれ個別の設定が可能です。


・セルフシャドウなし版について
セルフシャドウ描画が必要ない場合は｢セルフシャドウなし｣フォルダにあるエフェクト一式を使用した方が動作が軽くなります。
操作方法はセルフシャドウあり版と同じです。


・アクセサリ版について
MMDの描画順序の関係でどうしてもアクセサリの描画順にしなければならない時は｢MMEアクセ版｣フォルダ内のエフェクト一式を使用します。
MMMでは描画順をモデルとアクセ共に自由に変更出来るので、こちらを使うメリットがなく対応はしません。
   基本的な使用方法
   (1) HgPointLight.x をMMDにロードしてください。
   (2) HgPointLight.x のアクセサリパラメータで以下の制御が可能です。
        X,Y,Z : 光源位置（ボーンにアサインしてもOK）
        Rx,Ry,Ry : 光源の色(RGGで調整)
        Si : 光源の明るさ調整
   (3) その他のパラメータについては HgPointLight.fx, HgPL_Object.fxsub の先頭パラメータで対応して下さい。


・床影対策について
面積が大きいポリゴンを含むモデルではセルフシャドウが正常に描画されない場合があります。
床面でセルフシャドウが先細って消えてしまう様な場合は｢おまけ\床影対策｣フォルダにある
FloorAssist.x をMMDにロードすると直ります。


・Lat式モデルの対応について
このエフェクトではPMD・PMXモデルについてもライティング処理としてフォンシェードを採用しているため
Lat式モデルに適用するとフェイス部がとんでもない描画になってしまいます(Lat式モデルのフェイス部は特殊なデータ構造で
MMDのトーンシェードにしか対応していないため)。
そこで特別措置として｢おまけ\Lat式モデル対応｣フォルダにあるエフェクトを適用することでこの問題を回避出来ます。
   使用方法
   (1)｢おまけ\Lat式モデル対応｣フォルダにある中で使用条件に合うフォルダ内のHgPL_ObjectLat.fxsub(MMMではHgPL_ObjectLatMMM.fxm)の
      先頭パラメータで、Lat式モデルのフェイス材質番号リストを記述します。
      デフォルトでは Lat式ミクVer2.31_Normal.pmd に合わせているので使用モデルによって材質を調べて書き換える必要があります。
   (2)HgPL_ObjectLat.fxsub(MMMではHgPL_ObjectLatMMM.fxm)をオフスクリーンタブ｢HgPL_DrawRT｣にあるLat式モデルを選択して適用します。


・その他
(1)｢おまけ\BlackOut｣フォルダにあるBlackOut.x(MMMではBlackOut.fx)をロードすると、画面が暗転するので
   ライティングの調整がしやすくなります。Trで暗転度を変更出来ます。
   使用の際には必ずBlackOut.xの描画順を先頭にして下さい。
(2)セルフシャドウあり版では条件によってモデル輪郭部にちらつきが発生することがあります。
   その際にはMLAA(自作)やo_DLAA(おたもん氏)の併用をオススメします。


・更新履歴
v0.0.2  2014/04/11  MMM版でセルフ影描画におけるのエッジ処理の誤りを修正
v0.0.1  2014/04/7   初回版公開


・免責事項
ご利用・改変・二次配布は自由にやっていただいてかまいません。連絡も不要です。
ただしこれらの行為は全て自己責任でやってください。
このプログラム使用により、いかなる損害が生じた場合でも当方は一切の責任を負いません。


by 針金P
Twitter : @HariganeP


