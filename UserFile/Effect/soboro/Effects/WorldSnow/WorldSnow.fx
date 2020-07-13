//
//  WorldParticleEngine 1.0
//         ����F���ڂ�
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾


//���q�F
float3 ParticleColor
<
   string UIName = "ParticleColor";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float3(1,1,1);

//���q�\����
int count
<
   string UIName = "count";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   int UIMin = 1;
   int UIMax = 30000;
> = 10000;

//�\���̈�
float AreaSize
<
   string UIName = "AreaSize";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   int UIMin = 50;
   int UIMax = 2000;
> = 350;


//�������x
float Speed
<
   string UIName = "Speed";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 250.0;
> = 12;

//�p�[�e�B�N���T�C�Y
float ParticleSize
<
   string UIName = "ParticleSize";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = 2.5;

//�����O���̂�炬
float NoizeLevel
<
   string UIName = "NoizeLevel";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 4.0;
> = 1;

//��炬���x
float NoizeSpeed
<
   string UIName = "NoizeSpeed";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 4.0;
> = 1;

//�e�N�X�`���̉�]���x
float RotationSpeed
<
   string UIName = "RotationSpeed";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 20.0;
> = 3;

//��]��炬
float RotationNoize
<
   string UIName = "RotationNoize";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 3.0;
> = 0;


//�T�C�Y��炬
float Flicker
<
   string UIName = "Flicker";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = 0.5;

//�T�C�Y��炬���x
float FlickerSpeed
<
   string UIName = "FlickerSpeed";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = 1.0;

//�u���[
float Blur
<
   string UIName = "Blur";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = 0.0;

//����
float AlphaAppend
<
   string UIName = "AlphaAppend";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 4.0;
> = 0.0;



//�p�[�e�B�N���e�N�X�`��
texture2D Tex1 <
    string ResourceName = "snow1.png";
    int MipLevels = 0;
>;
sampler Tex1Samp = sampler_state {
    texture = <Tex1>;
    MINFILTER = ANISOTROPIC;
    MAGFILTER = ANISOTROPIC;
    MIPFILTER = LINEAR;
    AddressU  = Clamp;
    AddressV = Clamp;
    MAXANISOTROPY = 16;
};

texture2D Tex2 <
    string ResourceName = "snow2.png";
    int MipLevels = 0;
