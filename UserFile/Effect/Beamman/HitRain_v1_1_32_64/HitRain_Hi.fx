


////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

//���q�\����
int count
<
   string UIName = "count";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 1;
   int UIMax = 150000;
> = 150000;

//�\���̈�
float Height
<
   string UIName = "Height";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 1;
   int UIMax = 2000;
> = 100;

//�ύX�s��
float WidthX = 500;
float WidthZ = 500;


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


//�R���g���[������l�擾

float morph_width : CONTROLOBJECT < string name = "HitRain_Controller0.pmx"; string item = "�͈�"; >;
float morph_anm : CONTROLOBJECT < string name = "HitRain_Controller0.pmx"; string item = "�Đ����x"; >;
float morph_patnum : CONTROLOBJECT < string name = "HitRain_Controller0.pmx"; string item = "�p�[�e�B�N����"; >;
float morph_rain_si : CONTROLOBJECT < string name = "HitRain_Controller0.pmx"; string item = "�JSi"; >;
float morph_drop_si : CONTROLOBJECT < string name = "HitRain_Controller0.pmx"; string item = "���eSi"; >;







//�p�[�e�B�N���e�N�X�`��
texture2D Tex1 <
    string ResourceName = "rain6.png";
    int MipLevels = 0;
>;
sampler Tex1Samp = sampler_state {
    texture = <Tex1>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
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
    string ResourceName = "random512x512.bmp";
>;
sampler rnd = sampler_state {
    texture = <rndtex>;
    MINFILTER = NONE;
    MAGFILTER = NONE;
};

//�����e�N�X�`���T�C�Y
#define RNDTEX_WIDTH  512
#define RNDTEX_HEIGHT 512

//�}�X�N�e�N�X�`��
texture2D MaskTex <
    string ResourceName = "mask.png";
    int MipLevels = 0;
>;
sampler MaskSamp = sampler_state {
    texture = <MaskTex>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
};


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
    float4 ClearColor = { 0, 0, 0, 1 };
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
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
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
	WidthX *= saturate(morph_width-0.1);
	WidthZ *= saturate(morph_width-0.1);
	ftime *= 1-morph_anm;
	ParticleSize *= morph_rain_si*4;
    VS_OUTPUT Out;
    Out.Alpha = 1;
    
    //�|���S����Z���W���C���f�b�N�X�Ƃ��ė��p
    float index = Pos.z;
    Pos.z = 0;
    Pos.y += 0.1;
    
    
    // �����_���z�u
    float4 base_pos = getRandom(index);
    float base_y = base_pos.y;
    //base_y = frac(base_y - (Speed * ftime / Height));
    
    base_pos.xz -= 0.5;
    base_pos.xz += cos(index)*0.1;
    base_pos.y = 0;
    Out.WPos = base_pos.xyz;
	Out.WPos.xz += 0.5;
	Out.WPos.z = 1-Out.WPos.z;
	
	float len = tex2Dlod(LengthSamp,float4(Out.WPos.xz,0,0)).r;
    base_pos.y += (1-len)*10;
	base_pos.y += smoothstep(0.9,1,1-frac((-base_y)+len+((Speed * ftime / Height))));
	
    //�̈�ύX
    base_pos.xyz *= float3(WidthX, Height, WidthZ);
    
    
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
    Out.Pos.z -= (index >= count*(1-morph_patnum)) * 100000;

    
    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Out.Pos, ViewProjMatrix );
    
    
    //�����͔���
    Out.Alpha *= 0.3 + 0.7 * (1 - saturate((Out.Pos.z - 50) / FadeLength));
    Out.Alpha *= alpha1;
    
    Out.Alpha *= smoothstep(0.85,1,1-frac((-base_y)+len+((Speed * ftime / Height)))) * 1;
    // �e�N�X�`�����W
    Out.Tex = 1-((Pos.xy*10)*0.5+0.5);
	if(len == 0 || Out.WPos.x > 1.0 || Out.WPos.z > 1.0 || Out.WPos.x <= 0.0 || Out.WPos.z <= 0.0) Out.Alpha = 0;
    
    //�}�X�N
    Out.Alpha *= tex2Dlod(MaskSamp,float4(Out.WPos.xz,0,0)).r;

    return Out;
	/*
	WidthX *= saturate(morph_width-0.1);
	WidthZ *= saturate(morph_width-0.1);
	ftime *= 1-morph_anm;
	ParticleSize *= morph_rain_si*4;
    VS_OUTPUT Out;
    Out.Alpha = 1;
    
    //�|���S����Z���W���C���f�b�N�X�Ƃ��ė��p
    float index = Pos.z;
    Pos.z = 0;
    
    
    // �����_���z�u
    float4 base_pos = getRandom(index);
    base_pos.xz -= 0.5;
    base_pos += cos(index)*0.1;
    base_pos.y = frac(base_pos.y - (Speed * ftime / Height));
    Out.WPos = base_pos.xyz;
	Out.WPos.xz += 0.5;
	Out.WPos.z *= -1;
    //�o����Ə��Œ��O�̓t�F�[�h
    Out.Alpha = saturate((1 - base_pos.y) * 3) * saturate(base_pos.y * 40);
    
	float len = tex2Dlod(LengthSamp,float4(Out.WPos.xz,0,0)).r;
	if(len == 0) len = 1;
    base_pos.y += (1-len)*1;
    //�̈�ύX
    base_pos.xyz *= float3(WidthX*1, Height*10, WidthX*1);
    
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
    Out.Pos.z -= (index >= count*(1-morph_patnum)) * 100000;

    
    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Out.Pos, ViewProjMatrix );
    
    
    //�����͔���
    Out.Alpha *= 0.3 + 0.7 * (1 - saturate((Out.Pos.z - 50) / FadeLength));
    Out.Alpha *= alpha1;
    
    // �e�N�X�`�����W
    Out.Tex = 1-((Pos.xy*10)*0.5+0.5);
    
    //�}�X�N
    Out.Alpha *= tex2Dlod(MaskSamp,float4(Out.WPos.xz,0,0)).r;
    return Out;
    */
}

