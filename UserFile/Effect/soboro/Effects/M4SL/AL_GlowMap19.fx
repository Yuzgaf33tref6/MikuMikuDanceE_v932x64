////////////////////////////////////////////////////////////////////////////////////////////////
//
// EmittionDraw for AutoLuminous.fx
//
////////////////////////////////////////////////////////////////////////////////////////////////

//�ٕ����t�B���^�����O��Ɨp�e�N�X�`���T�C�Y
// 0�Ŗ�����
#define MIPMAPTEX_SIZE  0	// 256

//�����}�b�v�e�N�X�`����
#define TEXTURE_NAME "TEX_armcover.png"

//臒l
float LightThreshold = 0.9;

////////////////////////////////////////////////////////////////////////////////////////////////

#define SPECULAR_BASE 100
#define SYNC false

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float    SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;


// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 ViewMatrix               : VIEW;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;


#define PI 3.14159

float LightUp : CONTROLOBJECT < string name = "(self)"; string item = "LightUp"; >;
float LightUpE : CONTROLOBJECT < string name = "(self)"; string item = "LightUpE"; >;
float LightOff : CONTROLOBJECT < string name = "(self)"; string item = "LightOff"; >;
float Blink : CONTROLOBJECT < string name = "(self)"; string item = "LightBlink"; >;
float BlinkSq : CONTROLOBJECT < string name = "(self)"; string item = "LightBS"; >;
float BlinkDuty : CONTROLOBJECT < string name = "(self)"; string item = "LightDuty"; >;
float BlinkMin : CONTROLOBJECT < string name = "(self)"; string item = "LightMin"; >;

//����
float ftime : TIME <bool SyncInEditMode = SYNC;>;

static float duty = (BlinkDuty <= 0) ? 0.5 : BlinkDuty;
static float timerate = ((Blink > 0) ? ((1 - cos(saturate(frac(ftime / (Blink * 10)) / (duty * 2)) * 2 * PI)) * 0.5) : 1.0)
                      * ((BlinkSq > 0) ? (frac(ftime / (BlinkSq * 10)) < duty) : 1.0);
static float timerate1 = timerate * (1 - BlinkMin) + BlinkMin;

static bool IsEmittion = (SPECULAR_BASE < SpecularPower)/* && (SpecularPower <= (SPECULAR_BASE + 100))*/ && (length(MaterialSpecular) < 0.01);
static float EmittionPower0 = IsEmittion ? ((SpecularPower - SPECULAR_BASE) / 7.0) : 1;
static float EmittionPower1 = EmittionPower0 * (LightUp * 2 + 1.0) * pow(400, LightUpE) * (1.0 - LightOff);

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);


// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;


#if MIPMAPTEX_SIZE==0
    #define MIPMAPSCRIPT    "RenderColorTarget0=;" \
                                "RenderDepthStencilTarget=;" \
                                "Pass=DrawObject;"
    
    #define CREATEMIPMAP
    
    // �I�u�W�F�N�g�̃e�N�X�`��
    texture ObjectTexture: MATERIALTEXTURE;
    sampler ObjTexSampler = sampler_state {
        texture = <ObjectTexture>;
        MINFILTER = LINEAR;
        MAGFILTER = LINEAR;
    };
    
    texture2D MapTexture
	<
	    string ResourceName = TEXTURE_NAME;
	>;
	sampler MapTextureSampler = sampler_state
	{
	    texture = <MapTexture>;
        MINFILTER = LINEAR;
        MAGFILTER = LINEAR;
	};
    
