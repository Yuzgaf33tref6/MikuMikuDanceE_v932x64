
#include "ikPointColorSettings.fxsub"

// �����F���Ȃ������Ƃ��ɑI�΂��p���b�g�ԍ�
const int DefaultMark = 0;

// �w��p���b�g�Ƌ��e�ł���F�͈̔�
const float DistanceLatitude = 64 / 256.0;



///////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���@�ϊ��s��
float4x4 matWVP	: WORLDVIEWPROJECTION;
float4x4 matWV	: WORLDVIEW;

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};


shared texture2D PalletTex;
sampler PalletTexSamp = sampler_state {
	texture = <PalletTex>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT
{
	float4 Pos        : POSITION;    // �ˉe�ϊ����W
	float2 Tex	  : TEXCOORD1;
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL,float2 Tex: TEXCOORD0)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;
	Out.Pos = mul( Pos, matWVP );
	Out.Tex = Tex;
	return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS( VS_OUTPUT IN ) : COLOR
{
	// ���l��臒l�ȉ��̉ӏ��͕`�悵�Ȃ�
	float4 col = tex2D( ObjTexSampler, IN.Tex );
	float alpha = col.a;
	clip(alpha - AlphaThroughThreshold);

	// �߂��F��T��
	int index = DefaultMark;
	float dist = DistanceLatitude;
	const float ph = PALLET_HEIGHT * PALLET_SLOT;
	for(int i = 0; i < PALLET_HEIGHT; i++) {
		float3 pal = tex2D( PalletTexSamp, float2(1, (i + 0.5) / ph)).rgb;
		float tmpDist = dot(abs(col.rgb - pal), 1);
		if (tmpDist < dist)
		{
			dist = tmpDist;
			index = i;
		}
	}

	return float4((index  + 0.5) / PALLET_HEIGHT, 0,0,1);
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec < string MMDPass = "object"; > {
    pass DrawObject
    {
        VertexShader = compile vs_3_0 Basic_VS();
        PixelShader  = compile ps_3_0 Basic_PS();
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTecBS  < string MMDPass = "object_ss"; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS();
        PixelShader  = compile ps_3_0 Basic_PS();
    }
}

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTech < string MMDPass = "shadow";  > {}

///////////////////////////////////////////////////////////////////////////////////////////////
