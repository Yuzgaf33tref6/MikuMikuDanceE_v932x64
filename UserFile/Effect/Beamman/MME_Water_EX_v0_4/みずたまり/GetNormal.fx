// �p�����[�^�錾

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 ViewMatrix               : VIEW;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float4x4 MirrorWorldMatrix: CONTROLOBJECT < string Name = "(OffscreenOwner)"; >;
float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);



///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��


// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {

}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float4 WPos        : TEXCOORD1;    // ���[���h���W
    float3 Normal     : TEXCOORD2;   // �@��
};

// ���_�V�F�[�_
VS_OUTPUT NormalAndLen_VS(float4 Pos : POSITION, float3 Normal : NORMAL)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    Out.WPos = mul( Pos,WorldMatrix);
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    // ���_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 NormalAndLen_PS(VS_OUTPUT IN) : COLOR0
{
	float ypos = IN.WPos.y + 0xffff;
    return float4(IN.Normal,ypos);
}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {

}

////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 NormalAndLen_VS();
        PixelShader  = compile ps_3_0 NormalAndLen_PS();
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
technique MainTec  < string MMDPass = "object_ss"; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 NormalAndLen_VS();
        PixelShader  = compile ps_3_0 NormalAndLen_PS();
    }
}
technique MainTec  < string MMDPass = "object"; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 NormalAndLen_VS();
        PixelShader  = compile ps_3_0 NormalAndLen_PS();
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////
