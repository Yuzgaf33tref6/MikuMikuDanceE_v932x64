-----------------------------------------------------------------------------------
ikPolish v0.24 対応MikuMikuMobエフェクト定義ファイル
-----------------------------------------------------------------------------------

MikuMikuMobで、ikPolishを対象エフェクトとして選択すると複数のファイルが出力される。
(大量に出力されるので、モブ専用のフォルダに出力することを推奨)

出力pmx を "xxx.pmx" とすると、

xxx.fx
	ikPolish用の PolishMain相当になる。
	Mainタブに割り当てる。(自動で割り当てられる)

mat_xxx.fx
	マテリアル設定用のファイル。Material.fx相当。
	ColorMapRTタブに割り当てる。
	部位によって材質を変えたい場合は、このファイルをコピペして材質値を変更する。

ssao_xxx.fx
	SSAOMapRTタブに割り当てる。
	(黒ベタのキャラの場合、見た目にほとんど変わりないので、
	エフェクトを割り当てず、タブのチェックを外したほうが高速になる)

shadow_xxx.fx
	LightDepthRTタブに割り当てる。
	(黒ベタのキャラの場合、見た目にほとんど変わりないので、
	エフェクトを割り当てず、タブのチェックを外したほうが高速になる)

ikPolishShader.fxsub
	設定ファイル。念のために自分の設定したファイルで上書きする。
	ごく一部の値を参照している。

