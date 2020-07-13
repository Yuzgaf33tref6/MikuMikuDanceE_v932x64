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
> = 15000;

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
> = 100;

//�p�[�e�B�N���T�C�Y
float ParticleSize
<
   string UIName = "ParticleSize";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 2.5;
> = 1;

//�e�N�X�`���̃A�X�y�N�g��
float Aspect
<
   string UIName = "Aspect";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 2.0;
> = 0.1;


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
texture2D Tex2 <
    string ResourceName = "splash.png";
    int MipLevels = 0;
>;
sampler Tex2Samp = sampler_state {
    texture = <Tex2>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = NONE;
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

#define HITTEX_SIZE 1024

texture HitRainRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for HitRain.fx";
    int Width = HITTEX_SIZE;
    int Height = HITTEX_SIZE;
    string Format = "D3DFMT_R16F" ;
    float4 ClearColor = { 1, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "*=Length.fx;";
>;
sampler LengthSamp = sampler_state {
    texture = <HitRainRT>;
    MINFILTER = NONE;
    MAGFILTER = NONE;
};


///////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float3 WPos	  : TEXCOORD0;
    float2 Tex        : TEXCOORD1;   // �e�N�X�`��
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
    base_pos.xz *= 0.25;
    base_pos.y = frac(base_pos.y - (Speed * ftime / Height));
    Out.WPos = base_pos.xyz;
	Out.WPos.xz += 0.5;
	Out.WPos.z *= -1;
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
    float3 WorldPos = WorldMatrix[3].xyz + base_pos.xyz;
    
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
	float len = tex2D(LengthSamp,input.WPos.xz).r;
	float test = (1-len);
	float len_buf = (input.WPos.y > test);
	float4 color = tex2D( Tex1Samp, input.Tex );
    color.a *= input.Alpha*len_buf;
    //color.rgb = 1;
    //color.a = sign(color.a);
    return color;
}


// ���_�V�F�[�_
VS_OUTPUT Drop_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out;
    Out.Alpha = 1;
    
    //�|���S����Z���W���C���f�b�N�X�Ƃ��ė��p
    float index = Pos.z;
    Pos.z = 0;
    
    
    // �����_���z�u
    float4 base_pos = getRandom(index);
    float base_y = base_pos.y;
    //base_y = frac(base_y - (Speed * ftime / Height));
    
    base_pos.xz -= 0.5;
    base_pos.y = 0;
    base_pos.xz *= 0.25;
    Out.WPos = base_pos.xyz;
	Out.WPos.xz += 0.5;
	Out.WPos.z *= -1;
	
	float len = 1-tex2Dlod(LengthSamp,float4(Out.WPos.xz,0,0)).r;
    base_pos.y += len;

    //�̈�ύX
    base_pos.xyz *= float3(WidthX, Height, WidthZ);
    //base_pos.xyz *= 0.1;
    
    
    // Y����胉�C���r���{�[�h
    float3 Axis = float3(0, 1, 0);
    
    //���[���h��]�ϊ�
    base_pos.xyz = mul( base_pos.xyz, WorldRotMatrix );
    Axis = mul( Axis, WorldRotMatrix );
    
    //�p�[�e�B�N�����_�̃��[���h���W
    float3 WorldPos = WorldMatrix[3].xyz + base_pos.xyz;
    
    //�J��������̃x�N�g��
    float3 Eye = normalize(WorldPos - CameraPosition);
    
    //���x�N�g���ƃJ�����x�N�g���̊O�ςŉ������x�N�g���𓾂�
    float3 Side = normalize(cross(Axis,Eye));
    
    //���I�u�W�F�N�g�̍��W����{�[�h�`��
    Out.Pos = float4(WorldPos, 1);
    Out.Pos.xyz += (Pos.y * Axis + Pos.x * Side * Aspect) * ParticleSize * 20 * scaling;
    
    
    //�\���������̃p�[�e�B�N���͔ޕ��փX�b��΂�
    Out.Pos.z -= (index >= count) * 100000;

    
    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Out.Pos, ViewProjMatrix );
    
    
    //�����͔���
    Out.Alpha *= 0.3 + 0.7 * (1 - saturate((Out.Pos.z - 50) / FadeLength));
    Out.Alpha *= alpha1;
    
    Out.Alpha *= smoothstep(0.9,1,1-frac((-base_y)+len+((Speed * ftime / Height)))) * 1;
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Drop_PS( VS_OUTPUT input ) : COLOR0
{
    float4 color = tex2D( Tex2Samp, input.Tex );
    color.a *= input.Alpha;
    color.a *= 0.5;
    return color;
}

struct CPU_TO_VS
{
	float4 Pos		: POSITION;
};
struct VS_TO_PS
{
	float4 Pos		: POSITION;
	float2 Tex		: TEXCOORD0;
};
VS_TO_PS VS_Length( CPU_TO_VS In )
{
	VS_TO_PS Out;

	// �ʒu���̂܂�
	Out.Pos = In.Pos;

	float2 Tex = (In.Pos.xy+1)*0.5;
	Out.Pos.xy *= 0.3;
	Out.Pos.xy += 1-0.3;
	// �e�N�X�`�����W�͒��S����̂S�_
	float2 fInvSize = float2( 1.0, 1.0 ) / (float)HITTEX_SIZE;

    Out.Tex = Tex;
	return Out;
}
float4 PS_Length( VS_TO_PS In ) : COLOR
{
	float4 col = tex2D(LengthSamp,In.Tex);

	return pow(saturate(col),1);
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
    pass DrawDrop {
        ZWRITEENABLE = false; //Z�o�b�t�@���X�V���Ȃ�
        CullMode = NONE; //���\�`��
        
        //�����̃R�����g�A�E�g���O���Ή��Z������
        //SRCBLEND=ONE;
        //DESTBLEND=ONE;
        
        VertexShader = compile vs_3_0 Drop_VS();
        PixelShader  = compile ps_3_0 Drop_PS();
    }
    /*
    pass DrawLength < string Script = "Draw=Buffer;";> {
        VertexShader = compile vs_3_0 VS_Length();
        PixelShader  = compile ps_3_0 PS_Length();
    }
    */
}

