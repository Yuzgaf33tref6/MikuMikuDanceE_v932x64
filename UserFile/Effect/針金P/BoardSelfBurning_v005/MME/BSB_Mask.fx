////////////////////////////////////////////////////////////////////////////////////////////////
//
//  BSB_Mask.fx ���f���̌`��ɍ��킹�ĉ����o���G�t�F�N�g(���C���}�X�N�p)
//  ( BoardSelfBurning.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////

// ���W�ϊ��p�����[�^
float4x4 ViewMatrix          : VIEW;
float4x4 ProjMatrix          : PROJECTION;
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

float4x4 BoardWorldMatrix: CONTROLOBJECT < string Name = "(OffscreenOwner)"; >; // �{�[�h�̃��[���h�ϊ��s��
static float3 PlanarPos = mul( BoardWorldMatrix[3], ViewMatrix ).xyz;  // ���e���镽�ʏ�̌��_���W

// �}�e���A���F
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;

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
// �{�[�h�ʂւ̕`��

struct VS_OUTPUT {
    float4 Pos  : POSITION;
    float2 Tex  : TEXCOORD0;
    float4 VPos : TEXCOORD1; // �I�u�W�F�N�g���[���h�r���[�ˉe���W
    float4 CPos : TEXCOORD2; // �{�[�h�ʒ��S���[���h�r���[�ˉe���W
};

// ���_�V�F�[�_
VS_OUTPUT Object_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    // ���[���h�r���[�ˉe���W�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.VPos = Out.Pos;

    // �{�[�h�ʒ��S���[���h�r���[�ˉe�ϊ�
    Out.CPos = mul( float4(PlanarPos, 1), ProjMatrix );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

//�s�N�Z���V�F�[�_(�G�b�W�`��)
float4 PS_EdgeMask(VS_OUTPUT IN) : COLOR
{
    // �{�[�h�ʂ̉����͕`�悵�Ȃ�
    clip(IN.CPos.z/IN.CPos.w - IN.VPos.z/IN.VPos.w);

    return float4(0, 0, 0, 1);
}

//�s�N�Z���V�F�[�_(�I�u�W�F�N�g�`��)
float4 PS_ObjectMask(VS_OUTPUT IN, uniform bool useTexture) : COLOR
{
    // �{�[�h�ʂ̉����͕`�悵�Ȃ�
    clip(IN.CPos.z/IN.CPos.w - IN.VPos.z/IN.VPos.w);

    float alpha = MaterialDiffuse.a;

    if ( useTexture ) {
        // �e�N�X�`�����ߒl�K�p
        alpha *= tex2D( ObjTexSampler, IN.Tex ).a;
    }

    clip(alpha - 0.005f);

    return float4(alpha, alpha, alpha, 0.01); // ���]���ĐώZ��������̂�
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique EdgeTec < string MMDPass = "edge"; > {
    pass DrawMask {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader = compile ps_2_0 PS_EdgeMask();
    }
}

technique Mask0 < string MMDPass = "object"; bool UseTexture = false; > {
    pass DrawMask {
        AlphaBlendEnable = TRUE;
        SrcBlend = ZERO;
        DestBlend = INVSRCCOLOR;
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader = compile ps_2_0 PS_ObjectMask(false);
    }
}

technique Mask1 < string MMDPass = "object"; bool UseTexture = true; > {
    pass DrawMask {
        AlphaBlendEnable = TRUE;
        SrcBlend = ZERO;
        DestBlend = INVSRCCOLOR;
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader = compile ps_2_0 PS_ObjectMask(true);
    }
}

technique MaskSS0 < string MMDPass = "object_ss"; bool UseTexture = false; > {
    pass DrawMask {
        AlphaBlendEnable = TRUE;
        SrcBlend = ZERO;
        DestBlend = INVSRCCOLOR;
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader = compile ps_2_0 PS_ObjectMask(false);
    }
}

technique MaskSS1 < string MMDPass = "object_ss"; bool UseTexture = true; > {
    pass DrawMask {
        AlphaBlendEnable = TRUE;
        SrcBlend = ZERO;
        DestBlend = INVSRCCOLOR;
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader = compile ps_2_0 PS_ObjectMask(true);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////

// �n�ʉe�͕`�悵�Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }
// MMD�W���̃Z���t�V���h�E�͕`�悵�Ȃ�
technique ZplotTec < string MMDPass = "zplot"; > { }

