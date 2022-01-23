////////////////////////////////////////////////////////////////////////////////////////////////
//
//  MLAA.fx ver0.0.2  Morphological Antialiasing : �|�X�g�G�t�F�N�g�ɂ��A���`�G�C���A�V���O����
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�ݒ�

// �֊s���o���@�̗L��
#define SamplingDepth    1   // �[�x�ɂ�钊�o, 0:���Ȃ�, 1:����
#define SamplingNormal   1   // �@���ɂ�钊�o, 0:���Ȃ�, 1:����
#define SamplingColor    1   // �F���ɂ�钊�o, 0:���Ȃ�, 1:����
#define SamplingMMDEdge  1   // MMD�G�b�W�̒��o, 0:���Ȃ�, 1:����

// �֊s���o臒l�ݒ�
float DepthThreshold  = 1.0;    // �[�x��臒l
float NormalThreshold = 0.9;    // �@����臒l
float ColorThreshold  = 0.3;    // �F����臒l


#define SAMP_NUM   8   // ������̃T���v�����O��


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

#define DEPTH_FAR  5000.0f   // �[�x�ŉ��l

#define TEX_FORMAT "A32B32G32R32F"
//#define TEX_FORMAT "A16B16G16R16F"

#ifndef MIKUMIKUMOVING
    #define OFFSCREEN_FX_DEPNORMAL  "MLAA_DepthNormal.fxsub"     // �I�t�X�N���[���[�x�E�@���}�b�v�`��G�t�F�N�g1
    #define MLAA_TEX_FORMAT         "D3DFMT_A4R4G4B4"
#else
    #define OFFSCREEN_FX_DEPNORMAL  "MLAA_DepthNormal_MMM.fxsub" // �I�t�X�N���[���[�x�E�@���}�b�v�`��G�t�F�N�g1
    #define MLAA_TEX_FORMAT         "D3DFMT_A8R8G8B8"
#endif

//�[�x�E�@���}�b�v�쐬
texture MLAA_RT : OFFSCREENRENDERTARGET <
    string Description = "Depth && Normal Map for MLAA.fx";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1.0;
    string Format = TEX_FORMAT;
    bool AntiAlias = false;
    int MipLevels = 1;
    string DefaultEffect = 
        "self = hide;"
        "* = " OFFSCREEN_FX_DEPNORMAL ";" ;
>;
sampler DepthNormalSmap = sampler_state {
    texture = <MLAA_RT>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


// ���W�p�����[�^
float4x4 ProjMatrix  : PROJECTION;

// �J��������̃p�[�X�y�N�e�B�u�t���O
static bool IsParth = ProjMatrix._44 < 0.5f;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

static float2 SampStep = (float2(1,1)/ViewportSize);

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,1};
float ClearDepth  = 1.0;

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

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;

// LeftRight���E��AA�������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
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