>;
sampler Tex2Samp = sampler_state {
    texture = <Tex2>;
    MINFILTER = ANISOTROPIC;
    MAGFILTER = ANISOTROPIC;
    MIPFILTER = LINEAR;
    AddressU  = Clamp;
    AddressV = Clamp;
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


float alpha1 : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float size1 : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
static float size = size1 * 0.1;

float ftime : TIME <bool SyncInEditMode = false;>;

float4x4 matWorld : CONTROLOBJECT < string name = "(self)"; >; 
static float pos_y = matWorld._42;
static float pos_z = matWorld._43;

// ���@�ϊ��s��
float4x4 WorldMatrix : WORLD;
float4x4 ViewProjMatrix    : VIEWPROJECTION;
float4x4 WorldViewProjMatrix    : WORLDVIEWPROJECTION;

float4x4 WorldMatrixInverse : WORLDINVERSE;
float4x4 ViewMatrixInverse : VIEWINVERSE;
float4x4 WorldViewMatrixInverse : WORLDVIEWINVERSE;

float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;


static float3x3 BillboardMatrix = {
    normalize(ViewMatrixInverse[0].xyz),
    normalize(ViewMatrixInverse[1].xyz),
    normalize(ViewMatrixInverse[2].xyz),
};

static float3x3 RotMatrix = {
    normalize(WorldMatrix[0].xyz),
    normalize(WorldMatrix[1].xyz),
    normalize(WorldMatrix[2].xyz),
};
static float3x3 RotMatrixInverse = {
    normalize(WorldMatrixInverse[0].xyz),
    normalize(WorldMatrixInverse[1].xyz),
    normalize(WorldMatrixInverse[2].xyz),
};

float3 CameraDirection : DIRECTION < string Object = "Camera"; >;
float3 CameraPosition : POSITION  < string Object = "Camera"; >;


// Controller�Ή� ////////////////////////////////////////////////////////////

bool flag1 : CONTROLOBJECT < string name = "WorldParticleController.pmd"; >;
//bool flag1 = false;

float count_e : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "���q��"; >;
float AreaSize_e : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "�̈�L��"; >;

float Speed_e : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "�������x"; >;
float ParticleSize_e : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "���q����"; >;
float NoizeLevel_e : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "��炬"; >;

float R : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "R"; >;
float G : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "G"; >;
float B : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "B"; >;
float Shine : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "���邭"; >;

float NoizeSpeed_e : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "��ꑬ�x"; >;
float RotationSpeed_e : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "��]"; >;
float RotationNoize_e : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "��]���"; >;
float Flicker_e : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "���ނ��"; >;

float Blur_e : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "�u���["; >;

float TextureSelect : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "ø���"; >;
float Transparent : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "����"; >;
float AlphaAppend_e : CONTROLOBJECT < string name = "WorldParticleController.pmd"; string item = "����"; >;


static float count_m = flag1 ? (count_e * 30000) : count;
static float AreaSize_m = flag1 ? (AreaSize_e * 1000) : AreaSize;

static float Speed_m = flag1 ? (Speed_e * Speed_e * 300) : Speed;
static float ParticleSize_m = (flag1 ? (ParticleSize_e * ParticleSize_e * 40) : ParticleSize) * size;
static float NoizeLevel_m = flag1 ? (NoizeLevel_e * 4) : NoizeLevel;
static float Flicker_m = flag1 ? (Flicker_e * 1) : Flicker;

static float3 ParticleColor_m = flag1 ? (float3(R,G,B) * pow(10, Shine * 3)) : ParticleColor;

static float NoizeSpeed_m = flag1 ? (NoizeSpeed_e * 5) : NoizeSpeed;
static float RotationSpeed_m = flag1 ? (RotationSpeed_e * 10) : RotationSpeed;
static float RotationNoize_m = flag1 ? RotationNoize_e : RotationNoize;
static float Blur_m = flag1 ? Blur_e : Blur;
static float AlphaAppend_m = flag1 ? (AlphaAppend_e * 4) : AlphaAppend;


// �\���̈撆�S
static float3 AreaCenter = CameraPosition + CameraDirection * AreaSize_m / 4;
static float3 AreaCenterT = AreaCenter / AreaSize_m;



///////////////////////////////////////////////////////////////////////////////////////////////

//�����擾
float4 getRandom(float rindex)
{
    float2 tpos = float2(rindex % RNDTEX_WIDTH, trunc(rindex / RNDTEX_WIDTH));
    tpos += float2(0.5, 0.5);
    tpos /= float2(RNDTEX_WIDTH, RNDTEX_HEIGHT);
    return tex2Dlod(rnd, float4(tpos,0,0));
}

///////////////////////////////////////////////////////////////////////////////////////////////

//���q�ʒu����֐�
float4 getParticlePos(float index, float time){
    
    // �����_���z�u
    float4 base_pos = getRandom(index);
    
    //����
    base_pos.y = frac(base_pos.y - (Speed_m * time / AreaSize_m));
    
    //�m�C�Y�t��
    float stime = time * NoizeSpeed_m;
    base_pos.x += (sin(stime * 0.8 + index) + cos(stime * 0.5 + index) * 0.5) * (NoizeLevel_m / AreaSize_m);
    base_pos.z += (sin(stime * 0.45 + index) * 0.6 + cos(stime * 0.9 + index) * 0.8) * (NoizeLevel_m / AreaSize_m);
    
    //�̈�ύX
    float3 rotinvcenter = mul(AreaCenterT, RotMatrixInverse);
    base_pos.xyz -= rotinvcenter;
    float3 inner_pos = frac(base_pos.xyz); //�̈�����W
    inner_pos -= 0.5;
    base_pos.xyz = inner_pos + rotinvcenter;
    
    //�̈�T�C�Y�ύX
    base_pos.xyz *= AreaSize_m;
    
    //��]
    base_pos.xyz = mul(base_pos.xyz, RotMatrix);
    
    return base_pos;
}

///////////////////////////////////////////////////////////////////////////////////////////////

//���q�t�F�[�h�֐�
float ParticleFade(float4 particle_pos){
    float alpha;
    
    //�n�ʃt�F�[�h
    alpha = saturate((particle_pos.y - pos_y) * 0.2);
    
    //�����͔���
    float fadelen = (AreaSize_m * 0.75);
    float camera_len = length(particle_pos.xyz - CameraPosition.xyz);
    float farfade = saturate((fadelen - camera_len) / fadelen);
    
    farfade = pow(farfade, 0.4);
    //farfade = sqrt(farfade);
    
    alpha *= farfade;
    
    //���ߋ����͔���
    alpha *= saturate((camera_len - 10) * 0.05);
    
    return alpha;
}

///////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // �e�N�X�`��
    float4 TexRot     : TEXCOORD1;   // �e�N�X�`����]
    float4 ZCalcTex   : TEXCOORD2;   // Z�l
    float  Alpha      : COLOR0;
};

