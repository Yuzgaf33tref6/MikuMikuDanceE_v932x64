トゥーンっぽいメカシェーダ
作：ビームマンP

使い方

好きなモデルにメカトゥーン.fxを割り当てる
かっこいい？




設定は基本的にfxファイルをメモ帳などで編集します

・陰影がぱっきりしすぎていて気に入らない時
//ハーフランバート係数 0でランバート準拠 1でハーフランバート準拠
float HalfLambParam = 0.5;
この部分の数字を増やします

・エッジが目立ちすぎる時
//ベベルの広さ
float BevelParam = 1;
//ベベル強さ
float BevelPow = 4;
この部分で広さや強さを減らします

・そのほか
とりあえずfx開いてみよう、な！