#else
    #define MIPMAPSCRIPT    "RenderColorTarget0=UseMipmapObjectTexture;" \
                                "RenderDepthStencilTarget=MipDepthBuffer;" \
                                "ClearSetColor=ClearColor; Clear=Color;" \
                                "ClearSetDepth=ClearDepth; Clear=Depth;" \
                                "Pass=CreateMipmap;" \
                            "RenderColorTarget0=MapUseMipmapObjectTexture;" \
                                "ClearSetColor=ClearColor; Clear=Color;" \
                                "Pass=CreateMapMipmap;" \
                            "RenderColorTarget0=;" \
                                "RenderDepthStencilTarget=;" \
                                "Pass=DrawObject;"
    
    #define CREATEMIPMAP pass CreateMipmap < string Script= "Draw=Buffer;"; > { \
                                AlphaBlendEnable = FALSE; \
                                ZEnable = FALSE; \
                                VertexShader = compile vs_3_0 VS_MipMapCreater(); \
                                PixelShader  = compile ps_3_0 PS_MipMapCreater(); \
                            } \
                         pass CreateMapMipmap < string Script= "Draw=Buffer;"; > { \
                                AlphaBlendEnable = FALSE; \
                                ZEnable = FALSE; \
                                VertexShader = compile vs_3_0 VS_MipMapCreater(); \
                                PixelShader  = compile ps_3_0 PS_MapMipMapCreater(); \
                            }
    
    // �I�u�W�F�N�g�̃e�N�X�`��
    texture ObjectTexture: MATERIALTEXTURE<
        int MipLevels = 0;
    >;
    sampler DefObjTexSampler = sampler_state {
        texture = <ObjectTexture>;
        MINFILTER = LINEAR;
        MAGFILTER = LINEAR;
    };
    
    texture2D MipDepthBuffer : RenderDepthStencilTarget <
        int Width = MIPMAPTEX_SIZE;
        int Height = MIPMAPTEX_SIZE;
        string Format = "D24S8";
    >;
    texture UseMipmapObjectTexture : RENDERCOLORTARGET <
        int Width = MIPMAPTEX_SIZE;
        int Height = MIPMAPTEX_SIZE;
        int MipLevels = 0;
        string Format = "A8R8G8B8" ;
    >;
    sampler ObjTexSampler = sampler_state {
        texture = <UseMipmapObjectTexture>;
        MINFILTER = ANISOTROPIC;
        MAGFILTER = ANISOTROPIC;
        MIPFILTER = LINEAR;
        MAXANISOTROPY = 16;
    };
    
    texture2D MapTexture
	<
	    string ResourceName = TEXTURE_NAME;
	>;
	sampler DefMapTextureSampler = sampler_state
	{
	    texture = <MapTexture>;
        MINFILTER = LINEAR;
        MAGFILTER = LINEAR;
	};
    texture MapUseMipmapObjectTexture : RENDERCOLORTARGET <
        int Width = MIPMAPTEX_SIZE;
        int Height = MIPMAPTEX_SIZE;
        int MipLevels = 0;
        string Format = "A8R8G8B8" ;
    >;
    sampler MapTextureSampler = sampler_state {
        texture = <MapUseMipmapObjectTexture>;
        MINFILTER = ANISOTROPIC;
        MAGFILTER = ANISOTROPIC;
        MIPFILTER = LINEAR;
        MAXANISOTROPY = 16;
    };
    
    // �e�N�Z���ʒu�̃I�t�Z�b�g
    static float2 MipTexOffset = (float2(0.5,0.5)/MIPMAPTEX_SIZE);
    
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// �~�b�v�}�b�v�쐬

#if MIPMAPTEX_SIZE!=0
    struct VS_OUTPUT_MIPMAPCREATER {
        float4 Pos    : POSITION;
        float2 Tex    : TEXCOORD0;
    };
    VS_OUTPUT_MIPMAPCREATER VS_MipMapCreater( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ){
        VS_OUTPUT_MIPMAPCREATER Out;
        Out.Pos = Pos;
        Out.Tex = Tex + MipTexOffset;
        return Out;
    }

    float4  PS_MipMapCreater(float2 Tex: TEXCOORD0) : COLOR0
    {
        return tex2D(DefObjTexSampler,Tex);
    }

    float4  PS_MapMipMapCreater(float2 Tex: TEXCOORD0) : COLOR0
    {
        return tex2D(DefMapTextureSampler,Tex);
    }
#endif

///////////////////////////////////////////////////////////////////////////////////////////////

