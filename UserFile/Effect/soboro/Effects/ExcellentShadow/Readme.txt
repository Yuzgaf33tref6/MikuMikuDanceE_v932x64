﻿
超高品質セルフシャドウエフェクト　Ver.1.1

製作：そぼろ

きれいなシャドウを得るためなら、どれだけグラフィックボードを
いじめても構わないという方向けの高品質シャドウエフェクトです。

MMD標準のパースペクティブシャドウマップ、近景用固定シャドウマップ、
遠景用広域固定シャドウマップの3枚を動的にブレンドしつつ、
ポスト処理によってぼかしを入れることでかつてないエクセレントな影を実現しました。


■使用環境

MME0.27以降

SM3.0および浮動小数点テクスチャのミップマップをサポートするグラフィックボード
推奨VRAM：1GB以上


■使用方法

１．ExcellentShadow.xを読み込みます。この時点では何も起こりません。
２．すべてのモデル・アクセサリに full_ES.fx を適用します。
３．モデル・アクセサリのセルフシャドウを有効にします。


ExcellentShadow.x の位置がシャドウマップの中心になります。
また、ExcellentShadow.x のSiによりシャドウマップの大きさが決定されます。

シャドウマップを大きくすればより広い範囲にセルフシャドウを発生させることができますが、
その分細かいシャドウが潰れ、エッジも汚くなります。
遠景、近景でうまく調整してください。
デフォルトの状態でもゲキド街の半分程度をカバーします。

このエフェクトはMMD標準のシャドウも利用するため、
エフェクトオフ時のシャドウにも気を使うとより良い結果が得られます。


ExcellentShadow.x のTrにより影の濃さを調整できます。
Trを小さくすると影が濃くなります。

この効果は標準ではPMDモデルには弱くしか適用されません。
（人物モデルの影が濃くなりすぎるのを防止するためです）
PMDモデルにも適用したい時は full_ES.fx を編集して
PMD_SHADOWPOWERの値を大きくしてください。


アクセサリのX回転によって影のぼかし強度を増減できます。
範囲は-100～100です。
ボーン取り付けの影響は無視されます。


■軽量化

ExcellentShadowCommonSystem.fx を開き、
EXCELLENT_SHADOW_FULL をコメントアウトすると、
クオリティを落とした軽量モードになります。

重すぎてまともに動かない場合は試してみてください。


■シェーダエフェクトのExcellentShadow対応

full.fxベースのシェーダエフェクトは、
比較的簡単にExcellentShadowに対応させることができます。

エフェクトの中身がfull.fxから大幅に変更されていた場合、
この方法では上手くいかないことがあります。
また、頂点変化系、増殖系のエフェクトには適用できません。


・まず、目的のエフェクトを別名保存します。
　末尾に"_ES"などつけると分かりやすくなります。

・エフェクトをエディタで開き、full_ES.fxを参考にしながら、
　以下のように指示された箇所4点をコピペして追加します。


/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// ■ ExcellentShadowシステム　ここから↓

XXXX

// ■ ExcellentShadowシステム　ここまで↑
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////


また、この方法で改造したエフェクトは、ExcellentShadow 未使用時は
MMD通常のシャドウを表示することができます。



■注意事項

・AbsoluteShadowとの互換性はありません
・MMMは非対応です。今後も対応の予定はありません。


■更新履歴

Ver.1.1
・軽量化オプション実装

Ver.1.0
・公開


■利用条件

商用利用、改変、再配布を含むいかなる利用も自由です。
また、作者の許諾も不要です。
ただし、このエフェクトを利用したことによるどのような損害も
責任を負うことはできません。自己責任でご利用ください。

また、このエフェクトについては特に、
動作しないことに対するサポートはいたしません。

mylist:  http://www.nicovideo.jp/mylist/17392230
twitter: sovoro_mmd