// �s�N�Z���V�F�[�_
float4 Mask_PS( VS_OUTPUT input ) : COLOR0
{
	float4 color = tex2D( Tex1Samp, input.Tex );
    color.a *= input.Alpha;
    return color;
}


// ���_�V�F�[�_
VS_OUTPUT Drop_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
	WidthX *= saturate(morph_width-0.1);
	WidthZ *= saturate(morph_width-0.1);
	ftime *= 1-morph_anm;
	ParticleSize *= morph_drop_si*4;
    VS_OUTPUT Out;
    Out.Alpha = 1;
    // �e�N�X�`�����W
    Out.Tex = 1-((Pos.xy*10)*0.5+0.5);
    
    //�|���S����Z���W���C���f�b�N�X�Ƃ��ė��p
    float index = Pos.z;
    Pos.z = 0;
    Pos.y += 0.1;
    // �����_���z�u
    float4 base_pos = getRandom(index);
    float base_y = base_pos.y;
    //base_y = frac(base_y - (Speed * ftime / Height));
    
    base_pos.xz -= 0.5;
    base_pos.xz += cos(index)*0.1;
    base_pos.y = 0;
    Out.WPos = base_pos.xyz;
	Out.WPos.xz += 0.5;
	Out.WPos.z = 1-Out.WPos.z;
	
	float len = tex2Dlod(LengthSamp,float4(Out.WPos.xz,0,0)).r;
    base_pos.y += (1-len)*10;
	
	
    //�̈�ύX
    base_pos.xyz *= float3(WidthX, Height, WidthZ);
    
    
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
    Out.Pos.z -= (index >= count*(1-morph_patnum)) * 100000;

    
    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Out.Pos, ViewProjMatrix );
    
    
    //�����͔���
    Out.Alpha *= 0.3 + 0.7 * (1 - saturate((Out.Pos.z - 50) / FadeLength));
    Out.Alpha *= alpha1;
    
    Out.Alpha *= smoothstep(0.9,1,1-frac((-base_y)+len+((Speed * ftime / Height)))) * 1;

	if(len == 0 || Out.WPos.x > 1.0 || Out.WPos.z > 1.0 || Out.WPos.x <= 0.0 || Out.WPos.z <= 0.0) Out.Alpha = 0;
    
    //�}�X�N
    Out.Alpha *= tex2Dlod(MaskSamp,float4(Out.WPos.xz,0,0)).r;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Drop_PS( VS_OUTPUT input ) : COLOR0
{
    float4 color = tex2D( Tex2Samp, input.Tex );
    color.a *= input.Alpha;
    
    //color.rgb *= float3(1,0,0);
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
	//Out.Pos.xy *= 0.3;
	//Out.Pos.xy += 1-0.3;
	// �e�N�X�`�����W�͒��S����̂S�_
	float2 fInvSize = float2( 1.0, 1.0 ) / (float)HITTEX_SIZE;

    Out.Tex = Tex;
	return Out;
}
float4 PS_Length( VS_TO_PS In ) : COLOR
{
	In.Tex.x = 1-In.Tex;
	float4 col = tex2D(LengthSamp,In.Tex);
	col.gb = 0;
	col.r *= 1;
	col.a = 0.5;
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

