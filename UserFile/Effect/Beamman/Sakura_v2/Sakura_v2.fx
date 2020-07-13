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
> = 80;

float WidthX
<
   string UIName = "WidthX";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 1;
   int UIMax = 2000;
> = 100;

float WidthZ
<
   string UIName = "WidthZ";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 1;
   int UIMax = 2000;
> = 100;


//�������x
float Speed
<
   string UIName = "Speed";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 40.0;
> = 12;

//�p�[�e�B�N���T�C�Y
float ParticleSize
<
   string UIName = "ParticleSize";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 2.5;
> = 0.3;

//�����O���̌X��
float SlopeLevel
<
   string UIName = "SlopeLevel";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 2.0;
> = 0.3;

//�����O���̂�炬
float NoizeLevel
<
   string UIName = "NoizeLevel";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 2.0;
> = 0.4;

//�e�N�X�`���̉�]���x
float RotationSpeed
<
   string UIName = "RotationSpeed";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 20.0;
> = 3;

//�����Ńt�F�[�h�A�E�g���鋗��
float FadeLength
<
   string UIName = "FadeLength";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1000.0;
> = 200;



//�p�[�e�B�N���e�N�X�`��
texture2D Tex1 <
    string ResourceName = "sakura.png";
    int MipLevels = 0;
>;

float3 ControllerPos : CONTROLOBJECT < string name = "Controller_0.pmd"; string item = "�Z���^�["; >;
float morph_spd : CONTROLOBJECT < string name = "Controller_0.pmd"; string item = "���x����"; >;
float morph_width_x : CONTROLOBJECT < string name = "Controller_0.pmd"; string item = "�͈�X"; >;
float morph_width_z : CONTROLOBJECT < string name = "Controller_0.pmd"; string item = "�͈�Z"; >;
float morph_height : CONTROLOBJECT < string name = "Controller_0.pmd"; string item = "�͈�Y"; >;
float morph_width_x_down : CONTROLOBJECT < string name = "Controller_0.pmd"; string item = "�͈�X�k��"; >;
float morph_width_z_down : CONTROLOBJECT < string name = "Controller_0.pmd"; string item = "�͈�Z�k��"; >;
float morph_height_down : CONTROLOBJECT < string name = "Controller_0.pmd"; string item = "�͈�Y�k��"; >;
float morph_num : CONTROLOBJECT < string name = "Controller_0.pmd"; string item = "������"; >;








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
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;



// ���@�ϊ��s��
float4x4 WorldViewProjMatrix    : WORLDVIEWPROJECTION;
float4x4 WorldViewMatrixInverse : WORLDVIEWINVERSE;

