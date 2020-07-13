////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ExcellentShadowObject
//  �쐬: ���ڂ�
//
////////////////////////////////////////////////////////////////////////////////////////////////


#include "ExcellentShadowCommonSystem.fx"


//�A�N�Z�T���ɖ@�����g�����A�e�����邩
#define UNTOON_NORMALSHADOW 1


////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾


// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 ViewMatrix               : VIEW;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float    SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;
float3   MaterialToon      : TOONCOLOR;
float4   EdgeColor         : EDGECOLOR;
// ���C�g�F
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = min(1, MaterialAmbient * LightAmbient + MaterialEmmisive);
static float3 SpecularColor = MaterialSpecular * LightSpecular;

bool     parthf;   // �p�[�X�y�N�e�B�u�t���O
bool     transp;   // �������t���O
bool     spadd;    // �X�t�B�A�}�b�v���Z�����t���O
#define SKII1    1500
#define SKII2    8000
#define Toon     3

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = ANISOTROPIC;
    MAGFILTER = ANISOTROPIC;
    MIPFILTER = LINEAR;
    MAXANISOTROPY = 16;
};

// �X�t�B�A�}�b�v�̃e�N�X�`��
texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state {
    texture = <ObjectSphereMap>;
    MINFILTER = ANISOTROPIC;
    MAGFILTER = ANISOTROPIC;
    MIPFILTER = LINEAR;
    MAXANISOTROPY = 16;
};

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);



////////////////////////////////////////////////////////////////////////////////////////////////

shared texture ExcellentShadowZMap : OFFSCREENRENDERTARGET;

