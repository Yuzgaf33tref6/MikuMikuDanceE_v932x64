//�|�X�g�|�C���g���C�g�p�G�t�F�N�g
//--���ρF�r�[���}��P

// �p�����[�^�錾
// ���W�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 ViewMatrix               : VIEW;
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};
//----

// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {

}


// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {

}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex : TEXCOORD0;
    float4 WPos	 	  : TEXCOORD1;	 // ���[���h���W
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION,float2 Tex: TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    Out.Tex = Tex;
    Out.Pos = mul( Pos, WorldViewProjMatrix );
	Out.WPos = mul(Pos,WorldMatrix);

    return Out;
}
///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EON�j

// �s�N�Z���V�F�[�_
float4 BufferShadow_PS(VS_OUTPUT IN) : COLOR0
{
	float a = MaterialDiffuse.a * tex2D(ObjTexSampler,IN.Tex).a;
	if(a <= 0.9)
	{
		a = 0;
	}
	
    return float4(IN.WPos.xyz,a);
}
technique MainTec0 < string MMDPass = "object";> {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS();
        PixelShader  = compile ps_3_0 BufferShadow_PS();
    }
}
// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
technique MainTecBS0  < string MMDPass = "object_ss"; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS();
        PixelShader  = compile ps_3_0 BufferShadow_PS();
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////