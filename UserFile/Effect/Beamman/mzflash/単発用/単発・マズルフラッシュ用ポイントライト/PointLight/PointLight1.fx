// PointLight1

// �Ɩ��|�C���g�̕\��
static bool Draw = false;


//----
float ObjScaling : CONTROLOBJECT < string name = "PointLight1.x"; >;         // �X�P�[��
float4x4 ObjWorldMatrix : CONTROLOBJECT < string name = "PointLight1.x"; >;  // 

float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;

// �s��̉�]�ʂ���F�擾
float3 getRotCol(float4x4 rm)
{

    float4x4 m = rm / ObjScaling;
    return float3(degrees(-asin(m._32)),degrees(-atan2(-m._31, m._33)),degrees(-atan2(-m._12, m._22)));
}

// �F
static float3 LightColor = getRotCol(ObjWorldMatrix);


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

// ���_�V�F�[�_
float4 PL_VS(float4 Pos : POSITION, float3 Normal : NORMAL, uniform bool draw) : POSITION
{
    float4 p = float4(0,0,1,0);
    if(draw) {
        p = mul( Pos, WorldViewProjMatrix );
    }
    return p;
}

// �s�N�Z���V�F�[�_
float4 PL_PS() : COLOR0
{
    return float4(LightColor, 1);
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
technique MainTec0 < string MMDPass = "object"; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 PL_VS(Draw);
        PixelShader  = compile ps_3_0 PL_PS();
    }
}

technique MainTec0 < string MMDPass = "object_ss"; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 PL_VS(Draw);
        PixelShader  = compile ps_3_0 PL_PS();
    }
}



