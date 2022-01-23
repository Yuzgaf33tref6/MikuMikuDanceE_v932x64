////////////////////////////////////////////////////////////////////////////////////////////////
//
//  PC_Object.fx ���f���̌`����}�X�N����G�t�F�N�g
//  ( PostClip_Obj.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////

// ���W�ϊ��p�����[�^
float4x4 ViewMatrix          : VIEW;
float4x4 ProjMatrix          : PROJECTION;
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

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
};

// ���_�V�F�[�_
VS_OUTPUT Object_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    // ���[���h�r���[�ˉe���W�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

//�s�N�Z���V�F�[�_(�G�b�W�`��)
float4 PS_EdgeMask(VS_OUTPUT IN) : COLOR
{
    // �N���b�v����Ƃ���𔒂œh��ׂ�
    return float4(1, 1, 1, 1);
}

//�s�N�Z���V�F�[�_(�I�u�W�F�N�g�`��)
float4 PS_ObjectMask(VS_OUTPUT IN, uniform bool useTexture) : COLOR
{
    float alpha = MaterialDiffuse.a;

    if ( useTexture ) {
        // �e�N�X�`�����ߒl�K�p
        alpha *= tex2D( ObjTexSampler, IN.Tex ).a;
    }

    clip(alpha - 0.005f);

    // �N���b�v����Ƃ���𔒂œh��ׂ�
    return float4(1, 1, 1, 1);
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
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader = compile ps_2_0 PS_ObjectMask(false);
    }
}

technique Mask1 < string MMDPass = "object"; bool UseTexture = true; > {
    pass DrawMask {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader = compile ps_2_0 PS_ObjectMask(true);
    }
}

technique MaskSS0 < string MMDPass = "object_ss"; bool UseTexture = false; > {
    pass DrawMask {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader = compile ps_2_0 PS_ObjectMask(false);
    }
}

technique MaskSS1 < string MMDPass = "object_ss"; bool UseTexture = true; > {
    pass DrawMask {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader = compile ps_2_0 PS_ObjectMask(true);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////

// �n�ʉe�͕`�悵�Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }
// MMD�W���̃Z���t�V���h�E�͕`�悵�Ȃ�
technique ZplotTec < string MMDPass = "zplot"; > { }

