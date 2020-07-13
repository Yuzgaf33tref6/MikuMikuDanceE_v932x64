//�|�C���g���C�g�̐F�iRGB�j
float3 LightColor = float3(1,1,1);

//�|�C���g���C�g�̌�����(1�`�����j
float LightPow = 1.0;



float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

//���C�g�`��pRT
texture PointLightRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for PostPointLight.fx";
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    
    string DefaultEffect = 
        "self = hide;"
        "* = RT_Model.fx;";
>;
sampler PPL_Samp = sampler_state
{
   Texture = (PointLightRT);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   FILTER = LINEAR;
};


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;

static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;

static float2 SampStep = (float2(2,2)/ViewportSize);


// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,0};
float ClearDepth  = 1.0;

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g

struct VS_OUTPUT {
    float4 Pos			: POSITION;
	float2 Tex			: TEXCOORD0;
};

VS_OUTPUT VS_Main( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ){
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}

float4 PS_Main(float2 Tex: TEXCOORD0) : COLOR
{   
    float4 Color;
	Color = tex2D(PPL_Samp,Tex);
	Color.rgb = pow(Color.rgb,LightPow);
	Color.rgb *= LightColor;
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

technique PostPointLight <
    string Script = 
	    "ScriptExternal=Color;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=Main;"
    ;
> {

    pass Main < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = TRUE;
		SRCBLEND = ONE;
		DESTBLEND = ONE;
        VertexShader = compile vs_2_0 VS_Main();
        PixelShader  = compile ps_2_0 PS_Main();
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
