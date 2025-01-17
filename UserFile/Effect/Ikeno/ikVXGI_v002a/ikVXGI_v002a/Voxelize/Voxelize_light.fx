//=============================================================================
// ボクセル化用のデータ出力。実体のないライトとして扱う。

//-------------------------------------
// AutoLuminous用の設定

// ALを使用する
//#define ENABLE_AL

//テクスチャ高輝度識別フラグ
// #define TEXTURE_SELECTLIGHT

// ALの強度をどれだけ上げるか
#define AL_Power	4.0

//閾値
float LightThreshold = 0.9;
//-------------------------------------

// 強制的に明るくする(実体のあるライト扱いする)
// #define FORCE_EMISSIVE

// 強制的に加算半透明とみなす(実体のないライト扱いする)
#define FORCE_LIGHT

//-------------------------------------
#include "Voxelize_common.fxsub"
