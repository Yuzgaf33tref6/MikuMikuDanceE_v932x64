////////////////////////////////////////////////////////////////////////////////////////////////
//	
//	ObjectLuminous�p�V���v���G�~�b�^�[�i�ق�Basic.fx�j
//	�쐬�F�r�[���}��P
//  �x�[�X�FBasic.fx
//  �쐬: ���͉��P
//
////////////////////////////////////////////////////////////////////////////////////////////////

//���[�U��`�ϐ�

//�F�� ������RGBA
float4 AddColor = float4(0.05,0,0.5,1);

// �p�����[�^�錾

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {

}


///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��

// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {

}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS() : COLOR0
{
    return AddColor;
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
// �s�v�Ȃ��͍̂폜��
technique MainTec < string MMDPass = "object";> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}
technique MainTec_ss < string MMDPass = "object_ss";> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}