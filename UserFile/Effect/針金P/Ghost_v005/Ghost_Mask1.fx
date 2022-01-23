////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Ghost_Mask1.fx ver0.0.5  �}�X�N�摜�쐬�C�K�p���f�����𔒂�
//  ( Ghost.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P( ���͉��P����full.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////

// ���W�ϊ��s��
float4x4 WorldMatrix     : WORLD;
float4x4 ViewProjMatrix  : VIEWPROJECTION;

////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
    float4 Pos  : POSITION;    // �ˉe�ϊ����W
    float4 VPos : TEXCOORD1;   // ���[���h�ϊ����W
};

// ���_�V�F�[�_
VS_OUTPUT VS_Mask(float4 Pos : POSITION)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // ���[���h���W�ϊ�
    Pos = mul( Pos, WorldMatrix );
    Out.VPos = Pos;

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, ViewProjMatrix );

    return Out;
}

//�s�N�Z���V�F�[�_
float4 PS_Mask(VS_OUTPUT IN) : COLOR
{
    float h = max( IN.VPos.y/IN.VPos.w, 0.0f );
    float h10 = saturate( floor(h/10.0f) * 0.1f );
    float h1 = saturate( fmod(h,10.0f) * 0.1f );
    return float4(1.0, h10, h1, 1.0);
}

technique EdgeTec < string MMDPass = "edge"; > {
    pass DrawMask {
        VertexShader = compile vs_2_0 VS_Mask();
        PixelShader  = compile ps_2_0 PS_Mask();
    }
}

//�Z���t�V���h�E�Ȃ�
technique Mask < string MMDPass = "object"; > {
    pass DrawMask {
        VertexShader = compile vs_2_0 VS_Mask();
        PixelShader  = compile ps_2_0 PS_Mask();
    }
}

//�Z���t�V���h�E����
technique MaskSS < string MMDPass = "object_ss"; > {
    pass DrawMask {
        VertexShader = compile vs_2_0 VS_Mask();
        PixelShader  = compile ps_2_0 PS_Mask();
    }
}

//�`�悵�Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }

