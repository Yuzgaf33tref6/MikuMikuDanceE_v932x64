////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

//���U�C�N�̍r���E���Z���܂ނ��߁A�[���֎~
float BlockSize
<
   string UIName = "BlockSize";
   string UIWidget = "Slider";
   float UIMin = 0.01;
   float UIMax = 0.05;
> = 0.03;

//�m�C�Y�̋���
float Noize
<
   string UIName = "Noize";
   string UIWidget = "Slider";
   float UIMin = 0.0;
   float UIMax = 1.0;
> = 0.5;

////////////////////////////////////////////////////////////////////////////////////////////////

float4 Color_White = {1,1,1,1};
float4 Color_Black = {0,0,0,1};

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldViewMatrixInverse        : WORLDVIEWINVERSE;

static float3x3 BillboardMatrix = {
    normalize(WorldViewMatrixInverse[0].xyz),
    normalize(WorldViewMatrixInverse[1].xyz),
    normalize(WorldViewMatrixInverse[2].xyz),
};


float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;


// �}�e���A���F
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
static float alpha1 = (0.1 + 0.9 * MaterialDiffuse.a);

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;

static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
static float2 SampStep = (float2(BlockSize*alpha1,BlockSize*alpha1)/ViewportSize*ViewportSize.y);

float ftime : TIME <bool SyncInEditMode = false;>;

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,1};
float ClearDepth  = 1.0;


texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
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

texture2D ScnMap2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSamp2 = sampler_state {
    texture = <ScnMap2>;
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
VS_OUTPUT Object_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out;
    
    /*// �r���{�[�h
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    // �e�N�X�`�����W
    Out.Tex = Tex;*/
    
    Out.Pos = mul(Pos, WorldViewProjMatrix);
    Out.Tex = Tex;
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Object_PS( float2 Tex :TEXCOORD0 ) : COLOR0
{
	
    return Color_Black;
}

////////////////////////////////////////////////////////////////////////////////////////////////

VS_OUTPUT VS_Mix( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ){
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + float2(ViewportOffset.x, ViewportOffset.y);
    
    return Out;
}

float4 PS_Mix(float2 Tex: TEXCOORD0) : COLOR
{   
    float4 Color1;
	float4 ColorMask;
	
	ColorMask = tex2D( ScnSamp2, Tex );
	
	if(length(ColorMask.rgb) == 0){
		//�ʎq��
		Tex.x = (ceil(Tex.x / SampStep.x - 0.5) + noise(ftime * 10) * Noize) * SampStep.x;
		Tex.y = (ceil(Tex.y / SampStep.y - 0.5) + noise(ftime * 8) * Noize) * SampStep.y;
	}
	
	Color1 = tex2D( ScnSamp, Tex );
	
    return Color1;
}

///////////////////////////////////////////////////////////////////////////////////////////////

technique MainTec <
    string Script = 
        
        "RenderColorTarget0=ScnMap;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
	    "ScriptExternal=Color;"
		
		"RenderColorTarget0=ScnMap2;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
		"Pass=DrawObject;"
		
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=Mix;"
	    
    ;
> {
    
    pass DrawObject < string Script= "Draw=Geometry;"; > {
    	ZENABLE = false;
    	VertexShader = compile vs_2_0 Object_VS();
        PixelShader  = compile ps_2_0 Object_PS();
    }
    
    pass Mix < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Mix();
        PixelShader  = compile ps_2_0 PS_Mix();
    }
}

