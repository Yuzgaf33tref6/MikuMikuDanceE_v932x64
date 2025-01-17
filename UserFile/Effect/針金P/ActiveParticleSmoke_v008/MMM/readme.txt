MikuMikuMoving対応版

ActiveParticleSmoke_MMM.fxm ver0.0.8

オブジェクトの移動に応じて煙が尾を引きます．納豆ミサイルっぽい効果が出せます．
オブジェクトの移動量に応じて放出される粒子の数と放出位置が調整されるので,オブジェクトを速く動かしても煙の
尾が途切れにくくなっています．


・基本的な使用方法
(1)ActiveParticleSmoke_MMM.fxmをMMMにロードしてください．
(2)描画順序はできるだけ後の方にしてください．
(3)ActiveParticleSmoke_MMM.xを動かすと,動いた軌道上に煙の尾が描画されます。
(4)必要に応じてfxmファイルの先頭パラメータを変更してください．
(5)MMMのエフェクトプロパティで以下の変更が可能です。
    拡大    ：粒子の放出量
    アルファ：粒子の透過度
    その他UIアノテーションより追加したパラメータ変更が可能です。


・追加粒子描画について
ActiveParticleSmoke_MMM.fxmの先頭パラメータ UNIT_COUNT0 を1以上にするとオブジェクト粒子発生口にメインの煙描画とは別に
別系統の煙を描画することが出来ます。粒子発生直後の途切れをカバーしたり、ミサイル噴射口の閃光等に利用出来ます。


・接地表示方法について
エフェクトで作成される煙は他のモデルに接触すると、粒子が表示されているボードとモデルの交差による切れ目が
不自然な筋模様なって目立ってしまいます。同梱のSmoothControl.xを用いるとこの切れ目を目立たなくすることが
出来るため、地を這わせるような煙の演出に有効です。
(1)OptionフォルダにあるSmoothControl.xをMMMにロードしてください。地面に橙色の板ポリが表示されます。
(2)SmoothControl.xの描画順を必ずActiveParticleSmoke_MMM.fxmよりも前になるようにして下さい。
(3)このアクセの裏側域では煙は非表示になります。また接地面で表示がスムージングされ切れ目が目立たなくなります。
(4)SmoothControl.xのアクセサリパラメータで接地面の位置・角度を調整出来ます。また、｢拡大｣でスムージング幅を調整できます。
(5)調整がすんだらSmoothControl.xをアルファ=0で非表示にして使用します。


・背景移動演出時の利用方法ついて
オブジェクトの動きを表現する場合、直接オブジェクトを動かす以外に、背景の方を移動させてオブジェクトが
動いているように見せるような演出がよく使われます。
同梱のBackgroundControl.xを用いるとオブジェクトを動かさなくても、背景の動きに連動して煙を放出させることが出来ます。
(1)OptionフォルダにあるBackgroundControl.xをMMMにロードしてください。アクセ自体は表示されません。
(2)BackgroundControl.xの描画順を必ずActiveParticleSmoke_MMM.fxmよりも前になるようにして下さい。
(3)BackgroundControl.xを動かすと粒子の動きはアクセの位置・角度を基準にした座標系に切り替わり、
   オブジェクトとの相対的な位置関係でオブジェクトの移動量を計算して煙を放出します。


・時間コントロールの方法ついて
同梱のTimeControl.xを用いると粒子の運動に対する時間の流れを遅くしたり、停止させたりできます。
スローモーションの演出や、静止画の出力などに便利です。
(1)OptionフォルダにあるTimeControl.xをMMMにロードしてください。アクセ自体は表示されません。
(2)TimeControl.xの描画順を必ずActiveParticleSmoke_MMM.fxmよりも前になるようにして下さい。
(3)TimeControl.xのアクセサリパラメータで以下の変更が可能です。
    拡大    ：0.01以下にするとフレームを移動させた時だけ時間が流れます。静止画出力の時にご利用下さい。
    アルファ：時間の進行度、0にすると停止します。
  ※モニターより大きいサイズでの出力はうまく行かない場合があります。



・注意点
一度に描画できる最大粒子数はfxmファイルの先頭パラメータで変更できます。設定した数以上の粒子を発生させるような
状況になると発生中の粒子が消失するまで新たな粒子を放出しなくなります。

※このエフェクトファイルをMMMで使用するにはVTF(Vertex Texture Fetch)対応のSM3.0グラフィックボードが必須になります。

※このエフェクトはMME仕様のエフェクトをMikuMikuMoving向けに改変したものです。MME版はMMMでも一応動きますが、
ここではUIアノテーションの追加や動的パース,3照明の対応などMMM専用エフェクトとして最適化しています。


・更新履歴
v0.0.8  2014/5/20   時間コントロールの制御アクセTimeControl.x追加
                    内部コードの整理
v0.0.7  2013/11/28  MMD照明連動をしない時のエラー修正(MME版のみ)
v0.0.6  2013/6/22   追加粒子描画、シャドウマップ描画(MME版のみ)の追加
                    一度に描画できる粒子の数をfxファイルの先頭パラメータで変更可能に、事実上
                    無制限に粒子を発生させられるようにした(重くなるけど)、粒子数は1024の倍数で指定
                    この改変でActiveParticleSmokeHG.fxはActiveParticleSmoke.fxと統合
                    一時的に粒子が途切れる問題を修正、粒子発生・消失アルゴリズムの改良
                    粒子初期パラメータ・乱数テクスチャをPNGからPFMに変更
                    MikuMikuMoving版の追加
v0.0.5  2012/12/8   BackgroundControl.x追加、背景を移動させてオブジェクトが動いているように
                    見せる演出でも使えるようにした
v0.0.4  2012/9/10   x64版の対応、パラメータ更新時に表示がおかしくなる(同時に重くなる)バグ修正
                    接地表示用の制御アクセSmoothControl.x追加
                    ノーマルマップとMMDの照明操作の連動を追加、初期噴射設定追加
v0.0.3  2011/11/20  粒子発生･挙動アルゴリズムの改良,発生位置のムラを軽減
                    相対速度設定を廃止して重力設定,流体場設定追加
v0.0.2  2011/10/2   相対速度設定(止まっていても粒子放出可)追加
v0.0.1  2011/9/12   初回版公開


・免責事項
ご利用・改変・二次配布は自由にやっていただいてかまいません。連絡も不要です。
ただしこれらの行為は全て自己責任でやってください。
このプログラム使用により、いかなる損害が生じた場合でも当方は一切の責任を負いません。


by 針金P
Twitter : @HariganeP


