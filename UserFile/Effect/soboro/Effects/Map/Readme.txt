﻿
マップエフェクト　Ver.1.0

製作：そぼろ

地図を表示するエフェクトです。
演出や作業の補助にどうぞ。

MMMたぶん対応です。


■使用方法

まずは Map.x か PostMap.x（MMMではPostMap.fx）のどちらかを読み込みます。
そのあと追加でオプションのダミーアクセサリを読み込みます。
詳細は以下に。

□ Map.fx

　マップが表示される正方形の板です。
　通常のアクセサリと同じように操作します。

□ PostMap.fx

　画面の最前面に常に表示されるマップです。
　XとYで位置変更、Siでサイズ変更できます。

□ MapAreaSize.x

　マップの表示領域の大きさを指定するためのダミーアクセサリです。
　Siの値を変えることでマップに表示される領域の大きさを変更することができます。
　Trを小さくすると、カメラ視野内に入っている部分を強調表示するようになります。

□ MapCenter.x

　デフォルトではマップの中心はカメラ位置になりますが、
　MapCenter.xを読み込むとそこがマップ中心になります。
　モデルに取り付けたり、回転させたりも可能です。

□ MapFrame.png

　マップの表示枠とセンターマーカーの描画に使うテクスチャです。
　この画像は自由に差し替えて問題ありませんが、
　地図部分はちゃんと透明にするのを忘れないでください。

□ MapDraw.fxsub

　実際のマップ描画に使用されるシェーダです。
　いくつかこのエフェクト編集によって指定できるパラメータがあります。
　代表的なものを以下に。

・MapAreaSize
・MapAreaDepth

　デフォルトで表示される領域の広さと高さを指定します。

・MAP_TYPE

　高さ表示やワイヤーフレーム表示などが可能です。


■ マップにしか映らないオブジェクト

　アルファを0に、スペキュラのRを0に、スペキュラのGを1に、スペキュラ強度を0に
　指定したオブジェクトは、MMDではアルファ0のため描画されませんが、
　マップ上ではスペキュラのBをアルファの代用として表示されます。
　
　sample1.xを同梱したので参考にしてみてください。


■更新履歴

Ver.1.0
・公開


■利用条件

商用利用、改変、再配布を含むいかなる利用も自由です。
また、作者の許諾も不要です。
ただし、このエフェクトを利用したことによるどのような損害も
責任を負うことはできません。自己責任でご利用ください。

mylist:  http://www.nicovideo.jp/mylist/17392230
twitter: sovoro_mmd

