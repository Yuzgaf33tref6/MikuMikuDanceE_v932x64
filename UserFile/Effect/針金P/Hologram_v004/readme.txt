Hologram.fx ver0.0.4

モデルのホログラム表現を行うエフェクトです。


・使用方法
(1)Hologram.xをMMDにロードします。MMMではHologram.fxを直接ロードします。
(2)以下のどちらかの方法でエフェクトファイルファイルをそれぞれ設定します。

    �@GUI設定の場合
      ｢MMEffect｣→｢エフェクト割当｣の適用したいオブジェクトを選択して、
        Main          ：Hologram_Object.fxを適用する。MMMではHologram_Object_MMM.fxmを直接ロードして適用します。
        HologramRT    ：標準描画(解除ボタンを押す)→ここで別のシェーダ系エフェクトを適用することも出来ます。
        MaskHologramRT：Hologram_Mask1.fxを適用。MMMではHologram_Mask1_MMM.fxmをロードして適用します。

    �AHologram.fxの先頭パラメータで設定する場合
      Hologram.fxの先頭にある所定の箇所にモデルファイル名を記述。最大10体まで定義可能

      ｢MMEffect｣→｢エフェクト割当｣のメインタブよりHologram_Object.fを適用する。
      MMMではHologram_Object_MMM.fxmを直接ロードして適用します。

(3)Hologram.fxの先頭パラメータを適宜変更してください。
(4)MMDのアクセサリパラメータで以下の変更を行いキーフレーム登録してください。
    Si：(0〜1)フェードの進行度，フェードインは0→1，フェードアウトは1→0
    Tr：モデルの透過度
    X ：フェード開始相対高さ(Hologram.fxの先頭パラメータ＋この値が実際の指定高さになる)
    Y ：フェード終了相対高さ(Hologram.fxの先頭パラメータ＋この値が実際の指定高さになる)
      デフォルトでは下側からフェードで透明になる。開始･終了高さを入れ替える(例:X=20,Y=-20)と上側からのフェードになる。
    Z : ホログラムの透過度,0:全ホログラム化,1:元モデル化(スムーズには切り替えれない)
    影：offは発光色描画、onにすると発光色とモデル色の平均色で描画(MMEのみ,MMMではUIパラメータで設定)
    MMMではエフェクトプロパティに追加したUIコントロールより変更が可能です。
(5)Hologram.xの描画順序は出来るだけ最後の方に設定してください。


・注意点
ホログラム化したモデルにはセルフシャドウ描画が行われます。その際,背景モデルにもホログラム化モデルの
影が落ちることになります。影を消したい場合はホログラム化モデルのセルフシャドウをOFFにしてください。


・更新履歴
・更新履歴
v0.0.4  2013/7/01   先頭パラメータによるモデル設定方法の簡素化、内部コードの整理
                    ノイズパターンテクスチャの種類追加
                    MikuMikuMovingの対応
v0.0.3  2012/9/10   x64版の対応、影on/offで発光色の切り替え追加
v0.0.2  2011/10/12  グラボによって動作しなくなる不具合の修正
v0.0.1  2011/10/9   初回版公開


・免責事項
ご利用はすべて自己責任でお願いします。


by 針金P


