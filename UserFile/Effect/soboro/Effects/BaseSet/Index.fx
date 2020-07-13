

float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;

// ���_��
int VertexCount;

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float4 Color      : COLOR0;      // �f�B�t���[�Y�F
};


VS_OUTPUT Basic_VS(float4 Pos : POSITION, int index: _INDEX)
{
    VS_OUTPUT Out;
    Out.Pos = mul( Pos, WorldViewProjMatrix );

    float f = (float)index/VertexCount;
    Out.Color = float4(f,f,f,1);
    
    return Out;
}

float4 Basic_PS( VS_OUTPUT IN ) : COLOR0
{
    return IN.Color;
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec < string MMDPass = "object"; > {
    pass DrawObject
    {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}
technique MainTecSS < string MMDPass = "object_ss"; > {
    pass DrawObject
    {
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

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////

