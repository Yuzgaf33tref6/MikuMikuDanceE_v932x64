//-----------------------------------------------------------------------------
// 汎用のプリセット。AL対応版。

// パラメータ宣言

//----------------------------------------------------------
// AutoLuminous対応

#define ENABLE_AL

//テクスチャ高輝度識別フラグ
//#define TEXTURE_SELECTLIGHT

//テクスチャ高輝度識別閾値
float LightThreshold = 0.9;

// AutoLuminous対策。かってに発光しないように明るい部分をカットする。
// #define DISABLE_HDR

//----------------------------------------------------------
// SSS用の設定

// 逆光からの光で明るくする(カーテンや葉っぱなどに使う)
//#define ENABLE_BACKLIGHT

// SSS効果を有効にするか。
// #define ENABLE_SSS

// 表層：表面の色
const float3 TopCol = float3(1.0,1.0,1.0);	// 色
const float TopScale = 2.0;					// 視線との角度差に反応する度合い。
const float TopBias = 0.01;					// 正面でどの程度影響を与えるか
const float TopIntensity = 0.0;				// 全体影響度
// 深層：内部の色
const float3 BottomCol = float3(1.0, 1.0, 1.0);	// 色
const float BottomScale = 0.4;			// 視線との角度差に反応する度合い。
const float BottomBias = 0.2;			// 正面でどの程度影響を与えるか
const float BottomIntensity = 0.0;			// 全体影響度


//----------------------------------------------------------
//

#define ToonColor_Scale			0.5			// トゥーン色を強調する度合い。(0.0〜1.0)

// 第二スペキュラ
// 車のコート層とボディ本体、皮膚と汗などのように複数のハイライトがある場合用
const float SecondSpecularSmooth =	 0.4;		// 1に近づくほどスペキュラが鋭くなる。(0〜1)
const float SecondSpecularIntensity = 0.0;		// スペキュラの強度。0でオフ。1で等倍。(0〜)

// PMXEditorの環境色をライトの強さの影響を受けるようにする。
// #define EMMISIVE_AS_AMBIENT
#define IGNORE_EMISSIVE			// 環境色を無効にする。

// スフィアマップ無効
// スフィアマップによる偽ハイライトが不自然に見える場合に無効化する。
// NCHL用のモデルを使う場合も、スフィアマップを無効にする。
//#define IGNORE_SPHERE

// スフィアマップの強度
float3 SphereScale = float3(1.0, 1.0, 1.0) * 0.25;

// スペキュラに応じて不透明度を上げる。
// 有効にすると、ガラスなどに映るハイライトがより強く出る。
// #define ENABLE_SPECULAR_ALPHA

//----------------------------------------------------------

// テスト用：色を無視する。
//#define DISABLE_COLOR

//----------------------------------------------------------
// 共通処理の読み込み
#include "PolishMain_common.fxsub"
