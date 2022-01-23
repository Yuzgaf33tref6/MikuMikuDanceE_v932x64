////////////////////////////////////////////////////////////////////////////////////////////////
//
//  VolumeShadow_Header.fxh : VolumeShadow �e�����ɕK�v�Ȋ�{�p�����[�^��`�w�b�_�t�@�C��
//  �����̃p�����[�^�𑼂̃G�t�F�N�g�t�@�C���� #include ���Ďg�p���܂��B
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ����p�����[�^
bool VolumeShadow_Valid  : CONTROLOBJECT < string name = "VolumeShadow.x"; >;
float VolumeShadow_AcsSi : CONTROLOBJECT < string name = "VolumeShadow.x"; string item = "Si"; >;
float VolumeShadow_Levels  : CONTROLOBJECT < string name = "VolumeShadow.x"; string item = "Tr"; >;
float VolumeShadow_ObjTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float VolumeShadow_DensityUp   : CONTROLOBJECT < string name = "(self)"; string item = "ShadowDen+"; >;
float VolumeShadow_DensityDown : CONTROLOBJECT < string name = "(self)"; string item = "ShadowDen-"; >;

// �e�Z�x
static float VolumeShadow_Density = max((VolumeShadow_AcsSi*0.1f + 5.0f*VolumeShadow_DensityUp)*(1.0f - VolumeShadow_DensityDown), 0.0f);

// �V���h�E�{�����[���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
shared texture2D VolumeShadow_VolumeMap : RENDERCOLORTARGET;
sampler2D VolumeShadow_VolumeMapSamp = sampler_state {
    texture = <VolumeShadow_VolumeMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �X�N���[���T�C�Y
float2 VolumeShadow_ViewportSize : VIEWPORTPIXELSIZE;
static float2 VolumeShadow_ViewportOffset = (float2(0.5,0.5)/VolumeShadow_ViewportSize);

// �Z���t�V���h�E�̎Օ��������߂�
float VolumeShadow_GetSelfShadowRate(float4 PPos)
{
    // �X�N���[���̍��W
    float2 texCoord = float2( ( PPos.x/PPos.w + 1.0f ) * 0.5f,
                              1.0f - ( PPos.y/PPos.w + 1.0f ) * 0.5f ) + VolumeShadow_ViewportOffset;

    // �Օ���
    float comp = 1.0f - tex2Dlod( VolumeShadow_VolumeMapSamp, float4(texCoord, 0, 1.0f-VolumeShadow_Levels) ).r;

    return (1.0f-(1.0f-comp) * min(VolumeShadow_Density, 1.0f));
}


struct VolumeShadow_COLOR {
    float4 Color;        // �I�u�W�F�N�g�F
    float4 ShadowColor;  // �e�F
};


// �e�F�ɔZ�x����������
VolumeShadow_COLOR VolumeShadow_GetShadowDensity(float4 Color, float4 ShadowColor, bool useToon, float LightNormal)
{
    VolumeShadow_COLOR Out;
    Out.Color = Color;
    Out.ShadowColor = ShadowColor;

    if( !useToon || length(Color.rgb-ShadowColor.rgb) > 0.01f ){
        float e = max(VolumeShadow_Density, 1.0f);
        float s = 1.0f - 0.3f * smoothstep(4.0f, 6.0f, e);
        Out.ShadowColor = saturate(float4(pow(max(ShadowColor.rgb*s, float3(0.001f, 0.001f, 0.001f)), e), ShadowColor.a));
    }
    if( !useToon ){
        float e = lerp( max(VolumeShadow_Density, 1.0f), 1.0f, smoothstep(0.0f, 0.4f, LightNormal) );
        float s = 1.0f - 0.3f * smoothstep(4.0f, 6.0f, e);
        Out.Color = saturate(float4(pow(max(Color.rgb*s, float3(0.001f, 0.001f, 0.001f)), e), Color.a));
        Out.Color.a *= VolumeShadow_ObjTr;
        Out.ShadowColor.a *= VolumeShadow_ObjTr;
    }

    return Out;
}


#ifdef SHADOWVOLUMEMODEL

// �V���h�E�{�����[���ގ��͕`�悵�Ȃ�
technique VolumeShadow_Tech < string MMDPass = "object"; string Subset = "0"; >{ }
technique VolumeShadow_TechSS < string MMDPass = "object_ss"; string Subset = "0"; >{ }
technique VolumeShadow_ZplotTec < string MMDPass = "zplot"; string Subset = "0"; > { }

#endif

