////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Heat_PosDepthMMM.fxsub  �ʒu�E�[�x�}�b�v�쐬(MME�EMMM���p)
//  ( HeatGround.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���ߒl�ɑ΂���[�x�ǂݎ��臒l
float AlphaClipThreshold = 0.5;

// ���W�ϊ��s��
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;
float4x4 WorldViewMatrix     : WORLDVIEW;
float4x4 WorldMatrix         : WORLD;
float4x4 ProjMatrix          : PROJECTION;

//�J�����ʒu
float3 CameraPosition  : POSITION < string Object = "Camera"; >;

// �}�e���A���F
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
float4 EdgeColor       : EDGECOLOR;

bool opadd; // ���Z�����t���O

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�

#ifndef MIKUMIKUMOVING
    struct VS_INPUT{
        float4 Pos    : POSITION;
        float2 Tex    : TEXCOORD0;
        float3 Normal : NORMAL;
    };
    #define MMM_SKINNING
    #define GETPOS      (IN.Pos)
    #define GETPOSEDGE  (0.0f)
    #define GET_WVPMAT(p) (WorldViewProjMatrix)
#else
    float  EdgeWidth : EDGEWIDTH;
    #define VS_INPUT  MMM_SKINNING_INPUT
    #define MMM_SKINNING  MMM_SKINNING_OUTPUT SkinOut = MMM_SkinnedPositionNormal(IN.Pos, IN.Normal, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1);
    #define GETPOS      (SkinOut.Position)
    #define GETPOSEDGE  (float4(SkinOut.Normal, 0) * IN.EdgeWeight * EdgeWidth * distance(Pos.xyz, CameraPosition))
    #define GET_WVPMAT(p) (MMM_IsDinamicProjection ? mul(WorldViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-p.xyz))) : WorldViewProjMatrix)
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// �[�x�`��

struct VS_OUTPUT {
    float4 Pos  : POSITION;
    float4 WPos : TEXCOORD0;
    float2 Tex  : TEXCOORD2;
};

//==============================================
// ���_�V�F�[�_
//==============================================
VS_OUTPUT VS_Object(VS_INPUT IN, uniform bool isObj)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    MMM_SKINNING

    float4 Pos = GETPOS;
    if( !isObj ) Pos += GETPOSEDGE;

    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_WVPMAT(Pos) );

    // �J�������_�̃��[���h�ϊ�
    Out.WPos = mul( Pos, WorldMatrix );

    // �e�N�X�`�����W
    Out.Tex = IN.Tex;

    return Out;
}

//==============================================
// �s�N�Z���V�F�[�_
//==============================================
float4 PS_Object(VS_OUTPUT IN, uniform bool isObj, uniform bool useTexture) : COLOR0
{
    float alpha;
    if( isObj ) {
        alpha = MaterialDiffuse.a * !opadd;
        if ( useTexture ) {
            // �e�N�X�`�����ߒl�K�p
            alpha *= tex2D( ObjTexSampler, IN.Tex ).a * !opadd;
        }
    }else{
        alpha = EdgeColor.a * !opadd;
    }
    // ���l��臒l�ȉ��̉ӏ��͕`�悵�Ȃ�
    clip(alpha - AlphaClipThreshold);

    return float4(IN.WPos.xyz / IN.WPos.w, 0.0f);
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

// �G�b�W�`��
technique EdgeDepthTec < string MMDPass = "edge"; >
{
    pass DrawEdge {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_3_0 VS_Object(false);
        PixelShader  = compile ps_3_0 PS_Object(false, false);
    }
}

// �I�u�W�F�N�g�`��(�Z���t�V���h�E�Ȃ�)
technique DepthTec0 < string MMDPass = "object"; bool UseTexture = false; >
{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 VS_Object(true);
        PixelShader  = compile ps_2_0 PS_Object(true, false);
    }
}

technique DepthTec1 < string MMDPass = "object"; bool UseTexture = true; >
{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 VS_Object(true);
        PixelShader  = compile ps_2_0 PS_Object(true, true);
    }
}

// �I�u�W�F�N�g�`��(�Z���t�V���h�E����)
technique DepthTecSS0 < string MMDPass = "object_ss"; bool UseTexture = false; >
{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 VS_Object(true);
        PixelShader  = compile ps_2_0 PS_Object(true, false);
    }
}

technique DepthTecSS1 < string MMDPass = "object_ss"; bool UseTexture = true; >
{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 VS_Object(true);
        PixelShader  = compile ps_2_0 PS_Object(true, true);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////

//�n�ʉe�͕`�悵�Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }

