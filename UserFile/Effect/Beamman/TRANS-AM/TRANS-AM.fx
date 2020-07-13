//�{�̐F
float3 MainColor = float3(255,64,0)/255;

//�c���F
float3 BlurColor = float3(255,32,0)/255;



//�I�j�I���`�惂�[�h
//�w��\�萔
//1:SOLID 	: �|���S���`��
//2:WIREFRAME : ���C���[�t���[���`��
//3:POINT		: ���_�`��

#define Onion_DrawMode SOLID
//#define Onion_DrawMode WIREFRAME
//#define Onion_DrawMode POINT

//#define ONION_ADD
//�I�j�I���`�搔
//�ő�S�܂�
#define Onion_DrawNum 4

//�I�j�I�������x�@�����l
float Onion_Alpha = 0.75;

//�I�j�I�������x�@�����l
float Onion_AlphaSub = 0.5;



//�ǂ��킩��Ȃ��l�͂�������G��Ȃ�

int loop_index;
int count = Onion_DrawNum;

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 ViewProjMatrix      : VIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 ViewMatrix               : VIEW;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float    SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;
float3   MaterialToon      : TOONCOLOR;
float4   EdgeColor         : EDGECOLOR;
// ���C�g�F
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = saturate(MaterialAmbient  * LightAmbient + MaterialEmmisive);
static float3 SpecularColor = MaterialSpecular * LightSpecular;

bool     parthf;   // �p�[�X�y�N�e�B�u�t���O
bool     transp;   // �������t���O
bool	 spadd;    // �X�t�B�A�}�b�v���Z�����t���O
#define SKII1    1500
#define SKII2    8000
#define Toon     3

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

// �X�t�B�A�}�b�v�̃e�N�X�`��
texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state {
    texture = <ObjectSphereMap>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

#define VPBUF_WIDTH  256
#define VPBUF_HEIGHT 256
//���_���W�o�b�t�@�T�C�Y
static float2 VPBufSize = float2(VPBUF_WIDTH, VPBUF_HEIGHT);
static float2 VPBufOffset = float2(0.5 / VPBUF_WIDTH, 0.5 / VPBUF_HEIGHT);

shared texture VertexPosRT: OFFSCREENRENDERTARGET <
    string Description = "SaveVertexPos for OnionSkin.fx";

    int width = VPBUF_WIDTH * 2;
    int height = VPBUF_HEIGHT * 2;
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string Format="A32B32G32R32F";
    string DefaultEffect = 
        "self = SavePos.fx;"
        "* = hide;"
    ;
>;

sampler PosSamp = sampler_state {
    texture = <VertexPosRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


//���_���W�o�b�t�@�擾
float4 getVertexPosBuf(int index)
{
    float4 Color = 0;
    float2 tpos = 0;
	tpos.x = modf((float)index / VPBUF_WIDTH, tpos.y);
	tpos.y /= VPBUF_HEIGHT;
	tpos += VPBufOffset;
	tpos.xy *= 0.5;
	
	tpos.x += (loop_index%2)*0.5;
	tpos.y += (loop_index/2)*0.5;
	
	Color = tex2Dlod(PosSamp, float4(tpos,0,0));
	
	return Color;
}
// ���_�V�F�[�_

struct VS_OUTPUT {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD1;   // �e�N�X�`��
    float3 Normal     : TEXCOORD2;   // �@��
    float3 Eye        : TEXCOORD3;   // �J�����Ƃ̑��Έʒu
    float2 SpTex      : TEXCOORD4;	 // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 Color      : COLOR0;      // �f�B�t���[�Y�F
};

VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    // ���_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    
    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    if ( !useToon ) {
        Out.Color.rgb += max(0,dot( Out.Normal, -LightDirection )) * AmbientColor;
    }
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate( Out.Color );
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�e�N�X�`�����W
        float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix );
        Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
        Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
    }
    
    return Out;
}

VS_OUTPUT Onion_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0,int index: _INDEX, uniform bool useTexture, uniform bool useSphereMap)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
	Pos.xyz = getVertexPosBuf(index);
	
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, ViewProjMatrix );
    
    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    // ���_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    
    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;

    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate( Out.Color );
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�e�N�X�`�����W
        float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix );
        Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
        Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
    }
    return Out;
}
// �s�N�Z���V�F�[�_
float4 Basic_PS(VS_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon) : COLOR0
{
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;
    
    float4 Color = IN.Color;
	
    if ( useTexture ) {
        // �e�N�X�`���K�p
        Color *= tex2D( ObjTexSampler, IN.Tex );
    }
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�K�p
        if(spadd) Color.rgb += tex2D(ObjSphareSampler,IN.SpTex).rgb;
        else      Color.rgb *= tex2D(ObjSphareSampler,IN.SpTex).rgb;
    }
    if ( useToon ) {
        // �g�D�[���K�p
        float LightNormal = dot( IN.Normal, -LightDirection );
        Color.rgb *= lerp(MaterialToon, float3(1,1,1), saturate(LightNormal * 16 + 0.5));
    }
    
    // �X�y�L�����K�p
    Color.rgb += Specular;
    
    Color.rgb = length(Color.rgb)*MainColor;
    return Color;
}
// �s�N�Z���V�F�[�_
float4 Onion_PS(VS_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap) : COLOR0
{
    // �X�y�L�����F�v�Z
    float4 Color = IN.Color;
	
    if ( useTexture ) {
        // �e�N�X�`���K�p
        Color *= tex2D( ObjTexSampler, IN.Tex );
    }
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�K�p
        if(spadd) Color.rgb += tex2D(ObjSphareSampler,IN.SpTex).rgb;
        else      Color.rgb *= tex2D(ObjSphareSampler,IN.SpTex).rgb;
    }
    Color.a *= Onion_Alpha * pow(Onion_AlphaSub,loop_index);
    Color.rgb = length(Color.rgb)*BlurColor;
    return Color;
}

