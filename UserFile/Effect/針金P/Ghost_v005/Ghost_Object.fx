////////////////////////////////////////////////////////////////////////////////////////////////
//
//  �w��I�u�W�F�N�g�̓I�t�X�N���[���݂̂ɕ`�悷�邽�ߒʏ�`����\���ɂ���
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���W�ϊ��s��
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

#ifndef MIKUMIKUMOVING
///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g
// ���g�̃Z���t�V���h�[�`����s�����߂�Z�o�b�t�@�v���b�g�����͏o�͂���K�v�L��
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

    return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS( float4 ShadowMapTex : TEXCOORD0 ) : COLOR
{
    // R�F������Z�l���L�^����
    return float4(ShadowMapTex.z/ShadowMapTex.w,0,0,1);
}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {
    pass ZValuePlot {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 ZValuePlot_VS();
        PixelShader  = compile ps_2_0 ZValuePlot_PS();
    }
}

#endif

// ���͑S�Ĕ�\���ɂ���
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique MainTec < string MMDPass = "object"; > { }
technique MainTecBS  < string MMDPass = "object_ss"; > { }

///////////////////////////////////////////////////////////////////////////////////////////////