///////////////////////////////////////////////////////////////////////////////////////////////

// ���_�V�F�[�_
VS_OUTPUT WPEngine_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0, uniform bool Shadow)
{
    VS_OUTPUT Out;
    Out.Alpha = 1;
    
    //�|���S����Z���W���C���f�b�N�X�Ƃ��ė��p
    float index = Pos.z;
    Pos.z = 0;
    
    //�T�C�Y�ύX
    float fstime = ftime * FlickerSpeed * NoizeSpeed_m;
    float flicker = (sin(fstime * 5 + index) * 0.5 + 0.5) + (cos(fstime * 2.3 + index) * 0.5 + 0.5) * 0.5;
    
    flicker = lerp(1, flicker, Flicker_m);
    
    Pos.xy *= ParticleSize_m * flicker;
    
    // �r���{�[�h��
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );
    
    //�p�[�e�B�N�����W�̎擾
    float4 particle_pos = getParticlePos(index, ftime);
    
    Pos.xyz += particle_pos.xyz;
    
    //�\���������̃p�[�e�B�N���͉B��
    Pos.z -= (index >= count_m) * 100000;
    
    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, ViewProjMatrix );
    
    //�A���t�@�K�p
    Out.Alpha *= ParticleFade(particle_pos);
    Out.Alpha *= alpha1 * (1 - Transparent);
    Out.Alpha *= 1 + AlphaAppend_m;
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    //��]�P�ʃx�N�g���̍쐬
    float rot = ftime * RotationSpeed_m * (1 - (sin(index) * RotationNoize_m)) + index * 6;
    Out.TexRot.xy = float2(cos(rot), sin(rot)); //Ut
    Out.TexRot.zw = float2(-sin(rot), cos(rot)); //Vt
    
    if(Shadow){
        // ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�
        float4 uwpos = Pos;
        uwpos.xyz /= size1;
        uwpos.xyz = mul(uwpos.xyz, RotMatrixInverse);
        Out.ZCalcTex = mul( uwpos, LightWorldViewProjMatrix );
        
    }else{
        Out.ZCalcTex = 0;
    }
    
    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////////

// �s�N�Z���V�F�[�_
float4 WPEngine_PS( VS_OUTPUT input ) : COLOR0
{
    //UV�̍��W�ϊ�
    float2 tex = input.Tex - 0.5;
    tex = input.TexRot.xy * tex.x + input.TexRot.zw * tex.y;
    tex += 0.5;
    
    float4 color1 = tex2D( Tex1Samp, tex );
    float4 color2 = tex2D( Tex2Samp, tex );
    float4 color = lerp(color1, color2, TextureSelect);
    color.rgb = ParticleColor_m;
    color.a *= input.Alpha;
    
    //color = float4(1,1,1,1);
    
    return color;
}