//���[�v�p�萔
#define LOOPSCR	"LoopByCount=count;" \
                "LoopGetIndex=loop_index;" \
                "Pass=DrawObject_Onion;" \
                "LoopEnd=;" \
                 "Pass=DrawObject;" \
                
// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
// �s�v�Ȃ��͍̂폜��
technique MainTec0 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = false; 
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, false, false);
        PixelShader  = compile ps_2_0 Basic_PS(false, false, false);
    }
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(false, false);
        PixelShader  = compile ps_3_0 Onion_PS(false, false);
    }
}

technique MainTec1 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = false; 
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, false, false);
        PixelShader  = compile ps_2_0 Basic_PS(true, false, false);
    }
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(true, false);
        PixelShader  = compile ps_3_0 Onion_PS(true, false);
    }
}

technique MainTec2 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = false; 
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, true, false);
        PixelShader  = compile ps_2_0 Basic_PS(false, true, false);
    }
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(false, true);
        PixelShader  = compile ps_3_0 Onion_PS(false, true);
    }
}

technique MainTec3 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = false;  
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, true, false);
        PixelShader  = compile ps_2_0 Basic_PS(true, true, false);
    }
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(true, true);
        PixelShader  = compile ps_3_0 Onion_PS(true, true);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD���f���p�j
technique MainTec4 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = true;  
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, false, true);
        PixelShader  = compile ps_2_0 Basic_PS(false, false, true);
    }
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(false, false);
        PixelShader  = compile ps_3_0 Onion_PS(false, false);
    }
}

technique MainTec5 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = true;  
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, false, true);
        PixelShader  = compile ps_2_0 Basic_PS(true, false, true);
    }
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(true, false);
        PixelShader  = compile ps_3_0 Onion_PS(true, false);
    }
}

technique MainTec6 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = true;  
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, true, true);
        PixelShader  = compile ps_2_0 Basic_PS(false, true, true);
    }
    
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(false, true);
        PixelShader  = compile ps_3_0 Onion_PS(false, true);
    }
}

technique MainTec7 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = true;  
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, true, true);
        PixelShader  = compile ps_2_0 Basic_PS(true, true, true);
    }
    
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(true, true);
        PixelShader  = compile ps_3_0 Onion_PS(true, true);
    }
}
technique MainTec0_SS < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = false;  
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, false, false);
        PixelShader  = compile ps_2_0 Basic_PS(false, false, false);
    }
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	ZEnable = true;
    	ZWriteEnable = false;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(false, false);
        PixelShader  = compile ps_3_0 Onion_PS(false, false);
    }
}

