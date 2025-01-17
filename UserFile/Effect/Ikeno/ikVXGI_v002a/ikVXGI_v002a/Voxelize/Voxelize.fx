//=============================================================================
// ボクセル化用のデータ出力。一般用

//-------------------------------------
// AutoLuminous用の設定

// ALを使用する
#define ENABLE_AL

//テクスチャ高輝度識別フラグ
// #define TEXTURE_SELECTLIGHT

// ALの強度をどれだけ上げるか
#define AL_Power	4.0

//閾値
float LightThreshold = 0.9;
//-------------------------------------

// 強制的に明るくする
// #define FORCE_EMISSIVE


//-------------------------------------
#include "Voxelize_common.fxsub"
