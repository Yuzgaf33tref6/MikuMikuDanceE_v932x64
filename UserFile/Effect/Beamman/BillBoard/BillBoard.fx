static float4 yColor[4] = {float4(0, 0, 0, 1),float4(0, 0, 1, 1),float4(0, 1, 1, 1),float4(1, 1, 1, 1)};
//�������@�̐ݒ�
//
//�����������F
//BLENDMODE_SRC SRCALPHA
//BLENDMODE_DEST INVSRCALPHA
//
//���Z�����F
//
//BLENDMODE_SRC SRCALPHA
//BLENDMODE_DEST ONE

#define BLENDMODE_SRC SRCALPHA
#define BLENDMODE_DEST ONE

float FlashSpd = 1;
float FlashLen = 0.5;


////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldViewMatrixInverse        : WORLDVIEWINVERSE;

//texture MaskTex : ANIMATEDTEXTURE <
texture MaskTex<
    string ResourceName = "grf.png";
>;
sampler Mask = sampler_state {
    texture = <MaskTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


static float3x3 BillboardMatrix = {
    normalize(WorldViewMatrixInverse[0].xyz),
    normalize(WorldViewMatrixInverse[1].xyz),
    normalize(WorldViewMatrixInverse[2].xyz),
};
float time_0_X : Time;

///////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // �e�N�X�`��
};

// ���_�V�F�[�_
VS_OUTPUT Mask_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out;
    
    // �r���{�[�h
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );
    Pos.xyz *= 2+cos(time_0_X*FlashSpd)*FlashLen;
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Mask_PS( float2 Tex :TEXCOORD0 ) : COLOR0
{
    return tex2D( Mask, Tex );
}

technique MainTec < string MMDPass = "object"; > {
    pass DrawObject {
		ZENABLE = TRUE;
		ZWRITEENABLE = FALSE;
		CULLMODE = NONE;
		ALPHABLENDENABLE = TRUE;
		SRCBLEND=BLENDMODE_SRC;
		DESTBLEND=BLENDMODE_DEST;
        VertexShader = compile vs_1_1 Mask_VS();
        PixelShader  = compile ps_2_0 Mask_PS();
    }
}