static float3x3 BillboardMatrix = {
    normalize(WorldViewMatrixInverse[0].xyz),
    normalize(WorldViewMatrixInverse[1].xyz),
    normalize(WorldViewMatrixInverse[2].xyz),
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
    
    float rot_x = ftime * RotationSpeed + index * 6;
    float rot_y = ftime * RotationSpeed + index * 11;
    float rot_z = ftime * RotationSpeed + index * 33;
	static float3x3 RotationX = {
	    {1,	0,	0},
	    {0, cos(rot_x), sin(rot_x)},
	    {0, -sin(rot_x), cos(rot_x)},
	};
	static float3x3 RotationY = {
	    {cos(rot_y), 0, -sin(rot_y)},
	    {0, 1, 0},
		{sin(rot_y), 0,cos(rot_y)},
	    };
	static float3x3 RotationZ = {
	    {cos(rot_z), sin(rot_z), 0},
	    {-sin(rot_z), cos(rot_z), 0},
	    {0, 0, 1},
	};
	
    //��]�E�T�C�Y�ύX
    Pos.xyz = mul( Pos.xyz, RotationX );
    Pos.xyz = mul( Pos.xyz, RotationY );
    Pos.xyz = mul( Pos.xyz, RotationZ );
    Pos.xy *= ParticleSize;
    
    // �r���{�[�h
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );
    
    // �����_���z�u
    float4 base_pos = getRandom(index);
    
    base_pos.xz -= 0.5;
    base_pos.y = frac(base_pos.y - ((Speed * (1-morph_spd)) * ftime / Height));
    
    //�o����Ə��Œ��O�̓t�F�[�h
    Out.Alpha = saturate((1 - base_pos.y) * 3) * saturate(base_pos.y * 40);
    
    WidthX *= 1.0*(1-morph_width_x_down)+morph_width_x*10.0;
    WidthZ *= 1.0*(1-morph_width_z_down)+morph_width_z*10.0;
    Height *= 1.0*(1-morph_height_down)+morph_height*10.0;
    
    //�̈�ύX
    base_pos.xyz *= float3(WidthX, Height, WidthZ);
    base_pos.xyz *= 0.1;
    
    //�΂�
    float2 vec = ControllerPos.xz*0.1;
    vec *= base_pos.y;
    base_pos.xz += vec;
    
    //�m�C�Y�t��
    base_pos.xz += (sin(ftime * 0.2 + index) + cos(ftime * 0.5 + index) * 0.5)  * NoizeLevel;
    
    Pos.xyz += base_pos;
    
    //�\���������̃p�[�e�B�N���͔ޕ��փX�b��΂�
    Pos.z -= (index >= count*(1-morph_num)) * 100000;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    //�����͔���
    Out.Alpha *= 0.3 + 0.7 * (1 - saturate((Out.Pos.z - 50) / FadeLength));
    Out.Alpha *= alpha1;
    
    // �e�N�X�`�����W
    Out.Tex = Tex*0.5;
	
	//�S��ނ̃e�N�X�`������I��
	int w = index%4;
	if(w < 2)
	{
		Out.Tex.x += 0.5;
	}
	if(w%2 == 0)
	{
		Out.Tex.y += 0.5;
	}
	
    
    return Out;
}
// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);
#define SKII1    1500
#define SKII2    8000
#define Toon     3

