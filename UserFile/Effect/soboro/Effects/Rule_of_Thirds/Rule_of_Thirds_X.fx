

float3 LineColor = float3(0.3, 0.3, 0.3);

////////////////////////////////////////////////////////////////////////////////////////////////

float scaling0 : CONTROLOBJECT < string name = "(self)"; >;
static float scaling = scaling0 * 0.1;

//�A���t�@�l�擾
float alpha1 : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

//�t���[�����ԂƃV�X�e�����Ԃ���v������Đ����Ƃ݂Ȃ�
float elapsed_time1 : ELAPSEDTIME<bool SyncInEditMode=true;>;
float elapsed_time2 : ELAPSEDTIME<bool SyncInEditMode=false;>;
static bool IsPlaying = (abs(elapsed_time1 - elapsed_time2) < 0.01) && (scaling > 0.5);


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

struct VS_OUTPUT2
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
};

// ���_�V�F�[�_
VS_OUTPUT2 Line_VS(float4 Pos : POSITION, float3 Normal : NORMAL, uniform bool hidden)
{
    VS_OUTPUT2 Out = (VS_OUTPUT2)0;
    
    Out.Pos = Pos;
    Out.Pos.z = 0;
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Line_PS( VS_OUTPUT2 IN ) : COLOR0
{
    return float4(LineColor, alpha1 * (1 - IsPlaying));
}

///////////////////////////////////////////////////////////////////////////////////////////////
// ���̑��̃I�u�W�F�N�g���}�X�N�`��

technique MainTec < string MMDPass = "object"; > {
    pass DrawObject {
        FillMode = WIREFRAME;
        VertexShader = compile vs_2_0 Line_VS(false);
        PixelShader  = compile ps_2_0 Line_PS();
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTecBS  < string MMDPass = "object_ss"; > {
    pass DrawObject {
        FillMode = WIREFRAME;
        VertexShader = compile vs_2_0 Line_VS(false);
        PixelShader  = compile ps_2_0 Line_PS();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////

technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTech < string MMDPass = "shadow";  > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

///////////////////////////////////////////////////////////////////////////////////////////////
