////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Hologram_Mask1.fx  �}�X�N�摜�쐬�C�K�p���f�����𔒂�
//  ( Hologram.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P( ���͉��P����full.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////

float3 BoneCenter : CONTROLOBJECT < string name = "(self)"; string item = "�Z���^�["; >;
float3 AcsOffset : CONTROLOBJECT < string name = "(self)"; >;

// ���W�ϊ��s��
float4x4 WorldMatrix      : WORLD;
float4x4 ProjMatrix       : PROJECTION;
float4x4 ViewProjMatrix   : VIEWPROJECTION;

float3 CameraPosition   : POSITION  < string Object = "Camera"; >;
static float PmdEyeLength = max( length( CameraPosition - BoneCenter ), 10.0f ) * pow(2.4142f / ProjMatrix._22, 0.7f);;
static float AcsEyeLength = max( length( CameraPosition - AcsOffset ), 10.0f ) * pow(2.4142f / ProjMatrix._22, 0.7f);;


////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
    float4 Pos  : POSITION;    // �ˉe�ϊ����W
    float4 VPos : TEXCOORD1;   // ���[���h�ϊ����W
};

// ���_�V�F�[�_
VS_OUTPUT VS_Mask(float4 Pos : POSITION)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // ���[���h���W�ϊ�
    Pos = mul( Pos, WorldMatrix );
    Out.VPos = Pos;

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, ViewProjMatrix );

    return Out;
}

//�s�N�Z���V�F�[�_
float4 PS_PmdMask(VS_OUTPUT IN) : COLOR
{
    float height = IN.VPos.y/IN.VPos.w;
    return float4(1.0f, height, min(PmdEyeLength, 40.0f), 1.0f);
}

float4 PS_AcsMask(VS_OUTPUT IN) : COLOR
{
    float height = IN.VPos.y/IN.VPos.w;
    return float4(1.0f, height, min(AcsEyeLength, 40.0f), 1.0f);
}

//////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique EdgeTec < string MMDPass = "edge"; > {
    pass DrawMask {
        VertexShader = compile vs_2_0 VS_Mask();
        PixelShader  = compile ps_2_0 PS_PmdMask();
    }
}

//�Z���t�V���h�E�Ȃ�
technique Mask0 < string MMDPass = "object"; bool UseToon = false; > {
    pass DrawMask {
        VertexShader = compile vs_2_0 VS_Mask();
        PixelShader  = compile ps_2_0 PS_AcsMask();
    }
}

technique Mask1 < string MMDPass = "object"; bool UseToon = true; > {
    pass DrawMask {
        VertexShader = compile vs_2_0 VS_Mask();
        PixelShader  = compile ps_2_0 PS_PmdMask();
    }
}

//�Z���t�V���h�E����
technique MaskSS0 < string MMDPass = "object_ss"; bool UseToon = false; > {
    pass DrawMask {
        VertexShader = compile vs_2_0 VS_Mask();
        PixelShader  = compile ps_2_0 PS_AcsMask();
    }
}

technique MaskSS1 < string MMDPass = "object_ss"; bool UseToon = true; > {
    pass DrawMask {
        VertexShader = compile vs_2_0 VS_Mask();
        PixelShader  = compile ps_2_0 PS_PmdMask();
    }
}

//�`�悵�Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }

