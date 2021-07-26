////////////////////////////////////////////////////////////////////////////////
//
//  PostRimLighting.fx
//  �쐬: �~�[�t�H��
//
////////////////////////////////////////////////////////////////////////////////

// �|�X�g�G�t�F�N�g�錾
float Script : STANDARDSGLOBAL
<
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

float Tr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float2 ViewportSize : VIEWPORTPIXELSIZE;
static const float2 ViewportOffset = float2(0.5, 0.5) / ViewportSize;

////////////////////////////////////////////////////////////////
// ��Ɨp�e�N�X�`��
texture PRL_AdditiveRT : OFFSCREENRENDERTARGET
<
	string Description = "Additive Render Target for PostRimLighting.fx";
	float4 ClearColor = { 0, 0, 0, 0 };
	float ClearDepth = 1.0;
	bool AntiAlias = true;
	int Miplevels = 1;
	string DefaultEffect =
	    "self = hide;"
	    "* = AL_RimLighting.fx;";
>;
sampler AdditiveSampler = sampler_state
{
	texture = <PRL_AdditiveRT>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
};

/////////////////////////////
// �R�s�[�p�̃V�F�[�_
struct VS_OUTPUT
{
   float4 Pos: POSITION;
   float2 Tex: TEXCOORD0;
};

VS_OUTPUT CopyVS(float4 Pos : POSITION, float4 Tex : TEXCOORD0)
{ 
	VS_OUTPUT Out;
	
	Out.Pos = Pos;
	Out.Tex = Tex + ViewportOffset;
	
	return Out;
}

/////////////////////////////
// �����p�̃V�F�[�_
float4 MixPS(float2 Tex: TEXCOORD0) : COLOR
{
	return tex2D(AdditiveSampler, Tex) * float4(1, 1, 1, Tr);
}

////////////////////////////////////////////////////////////////
// �G�t�F�N�g�e�N�j�b�N
//
float4 ClearColor = { 0, 0, 0, 0 };
float ClearDepth = 1;

technique PostEffectTec
<
	string Script =
		"ScriptExternal=Color;"
		"Pass=PassMix;";
>
{
	pass PassMix < string Script = "Draw=Buffer;"; >
	{
		AlphaBlendEnable = true;
      	SRCBLEND = SRCALPHA;
        DESTBLEND = ONE;
		VertexShader = compile vs_2_0 CopyVS();
		PixelShader  = compile ps_2_0 MixPS();
	}
};
