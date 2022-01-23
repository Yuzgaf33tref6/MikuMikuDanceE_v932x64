////////////////////////////////////////////////////////////////////////////////////////////////
//
//  BSB_Object.fx ���f���̌`��ɍ��킹�ĉ����o���G�t�F�N�g(���f���Z���N�^)
//  ( BoardSelfBurning.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////

// ���W�ϊ��p�����[�^
float4x4 ViewMatrix          : VIEW;
float4x4 ProjMatrix          : PROJECTION;
float4x4 WorldViewMatrix     : WORLDVIEW;
float4x4 ViewProjMatrix      : VIEWPROJECTION;
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

float4x4 BoardWorldMatrix: CONTROLOBJECT < string Name = "(OffscreenOwner)"; >; // �{�[�h�̃��[���h�ϊ��s��
static float3 PlanarPos = mul( BoardWorldMatrix[3], ViewMatrix ).xyz;  // ���e���镽�ʏ�̌��_���W
static float3 PlanarNormal = float3(0.0, 0.0, -1.0);                   // ���e���镽�ʂ̖@���x�N�g��
static float scaling = length(BoardWorldMatrix._11_12_13)*0.1f;
static float aspect = ProjMatrix._22 /  ProjMatrix._11;  // ���C����ʂ̃A�X�y�N�g��(ProjMatrix��Offscreen�̃T�C�Y�Ɋ֌W�Ȃ����C����ʂ̂��擾�����)

// �{�[�h��Z����]�s��
static float4 WPos = float4(BoardWorldMatrix._41_42_43, 1);
static float4 pos0 = mul( WPos, ViewProjMatrix);
static float4 posY = mul( float4(WPos.x, WPos.y+1, WPos.z, 1), ViewProjMatrix);
static float2 rotVec0 = posY.xy/posY.w - pos0.xy/pos0.w;
static float2 rotVec = normalize( float2(rotVec0.x*aspect, rotVec0.y) );
static float2x2 RotMatrix = float2x2( rotVec.y, rotVec.x,
                                     -rotVec.x, rotVec.y );

// ���f���`��̂͂ݏo���x
float AcsRz: CONTROLOBJECT < string Name = "(OffscreenOwner)"; string item = "Rz"; >;
static float sourceFatness = max(0.8f + degrees(AcsRz), -0.2f);

// �}�e���A���F
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};


///////////////////////////////////////////////////////////////////////////////////////////////
// �{�[�h�ʂւ̕`��

struct VS_OUTPUT {
    float4 Pos  : POSITION;
    float2 Tex  : TEXCOORD0;
};

// ���_�V�F�[�_
VS_OUTPUT Object_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    // ���[���h�r���[�ˉe���W�ϊ�(z,w�������̂܂ܗp����)
    float4 Pos0 = mul( Pos, WorldViewProjMatrix );

    // ���[���h�r���[���W�ϊ�
    Pos = mul( Pos, WorldViewMatrix );
    Normal = normalize( mul( Normal, (float3x3)WorldViewMatrix ) );

    // �@�������ɏ��������o��
    Pos.xyz += Normal * sourceFatness;

    // �{�[�h�ʂɓ��e
    if(ProjMatrix._44 < 0.5f){
        float a = dot(PlanarNormal, PlanarPos);
        float b = dot(PlanarNormal, Pos.xyz);
        Pos.xyz *= a/b;
    }

    // �ˉe�ϊ����ǂ�
    Pos.xyz -= PlanarPos;
    Pos.xy = mul( Pos.xy, RotMatrix );
    Pos.x /= 30.0f * scaling; // �A�N�Z��-30�`30�Ȃ̂�
    Pos.y -= 10.0f * scaling;
    Pos.y /= 30.0f * scaling; // �A�N�Z��-20�`40�Ȃ̂�
    Pos.xy *= Pos0.w;
    Pos.zw = Pos0.zw;

    Out.Pos = Pos;
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Object_PS(float2 Tex : TEXCOORD0, uniform bool useTexture) : COLOR
{
    // �{�[�h�ʂ��J�����̗����ɂ���Ƃ��͕`�悵�Ȃ�
    clip(PlanarPos.z - 2.0f);

    float alpha = MaterialDiffuse.a;

    if ( useTexture ) {
        // �e�N�X�`�����ߒl�K�p
        alpha *= tex2D( ObjTexSampler, Tex ).a;
    }

    clip(alpha - 0.005f);

    return float4(alpha, alpha, alpha, 1);
}

///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique Tec1 < string MMDPass = "object"; bool UseTexture = false; > {
    pass DrawShadow {
        DestBlend = ONE;
        SrcBlend = ONE;
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader  = compile ps_2_0 Object_PS(false);
    }
}

technique Tec2 < string MMDPass = "object"; bool UseTexture = true; > {
    pass DrawShadow {
        DestBlend = ONE;
        SrcBlend = ONE;
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader  = compile ps_2_0 Object_PS(true);
    }
}

technique TecSS1 < string MMDPass = "object_ss"; bool UseTexture = false; > {
    pass DrawShadow {
        DestBlend = ONE;
        SrcBlend = ONE;
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader  = compile ps_2_0 Object_PS(false);
    }
}

technique TecSS2 < string MMDPass = "object_ss"; bool UseTexture = true; > {
    pass DrawShadow {
        DestBlend = ONE;
        SrcBlend = ONE;
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader  = compile ps_2_0 Object_PS(true);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////

// �G�b�W�͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
// �n�ʉe�͕`�悵�Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }
// MMD�W���̃Z���t�V���h�E�͕`�悵�Ȃ�
technique ZplotTec < string MMDPass = "zplot"; > { }

