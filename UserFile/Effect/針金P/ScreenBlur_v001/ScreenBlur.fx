////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ScreenBlur.fx ver0.0.1  Screen.bmp�𗘗p�����ȈՃ��[�V�����u���[
//  �쐬: �j��P( ���͉��P����laughing_man.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////

// �A�N�Z�T���p�����[�^
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
static float AcsAlpha = MaterialDiffuse.a;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler TexSampler = sampler_state {
    texture = <ObjectTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

///////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // �e�N�X�`��
};

// ���_�V�F�[�_
VS_OUTPUT ScreenBlur_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    Out.Pos = Pos;
    Out.Tex = Tex + float2(ViewportOffset.x, ViewportOffset.y);
    return Out;
}

// �s�N�Z���V�F�[�_
float4 ScreenBlur_PS( float2 Tex :TEXCOORD0 ) : COLOR0
{
    // �e�N�X�`���K�p
    float4 Color = tex2D( TexSampler, Tex );
    Color.a *= AcsAlpha;
    return Color;
}

technique MainTec < string MMDPass = "object"; > {
    pass DrawObject < string Script= "Draw=Buffer;"; > {
        ZENABLE = false;
        VertexShader = compile vs_1_1 ScreenBlur_VS();
        PixelShader  = compile ps_2_0 ScreenBlur_PS();
    }
}

