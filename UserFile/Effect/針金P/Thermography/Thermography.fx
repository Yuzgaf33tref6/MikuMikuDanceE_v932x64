////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Thermography.fx ver0.0.1  �^���T�[���O���t�B�G�t�F�N�g
//  �쐬: �j��P( ���͉��P����Gaussian.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

// �A�N�Z�T���p�����[�^
float4x4 WorldMatrix : WORLD;
static float3 AcsOffset = WorldMatrix._41_42_43;


float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;


// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,1};
float ClearDepth  = 1.0;

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    string Format = "D24S8";
>;

////////////////////////////////////////////////////////////////////////////////////////////////
// HSV����RGB�ւ̕ϊ� H:0.0�`360.0, S:0.0�`1.0, V:0.0�`1.0 (S==0���͏ȗ�)
float4 HSV2RGB(float h, float s, float v) : COLOR
{
   h %= 360.0;
   int hi = (int)(h/60) % 6;
   float f = h/60.0 - (float)hi;
   float p = v*(1.0 - s);
   float q = v*(1.0 - f*s);
   float t = v*(1.0 - (1.0-f)*s);
   float4 Color;
   if(hi == 0){
      Color = float4(v, t, p, 1.0);
   }else if(hi == 1){
      Color = float4(q, v, p, 1.0);
   }else if(hi == 2){
      Color = float4(p, v, t, 1.0);
   }else if(hi == 3){
      Color = float4(p, q, v, 1.0);
   }else if(hi == 4){
      Color = float4(t, p, v, 1.0);
   }else if(hi == 5){
      Color = float4(v, p, q, 1.0);
   }
   return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �T�[���O���t�B�V�F�[�_

struct VS_OUTPUT {
    float4 Pos			: POSITION;
    float2 Tex			: TEXCOORD0;
};

VS_OUTPUT VS_Thermography( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex;

    return Out;
}

float4 PS_Thermography( float2 Tex: TEXCOORD0 ) : COLOR {   
    float4 Color = tex2D( ScnSamp, Tex+ViewportOffset );

    // �O���C�X�P�[���v�Z(NTSC�n���d���ϖ@)
    float v = 0.298912 * Color.r + 0.586611 * Color.g + 0.114478 * Color.b;

    // �O���C�X�P�[����F���O���f�[�V�����ɃJ���[���}�b�v
    Color = HSV2RGB(360.0*v+AcsOffset.x, 1.0, 0.9);

    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

technique ThermographyTech <
    string Script = 
        "RenderColorTarget0=ScnMap;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
	    "ScriptExternal=Color;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=ThermographyPass;"
    ;
> {
    pass ThermographyPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Thermography();
        PixelShader  = compile ps_2_0 PS_Thermography();
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////