struct VS_SB_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // �e�N�X�`��
    float  Alpha      : COLOR0;
    float4 ZCalcTex : TEXCOORD1;    // Z�l
};
// ���_�V�F�[�_
VS_SB_OUTPUT Mask_SB_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_SB_OUTPUT Out;
    Out.Alpha = 1;
    
    //�|���S����Z���W���C���f�b�N�X�Ƃ��ė��p
    float index = Pos.z;
    Pos.z = 0;
    
    float rot_x = ftime * RotationSpeed + index * 6;
    float rot_y = ftime * RotationSpeed + index * 11;
    float rot_z = ftime * RotationSpeed + index * 33;
	static float3x3 RotationX = {
	    {1,	0,	0},
	    {0, cos(rot_x), sin(rot_x)},
	    {0, -sin(rot_x), cos(rot_x)},
	};
	static float3x3 RotationY = {
	    {cos(rot_y), 0, -sin(rot_y)},
	    {0, 1, 0},
		{sin(rot_y), 0,cos(rot_y)},
	    };
	static float3x3 RotationZ = {
	    {cos(rot_z), sin(rot_z), 0},
	    {-sin(rot_z), cos(rot_z), 0},
	    {0, 0, 1},
	};
	
    //��]�E�T�C�Y�ύX
    Pos.xyz = mul( Pos.xyz, RotationX );
    Pos.xyz = mul( Pos.xyz, RotationY );
    Pos.xyz = mul( Pos.xyz, RotationZ );
    Pos.xy *= ParticleSize;
    
    // �r���{�[�h
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );
    
    // �����_���z�u
    float4 base_pos = getRandom(index);
    
    base_pos.xz -= 0.5;
    base_pos.y = frac(base_pos.y - ((Speed * (1-morph_spd)) * ftime / Height));
    
    //�o����Ə��Œ��O�̓t�F�[�h
    Out.Alpha = saturate((1 - base_pos.y) * 3) * saturate(base_pos.y * 40);
    
    WidthX *= 1.0*(1-morph_width_x_down)+morph_width_x*10.0;
    WidthZ *= 1.0*(1-morph_width_z_down)+morph_width_z*10.0;
    Height *= 1.0*(1-morph_height_down)+morph_height*10.0;
    
    //�̈�ύX
    base_pos.xyz *= float3(WidthX, Height, WidthZ);
    base_pos.xyz *= 0.1;
    
    //�΂�
    float2 vec = ControllerPos.xz*0.1;
    vec *= base_pos.y;
    base_pos.xz += vec;
    
    //�m�C�Y�t��
    base_pos.xz += (sin(ftime * 0.2 + index) + cos(ftime * 0.5 + index) * 0.5)  * NoizeLevel;
    
    Pos.xyz += base_pos;
    
    //�\���������̃p�[�e�B�N���͔ޕ��փX�b��΂�
    Pos.z -= (index >= count*(1-morph_num)) * 100000;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    //�����͔���
    Out.Alpha *= 0.3 + 0.7 * (1 - saturate((Out.Pos.z - 50) / FadeLength));
    Out.Alpha *= alpha1;
    
    // �e�N�X�`�����W
    Out.Tex = Tex*0.5;
	
	//�S��ނ̃e�N�X�`������I��
	int w = index%4;
	if(w < 2)
	{
		Out.Tex.x += 0.5;
	}
	if(w%2 == 0)
	{
		Out.Tex.y += 0.5;
	}
	// ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�
    Out.ZCalcTex = mul( Pos, LightWorldViewProjMatrix );
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Mask_SB_PS( VS_SB_OUTPUT input ) : COLOR0
{
    float4 color = tex2D( Tex1Samp, input.Tex );
    color.a *= input.Alpha;
    float4 ShadowColor = color;
    ShadowColor.rgb *= 0.5;
    
    // �e�N�X�`�����W�ɕϊ�
    input.ZCalcTex /= input.ZCalcTex.w;
    float2 TransTexCoord;
    TransTexCoord.x = (1.0f + input.ZCalcTex.x)*0.5f;
    TransTexCoord.y = (1.0f - input.ZCalcTex.y)*0.5f;
    
    if( any( saturate(TransTexCoord) != TransTexCoord ) ) {
        // �V���h�E�o�b�t�@�O
        return color;
    } else {
        float comp;
        // �Z���t�V���h�E mode1
        comp=1-saturate(max(input.ZCalcTex.z-tex2D(DefSampler,TransTexCoord).r , 0.0f)*SKII1-0.3f);

        float4 ans = lerp(ShadowColor, color, comp);
        return ans;
    }
    
    
    return color;
}
// �s�N�Z���V�F�[�_
float4 Mask_PS( VS_OUTPUT input ) : COLOR0
{
    float4 color = tex2D( Tex1Samp, input.Tex );
    color.a *= input.Alpha;
    return color;
}

///////////////////////////////////////////////////////////////////////////////////////////////

technique MainTec <string MMDPass = "object";>{
    pass DrawObject {
        ZWRITEENABLE = false; //Z�o�b�t�@���X�V���Ȃ�
        
        //�����̃R�����g�A�E�g���O���Ή��Z������
        //SRCBLEND=ONE;
        //DESTBLEND=ONE;
        CULLMODE = NONE;
        
        VertexShader = compile vs_3_0 Mask_VS();
        PixelShader  = compile ps_3_0 Mask_PS();
    }
}
technique MainTecSS <string MMDPass = "object_ss";>{
    pass DrawObject {
        ZWRITEENABLE = false; //Z�o�b�t�@���X�V���Ȃ�
        
        //�����̃R�����g�A�E�g���O���Ή��Z������
        //SRCBLEND=ONE;
        //DESTBLEND=ONE;
        CULLMODE = NONE;
        
        VertexShader = compile vs_3_0 Mask_SB_VS();
        PixelShader  = compile ps_3_0 Mask_SB_PS();
    }
}

struct VS_ZValuePlot_OUTPUT {
    float4 Pos : POSITION;              // �ˉe�ϊ����W
    float  Alpha      : COLOR0;
    float4 ShadowMapTex : TEXCOORD0;    // Z�o�b�t�@�e�N�X�`��
    float2 Tex        : TEXCOORD1;   // �e�N�X�`��
};