// �֊s���o���ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D OutlineMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = MLAA_TEX_FORMAT;
>;
sampler2D OutlineMapSamp = sampler_state {
    texture = <OutlineMap>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// ���ʂ̒��_�V�F�[�_

struct VS_OUTPUT {
    float4 Pos  : POSITION;
    float2 Tex  : TEXCOORD0;
};

VS_OUTPUT VS_Common( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s���o

float4 PS_PickupOutline( float2 Tex: TEXCOORD0 ) : COLOR
{
    // �[�x�E�@���}�b�v�f�[�^
    float4 data0 = tex2D( DepthNormalSmap, Tex );
    float4 dataL = tex2D( DepthNormalSmap, Tex-float2(SampStep.x,0) );
    float4 dataR = tex2D( DepthNormalSmap, Tex+float2(SampStep.x,0) );
    float4 dataB = tex2D( DepthNormalSmap, Tex+float2(0,SampStep.y) );
    float4 dataT = tex2D( DepthNormalSmap, Tex-float2(0,SampStep.y) );

    // �[�x
    float dep0 = data0.x * DEPTH_FAR;
    float depL = dataL.x * DEPTH_FAR;
    float depR = dataR.x * DEPTH_FAR;
    float depB = dataB.x * DEPTH_FAR;
    float depT = dataT.x * DEPTH_FAR;

    // �@��
    float3 normal0 = (data0.yzw * 2.0f - 1.0f);
    float3 normalL = (dataL.yzw * 2.0f - 1.0f);
    float3 normalR = (dataR.yzw * 2.0f - 1.0f);
    float3 normalB = (dataB.yzw * 2.0f - 1.0f);
    float3 normalT = (dataT.yzw * 2.0f - 1.0f);

    // �F�f�[�^
    float3 color0 = saturate( tex2D( ScnSamp, Tex ).rgb );
    float3 colorL = saturate( tex2D( ScnSamp, Tex-float2(SampStep.x,0) ).rgb );
    float3 colorR = saturate( tex2D( ScnSamp, Tex+float2(SampStep.x,0) ).rgb );
    float3 colorB = saturate( tex2D( ScnSamp, Tex+float2(0,SampStep.y) ).rgb );
    float3 colorT = saturate( tex2D( ScnSamp, Tex-float2(0,SampStep.y) ).rgb );

    // ���_����
    float2 pos = float2((2.0f*Tex.x-1.0f)*ViewportSize.x/ViewportSize.y, 1.0f-2.0f*Tex.y);
    float3 viewDirection = IsParth ? normalize( float3(pos/ProjMatrix._22, 1.0f) ) : float3(0,0,1);

    // �[�x臒l
    float depThreshold = DepthThreshold/max(dot(normal0*step(data0.w,50.0f), viewDirection), 0.005f);

    // �֊s�t���O
    float bflagL = 0.0f;
    float bflagR = 0.0f;
    float bflagB = 0.0f;
    float bflagT = 0.0f;

    // �[�x�ɂ��֊s���o
    #if SamplingDepth==1
    bflagL = step(depThreshold, abs(dep0 - depL));
    bflagR = step(depThreshold, abs(dep0 - depR));
    bflagB = step(depThreshold, abs(dep0 - depB));
    bflagT = step(depThreshold, abs(dep0 - depT));
    #endif

    // �@���ɂ��֊s���o
    #if SamplingNormal==1
    bflagL = max(bflagL, step(dot(normal0, normalL), NormalThreshold));
    bflagR = max(bflagR, step(dot(normal0, normalR), NormalThreshold));
    bflagB = max(bflagB, step(dot(normal0, normalB), NormalThreshold));
    bflagT = max(bflagT, step(dot(normal0, normalT), NormalThreshold));
    #endif

    // �F���ɂ��֊s���o
    #if SamplingColor==1
    bflagL = max(bflagL, step(ColorThreshold, length(color0 - colorL)));
    bflagR = max(bflagR, step(ColorThreshold, length(color0 - colorR)));
    bflagB = max(bflagB, step(ColorThreshold, length(color0 - colorB)));
    bflagT = max(bflagT, step(ColorThreshold, length(color0 - colorT)));
    #endif

    // MMD�G�b�W�`�敔�̗֊s���o
    #if SamplingMMDEdge==1
    float edge0 = step(50.0f, data0.w);
    float edgeL = step(50.0f, dataL.w);
    float edgeR = step(50.0f, dataR.w);
    float edgeB = step(50.0f, dataB.w);
    float edgeT = step(50.0f, dataT.w);
    bflagL = max(bflagL, abs(edge0 - edgeL));
    bflagR = max(bflagR, abs(edge0 - edgeR));
    bflagB = max(bflagB, abs(edge0 - edgeB));
    bflagT = max(bflagT, abs(edge0 - edgeT));
    #endif

    return float4(bflagL, bflagR, bflagB, bflagT);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// MLAA�@�ɂ��A���`�G�C���A�V���O����

// ���E�F�̃u�����h
float4 AAColorBlend(float4 color0, float4 color1, float2 linePt1, float2 linePt2)
{
    float4 Color = color0;

    if(linePt1.y * linePt2.y == 0.0f){
        // L�^���E�̏���
        float x1 = (linePt1.y == 0.0f) ? max(linePt1.x, linePt2.x-SAMP_NUM-1) : linePt1.x;
        float x2 = (linePt2.y == 0.0f) ? min(linePt2.x, linePt1.x+SAMP_NUM+1) : linePt2.x;
        float h1 = lerp(linePt1.y, linePt2.y, (-0.5f-x1)/(x2-x1));
        float h2 = lerp(linePt1.y, linePt2.y, ( 0.5f-x1)/(x2-x1));
        if(h1 >= 0.0f && h2 >= 0.0f){
            Color = lerp(color0, color1, 0.5f*(h1+h2));
        }else if(h1 > 0.0f){
            Color = lerp(color0, color1, 0.25f*h1);
        }else if(h2 > 0.0f){
            Color = lerp(color0, color1, 0.25f*h2);
        }
    }else if(linePt1.y * linePt2.y < 0.0f){
        // Z�^���E�̏���
        float h1 = lerp(linePt1.y, linePt2.y, (-0.5f-linePt1.x)/(linePt2.x-linePt1.x));
        float h2 = lerp(linePt1.y, linePt2.y, ( 0.5f-linePt1.x)/(linePt2.x-linePt1.x));
        if(h1 >= 0.0f && h2 >= 0.0f){
            Color = lerp(color0, color1, 0.5f*(h1+h2));
        }else if(h1 > 0.0f){
            Color = lerp(color0, color1, 0.25f*h1);
        }else if(h2 > 0.0f){
            Color = lerp(color0, color1, 0.25f*h2);
        }
    }else if(linePt1.y > 0.0f && linePt2.y > 0.0f){
        // U�^���E�̏���
        float h1, h2;
        float x0 = (linePt1.x + linePt2.x) * 0.5f;
        if(x0 >= 0.5f){
            h1 = lerp(linePt1.y, 0.0f, (-0.5f-linePt1.x)/(x0-linePt1.x));
            h2 = lerp(linePt1.y, 0.0f, ( 0.5f-linePt1.x)/(x0-linePt1.x));
            Color = lerp(color0, color1, 0.5f*(h1+h2));
        }else if(x0 <= -0.5f){
            h1 = lerp(0.0f, linePt2.y, (-0.5f-x0)/(linePt2.x-x0));
            h2 = lerp(0.0f, linePt2.y, ( 0.5f-x0)/(linePt2.x-x0));
            Color = lerp(color0, color1, 0.5f*(h1+h2));
        }else{
            h1 = lerp(linePt1.y, 0.0f, (-0.5f-linePt1.x)/(-linePt1.x));
            h2 = lerp(0.0f, linePt2.y,   0.5f           /( linePt2.x));
            Color = lerp(color0, color1, 0.25f*(h1+h2));
        }
    }

    return Color;
}


// LeftRight���E��AA����
float4 PS_MLAA_LeftRight(float2 Tex: TEXCOORD0) : COLOR
{
    float4 Color  = tex2D( ScnSamp, Tex );
    float4 colorL = tex2D( ScnSamp, Tex-float2(SampStep.x,0) );
    float4 colorR = tex2D( ScnSamp, Tex+float2(SampStep.x,0) );

    float4 bflag = tex2D( OutlineMapSamp, Tex ); // �֊s�t���O

    // Left���E��AA����
    if(bflag.x > 0.5f){
        // Left���E�̃W���M�[�`����
        float4 bflag0, bflagL;
        float2 linePt1 = float2(-0.5f-SAMP_NUM, 0.0f);
        float2 linePt2 = float2( 0.5f+SAMP_NUM, 0.0f);
        [unroll] //���[�v�W�J
        for(int i=SAMP_NUM; i>=0; i--){
            bflag0 = tex2D( OutlineMapSamp, Tex+float2( 0         , SampStep.y*i) );
            bflagL = tex2D( OutlineMapSamp, Tex+float2(-SampStep.x, SampStep.y*i) );
            if(bflag0.x < 0.5f){
                linePt1 = float2( 0.5f-i, 0.0f);
            }else if(bflag0.z > 0.5f){
                linePt1 = float2(-0.5f-i, 0.5f);
            }else if(bflagL.z > 0.5f){
                linePt1 = float2(-0.5f-i,-0.5f);
            }

            bflag0 = tex2D( OutlineMapSamp, Tex+float2( 0         ,-SampStep.y*i) );
            bflagL = tex2D( OutlineMapSamp, Tex+float2(-SampStep.x,-SampStep.y*i) );
            if(bflag0.x < 0.5f){
                linePt2 = float2(-0.5f+i, 0.0f);
            }else if(bflag0.w > 0.5f){
                linePt2 = float2( 0.5f+i, 0.5f);
            }else if(bflagL.w > 0.5f){
                linePt2 = float2( 0.5f+i,-0.5f);
            }
        }
        // Left���E�F�u�����h
        Color = AAColorBlend(Color, colorL, linePt1, linePt2);
    }

    // Right���E��AA����
    if(bflag.y > 0.5f){
        // Right���E�̃W���M�[�`����
        float4 bflag0, bflagR;
        float2 linePt1 = float2(-0.5f-SAMP_NUM, 0.0f);
        float2 linePt2 = float2( 0.5f+SAMP_NUM, 0.0f);
        [unroll] //���[�v�W�J
        for(int i=SAMP_NUM; i>=0; i--){
            bflag0 = tex2D( OutlineMapSamp, Tex+float2( 0         , SampStep.y*i) );
            bflagR = tex2D( OutlineMapSamp, Tex+float2( SampStep.x, SampStep.y*i) );
            if(bflag0.y < 0.5f){
                linePt1 = float2( 0.5f-i, 0.0f);
            }else if(bflag0.z > 0.5f){
                linePt1 = float2(-0.5f-i, 0.5f);
            }else if(bflagR.z > 0.5f){
                linePt1 = float2(-0.5f-i,-0.5f);
            }

            bflag0 = tex2D( OutlineMapSamp, Tex+float2( 0         ,-SampStep.y*i) );
            bflagR = tex2D( OutlineMapSamp, Tex+float2( SampStep.x,-SampStep.y*i) );
            if(bflag0.y < 0.5f){
                linePt2 = float2(-0.5f+i, 0.0f);
            }else if(bflag0.w > 0.5f){
                linePt2 = float2( 0.5f+i, 0.5f);
            }else if(bflagR.w > 0.5f){
                linePt2 = float2( 0.5f+i,-0.5f);
            }
        }
        // Right���E�F�u�����h
        Color = AAColorBlend(Color, colorR, linePt1, linePt2);
    }

    return Color;
}


// BottomTop���E��AA����
float4 PS_MLAA_BottomTop(float2 Tex: TEXCOORD0) : COLOR
{
    float4 Color  = tex2D( ScnSamp2, Tex );
    float4 colorB = tex2D( ScnSamp2, Tex+float2(0,SampStep.y) );
    float4 colorT = tex2D( ScnSamp2, Tex-float2(0,SampStep.y) );

    float4 bflag = tex2D( OutlineMapSamp, Tex ); // �֊s�t���O

    // Bottom���E��AA����
    if(bflag.z > 0.5f){
        // Bottom���E�̃W���M�[�`����
        float4 bflag0, bflagB;
        float2 linePt1 = float2(-0.5f-SAMP_NUM, 0.0f);
        float2 linePt2 = float2( 0.5f+SAMP_NUM, 0.0f);
        [unroll] //���[�v�W�J
        for(int i=SAMP_NUM; i>=0; i--){
            bflag0 = tex2D( OutlineMapSamp, Tex+float2(-SampStep.x*i, 0         ) );
            bflagB = tex2D( OutlineMapSamp, Tex+float2(-SampStep.x*i, SampStep.y) );
            if(bflag0.z < 0.5f){
                linePt1 = float2( 0.5f-i, 0.0f);
            }else if(bflag0.x > 0.5f){
                linePt1 = float2(-0.5f-i, 0.5f);
            }else if(bflagB.x > 0.5f){
                linePt1 = float2(-0.5f-i,-0.5f);
            }

            bflag0 = tex2D( OutlineMapSamp, Tex+float2( SampStep.x*i, 0         ) );
            bflagB = tex2D( OutlineMapSamp, Tex+float2( SampStep.x*i, SampStep.y) );
            if(bflag0.z < 0.5f){
                linePt2 = float2(-0.5f+i, 0.0f);
            }else if(bflag0.y > 0.5f){
                linePt2 = float2( 0.5f+i, 0.5f);
            }else if(bflagB.y > 0.5f){
                linePt2 = float2( 0.5f+i,-0.5f);
            }
        }
        // Bottom���E�F�u�����h
        Color = AAColorBlend(Color, colorB, linePt1, linePt2);
    }

    // Top���E��AA����
    if(bflag.w > 0.5f){
        // Top���E�̃W���M�[�`����
        float4 bflag0, bflagT;
        float2 linePt1 = float2(-0.5f-SAMP_NUM, 0.0f);
        float2 linePt2 = float2( 0.5f+SAMP_NUM, 0.0f);
        [unroll] //���[�v�W�J
        for(int i=SAMP_NUM; i>=0; i--){
            bflag0 = tex2D( OutlineMapSamp, Tex+float2(-SampStep.x*i, 0         ) );
            bflagT = tex2D( OutlineMapSamp, Tex+float2(-SampStep.x*i, SampStep.y) );
            if(bflag0.w < 0.5f){
                linePt1 = float2( 0.5f-i, 0.0f);
            }else if(bflag0.x > 0.5f){
                linePt1 = float2(-0.5f-i, 0.5f);
            }else if(bflagT.x > 0.5f){
                linePt1 = float2(-0.5f-i,-0.5f);
            }

            bflag0 = tex2D( OutlineMapSamp, Tex+float2( SampStep.x*i, 0         ) );
            bflagT = tex2D( OutlineMapSamp, Tex+float2( SampStep.x*i, SampStep.y) );
            if(bflag0.w < 0.5f){
                linePt2 = float2(-0.5f+i, 0.0f);
            }else if(bflag0.y > 0.5f){
                linePt2 = float2( 0.5f+i, 0.5f);
            }else if(bflagT.y > 0.5f){
                linePt2 = float2( 0.5f+i,-0.5f);
            }
        }
        // Top���E�F�u�����h
        Color = AAColorBlend(Color, colorT, linePt1, linePt2);
    }

    return Color;
    //return tex2D( OutlineMapSamp, Tex );
}

////////////////////////////////////////////////////////////////////////////////////////////////

technique MLAA_Tech <
    string Script = 
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "ScriptExternal=Color;"

        "RenderColorTarget0=OutlineMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=PickupOutline;"

        "RenderColorTarget0=ScnMap2;"
        "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=MLAA_LeftRight;"

        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "Pass=MLAA_BottomTop;"
    ;
> {
    pass PickupOutline < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_PickupOutline();
    }
    pass MLAA_LeftRight < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_MLAA_LeftRight();
    }
    pass MLAA_BottomTop < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_MLAA_BottomTop();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
