ActiveDistortion.fx(DistWind)

つむじ風のようなの空間歪みエフェクトです。


・使用方法(MMEの場合)
(1)ActiveDistortion.xをMMDにロードしてください。
(2)ActiveDistortion.xの描画順序は出来るだけ最後の方に設定してください。
他の歪みエフェクトでActiveDistortionをすでに使用している場合は上の処理は不要です。

(3)DistWind.xをMMDにロードしてください。
(4)AD_Wind.fxの先頭パラメータを適宜変更してください。
(5)DistWind.xのアクセサリパラメータで以下の変更が可能です。
    Si：風の歪み範囲スケール変更
    Tr：風の歪みの強さ

以下全歪みエフェクト共通の処理
(6)ActiveDistortion.fxの先頭パラメータを適宜変更してください。
(7)ActiveDistortion.xのアクセサリパラメータで以下の変更が可能です。
    Si：歪みのぼかし度(大きくすると歪み方がマイルドになります)
    Tr：歪みの強度(最大値をActiveDistortion.fxの先頭パラメータで決めてここで調整)


・使用方法(MMMの場合)
(1)ActiveDistortion.fxをMMMにロードしてください。
(2)ActiveDistortion.xの描画順序は出来るだけ最後の方に設定してください。
他の歪みエフェクトでActiveDistortionをすでに使用している場合は上の処理は不要です。

(3)DistWind.xとAD_Wind.fxをMMMにロードします。メインのエフェクト割り当てでDistWind.xを描画無しに、
   ActiveDistortionのオフスクリーンタブDistortionRTよりDistWind.xにAD_Wind.fxを適用してください。
(4)AD_Wind.fxの先頭パラメータを適宜変更してください。
   またエフェクトプロパティに追加したUIコントロールより変更が可能です。
(5)DistWind.xのアクセサリパラメータで以下の変更が可能です。
    拡大：風の歪み範囲スケール変更
    アルファ：風の歪みの強さ

以下全歪みエフェクト共通の処理
(6)ActiveDistortion.fxの先頭パラメータを適宜変更してください。
(7)フェクトプロパティに追加したUIコントロールよりパラメータ変更が可能です。


・時間コントロールの方法ついて
同梱のTimeControl.xを用いると風移動に対する時間の流れを遅くしたり、停止させたりできます。
スローモーションの演出や、静止画の出力などに便利です。
(1)OptionフォルダにあるTimeControl.xをMMD/MMMにロードしてください。アクセ自体は表示されません。
(2)MMMではTimeControl.xの描画順を必ずAD_Wind.fxよりも前になるようにして下さい。
(2)TimeControl.xのアクセサリパラメータで以下の変更が可能です。
    Si：0にするとフレームを移動させた時だけ時間が流れます。静止画出力の時にご利用下さい。
    Tr：時間の進行度、0にすると停止します。
  ※モニターより大きいサイズでの出力はうまく行かない場合があります。



・免責事項
ご利用・改変・二次配布は自由にやっていただいてかまいません。連絡も不要です。
ただしこれらの行為は全て自己責任でやってください。
このプログラム使用により、いかなる損害が生じた場合でも当方は一切の責任を負いません。


by 針金P
Twitter : @HariganeP


