////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ��ʊE�[�x�G�t�F�N�g ���掿�� Ver.2
//  �쐬: ���ڂ�
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ���[�U�[�p�����[�^

// �ڂ����͈�(�傫����������ƎȂ��o�܂�)
float Extent
<
   string UIName = "Extent";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 0.01;
> = float( 0.0005 );


float BlurLimit
<
   string UIName = "BlurLimit";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 30.0;
> = 10;

//�w�i�F
float4 ClearColor
<
   string UIName = "ClearColor";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4(0,0,0,0);

//������̃T���v�����O��
#define SAMP_NUM   12

///////////////////////////////////////////////////////////////////////////////////

//�X�P�[���W��
#define SCALE_VALUE 4

//�o�b�t�@�g�嗦
float fmRange = 0.75f;

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;


#define PI 3.14159
#define DEG_TO_RAD (PI / 180)

// �X�P�[���l�擾
float scaling : CONTROLOBJECT < string name = "(self)"; >;

//����p�ɂ��ڂ������x��
float4x4 ProjMatrix      : PROJECTION;
static float viewangle = atan(1 / ProjMatrix[0][0]);
static float viewscale = (45 / 2 * DEG_TO_RAD) / viewangle;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;

static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

static float2 SampStep = (float2(Extent,Extent)/ViewportSize*ViewportSize.y);
static float2 SampStepScaled = SampStep  * scaling * 0.1 * viewscale * 0.5;


#define SAMP_NUM2  6
float ext2 = 0.002;
static float2 SampStep2 = (float2(ext2, ext2)/ViewportSize*ViewportSize.y);


//�[�x�}�b�v�쐬
texture DepthRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for SvDOF.fx";
    float4 ClearColor = { 1, 0, 0, 1 };
    float ClearDepth = 1.0;
    string Format = "D3DFMT_R32F" ;
    bool AntiAlias = true;
    int MipLevels = 1;
    string DefaultEffect = 
        "self = hide;"
        "* = SvDOF_DepthOut.fx";
>;

sampler DepthView = sampler_state {
    texture = <DepthRT>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = NONE;
};


// �����_�����O�^�[�Q�b�g�̃N���A�l
float ClearDepth  = 1.0;

// �[�x�o�b�t�@
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
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSamp2 = sampler_state {
    texture = <ScnMap2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


// �[�x�}�b�v��X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D DpMapX : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "D3DFMT_R32F" ;
>;
sampler2D DpSampX = sampler_state {
    texture = <DpMapX>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
// �[�x�}�b�v��Y�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D DpMapY : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "D3DFMT_R32F" ;
>;
sampler2D DpSampY = sampler_state {
    texture = <DpMapY>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

////////////////////////////////////////////////////////////////////////////////////////////////
// ���ʒ��_�V�F�[�_
struct VS_OUTPUT {
    float4 Pos            : POSITION;
    float2 Tex            : TEXCOORD0;
};

VS_OUTPUT VS_passDraw( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    
    return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�[�x�}�b�v�ڂ���
#define DX_SAMPLER DepthView

float4 PS_passDX( VS_OUTPUT IN ) : COLOR {   
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    float step = SampStep2.x;
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM2; i <= SAMP_NUM2; i++){
        e = exp(-pow((float)i / (SAMP_NUM2 / 2.0), 2) / 2); //���K���z
        stex = IN.Tex + float2(step * (float)i, 0);
        sum += tex2D( DX_SAMPLER, stex ) * e;
        n += e;
    }
    
    Color = sum / n;
    
    return Color;
}

#define DY_SAMPLER DpSampX

float4 PS_passDY( VS_OUTPUT IN ) : COLOR {   
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    float step = SampStep2.y;
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM2; i <= SAMP_NUM2; i++){
        e = exp(-pow((float)i / (SAMP_NUM2 / 2.0), 2) / 2); //���K���z
        stex = IN.Tex + float2(0, step * (float)i);
        sum += tex2D( DY_SAMPLER, stex ) * e;
        n += e;
    }
    
    Color = sum / n;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�ڂ������x�}�b�v�擾

#define GetDepthMap GetDepthMapMix

float GetDepthMapDef(float2 screenPos){
    return tex2D( DepthView, screenPos ).r;
}
float GetDepthMapBlr(float2 screenPos){
    return tex2D( DpSampY, screenPos ).r;
}
float GetDepthMapMix(float2 screenPos){
    float depth1 = GetDepthMapDef(screenPos);
    float depth2 = GetDepthMapBlr(screenPos);
    
    float blrval = abs(depth1 - (1.0 / SCALE_VALUE));
    
    return lerp(depth1, depth2, saturate(blrval * 2));
}
float DepthToBlur(float depth){
    float blrval = abs(depth - (1.0 / SCALE_VALUE));
    //��O���̃u���[���x�͂�����ƉR��
    if(depth < (1.0 / SCALE_VALUE)) blrval = pow(blrval * 15, 2) / 15; 
    return blrval;
}
float DepthComp(float dsrc, float ddst){
    return ((ddst < (1.0 / SCALE_VALUE)) && (DepthToBlur(dsrc) < DepthToBlur(ddst))) ? ddst : 1000;
}
float GetBlurMap(float2 screenPos){
    float depth = GetDepthMap(screenPos);
    float depth2 = depth;
    depth2 = min(depth2, DepthComp(depth, GetDepthMap(screenPos + float2( SampStep.x, 0))));
    depth2 = min(depth2, DepthComp(depth, GetDepthMap(screenPos + float2(-SampStep.x, 0))));
    depth2 = min(depth2, DepthComp(depth, GetDepthMap(screenPos + float2(0,  SampStep.y))));
    depth2 = min(depth2, DepthComp(depth, GetDepthMap(screenPos + float2(0, -SampStep.y))));
    
    depth2 = min(BlurLimit, depth2);
    
    return DepthToBlur(depth2);
}

////////////////////////////////////////////////////////////////////////////////////////////////
// X�����ڂ���

#define X_SAMPLER ScnSamp

float4 PS_passX( VS_OUTPUT IN ) : COLOR {   
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    float step = SampStepScaled.x * GetBlurMap(IN.Tex);
    float depth, centerdepth = GetDepthMap(IN.Tex) - 0.01;
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
        e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
        stex = IN.Tex + float2(step * (float)i, 0);
        
        //��O���s���g�̍����Ă��镔������̃T���v�����O�͎キ
        depth = GetDepthMap(stex);
        e *= max(saturate(DepthToBlur(depth) * 2), (depth >= centerdepth));
        sum += tex2D( X_SAMPLER, stex ) * e;
        n += e;
    }
    
    Color = sum / n;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// Y�����ڂ���

#define Y_SAMPLER ScnSamp2

float4 PS_passY( VS_OUTPUT IN ) : COLOR {   
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    float step = SampStepScaled.y * GetBlurMap(IN.Tex);
    float depth, centerdepth = GetDepthMap(IN.Tex) - 0.01;
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
        e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
        stex = IN.Tex + float2(0, step * (float)i);
        
        //��O���s���g�̍����Ă��镔������̃T���v�����O�͎キ
        depth = GetDepthMap(stex);
        e *= max(saturate(DepthToBlur(depth) * 2), (depth >= centerdepth));
        sum += tex2D( Y_SAMPLER, stex ) * e;
        n += e;
    }
    
    Color = sum / n;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////
// Y�����ڂ���

#define Y_SAMPLER2 ScnSamp

float4 PS_passY2( VS_OUTPUT IN ) : COLOR {   
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    float step = SampStepScaled.y * GetBlurMap(IN.Tex);
    float depth, centerdepth = GetDepthMap(IN.Tex) - 0.01;
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
        e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
        stex = IN.Tex + float2(0, step * (float)i);
        
        //��O���s���g�̍����Ă��镔������̃T���v�����O�͎キ
        depth = GetDepthMap(stex);
        e *= max(saturate(DepthToBlur(depth) * 2), (depth >= centerdepth));
        sum += tex2D( Y_SAMPLER2, stex ) * e;
        n += e;
    }
    
    Color = sum / n;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// X�����ڂ���

#define X_SAMPLER2 ScnSamp2

float4 PS_passX2( VS_OUTPUT IN ) : COLOR {   
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    float step = SampStepScaled.x * GetBlurMap(IN.Tex);
    float depth, centerdepth = GetDepthMap(IN.Tex) - 0.01;
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
        e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
        stex = IN.Tex + float2(step * (float)i, 0);
        
        //��O���s���g�̍����Ă��镔������̃T���v�����O�͎キ
        depth = GetDepthMap(stex);
        e *= max(saturate(DepthToBlur(depth) * 2), (depth >= centerdepth));
        sum += tex2D( X_SAMPLER2, stex ) * e;
        n += e;
    }
    
    Color = sum / n;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

technique SvDOF <
    string Script = 
        
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"
         
        "RenderColorTarget0=DpMapX;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=Gaussian_DX;"
         
        "RenderColorTarget0=DpMapY;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=Gaussian_DY;"
        
        "RenderColorTarget0=ScnMap2;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=Gaussian_Y2;"
        
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=Gaussian_X2;"
        
        "RenderColorTarget0=ScnMap2;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=Gaussian_X;"
        
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=Gaussian_Y;"
        
        
        
        
    ;
    
> {
    
    
    pass Gaussian_DX < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_passDX();
    }
    pass Gaussian_DY < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_passDY();
    }
    
    pass Gaussian_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_passX();
    }
    pass Gaussian_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_passY();
    }
    
    pass Gaussian_X2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_passX2();
    }
    pass Gaussian_Y2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_passY2();
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////

