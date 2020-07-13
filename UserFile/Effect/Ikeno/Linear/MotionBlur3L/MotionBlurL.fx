////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ���ڂ낳��̃��[�V�����u���[�G�t�F�N�g�����j�A����������
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ���[�U�[�p�����[�^

// HDR��L���ɂ��� (ikeno)
#define ENABLE_HDR		1
// ���`��ԂŌv�Z���s����?(ikeno)
#define ENABLE_GAMMA_CORRECT	1


// �ڂ������x(�傫����������ƎȂ��o�܂�)
float DirectionalBlurStrength
<
   string UIName = "DirectionalBlurStrength";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 3.0;
> = float( 0.5 );

//�c������
float LineBlurLength
<
   string UIName = "LineBlurLength";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 1.5 );

//�c���Z��
float LineBlurStrength
<
   string UIName = "LineBlurStrength";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 1.0 );

//���x�̏���l
float VelocityLimit
<
   string UIName = "VelocityLimit";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 3.0;
> = float( 0.12 );

//���x�̉����l
float VelocityUnderCut
<
   string UIName = "VelocityUnderCut";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 3.0;
> = float( 0.006 );

//�V�[���؂�ւ�臒l
float SceneChangeThreshold
<
   string UIName = "SceneChangeThreshold";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 100;
> = float( 20 );

//�V�[���؂�ւ��p�x臒l
float SceneChangeAngleThreshold
<
   string UIName = "SceneChangeAngleThreshold";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 100;
> = float( 25 );


//�w�i�F
float4 BackColor
<
   string UIName = "BackColor";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4( 0, 0, 0, 0 );


//������̃T���v�����O��
#define SAMP_NUM   9

#define SAMP_NUM_LB  6


#if defined(ENABLE_HDR) && ENABLE_HDR > 0
#define COLOR_TEXFORMAT "D3DFMT_A16B16G16R16F"
#else
#define COLOR_TEXFORMAT "A8R8G8B8"
#endif

///////////////////////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;


//�A���t�@�l�擾
float alpha1 : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

// �X�P�[���l�擾
float scaling : CONTROLOBJECT < string name = "(self)"; >;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float ViewportAspect = ViewportSize.x / ViewportSize.y;

static float2 ViewportOffset = (float2(0.5,0.5) / ViewportSize);

static float2 BlurSampStep = (float2(DirectionalBlurStrength, DirectionalBlurStrength)/ViewportSize*ViewportSize.y);
static float2 BlurSampStepScaled = BlurSampStep;



#define VM_TEXFORMAT "A32B32G32R32F"
//#define VM_TEXFORMAT "A16B16G16R16F"

//�[�x�t���x���V�e�B�}�b�v�쐬
texture VelocityRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for MotionBlur.fx";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0.5, 0.5, 1, 0 };
    float ClearDepth = 1.0;
    string Format = VM_TEXFORMAT ;
    bool AntiAlias = true;
    int MipLevels = 1;
    string DefaultEffect = 
        "self = hide;"
        "* = VelocityMap.fx;"
        ;
>;

sampler VelocitySampler = sampler_state {
    texture = <VelocityRT>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = NONE;
};



// �[�x�o�b�t�@
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 0;
    string Format = COLOR_TEXFORMAT ;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// �����u���[�̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 0;
    string Format = COLOR_TEXFORMAT ;
>;
sampler2D ScnSamp2 = sampler_state {
    texture = <ScnMap2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

//���C���u���[�o�̓o�b�t�@


//�I���W�i���̃O���b�h�T�C�Y
#define LINEBLUR_ORGGRID 128

#define LINEBLUR_RESRATE  8

#define LINEBLUR_GRIDSIZE (LINEBLUR_ORGGRID*LINEBLUR_RESRATE)
#define LINEBLUR_BUFSIZE  512

int loopindex_x = 0;
int loopindex_y = 0;
int loopcount = LINEBLUR_RESRATE;


texture2D LineBluerDepthBuffer : RENDERDEPTHSTENCILTARGET <
    int Width = LINEBLUR_BUFSIZE;
    int Height = LINEBLUR_BUFSIZE;
    string Format = "D24S8";
>;
texture2D LineBluerTex : RENDERCOLORTARGET <
    //int Width = LINEBLUR_BUFSIZE;
    //int Height = LINEBLUR_BUFSIZE;
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = COLOR_TEXFORMAT;
>;
sampler2D LineBluerSamp = sampler_state {
    texture = <LineBluerTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

texture2D LineBluerInfoTex : RENDERCOLORTARGET <
    int Width = LINEBLUR_BUFSIZE;
    int Height = LINEBLUR_BUFSIZE;
    int MipLevels = 1;
    string Format = VM_TEXFORMAT;
>;
sampler2D LineBluerInfoSamp = sampler_state {
    texture = <LineBluerInfoTex>;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

//���X�N���[���Q�Ǝ��̃~�b�v���x��
static float ScnMipLevel1 = log2(ViewportSize.x / (float)LINEBLUR_GRIDSIZE) + 0.5;


//�J�����ʒu�̋L�^

#define INFOBUFSIZE 2

float2 InfoBufOffset = float2(0.5 / INFOBUFSIZE, 0.5);

texture CameraBufferMB : RenderDepthStencilTarget <
   int Width=INFOBUFSIZE;
   int Height=1;
    string Format = "D24S8";
>;
texture CameraBufferTex : RenderColorTarget
<
    int Width=INFOBUFSIZE;
    int Height=1;
    bool AntiAlias = false;
    int Miplevels = 1;
    string Format="A32B32G32R32F";
>;

float4 CameraBuffer[INFOBUFSIZE] : TEXTUREVALUE <
    string TextureName = "CameraBufferTex";
>;

//�J�����ʒu
float3 CameraPosition : POSITION  < string Object = "Camera"; >;
float3 CameraDirection : DIRECTION < string Object = "Camera"; >;

//�V�[���؂�ւ����ǂ�������
static bool IsSceneChange = (length(CameraPosition - CameraBuffer[0].xyz) > SceneChangeThreshold)
                            || (dot(CameraDirection, CameraBuffer[1].xyz) < cos(SceneChangeAngleThreshold * 3.14 / 180));

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

//�����擾
float4 getRandom(float rindex)
{
    float2 tpos = float2(rindex % RNDTEX_WIDTH, trunc(rindex / RNDTEX_WIDTH));
    tpos += float2(0.5,0.5);
    tpos /= float2(RNDTEX_WIDTH, RNDTEX_HEIGHT);
    return tex2Dlod(rnd, float4(tpos,0,1));
}


//-----------------------------------------------------------------------------
// �K���}�␳�Ή�
#if defined(ENABLE_GAMMA_CORRECT) && ENABLE_GAMMA_CORRECT > 0
bool bLinearMode : CONTROLOBJECT < string name = "ikLinearEnd.x"; >;
const float epsilon = 1.0e-6;
const float gamma = 2.2;
inline float3 Degamma(float3 col)
{
	return (!bLinearMode) ? pow(max(col,epsilon), gamma) : col;
}
inline float3 Gamma(float3 col)
{
	return (!bLinearMode) ? pow(max(col,epsilon), 1.0/gamma) : col;
}
inline float4 Degamma4(float4 col) { return float4(Degamma(col.rgb), col.a); }
inline float4 Gamma4(float4 col) { return float4(Gamma(col.rgb), col.a); }

inline float3 DegammaEmissive(float3 col)
{
	// �������`����ƁA�I���W�i���ƐF�����ς�肷����
	return col; // pow(max(col,epsilon), gamma);
}
inline float4 DegammaEmissive4(float4 col) { return float4(DegammaEmissive(col.rgb), col.a); }
#else
inline float3 Degamma(float3 col) { return col; }
inline float3 Gamma(float3 col) { return col; }
inline float4 Degamma4(float4 col) { return col; }
inline float4 Gamma4(float4 col) { return col; }
inline float4 DegammaEmissive4(float4 col) { return col; }
#endif

//-----------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////////////////////
// ���ʒ��_�V�F�[�_
struct VS_OUTPUT {
    float4 Pos            : POSITION;
    float2 Tex            : TEXCOORD0;
};

VS_OUTPUT VS_passDraw( float4 Pos : POSITION, float2 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    
    return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�[�x�t���x���V�e�B�}�b�v�Q�Ɗ֐��Q


#define VELMAP_SAMPLER  VelocitySampler


//�}�b�v�i�[��񂩂瑬�x�x�N�g���𓾂�
float2 MB_VelocityPreparation(float4 rawvec){
    float2 vel = rawvec.xy - 0.5;
    float len = length(vel);
    vel = max(0, len - VelocityUnderCut) * normalize(vel);
    
    vel = min(vel, float2(VelocityLimit, VelocityLimit));
    vel = max(vel, float2(-VelocityLimit, -VelocityLimit));
    
    return vel  * scaling * 0.1;
}

float2 MB_GetBlurMap(float2 Tex){
    return MB_VelocityPreparation(tex2Dlod( VELMAP_SAMPLER, float4(Tex, 0, 0) ));
}

float MB_GetDepthMap(float2 Tex){
    return tex2Dlod( VELMAP_SAMPLER, float4(Tex, 0, 0) ).z;
}

float2 MB_GetBlurMapAround(float2 Tex){
    float4 vm, vms;
    const float step = 4.5 / LINEBLUR_BUFSIZE;
    float z0, n = 1;
    
    vms = tex2Dlod( VELMAP_SAMPLER, float4(Tex, 0, 0) );
    
    z0 = vms.z;
    
    vm = tex2Dlod( VELMAP_SAMPLER, float4( Tex.x + step, Tex.y, 0, 0 ) );
    vms += vm * (vm.z >= z0);
    n += (vm.z >= z0);
    
    vm = tex2Dlod( VELMAP_SAMPLER, float4( Tex.x - step, Tex.y, 0, 0 ) );
    vms += vm * (vm.z >= z0);
    n += (vm.z >= z0);
    
    vm = tex2Dlod( VELMAP_SAMPLER, float4( Tex.x, Tex.y + step, 0, 0 ) );
    vms += vm * (vm.z >= z0);
    n += (vm.z >= z0);
    
    vm = tex2Dlod( VELMAP_SAMPLER, float4( Tex.x, Tex.y - step, 0, 0 ) );
    vms += vm * (vm.z >= z0);
    n += (vm.z >= z0);
    
    vms /= n;
    
    return MB_VelocityPreparation(vms);
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�x���V�e�B�}�b�v�ɏ]���������u���[��������

float4 PS_DirectionalBlur( float2 Tex: TEXCOORD0 , uniform float rate, uniform bool isLast) : COLOR {   
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    
    float2 vel = MB_GetBlurMap(Tex);
    
    float4 info;
    float2 step = BlurSampStepScaled * vel / SAMP_NUM * float2(1,-1) * rate;
    float depth, centerdepth = MB_GetDepthMap(Tex) - 0.01;
    
    float bp = saturate(length(vel) * 10);
    
    step *= (!IsSceneChange); //�V�[���؂�ւ��̓u���[����
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
        e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
        stex = Tex + (step * (float)i);
        
        //��O�����܂蓮���Ă��Ȃ���������̃T���v�����O�͎キ
        if(i != 0){
            depth = MB_GetDepthMap(stex);
            
            float4 sinfo = tex2Dlod( VELMAP_SAMPLER, float4(stex, 0, 0) );
            float2 svel = MB_VelocityPreparation(sinfo);
            
            e *= max(saturate(length(svel) / 0.02), (depth > centerdepth));
            
            e *= sinfo.a;
        }
        
        //�T���v�����O
		float4 col = tex2Dlod( ScnSamp, float4(stex, 0, 0));
		if (!isLast) col = Degamma4(col);
        sum += col * e;
        n += e;
    }
    
    Color = sum / n;

	if (isLast) Color = Gamma4(Color);

    return Color;
    
}



////////////////////////////////////////////////////////////////////////////////////////////////
//���C���u���[�o�̓o�b�t�@�̏����l�ݒ�


float4 PS_ClearLineBluer( float2 Tex: TEXCOORD0 ) : COLOR  {
    
    float4 Color;
    
    //�A���t�@�l��0�ɂ������X�N���[���摜�Ŗ��߂�
    Color = tex2Dlod( ScnSamp2, float4(Tex,0,0) );
    Color.a = 0;
    
    return Color;
}

float4 PS_ClearLineBluerInfo( float2 Tex: TEXCOORD0 ) : COLOR  {
    
    float4 Info;
    
    //���C���u���[�Ŏg�p������}�b�v���o��
    Info.xy = MB_GetBlurMapAround( Tex );
    Info.z = MB_GetDepthMap( Tex );
    Info.w = 1;
    
    return Info;
}

/////////////////////////////////////////////////////////////////////////////////////
//���C���u���[�`��

struct VS_OUTPUT3 {
    float4 Pos: POSITION;
    float4 Color: COLOR0;
    float3 Tex : TEXCOORD0;
    float2 BaseVel : TEXCOORD1;
    float2 Tex2 : TEXCOORD2;
    float2 SampTex : TEXCOORD3;
    
};

VS_OUTPUT3 VS_LineBluer(float4 Pos : POSITION, int index: _INDEX)
{
    VS_OUTPUT3 Out;
    float2 PosEx = Pos.xy;
    //bool IsTip = (Pos.x > 0); //���C���̐L�т���[
    
    float findex = Pos.z;
    
    //findex = 128 * 128 - 1 - findex;
    
    bool OutsideGrid = (findex >= (LINEBLUR_ORGGRID * LINEBLUR_ORGGRID));
    
    float2 findex_xy = float2(findex % LINEBLUR_ORGGRID, trunc(findex / LINEBLUR_ORGGRID));
    
    //if ((float)(loopindex_y) % 2 <= 0.1) findex_xy.y = LINEBLUR_ORGGRID - 1 - findex_xy.y;
    
    
    //findex += (loopindex_x + loopindex_y * loopcount) * (128 * 128);
    //findex = findex * 4 + loopindex;
    
    float2 lofs = float2(loopindex_x, loopindex_y);
    
    
    lofs.x = lerp(lofs.x, LINEBLUR_RESRATE - 1 - lofs.x, (findex_xy.x % 2) < 0.1);
    lofs.y = lerp(lofs.y, LINEBLUR_RESRATE - 1 - lofs.y, (findex_xy.y % 2) < 0.1);
    
    #ifdef MIKUMIKUMOVING
        findex_xy = findex_xy * (float)LINEBLUR_RESRATE + lofs;
    #else
        findex_xy += lofs * LINEBLUR_ORGGRID;
    #endif
    
    float4 rnd = getRandom(findex + loopindex_x + loopindex_y);
    
    findex_xy += (rnd.xy - 0.5) * 2;
    
    
    
    
    //float2 findex_xy = float2(findex % LINEBLUR_GRIDSIZE, trunc(findex / LINEBLUR_GRIDSIZE));
    
    float2 TexPos = findex_xy / LINEBLUR_GRIDSIZE;// + ViewportOffset;
    float2 ScreenPos = (TexPos * 2 - 1) * float2(1,-1);
    
    //�x���V�e�B�}�b�v�Q��
    float4 VelMap = tex2Dlod( VELMAP_SAMPLER, float4(TexPos, 0, 0) );
    float2 Velocity = MB_VelocityPreparation(VelMap);
    
    float2 AspectedVelocity = -Velocity / float2(ViewportAspect, 1);
    
    float VelLen = length(Velocity) * alpha1;
    
    Out.BaseVel = Velocity; //PS�ɑ��x��n���B
    
    Out.Tex2 = Pos.xy;
    
    //���C����
    PosEx *= (1.0 / LINEBLUR_GRIDSIZE);
    //���C������
    PosEx.x += Pos.x * sqrt(VelLen) * 0.1 * LineBlurLength;
    
    
    //�΂߃��C���͑���
    //PosEx.y *= 1.5 + 0.4 * abs(sin(atan2(AspectedVelocity.x, AspectedVelocity.y) * 2));
    PosEx.y *= 5.0;
    
    
    //���C����]
    float2 AxU = normalize(AspectedVelocity);
    float2 AxV = float2(AxU.y, -AxU.x);
    
    PosEx = PosEx.x * AxU + PosEx.y * AxV;
    
    //���_�ʒu�ɂ��T���v�����O�ʒu�̃I�t�Z�b�g
    //TexPos += (-Pos.y * AxV) / (LINEBLUR_GRIDSIZE * 2);
    //TexPos -= float2(AxU.x, -AxU.y) * 0.0001;
    
    Out.SampTex = TexPos;
    
    //���X�N���[���Q��
    Out.Color = tex2Dlod( ScnSamp2, float4(Out.SampTex, 0, 0) );
    //Out.Color = tex2Dlod( ScnSamp2, float4(TexPos, 0, ScnMipLevel1) );
    //Out.Color = float4(1,1,1,1);
    
    //�u���[���x����A���t�@�ݒ�E���C����[�͓�����
    //Out.Color.a *= saturate(VelLen * 250) * (1 - IsTip);
    Out.Color.a = saturate(VelLen * 50);
    
    
    Out.Color.a *= 0.8;
    
    
    
    Out.Color.a *= (!IsSceneChange); //�V�[���؂�ւ��̓u���[����
    
    //�o�b�t�@�o��
    Out.Pos.xy = ScreenPos + PosEx + (2000 * (Out.Color.a < 0.01)) + (2000 * OutsideGrid);
    Out.Pos.z = 0.5;
    Out.Pos.w = 1;
    
    //�X�N���[���e�N�X�`�����W
    Out.Tex.xy = (Out.Pos.xy * float2(1,-1) + 1) * 0.5 + (0.5 / LINEBLUR_BUFSIZE);
    Out.Tex.z = VelMap.z; //TEXCOORD0��Z���؂�āA�c���̔�������Z�l��n��
    
    return Out;
}

float4 PS_LineBluer( VS_OUTPUT3 IN ) : COLOR0
{
    
    //float4 Info = tex2D( LineBluerInfoSamp, IN.Tex.xy);
    float4 Info = tex2Dlod( LineBluerInfoSamp, float4(IN.Tex.xy, 0, 0));
    
    /*float4 Info;
    
    //���C���u���[�Ŏg�p������}�b�v���o��
    Info.xy = MB_GetBlurMapAround( IN.Tex.xy );
    Info.z = MB_GetDepthMap( IN.Tex.xy );
    Info.w = 1;*/
    
    float4 Color = IN.Color;
    float alpha = saturate((1.0 - abs(IN.Tex2.x)) * 1.2) ; //��[�𓧖���
    //float alpha = saturate((1.0 - length(IN.Tex2.xy)) * 1.0) ; //��[�𓧖���
    //float alpha = 1.0;
    
    //alpha *= saturate(1.2 - abs(atan2(IN.Tex2.x, IN.Tex2.y) / 3));
    
    //alpha *= saturate(abs(IN.Tex2.x / IN.Tex2.y) * 0.8 + 0.2);
    
    //Color.rgb = tex2Dlod( ScnSamp2, float4(IN.SampTex, 0, 0) ).rgb;
    
    /*Color.r = abs(IN.Tex2.x);
    Color.g = 1 - abs(IN.Tex2.x);
    Color.b = 0;*/
    
    Color.a *= alpha;
    
    float BaseZ = Info.z; //���摜��Z
    float AfImZ = IN.Tex.z; //�c����Z
    
    //��O�̃I�u�W�F�N�g��̎c���͉B��
    Color.a *= saturate(1 - (AfImZ - BaseZ) * 10);
    //Color.a *= saturate(1 - (AfImZ - BaseZ) * 200);
    
    float2 vel = Info.xy;
    
    //�w�i�̑��x�x�N�g������v���Ă���Ƃ��͔���
    float vdrate = max(length(vel), length(IN.BaseVel));
    vdrate = (vdrate == 0) ? 0 : (1 / vdrate);
    float VelDif = length(vel - IN.BaseVel) * vdrate;
    //VelDif += saturate(1.0 - abs(IN.Tex2.x) * 4);
    Color.a *= saturate(VelDif * 2);
    
    //Color.a = 1;
    
    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
//���C���u���[�̍���

VS_OUTPUT VS_LineBluerInfo( float4 Pos : POSITION, float2 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + (0.5 / LINEBLUR_BUFSIZE);
    
    return Out;
}


float4 PS_LB_Gaussian( float2 Tex: TEXCOORD0, 
           uniform bool Horizontal, uniform sampler2D Samp 
           ) : COLOR {
    
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    
    float step = (Horizontal ? (1.0 / ViewportAspect) : 1.0) * (0.012 / SAMP_NUM_LB);
    const float2 dir = float2(Horizontal, !Horizontal);
    float4 scolor;
    float amax = 0;
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM_LB; i <= SAMP_NUM_LB; i++){
        e = exp(-pow((float)i / (SAMP_NUM_LB / 2.0), 2) / 2); //���K���z
        stex = Tex + dir * (step * (float)i);
        scolor = tex2Dlod( Samp, float4(stex, 0, 0));
        //amax = max(amax, scolor.a);
        sum += scolor * e;
        n += e;
    }
    
    Color = sum / n;
    
    //Color.a = lerp(amax, Color.a, 0.5);
    
    return Color;
}



#define LBSAMP LineBluerSamp

float4 PS_MixLineBluer( float2 Tex: TEXCOORD0 ) : COLOR {   
    float2 step = 1.4 / LINEBLUR_BUFSIZE;
    
    //float4 Color = tex2D( LineBluerSamp, Tex);
    float4 Color = tex2Dlod( LineBluerSamp, float4(Tex,0,0));
    
    //������𑜓x�Ȃ̂ŁA�W���M�[�����̂��߂Ɍy���ڂ���
    /*[unroll] for(int j = -1; j <= 1; j++){
        [unroll] for(int i = -1; i <= 1; i++){
            Color += tex2D( LineBluerSamp, Tex + step * float2(i,j) );
            
        }
    }
    
    Color /= 10;
    */
    
    //Color.a = saturate(pow(Color.a, 0.7));
    
    Color.a = saturate(Color.a * 1.3);
    
    //Color.a = saturate(Color.a * 2);
    
    Color.a *= LineBlurStrength;
    
    float4 ColorOrg = tex2Dlod( ScnSamp2, float4(Tex,0,0));
    
    Color.rgb = lerp(ColorOrg.rgb, Color.rgb, Color.a);
    //Color.rgb = lerp(ColorOrg.rgb, float3(1,0,0), Color.a);
    
    Color.a = max(ColorOrg.a, Color.a);
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�J�����ʒu�̋L�^

VS_OUTPUT VS_CameraBuffer( float4 Pos : POSITION, float2 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + InfoBufOffset;
    
    return Out;
}

float4 PS_CameraBuffer( float4 Tex : TEXCOORD0 ) : COLOR {   
    float4 Color = float4(CameraPosition, 1);
    Color = (Tex.x >= 0.5) ? float4(CameraDirection, 1) : Color;
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

// �����_�����O�^�[�Q�b�g�̃N���A�l
//float4 ClearColor = {1,1,1,0};
float4 ClearColor = {0,0,0,0};
float4 ClearColor2 = {0,0,0,0};
float ClearDepth  = 1.0;


technique MotionBlur <
    string Script = 
        
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=BackColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"
        
        "RenderColorTarget0=ScnMap2;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=BackColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=DirectionalBlur1;"
        
        "RenderColorTarget0=LineBluerTex;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor2; Clear=Color;"
        "ClearSetDepth=ClearDepth; Clear=Depth;"
        "Pass=ClearLineBluer;"
        
        "RenderColorTarget0=LineBluerInfoTex;"
        "RenderDepthStencilTarget=LineBluerDepthBuffer;"
        "ClearSetColor=ClearColor2; Clear=Color;"
        "ClearSetDepth=ClearDepth; Clear=Depth;"
        "Pass=ClearLineBluerInfo;"
        
        "RenderColorTarget0=LineBluerTex;"
        "RenderColorTarget1=;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "Clear=Depth;"
        
        
        //�J��Ԃ�
        "LoopByCount=loopcount;"
        "LoopGetIndex=loopindex_x;"
            "LoopByCount=loopcount;"
            "LoopGetIndex=loopindex_y;"
                "Pass=DrawLineBluer;"
            "LoopEnd=;"
        "LoopEnd=;"
        
        
        
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=BackColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=LineBlurGaussianX;"
        
        "RenderColorTarget0=LineBluerTex;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=BackColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=LineBlurGaussianY;"
        
        
        /*"RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=MixLineBluer;"*/
        
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "Pass=MixLineBluer;"
        
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=BackColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=DirectionalBlur2;"
        
        
        "RenderColorTarget=CameraBufferTex;"
        "RenderDepthStencilTarget=CameraBufferMB;"
        "Pass=DrawCameraBuffer;"
        
    ;
    
> {
    
    
    //�������u���[
    pass DirectionalBlur1 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_DirectionalBlur(0.7, false);
    }
    
    pass DirectionalBlur2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_DirectionalBlur(0.4, true);
    }
    
    //���C���u���[
    pass ClearLineBluer < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_ClearLineBluer();
    }
    
    pass ClearLineBluerInfo < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_ClearLineBluerInfo();
    }
    
    pass DrawLineBluer < string Script= "Draw=Geometry;"; > {
        AlphaBlendEnable = true;
        AlphaTestEnable = true;
        CullMode = NONE;
        ZEnable = false;
        ZWriteEnable = false;
        DestBlend = InvSrcAlpha; SrcBlend = SrcAlpha; //�ʏ�A���t�@����
        //DestBlend = One; SrcBlend = One;
        //BlendOp = Max;
        
        //SeparateAlphaBlendEnabled = true;
        //AlphaBlendOperation = Max;
        
        //SrcBlendAlpha = One;
        //DestBlendAlpha = One;
        //BlendOpAlpha = Max;
        
        VertexShader = compile vs_3_0 VS_LineBluer();
        PixelShader  = compile ps_3_0 PS_LineBluer();
    }
    
    pass LineBlurGaussianX < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_LB_Gaussian(true, LineBluerSamp);
    }
    pass LineBlurGaussianY < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_LB_Gaussian(false, ScnSamp);
    }
    
    pass MixLineBluer < string Script= "Draw=Buffer;"; > {
        //AlphaBlendEnable = true;
        
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_MixLineBluer();
    }
    
    
    
    //�J�����ʒu�ۑ�
    pass DrawCameraBuffer < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_CameraBuffer();
        PixelShader  = compile ps_3_0 PS_CameraBuffer();
    }
    
}
////////////////////////////////////////////////////////////////////////////////////////////////