technique MainTec1_SS < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = false; > {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, false, false);
        PixelShader  = compile ps_2_0 Basic_PS(true, false, false);
    }
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	ZEnable = true;
    	ZWriteEnable = false;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(true, false);
        PixelShader  = compile ps_3_0 Onion_PS(true, false);
    }
}

technique MainTec2_SS < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = false;  
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, true, false);
        PixelShader  = compile ps_2_0 Basic_PS(false, true, false);
    }
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	ZEnable = true;
    	ZWriteEnable = false;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(false, true);
        PixelShader  = compile ps_3_0 Onion_PS(false, true);
    }
}

technique MainTec3_SS < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = false;  
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, true, false);
        PixelShader  = compile ps_2_0 Basic_PS(true, true, false);
    }
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	ZEnable = true;
    	ZWriteEnable = false;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(true, true);
        PixelShader  = compile ps_3_0 Onion_PS(true, true);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD���f���p�j
technique MainTec4_SS < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = true;  
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, false, true);
        PixelShader  = compile ps_2_0 Basic_PS(false, false, true);
    }
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	ZEnable = true;
    	ZWriteEnable = false;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(false, false);
        PixelShader  = compile ps_3_0 Onion_PS(false, false);
    }
}

technique MainTec5_SS < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = true;  
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, false, true);
        PixelShader  = compile ps_2_0 Basic_PS(true, false, true);
    }
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	ZEnable = true;
    	ZWriteEnable = false;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(true, false);
        PixelShader  = compile ps_3_0 Onion_PS(true, false);
    }
}

technique MainTec6_SS < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = true;  
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, true, true);
        PixelShader  = compile ps_2_0 Basic_PS(false, true, true);
    }
    
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	ZEnable = true;
    	ZWriteEnable = false;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(false, true);
        PixelShader  = compile ps_3_0 Onion_PS(false, true);
    }
}

technique MainTec7_SS < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = true;  
	string Script = LOOPSCR;
	> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, true, true);
        PixelShader  = compile ps_2_0 Basic_PS(true, true, true);
    }
    
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
    	ZEnable = true;
    	ZWriteEnable = false;
    	#ifdef ONION_ADD
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	#endif
        VertexShader = compile vs_3_0 Onion_VS(true, true);
        PixelShader  = compile ps_3_0 Onion_PS(true, true);
    }
}
// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {}

///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��

// ���_�V�F�[�_
float4 Shadow_VS(float4 Pos : POSITION) : POSITION
{
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    return mul( Pos, WorldViewProjMatrix );
}
float4 Shadow_Onion_VS(float4 Pos : POSITION, int index : _INDEX) : POSITION
{
	Pos.xyz = getVertexPosBuf(index);
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    return mul( Pos, WorldViewProjMatrix );
}
// �s�N�Z���V�F�[�_
float4 Shadow_PS() : COLOR
{
    // �A���r�G���g�F�œh��Ԃ�
    return float4(AmbientColor.rgb, 0.65f);
}
float4 Shadow_Onion_PS() : COLOR
{
    // �A���r�G���g�F�œh��Ԃ�
    return float4(AmbientColor.rgb * Onion_Alpha * pow(Onion_AlphaSub,loop_index), 0.65f);
}
// �e�`��p�e�N�j�b�N
technique ShadowTec < 
    string MMDPass = "shadow";
    string Script = LOOPSCR;
> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Shadow_VS();
        PixelShader  = compile ps_2_0 Shadow_PS();
    }
    pass DrawObject_Onion {
    	FillMode = Onion_DrawMode;
        VertexShader = compile vs_3_0 Shadow_Onion_VS();
        PixelShader  = compile ps_3_0 Shadow_Onion_PS();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

// ���_�V�F�[�_
float4 ColorRender_VS(float4 Pos : POSITION) : POSITION 
{
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    return mul( Pos, WorldViewProjMatrix );
}

// �s�N�Z���V�F�[�_
float4 ColorRender_PS() : COLOR
{
    // ���œh��Ԃ�
    return float4(0,0,0,1);
}

// �֊s�`��p�e�N�j�b�N
technique EdgeTec <string MMDPass = "edge";> {
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;

        VertexShader = compile vs_3_0 ColorRender_VS();
        PixelShader  = compile ps_3_0 ColorRender_PS();
    }
}
