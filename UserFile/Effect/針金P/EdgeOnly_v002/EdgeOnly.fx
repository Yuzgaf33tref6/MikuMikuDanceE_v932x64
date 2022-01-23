////////////////////////////////////////////////////////////////////////////////////////////////
//
//  EdgeOnly.fx ver0.0.2  ����G�t�F�N�g(�G�b�W�ƈÂ��F�݂̂�\�����܂�)
//  �쐬: �j��P( ���͉��P����basic.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
float DrawRate = 0.18;   // �`��臒l(0�ŃG�b�W�̂�,���l���グ��Ɩ��x�̒Ⴂ������`�悳��Ă����܂�)


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;
float4x4 WorldMatrix         : WORLD;

float3 LightDirection    : DIRECTION < string Object = "Light"; >;
float3 CameraPosition    : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4 MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3 MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3 MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3 MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float4 EdgeColor         : EDGECOLOR;
// ���C�g�F
float3   LightDiffuse    : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient    : AMBIENT   < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = MaterialAmbient  * LightAmbient + MaterialEmmisive;

bool use_texture;  //�e�N�X�`���̗L��

texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state
{
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

struct VS_OUTPUT
{
    float4 Pos    : POSITION;    // �ˉe�ϊ����W
    float2 Tex    : TEXCOORD1;   // �e�N�X�`��
    float3 Normal : TEXCOORD2;   // �@��
    float3 Eye    : TEXCOORD3;   // �J�����Ƃ̑��Έʒu
    float4 Color  : COLOR0;      // �f�B�t���[�Y�F
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    // ���_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    
    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = saturate( max(0,dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb + AmbientColor );
    Out.Color.a = DiffuseColor.a;
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS( VS_OUTPUT IN ) : COLOR0
{
    float4 Color = IN.Color;
    
    // �e�N�X�`���K�p
    if ( use_texture ) Color *= tex2D( ObjTexSampler, IN.Tex );
    
    // ���x�����߂�
    float brightness = (Color.r + Color.g + Color.b)*0.33333333;
    // ���x�̍����Ƃ���͓���
    if(brightness >= DrawRate) Color.a = 0.003;  // 0�ɂ����Z�o�b�t�@���Z�b�g����Ȃ�(����)
    
    return Color;
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec < string MMDPass = "object"; > {
    pass DrawObject
    {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}

technique MainTecBS  < string MMDPass = "object_ss"; > {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �n�ʉe�͕\�����Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }
// MMD�W���̃Z���t�V���h�E�͕\�����Ȃ�
technique ZplotTec < string MMDPass = "zplot"; > { }

