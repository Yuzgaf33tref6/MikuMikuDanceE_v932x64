水彩っぽく加工するエフェクト

	色味が変わるため、絵によってはかなりおかしくなります。



使い方
	ikWaterColor.xをMMDに放り込む。
	描画順番を調整する。(後のほうがいいかも?)


調整の仕方
	エフェクト内の設定を触る

	アクセサリで設定を変える。
		Si: 歪み度合いを調整可能。負の値をいれると反対方向に歪む。
		Tr: 下地の影響度合いを調整できる。

	MMEのComplexMapタブで、モデル・材質単位で滲み度合いを指定できる。
		（滲みマップ(ENABLE_BLEEDING_MASK)が有効な場合）
		顔とか目とかだけの滲みを抑えたい場合に使用。

		ただし、顔自体を歪ませない指定をしても、顔の隣の背景が歪んだ結果、
		顔の色が背景側にはみ出すことがある。

	歪みテクスチャを変更する。
		赤チャンネルで左右方向、緑チャンネルで上下方向へのズレを指定している。


アイデア？
	モデルのエッジ太さを0にして、エッジ描画エフェクトを使う。
		MMD標準のエッジもエフェクトの加工対象になるためです。
		Croquisなど、エッジを描画するエフェクトをikWaterColorのあとから
		エッジを足すと綺麗にエッジが出ます。

	トーンマップなどの色調補正を掛けるエフェクトを先に使う。

	DoF、被写界深度エフェクトで背景をボカす。



使用、再配布に関して
	エフェクトの利用、改造などについては自由に行ってもらってかまいません、連絡も不要です。

	このエフェクトを使用したことによって起きたすべての損害等について、
	作者及び関係者は一切責任を負わないものとします。


更新履歴

	2015/04/08 Ver 0.01
		初公開

ikeno
twitter: @ikeno_mmd

