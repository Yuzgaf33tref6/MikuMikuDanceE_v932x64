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
> = 0.5;

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
> = 0;

//�e�N�X�`���̉�]���x
float RotationSpeed
<
   string UIName = "RotationSpeed";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 20.0;
> = 0.5;

//�����Ńt�F�[�h�A�E�g���鋗��
float FadeLength
<
   string UIName = "FadeLength";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1000.0;
> = 200;

//�c�݌W��
float DistParam = 1.0;

//�X�y�L��������
float SpecularScale = 5.0;

//�X�y�L�������x
float SpecularPow = 8.0;


float3 ControllerPos : CONTROLOBJECT < string name = "FG_Controller_0.pmd"; string item = "�Z���^�["; >;
float morph_spd : CONTROLOBJECT < string name = "FG_Controller_0.pmd"; string item = "���x����"; >;
float morph_width_x : CONTROLOBJECT < string name = "FG_Controller_0.pmd"; string item = "�͈�X"; >;
float morph_width_z : CONTROLOBJECT < string name = "FG_Controller_0.pmd"; string item = "�͈�Z"; >;
float morph_height : CONTROLOBJECT < string name = "FG_Controller_0.pmd"; string item = "�͈�Y"; >;
float morph_width_x_down : CONTROLOBJECT < string name = "FG_Controller_0.pmd"; string item = "�͈�X�k��"; >;
float morph_width_z_down : CONTROLOBJECT < string name = "FG_Controller_0.pmd"; string item = "�͈�Z�k��"; >;
float morph_height_down : CONTROLOBJECT < string name = "FG_Controller_0.pmd"; string item = "�͈�Y�k��"; >;
float morph_num : CONTROLOBJECT < string name = "FG_Controller_0.pmd"; string item = "������"; >;


texture FallGlass_DistRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for FallGlass.fx";
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;";
>;
sampler DistortionView = sampler_state {
    texture = <FallGlass_DistRT>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    FILTER = LINEAR;
};

texture FallGlass_DepthRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for FallGlass.fx";
    float4 ClearColor = { 0, 0, 0, 1 };
    string Format="R32F";
    float ClearDepth = 1.0;
    bool AntiAlias = false;
    
    string DefaultEffect = 
        "self = hide;"
        "* = DrawZ.fx;";
>;
sampler DepthView = sampler_state {
    texture = <FallGlass_DepthRT>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    FILTER = LINEAR;
};



//�p�[�e�B�N���e�N�X�`��
texture2D ParticleTex <
    string ResourceName = "particle.png";
>;

sampler ParticleSamp = sampler_state {
    texture = <ParticleTex>;
	FILTER = LINEAR;
};
texture2D Particle_AddTex <
    string ResourceName = "particle_add.png";
>;

sampler Particle_AddSamp = sampler_state {
    texture = <Particle_AddTex>;
	FILTER = LINEAR;
};
texture2D Particle_NormalTex <
    string ResourceName = "particle_n.png";
>;

sampler Particle_NormalSamp = sampler_state {
    texture = <Particle_NormalTex>;
	FILTER = LINEAR;
};
texture2D Particle_AlphaTex <
    string ResourceName = "particle_d.png";
>;

sampler Particle_AlphaSamp = sampler_state {
    texture = <Particle_AlphaTex>;
	FILTER = LINEAR;
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

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;

// ���@�ϊ��s��
float4x4 WorldMatrix    : WORLD;
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
    float3 Normal	  : TEXCOORD1;
    float4 LastPos : TEXCOORD2;    // �ˉe�ϊ����W�̃R�s�[
    float3 Eye		: TEXCOORD3;	// �����x�N�g��
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
VS_OUTPUT Mask_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0,float3 Normal : NORMAL)
{
	RotationSpeed *= (Speed * (1-morph_spd));
    VS_OUTPUT Out;
    Out.Alpha = 1;
    
    //�|���S����Z���W���C���f�b�N�X�Ƃ��ė��p
    float index = Pos.z;
    Pos.z = 0;
    
    float3 rot_rand = getRandom(index*32)*2*3.1415;
    
    float rot_x = ftime * RotationSpeed + rot_rand.x;
    float rot_y = 0;//ftime * RotationSpeed + rot_rand.y;
    float rot_z = ftime * RotationSpeed + rot_rand.z;
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
    
    Normal = normalize(Normal);
    Normal = mul( Normal, RotationX );
    Normal = mul( Normal, RotationY );
    Normal = mul( Normal, RotationZ );
    
    Pos.xy *= ParticleSize;
    
    // �r���{�[�h
    //Pos.xyz = mul( Pos.xyz, BillboardMatrix );
    
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
    
    Out.Normal = normalize(mul(Normal,WorldMatrix));
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    //�����͔���
    Out.Alpha *= 0.3 + 0.7 * (1 - saturate((Out.Pos.z - 50) / FadeLength));
    Out.Alpha *= alpha1;
    
	
	//16��ނ̃e�N�X�`������I��

    // �e�N�X�`�����W
    Out.Tex = Tex*0.25;
    
	int w = index%4;
	int h = index/4;
	
	Out.Tex.x += w*0.25;
	Out.Tex.y += h*0.25;
	
	Out.LastPos = Out.Pos;
    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
	
    
    return Out;
}
// �s�N�Z���V�F�[�_
float4 Mask_PS( VS_OUTPUT IN ) : COLOR0
{
    float4 color = tex2D( ParticleSamp, IN.Tex );
    float4 normal = tex2D( Particle_NormalSamp, IN.Tex );
    float add = tex2D( Particle_AddSamp, IN.Tex ).a;
    float alpha = tex2D( Particle_AlphaSamp, IN.Tex ).a;
	
	normal.rgb = normalize(normal.rgb+IN.Normal);
		
	float2 ScrTex;
	ScrTex.x = (IN.LastPos.x / IN.LastPos.w)*0.5+0.5;
	ScrTex.y = (-IN.LastPos.y / IN.LastPos.w)*0.5+0.5;
	
	float2 AddScr = (-0.5 + normal.xy)*0.05*DistParam;
	
    float depth = tex2D( DepthView, ScrTex+AddScr ).r;
    depth = saturate(depth - length(IN.Eye));
	AddScr *= depth;
	float4 ret = tex2D(DistortionView,ScrTex+AddScr);

    color.a *= IN.Alpha;
	ret = lerp(ret,color,color.a);
    ret.a *= alpha;
    
    
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPow ) * LightSpecular * SpecularScale;
    
    ret.rgb *= saturate(dot(normal.rgb,-LightDirection)+1.5)*LightDiffuse;
    ret.rgb += Specular*(0.5+add);
    
    
    return ret;
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
        
        VertexShader = compile vs_3_0 Mask_VS();
        PixelShader  = compile ps_3_0 Mask_PS();
    }
}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot";> {}