sampler ExcellentShadowZMapSampler = sampler_state {
    texture = <ExcellentShadowZMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

shared texture ExcellentShadowZMapFar : OFFSCREENRENDERTARGET;

sampler ExcellentShadowZMapFarSampler = sampler_state {
    texture = <ExcellentShadowZMapFar>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

// ���_�V�F�[�_
float4 ColorRender_VS(float4 Pos : POSITION) : POSITION 
{
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    float4 Out = mul( Pos, WorldViewProjMatrix );
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 ColorRender_PS() : COLOR
{
    // �֊s�F�œh��Ԃ�
    return EdgeColor;
}

// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {
    /*pass DrawEdge {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        
        VertexShader = compile vs_2_0 ColorRender_VS();
        PixelShader  = compile ps_2_0 ColorRender_PS();
    }*/
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��

// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec0 < string MMDPass = "object";  > {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g

struct VS_ZValuePlot_OUTPUT {
    float4 Pos : POSITION;              // �ˉe�ϊ����W
    float4 ShadowMapTex : TEXCOORD0;    // Z�o�b�t�@�e�N�X�`��
};

// ���_�V�F�[�_
VS_ZValuePlot_OUTPUT ZValuePlot_VS( float4 Pos : POSITION )
{
    VS_ZValuePlot_OUTPUT Out = (VS_ZValuePlot_OUTPUT)0;
    
    // ���C�g�̖ڐ��ɂ�郏�[���h�r���[�ˉe�ϊ�������
    Out.Pos = mul( Pos, LightWorldViewProjMatrix );
    
    // �e�N�X�`�����W�𒸓_�ɍ��킹��
    Out.ShadowMapTex = Out.Pos;
    
    //Out.Pos.z *= 0.1;
    //Out.Pos.z += 0.1;
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS( float4 ShadowMapTex : TEXCOORD0 ) : COLOR
{
    float depth = ShadowMapTex.z/ShadowMapTex.w;
    
    // R�F������Z�l���L�^����
    return float4(depth, 0, 0, 1);
}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {
    pass ZValuePlot {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 ZValuePlot_VS();
        PixelShader  = compile ps_2_0 ZValuePlot_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EON�j

// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);

struct BufferShadow_OUTPUT {
    float4 Pos       : POSITION;     // �ˉe�ϊ����W
    float4 ZCalcTex  : TEXCOORD0;    // Z�l
    float2 Tex       : TEXCOORD1;    // �e�N�X�`��
    float3 Normal    : TEXCOORD2;    // �@��
    float3 Eye       : TEXCOORD3;    // �J�����Ƃ̑��Έʒu
    float4 IZCalcTex : TEXCOORD4;     // �X�t�B�A�}�b�v�e�N�X�`�����W
    
    float4 ScreenPos : TEXCOORD5;
    
};

// ���_�V�F�[�_
BufferShadow_OUTPUT BufferShadow_VS(MMM_SKINNING_INPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon)
{
    BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;
    
    float4 pos = GETPOS;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( pos, WorldViewProjMatrix );
    
    Out.ScreenPos = Out.Pos;
    
    Out.Normal = normalize( mul( IN.Normal, (float3x3)WorldMatrix ) );
    // ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�
    Out.ZCalcTex = mul( pos, LightWorldViewProjMatrix );
    Out.IZCalcTex = mul( pos, InternalLightWorldViewProjMatrix );
    
    // �e�N�X�`�����W
    Out.Tex = IN.Tex;
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 BufferShadow_PS(BufferShadow_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon) : COLOR
{
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;
    
    float4 Color = float4(1,1,1,1);
    
    float Alpha = DiffuseColor.a;
    float ShadowRate = 1;
    float ShadowBlurStrength = 0;
    
    float Z1 = IN.ScreenPos.w;
    
    if ( useTexture ) {
        // �e�N�X�`���K�p
        float4 TexColor = tex2D( ObjTexSampler, IN.Tex );
        Alpha *= TexColor.a;
        
    }
    
    
    
    ///////////////////////////////////////////////////////////////////////
    //�V���h�E�V�X�e��
    
    // �e�N�X�`�����W�ɕϊ�
    IN.IZCalcTex.xyz /= IN.IZCalcTex.w;
    float2 TransTexCoord1 = 0.5 + IN.IZCalcTex.xy * float2(0.5, -0.5);
    float2 TransTexCoord2 = 0.5 + (IN.IZCalcTex.xy / SIZERATE_FAR) * float2(0.5, -0.5);
    
    float farfade = saturate(5 * (1 - length(IN.IZCalcTex.xy / SIZERATE_FAR)));
    
    if(!any( saturate(TransTexCoord2) != TransTexCoord2 ) ) { 
        float comp;
        
        float mixrate = saturate((length(IN.IZCalcTex.xy) - 0.8) / (1 - 0.8));
        
        float depth = tex2D(ExcellentShadowZMapSampler,TransTexCoord1).r;
        float depth2 = tex2D(ExcellentShadowZMapFarSampler,TransTexCoord2).r;
        
        depth = lerp(depth, depth2, mixrate);
        
        float dist = IN.IZCalcTex.z - depth;
        
        //comp = 1 - saturate(max(dist, 0.0f) * 20000 / (1 + mixrate * 3) - 0.05);
        comp = 1 - saturate(max(dist, 0.0f) * 20000 * size1 / (1 + mixrate * 3) - 0.05 * sqrt(size1));
        
        comp = lerp(1, comp, farfade);
        
        ShadowBlurStrength = max(0, dist) * 300 / sqrt(size1);
        ShadowRate = comp;
    }
    
    
    #ifndef MIKUMIKUMOVING
    
    // �e�N�X�`�����W�ɕϊ�
    IN.ZCalcTex /= IN.ZCalcTex.w;
    float2 TransTexCoord0;
    TransTexCoord0.x = (1.0f + IN.ZCalcTex.x)*0.5f;
    TransTexCoord0.y = (1.0f - IN.ZCalcTex.y)*0.5f;
    
    if( !any( saturate(TransTexCoord0) != TransTexCoord0 ) && IN.ZCalcTex.z <= 1) {
        
        float comp;
        
        float dist = IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord0).r;
        
        float mixrate = saturate(4 * (1 - length(IN.ZCalcTex.xy)));
        
        if(parthf) {
            // �Z���t�V���h�E mode2
            comp=1-saturate(max(dist , 0.0f)*SKII2*TransTexCoord0.y-0.3f);
        } else {
            // �Z���t�V���h�E mode1
            comp=1-saturate(max(dist , 0.0f)*SKII1-0.3f);
        }
        
        
        float mix1 = lerp(ShadowRate, comp, mixrate);
        float mix2 = min(ShadowRate, lerp(1, comp, mixrate));
        
        ShadowRate = lerp(mix1, mix2, saturate(ShadowBlurStrength * 6));
        
    }
    
    #endif
    
    
    if ( useToon ) ShadowRate = min(ShadowRate, saturate(dot(IN.Normal,-LightDirection)*Toon));
    #if UNTOON_NORMALSHADOW==1
    //else           ShadowRate = min(ShadowRate, saturate(dot(IN.Normal,-LightDirection)*Toon));
    #endif
    
    
    Color.r = ShadowRate;
    Color.g = Z1;
    Color.b = ShadowBlurStrength;
    Color.a = Alpha;
    
    if(Alpha < 0.9) Color.a = 0;
    
    return Color;
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
technique MainTecBS0  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, false, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, false, false);
    }
}

technique MainTecBS1  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, false, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, false, false);
    }
}

technique MainTecBS2  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, true, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, true, false);
    }
}

technique MainTecBS3  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, true, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, true, false);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD���f���p�j
technique MainTecBS4  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, false, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, false, true);
    }
}

technique MainTecBS5  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, false, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, false, true);
    }
}

technique MainTecBS6  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, true, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, true, true);
    }
}

technique MainTecBS7  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, true, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, true, true);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
