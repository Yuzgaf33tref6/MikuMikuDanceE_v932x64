////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

//���q�\����
int count
<
   string UIName = "count";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 1;
   int UIMax = 15000;
> = 8000;

//�\���̈�
float Height
<
   string UIName = "Height";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 1;
   int UIMax = 2000;
> = 100;

float WidthX
<
   string UIName = "WidthX";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 1;
   int UIMax = 2000;
> = 250;

float WidthZ
<
   string UIName = "WidthZ";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 1;
   int UIMax = 2000;
> = 250;


//�������x
float Speed
<
   string UIName = "Speed";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 100.0;
> = 60;

//�p�[�e�B�N���T�C�Y
float ParticleSize
<
   string UIName = "ParticleSize";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 2.5;
> = 1.8;

//�e�N�X�`���̃A�X�y�N�g��
float Aspect
<
   string UIName = "Aspect";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 2.0;
> = 0.25;


//�����Ńt�F�[�h�A�E�g���鋗��
float FadeLength
<
   string UIName = "FadeLength";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1000.0;
> = 300;



//�p�[�e�B�N���e�N�X�`��
texture2D Tex1 <
    string ResourceName = "rain6.png";
    int MipLevels = 0;
>;
sampler Tex1Samp = sampler_state {
    texture = <Tex1>;
    MINFILTER = ANISOTROPIC;
    MAGFILTER = ANISOTROPIC;
    MIPFILTER = LINEAR;
    MAXANISOTROPY = 16;
};

//�����e�N�X�`��
texture2D rndtex <
    string ResourceName = "random256x256.bmp";
>;
sampler rnd = sampler_state {
    texture = <rndtex>;
    MINFILTER = NONE;
    MAGFILTER = NONE;
};

//�����e�N�X�`���T�C�Y
#define RNDTEX_WIDTH  256
#define RNDTEX_HEIGHT 256


float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
static float alpha1 = MaterialDiffuse.a;

float ftime : TIME <bool SyncInEditMode = false;>;


// ���@�ϊ��s��
float4x4 WorldMatrix : World;
float4x4 ViewProjMatrix : ViewProjection;
float4x4 ViewTransMatrix : ViewTranspose;
float4x4 WorldViewProjMatrix    : WORLDVIEWPROJECTION;
float4x4 WorldViewMatrixInverse : WORLDVIEWINVERSE;

static float scaling = length(WorldMatrix._11_12_13) * 0.1;

float3   CameraPosition     : POSITION  < string Object = "Camera"; >;

// ���[���h��]�s��
static float3x3 WorldRotMatrix = {
    normalize(WorldMatrix[0].xyz),
    normalize(WorldMatrix[1].xyz),
    normalize(WorldMatrix[2].xyz),
};


///////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // �e�N�X�`��
    float  Alpha      : COLOR0;
};

//�����擾
float4 getRandom(float rindex)
{
    float2 tpos = float2(rindex % RNDTEX_WIDTH, trunc(rindex / RNDTEX_WIDTH));
    tpos += float2(0.5,0.5);
    tpos /= float2(RNDTEX_WIDTH, RNDTEX_HEIGHT);
    return tex2Dlod(rnd, float4(tpos,0,1));
}

// ���_�V�F�[�_
VS_OUTPUT Mask_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out;
    Out.Alpha = 1;
    
    //�|���S����Z���W���C���f�b�N�X�Ƃ��ė��p
    float index = Pos.z;
    Pos.z = 0;
    
    
    // �����_���z�u
    float4 base_pos = getRandom(index);
    
    base_pos.xz -= 0.5;
    base_pos.y = frac(base_pos.y - (Speed * ftime / Height));
    
    //�o����Ə��Œ��O�̓t�F�[�h
    Out.Alpha = saturate((1 - base_pos.y) * 3) * saturate(base_pos.y * 40);
    
    //�̈�ύX
    base_pos.xyz *= float3(WidthX, Height, WidthZ);
    //base_pos.xyz *= 0.1;
    
    
    
    // Y����胉�C���r���{�[�h
    float3 Axis = float3(0, 1, 0);
    
    //���[���h��]�ϊ�
    base_pos.xyz = mul( base_pos.xyz, WorldRotMatrix );
    Axis = mul( Axis, WorldRotMatrix );
    
    //�p�[�e�B�N�����_�̃��[���h���W
    float3 WorldPos = WorldMatrix[3].xyz + base_pos.xyz * scaling;
    
    //�J��������̃x�N�g��
    float3 Eye = normalize(WorldPos - CameraPosition);
    
    //���x�N�g���ƃJ�����x�N�g���̊O�ςŉ������x�N�g���𓾂�
    float3 Side = normalize(cross(Axis,Eye));
    
    //���I�u�W�F�N�g�̍��W����{�[�h�`��
    Out.Pos = float4(WorldPos, 1);
    Out.Pos.xyz += (Pos.y * Axis + Pos.x * Side * Aspect) * ParticleSize * 10 * scaling;
    
    
    //�\���������̃p�[�e�B�N���͔ޕ��փX�b��΂�
    Out.Pos.z -= (index >= count) * 100000;
    
    
    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Out.Pos, ViewProjMatrix );
    
    
    //�����͔���
    Out.Alpha *= 0.3 + 0.7 * (1 - saturate((Out.Pos.z - 50) / FadeLength));
    Out.Alpha *= alpha1;
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Mask_PS( VS_OUTPUT input ) : COLOR0
{
    float4 color = tex2D( Tex1Samp, input.Tex );
    color.a *= input.Alpha;
    return color;
}

///////////////////////////////////////////////////////////////////////////////////////////////

technique MainTec {
    pass DrawObject {
        ZWRITEENABLE = false; //Z�o�b�t�@���X�V���Ȃ�
        CullMode = NONE; //���\�`��
        
        //�����̃R�����g�A�E�g���O���Ή��Z������
        //SRCBLEND=ONE;
        //DESTBLEND=ONE;
        
        VertexShader = compile vs_3_0 Mask_VS();
        PixelShader  = compile ps_3_0 Mask_PS();
    }
}

