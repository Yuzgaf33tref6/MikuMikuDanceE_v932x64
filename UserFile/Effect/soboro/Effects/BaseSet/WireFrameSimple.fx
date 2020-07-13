////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float4 DrawColor = float4(0, 0.9, 0.5, 0.5);



// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION)
{
    VS_OUTPUT Out;
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS() : COLOR0
{
    return DrawColor;
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec < string MMDPass = "object"; > {
    pass DrawObject {
        FillMode = WIREFRAME;
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTecSS < string MMDPass = "object_ss"; > {
    pass DrawObject {
        FillMode = WIREFRAME;
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

// �֊s�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��

// �e�Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g

// �Z���t�V���h�E�Ȃ�
technique ZplotTec < string MMDPass = "zplot"; > {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////