// ���_�V�F�[�_
VS_ZValuePlot_OUTPUT ZValuePlot_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_ZValuePlot_OUTPUT Out;
    Out.Alpha = 1;
    
    //�|���S����Z���W���C���f�b�N�X�Ƃ��ė��p
    float index = Pos.z;
    Pos.z = 0;
    
    float rot_x = ftime * RotationSpeed + index * 6;
    float rot_y = ftime * RotationSpeed + index * 11;
    float rot_z = ftime * RotationSpeed + index * 33;
	static float3x3 RotationX = {
	    {1,	0,	0},
	    {0, cos(rot_x), sin(rot_x)},
	    {0, -sin(rot_x), cos(rot_x)},
	};
	static float3x3 RotationY = {
	    {cos(rot_y), 0, -sin(rot_y)},
	    {0, 1, 0},
		{sin(rot_y), 0,cos(rot_y)},
	    };
	static float3x3 RotationZ = {
	    {cos(rot_z), sin(rot_z), 0},
	    {-sin(rot_z), cos(rot_z), 0},
	    {0, 0, 1},
	};
	
    //��]�E�T�C�Y�ύX
    Pos.xyz = mul( Pos.xyz, RotationX );
    Pos.xyz = mul( Pos.xyz, RotationY );
    Pos.xyz = mul( Pos.xyz, RotationZ );
    Pos.xy *= ParticleSize;
    
    // �r���{�[�h
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );
    
    // �����_���z�u
    float4 base_pos = getRandom(index);
    
    base_pos.xz -= 0.5;
    base_pos.y = frac(base_pos.y - ((Speed * (1-morph_spd)) * ftime / Height));
    
    //�o����Ə��Œ��O�̓t�F�[�h
    Out.Alpha = saturate((1 - base_pos.y) * 3) * saturate(base_pos.y * 40);
    
    WidthX *= 1.0*(1-morph_width_x_down)+morph_width_x*10.0;
    WidthZ *= 1.0*(1-morph_width_z_down)+morph_width_z*10.0;
    Height *= 1.0*(1-morph_height_down)+morph_height*10.0;
    
    //�̈�ύX
    base_pos.xyz *= float3(WidthX, Height, WidthZ);
    base_pos.xyz *= 0.1;
    
    //�΂�
    float2 vec = ControllerPos.xz*0.1;
    vec *= base_pos.y;
    base_pos.xz += vec;
    
    //�m�C�Y�t��
    base_pos.xz += (sin(ftime * 0.2 + index) + cos(ftime * 0.5 + index) * 0.5)  * NoizeLevel;
    
    Pos.xyz += base_pos;
    
    //�\���������̃p�[�e�B�N���͔ޕ��փX�b��΂�
    Pos.z -= (index >= count*(1-morph_num)) * 100000;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    //�����͔���
    Out.Alpha *= 0.3 + 0.7 * (1 - saturate((Out.Pos.z - 50) / FadeLength));
    Out.Alpha *= alpha1;
    
    // �e�N�X�`�����W
    Out.Tex = Tex*0.5;
	
	//�S��ނ̃e�N�X�`������I��
	int w = index%4;
	if(w < 2)
	{
		Out.Tex.x += 0.5;
	}
	if(w%2 == 0)
	{
		Out.Tex.y += 0.5;
	}

    // ���C�g�̖ڐ��ɂ�郏�[���h�r���[�ˉe�ϊ�������
    Out.Pos = mul( Pos, LightWorldViewProjMatrix );

    // �e�N�X�`�����W�𒸓_�ɍ��킹��
    Out.ShadowMapTex = Out.Pos;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS( float4 ShadowMapTex : TEXCOORD0,float2 Tex : TEXCOORD1 ) : COLOR
{
   float4 color = tex2D( Tex1Samp, Tex );
    
    // R�F������Z�l���L�^����
    return color * float4(ShadowMapTex.z/ShadowMapTex.w,0,0,1);
}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec <
	string MMDPass = "zplot";
> {
    pass ZValuePlot {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 ZValuePlot_VS();
        PixelShader  = compile ps_3_0 ZValuePlot_PS();
    }
}

