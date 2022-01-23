////////////////////////////////////////////////////////////////////////////////////////////////
//
//  SF_Mask1.fx  �}�X�N�摜�쐬�C�K�p���f�����𔒂�
//  ( ShadeFader.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P( ���͉��P����full.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////

// ���W�ϊ��s��
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;


////////////////////////////////////////////////////////////////////////////////////////////////

// ���_�V�F�[�_
float4 VS_Mask(float4 Pos : POSITION) : POSITION
{
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    return mul( Pos, WorldViewProjMatrix );
}

//�s�N�Z���V�F�[�_
float4 PS_Mask() : COLOR {
    return float4(1.0, 1.0, 1.0, 1.0);
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique EdgeTec < string MMDPass = "edge"; > {
    pass DrawMask {
        VertexShader = compile vs_2_0 VS_Mask();
        PixelShader  = compile ps_2_0 PS_Mask();
    }
}

technique ShadowTec < string MMDPass = "shadow"; > {
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


