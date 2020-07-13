// �ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;

//HDR����ۑ�����e�N�X�`��
shared texture HDROutTex : RenderColorTarget;

sampler HDROutSamp = sampler_state
{
	Texture = <HDROutTex>;
	Filter = LINEAR;
};

// ���_�V�F�[�_
struct OutVS
{
	float4 Pos : POSITION;
	float2 Tex : TEXCOORD0;
};

OutVS Test_VS(float4 Pos : POSITION,float2 Tex : TEXCOORD0)
{
	OutVS Out;
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.Tex = Tex*float2(-1,1);
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Test_PS(OutVS IN) : COLOR
{
	return tex2D(HDROutSamp,IN.Tex);
}

// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {}
// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {}
// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainPass  < string MMDPass = "object"; > {
    pass DrawObject {
        VertexShader = compile vs_2_0 Test_VS();
        PixelShader  = compile ps_2_0 Test_PS();
    }
}
technique MainPass_SS  < string MMDPass = "object_ss"; > {
    pass DrawObject {
        VertexShader = compile vs_2_0 Test_VS();
        PixelShader  = compile ps_2_0 Test_PS();
    }
}
