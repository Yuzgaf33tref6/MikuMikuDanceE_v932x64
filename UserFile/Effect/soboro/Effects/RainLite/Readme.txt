MikuMikuEffect用 降雨エフェクト Ver.1.1

製作：そぼろ

TexSnowLiteをセルフ改造して、雨を降らせるエフェクトにしてみました。
おおむねTexSnowに準じますが、いくつかのパラメータは省いています。

Tr値を0.3ぐらいにすると背景になじんでいい感じ・・・かも。


ビームマンPのLineBillboard.fxを参考にさせていただきました。


●更新履歴

Ver.1.1
・ラインビルボードの方式を見直し、どこから見ても消えなくなりました。


●通常の使用方法
・RainLite.xをMMDで読み込む
・描画順を最後に設定

●注意事項
・アルファブレンドを使用しているので、最後に描画されるよう設定してください。
・頂点シェーダ3.0およびVTFに対応したビデオカードが必要です。