float texlight(float3 rgb){
    float val = saturate((length(rgb) - LightThreshold) * 3);
    
    val *= 0.2;
    
    return val;
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �ǉ�UV��AL�p�f�[�^���ǂ�������

bool DecisionSystemCode(float4 SystemCode){
    bool val = (0.199 < SystemCode.r) && (SystemCode.r < 0.201)
            && (0.699 < SystemCode.g) && (SystemCode.g < 0.701);
    return val;
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float4 Color      : TEXCOORD0;   // �F
    float4 Tex        : TEXCOORD1;   // UV
};

#ifdef MIKUMIKUMOVING

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(MMM_SKINNING_INPUT IN)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    float4 SystemCode = IN.AddUV1;
    float4 ColorCode = IN.AddUV2;
    
    bool IsALCode = DecisionSystemCode(SystemCode);
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    float4 pos = MMM_SkinnedPosition(IN.Pos, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1);
    Out.Pos = mul( pos, WorldViewProjMatrix );
        
    Out.Color = MaterialDiffuse;
    Out.Color.rgb += MaterialEmmisive / 2;
    Out.Color.rgb *= 0.5;
    Out.Color.rgb = IsEmittion ? Out.Color.rgb : float3(0,0,0);
    
    float3 UVColor = ColorCode.rgb * ColorCode.a;
    
    Out.Color.rgb += IsALCode ? UVColor : float3(0,0,0);
    
    float timerate2 = (SystemCode.z > 0) ? ((1 - cos(saturate(frac(ftime / SystemCode.z) / (duty * 2)) * 2 * PI)) * 0.5)
                     : ((SystemCode.z < 0) ? (frac(ftime / (-SystemCode.z / PI * 180)) < duty) : 1.0);
    Out.Color.rgb *= max(timerate2 * (1 - BlinkMin) + BlinkMin, !IsALCode);
    Out.Color.rgb *= max(timerate1, SystemCode.z != 0);
    
    Out.Tex.xy = IN.Tex; //�e�N�X�`��UV
    Out.Tex.w = IsALCode && (0.99 < SystemCode.w && SystemCode.w < 1.01);
    
    return Out;
}

#else

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0, 
                   float4 SystemCode : TEXCOORD1, float4 ColorCode : TEXCOORD2)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    bool IsALCode = DecisionSystemCode(SystemCode);
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    Out.Color = MaterialDiffuse;
    Out.Color.rgb += MaterialEmmisive / 2;
    Out.Color.rgb *= 0.5;
    Out.Color.rgb = IsEmittion ? Out.Color.rgb : float3(0,0,0);
    
    float3 UVColor = ColorCode.rgb * ColorCode.a;
    
    Out.Color.rgb += IsALCode ? UVColor : float3(0,0,0);
    
    float timerate2 = (SystemCode.z > 0) ? ((1 - cos(saturate(frac(ftime / SystemCode.z) / (duty * 2)) * 2 * PI)) * 0.5)
                     : ((SystemCode.z < 0) ? (frac(ftime / (-SystemCode.z / PI * 180)) < duty) : 1.0);
    Out.Color.rgb *= max(timerate2 * (1 - BlinkMin) + BlinkMin, !IsALCode);
    Out.Color.rgb *= max(timerate1, SystemCode.z != 0);
    
    Out.Tex.xy = Tex; //�e�N�X�`��UV
    Out.Tex.w = IsALCode && (0.99 < SystemCode.w && SystemCode.w < 1.01);
    
    return Out;
}

#endif

// �s�N�Z���V�F�[�_
float4 Basic_PS(VS_OUTPUT IN, uniform bool useTexture, uniform bool useToon) : COLOR0
{
    float4 Color = IN.Color;
    
    if(useTexture){
        #ifdef TEXTURE_SELECTLIGHT
            Color = tex2D(ObjTexSampler,IN.Tex.xy);
            Color.rgb *= texlight(Color.rgb);
        #else
            Color *= max(tex2D(ObjTexSampler,IN.Tex.xy), IN.Tex.w);
        #endif
        
        float4 glow = tex2D(MapTextureSampler, IN.Tex.xy);
        
        Color.rgb += glow.rgb * glow.a;
    }
    
    if(useToon){
        Color.rgb *= EmittionPower1;
    }else{
        Color.rgb *= EmittionPower0;
    }
    
    return Color;
}

///////////////////////////////////////////////////////////////////////////////////////////////

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec1 < string MMDPass = "object"; bool UseTexture = false; bool UseToon = false; > {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(false, false);
    }
}

technique MainTec2 < string MMDPass = "object"; bool UseTexture = true; bool UseToon = false; 
                     string Script = MIPMAPSCRIPT;
> {
    
    CREATEMIPMAP
    
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(true, false);
    }
}

technique MainTec3 < string MMDPass = "object"; bool UseTexture = false; bool UseToon = true; > {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(false, true);
    }
}

technique MainTec4 < string MMDPass = "object"; bool UseTexture = true; bool UseToon = true; 
                     string Script = MIPMAPSCRIPT;
> {
    
    CREATEMIPMAP
    
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(true, true);
    }
}


technique MainTecBS1 < string MMDPass = "object_ss"; bool UseTexture = false; bool UseToon = false; > {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(false, false);
    }
}

technique MainTecBS2 < string MMDPass = "object_ss"; bool UseTexture = true; bool UseToon = false; 
                       string Script = MIPMAPSCRIPT;
 > {
    
    CREATEMIPMAP
    
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(true, false);
    }
}

technique MainTecBS3 < string MMDPass = "object_ss"; bool UseTexture = false; bool UseToon = true; > {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(false, true);
    }
}

technique MainTecBS4 < string MMDPass = "object_ss"; bool UseTexture = true; bool UseToon = true; 
                       string Script = MIPMAPSCRIPT;
 > {
    
    CREATEMIPMAP
    
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(true, true);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////

//�e��֊s�͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

