
ikOverray


■ 概要

アニメによくある? 光を表現するウソグラデを描画するエフェクト。


■ 使用方法

1. MMDのアクセサリに、"ikOverray.x"を追加する。
2. ikOverrayController.pmx を追加する。
3. ikOverrayController.pmxの表情モーフで適当に設定する。


■ パラメータ

ライト色指定
　0:MMD標準のライトの色を使うか、1:指定した色を使うかを指定。
　0.5の場合は、両方の色の中間値を使う。

ライト色1R-,G-,B-
　ライト色指定が有効な場合の光源側の色。
　0だと明るく、1だと暗くなるためにマイナスが付いている。
　赤なら、R-,G-,B-をそれぞれ、0,1,1と設定する。

ライト色2R-,G-,B-
　ライト色指定が有効な場合の光源と反対側の色。
　ライト色指定が無効な場合は、ライト色になる。

　夕日などを表現する場合に、ライト色1を黄色、ライト色2を赤に設定するような
　使用方法を想定している。



ライト方向指定
　0:MMD標準のライトの方向を利用する。
　1:コントローラの方向をライト方向とみなす。
　1の場合、カメラを回転してもグラデの方向は変わらない。
　→ .fxファイル内の設定で変更可能。

方向感度
　ライト方向とエフェクト量の関連付け。
　0: ライト方向に合うほどエフェクトが強くなる。
　1: 方向と無関係にエフェクトが出る。

　霧、霞などで全体的にエフェクトの影響を出したいときに、1側に寄せる。

グラデタイプ
　グラデーションの形状を指定。

　0.00: 平行グラデ、
　0.25: 円形グラデ、
　0.50: 球状グラデ



デプス感度
　0:デプスの影響を受けない。1:デプスの影響を受ける。
　1に近いほど、手前にあるものはエフェクトの影響が薄くなる。

デプス幅
　デプスの影響する距離を調整する。デプス感度が0の場合は無効。
　0:手前から奥に行くに従って、徐々にエフェクトの影響が強くなる。
　1:デプスによる変化の幅が狭くなり、手前からすぐにエフェクトの影響が強くなる。

　手前にいるキャラと奥にいるキャラでエフェクトの係り具合を調整したい場合用。



ライト強度
　ライトの強さを指定。0:弱い〜1:強い。

ライト幅
　ライトのグラデーションの幅を指定。0:長い〜1:短い。

透明度
　エフェクト全体の係り具合を調整する。
　0:100%適用 〜 1:エフェクトオフ

　アクセサリのTrでも設定可能。

合成モード
　エフェクトを合成するモード

　0.00: 加算：光を足しこむ
　0.25: 乗算：暗くなる。暗雲などに使えるかも?
　0.50: オーバーレイ：明るいときは足し、暗いときは乗算
　0.75: 塗りつぶし。フォグなどに使う。



テストモード
　1でテストモード有効。

　ライトが当たる部分は青、
　ライトの影響力が下がるほど緑に近づく。
　ライトが影響しない部分はグレーであらわされる。



■ 使用、再配布に関して

エフェクトの利用、改造などについては自由に行ってもらってかまいません、連絡も不要です。
このエフェクトを使用したことによって起きたすべての損害等について、作者及び関係者は一切責任を負わないものとします。



■ 更新履歴

2015/11/03 Ver.0.03
　　コントローラー対応

2015/01/04 Ver.0.02
　　細かい修正と機能追加
　　・合成モードの追加
　　・ガンマ補正モードを追加
　　・テストモードの追加
　　・Trの扱いをエフェクト強度指定に変更した。

2014/09/13 Ver.0.01
　　初公開

ikeno
Twitter: @ikeno_mmd
