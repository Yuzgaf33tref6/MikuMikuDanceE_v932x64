ikSplats

テクスチャパターンで塗りつぶすエフェクト


■ 使い方
1. Splats.x をMMDに入れる。
2. MMEのエフェクト割り当てを開き、SplatSizeMapで各材質に適切なサイズを指定する。
　背景などディテールが潰れていいものは大きめ、顔など詳細が残って欲しい部分は弱やマスクを指定する。
3. Siでパターンのサイズを調整する。


■ 設定方法
・MMDのアクセサリ操作で調整。
Si：パターンのサイズを変更する。0.5〜4.0程度。
Tr：パターン数を変更する。0.0 〜 1.0。 ※ 透明度は変更されません。

・ikSplats.fx の中の設定を弄る。(主な項目のみ)
TEX_FileName：使用するパターンを指定する。
SYNTH_Y_ONLY：1にすると明暗だけを置き換える。0だと色全体を置き換える。
ENABLE_MOVEMENT：パターンを時間で変化させるかどうか。

・パターンが暗くなる不具合が出る人向けの設定。
ENABLE_FADE：0にすると色の変化を即座に反映するようになる。動画ではチラつきの原因になる。静止画では0でも1でも関係ない。
ENABLE_PS_COLOR_FETCH：1にするとパターンの色の取得方法が変わる。多少遅くなる。これで直るか不明。ENABLE_FADEを0にしても直らない or ENABLE_FADEを1のままにしたい場合に使ってみる。


■ 免責その他
・エフェクトの利用、改造などについては自由に行ってもらってかまいません、連絡も不要です。
・このエフェクトを使用したことによって起きたすべての損害等について、作者及び関係者は一切責任を負わないものとします。


■ 更新履歴

2016/04/17　ver.0.03　色がおかしくなるバグの修正
2016/06/11　ver.0.02　色がおかしくなるバグの対策
2015/06/08　ver.0.01　初公開


ikeno
twitter: @ikeno_mmd
