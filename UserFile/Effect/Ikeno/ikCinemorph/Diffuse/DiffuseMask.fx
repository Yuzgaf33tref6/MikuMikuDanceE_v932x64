////////////////////////////////////////////////////////////////////////////////////////////////
// 明るくさせない
////////////////////////////////////////////////////////////////////////////////////////////////

// 通常の色の明るさ。0.0〜1程度
#define LightScale	0.0

// AutoLuminous用の設定
// ALを使用する
//#define ENABLE_AL

//テクスチャ高輝度識別フラグ
// #define TEXTURE_SELECTLIGHT

// ALの強度をどれだけ上げるか
#define AL_Power	0.0

//閾値
float LightThreshold = 0.9;


#include "DiffuseCommon.fxsub"