///////////////////////////////////////////////////////////////////////////////////////////////

// �V���h�E�o�b�t�@�̃T���v��
sampler DefSampler : register(s0);

// �s�N�Z���V�F�[�_(�V���h�E��)
float4 WPEngine_S_PS( VS_OUTPUT input ) : COLOR0
{
    //UV�̍��W�ϊ�
    float2 tex = input.Tex - 0.5;
    tex = input.TexRot.xy * tex.x + input.TexRot.zw * tex.y;
    tex += 0.5;
    
    float4 color1 = tex2D( Tex1Samp, tex );
    float4 color2 = tex2D( Tex2Samp, tex );
    float4 color = lerp(color1, color2, TextureSelect);
    color.rgb *= ParticleColor_m;
    color.a *= input.Alpha;
    
    //�V���h�E�Ή�
    
    float light = 1;
    float darklight = 0.3;
    
    // �e�N�X�`�����W�ɕϊ�
    input.ZCalcTex /= input.ZCalcTex.w;
    float2 TransTexCoord;
    TransTexCoord = 0.5 + (input.ZCalcTex.xy * float2(0.5, -0.5));
    
    if( any( saturate(TransTexCoord) != TransTexCoord ) ) {
        light = darklight;
    } else {
        light = (input.ZCalcTex.z >= tex2D(DefSampler,TransTexCoord).r) ? darklight : 1;
    }
    
    color *= light;
    
    return color;
}

///////////////////////////////////////////////////////////////////////////////////////////////

technique MainTec < string MMDPass = "object"; > {
    pass DrawObject {
        ZWRITEENABLE = false; //Z�o�b�t�@���X�V���Ȃ�
        
        //�����̃R�����g�A�E�g���O���Ή��Z������
        //SRCBLEND=ONE;
        //DESTBLEND=ONE;
        
        VertexShader = compile vs_3_0 WPEngine_VS(false);
        PixelShader  = compile ps_3_0 WPEngine_PS();
    }
}

technique MainTec2 < string MMDPass = "object_ss"; > {
    pass DrawObject {
        ZWRITEENABLE = false; //Z�o�b�t�@���X�V���Ȃ�
        
        //�����̃R�����g�A�E�g���O���Ή��Z������
        //SRCBLEND=ONE;
        //DESTBLEND=ONE;
        
        VertexShader = compile vs_3_0 WPEngine_VS(true);
        PixelShader  = compile ps_3_0 WPEngine_S_PS();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g

struct VS_ZValuePlot_OUTPUT {
    float4 Pos : POSITION;              // �ˉe�ϊ����W
    float4 ShadowMapTex : TEXCOORD0;    // Z�o�b�t�@�e�N�X�`��
};

// ���_�V�F�[�_
VS_ZValuePlot_OUTPUT ZValuePlot_VS( float4 Pos : POSITION )
{
    VS_ZValuePlot_OUTPUT Out = (VS_ZValuePlot_OUTPUT)0;

    // ���C�g�̖ڐ��ɂ�郏�[���h�r���[�ˉe�ϊ�������
    Out.Pos = mul( Pos, LightWorldViewProjMatrix );

    // �e�N�X�`�����W�𒸓_�ɍ��킹��
    Out.ShadowMapTex = Out.Pos;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS( float4 ShadowMapTex : TEXCOORD0 ) : COLOR
{
    // R�F������Z�l���L�^����
    return float4(ShadowMapTex.z/ShadowMapTex.w,0,0,1);
}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {
    /*pass ZValuePlot {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 ZValuePlot_VS();
        PixelShader  = compile ps_2_0 ZValuePlot_PS();
    }*/
}

// �n�ʉe�Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }