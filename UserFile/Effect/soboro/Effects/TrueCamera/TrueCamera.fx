////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ��ʊE�[�x�{���[�V�����u���[ �����G�t�F�N�g Ver.2.0
//  �쐬: ���ڂ�
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ���[�U�[�p�����[�^


// DOF�p�����[�^ //////////////////////////////////////////////////////////

// �ڂ����͈�(�傫����������ƎȂ��o�܂�)
float DOF_Extent = 0.0003;

//�ڂ��������l
float BlurLimit = 8;

//���i��DOF���[�h�@1�ŗL���A0�Ŗ���
#define DOF_HIGHQUALITY  1


// ���[�V�����u���[�p�����[�^ //////////////////////////////////////////////

// �ڂ������x(�傫����������ƎȂ��o�܂�)
float DirectionalBlurStrength = 0.35;

//�c������
float LineBlurLength = 1.8;

//�c���Z��
float LineBlurStrength = 1;

//���x�̏���l
float VelocityLimit = 0.1;

//���x�̉����l
float VelocityUnderCut = 0.006;

//�V�[���؂�ւ�臒l
float SceneChangeThreshold = 20;

//�V�[���؂�ւ��p�x臒l
float SceneChangeAngleThreshold = 25;

//���C���u���[�̉𑜓x��{�ɂ��܂��B1�ŗL���A0�Ŗ���
#define LINEBLUR_QUAD  1


// ���჌���Y�p�����[�^ ////////////////////////////////////////////////


//���჌���Y�G�t�F�N�g��L���ɂ��܂��@1�ŗL���A0�Ŗ���
#define FISHEYE_ENABLE 0

//�����Y�c�݋��x
float FishEyeStregth = 0.75;

//���x�^�ǉ��T�C�Y
float BetaSize = 0.095;

//�����I�ɃT�C�Y�ύX�@1�ŗL���A0�Ŗ���
#define AUTO_RESIZE  0

//�����T�C�Y�ύX�g�p���́A�𑜓x�̔{���ł�
//��ʃT�C�Y����яo�̓T�C�Y �~ ���̒l ��
//�f�B�X�v���C�𑜓x���΂ɒ����Ȃ��悤�ɂ��Ă��������B
#define RESOLUTION_RATIO 1.5


// ���ʃp�����[�^ //////////////////////////////////////////////////////


//�ȈՐF���␳�E�z���C�g�o�����X�����p
const float3 ColorCorrection = float3( 1, 1, 1 );

//������̃T���v�����O��
#define SAMP_NUM   8

//�w�i�F
const float4 BackColor = float4( 0, 0, 0, 0 );



///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
//����ȍ~�̓G�t�F�N�g�̒m���̂���l�ȊO�͐G��Ȃ�����


//�X�P�[���W��
#define SCALE_VALUE 4

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;


#define PI 3.14159
#define DEG_TO_RAD (PI / 180)

#if FISHEYE_ENABLE==0
    #define VPRATIO 1.0
#else
    #if AUTO_RESIZE==0
        #define VPRATIO 1.0
    #else
        #define VPRATIO RESOLUTION_RATIO
    #endif
#endif

//�A���t�@�l�擾
float alpha1 : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

// �X�P�[���l�擾
float scaling0 : CONTROLOBJECT < string name = "(self)"; >;
static float scaling = scaling0 * 0.1 * 0.5;

//����p�ɂ��ڂ������x��
float4x4 ProjMatrix      : PROJECTION;
static float viewangle = atan(1 / ProjMatrix[0][0]);
static float viewscale = (45 / 2 * DEG_TO_RAD) / viewangle;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float ViewportAspect = ViewportSize.x / ViewportSize.y;

static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

//�ڂ����T���v�����O�Ԋu
static float2 SampStep = (float2(DOF_Extent,DOF_Extent)/ViewportSize*ViewportSize.y);
static float2 SampStepScaled = SampStep  * scaling * viewscale;


static float BlurLimitScaled = BlurLimit / pow(scaling, 0.7);



static float2 MBlurSampStep = (float2(DirectionalBlurStrength, DirectionalBlurStrength)/ViewportSize*ViewportSize.y);
static float2 MBlurSampStepScaled = MBlurSampStep * alpha1;


#define VM_TEXFORMAT "A32B32G32R32F"
//#define VM_TEXFORMAT "A16B16G16R16F"

//�[�x�t���x���V�e�B�}�b�v�쐬
texture DVMapDraw: OFFSCREENRENDERTARGET <
    string Description = "Depth && Velocity Map Drawing";
    float2 ViewPortRatio = {VPRATIO,VPRATIO};
    float4 ClearColor = { 0.5, 0.5, 1, 1 };
    float ClearDepth = 1.0;
    string Format = VM_TEXFORMAT ;
    bool AntiAlias = false;
    int MipLevels = 1;
    string DefaultEffect = 
        "self = hide;"
        "* = TrueCameraObject.fx;"
        ;
>;

sampler DVSampler = sampler_state {
    texture = <DVMapDraw>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = NONE;
};


#if DOF_HIGHQUALITY!=0
    // �[�x�}�b�v��X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
    texture2D DpMapX : RENDERCOLORTARGET <
        float2 ViewPortRatio = {0.5,0.5};
        int MipLevels = 1;
        string Format = "D3DFMT_R32F" ;
    >;
    sampler2D DpSampX = sampler_state {
        texture = <DpMapX>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        AddressU  = CLAMP;
        AddressV = CLAMP;
    };
    // �[�x�}�b�v��Y�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
    texture2D DpMapY : RENDERCOLORTARGET <
        float2 ViewPortRatio = {0.5,0.5};
        int MipLevels = 1;
        string Format = "D3DFMT_R32F" ;
    >;
    sampler2D DpSampY = sampler_state {
        texture = <DpMapY>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        AddressU  = CLAMP;
        AddressV = CLAMP;
    };
#endif


// �[�x�o�b�t�@
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {VPRATIO,VPRATIO};
    string Format = "D24S8";
>;


// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {VPRATIO,VPRATIO};
    int MipLevels = 0;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {VPRATIO,VPRATIO};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
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

#if LINEBLUR_QUAD==0
    #define LINEBLUR_GRIDSIZE 128
    #define LINEBLUR_BUFSIZE  256
#else
    #define LINEBLUR_GRIDSIZE 256
    #define LINEBLUR_BUFSIZE  512
    
    int loopindex = 0;
    int loopcount = 4;
    
#endif

texture2D LineBluerDepthBuffer : RENDERDEPTHSTENCILTARGET <
    int Width = LINEBLUR_BUFSIZE;
    int Height = LINEBLUR_BUFSIZE;
    string Format = "D24S8";
>;
texture2D LineBluerTex : RENDERCOLORTARGET <
    int Width = LINEBLUR_BUFSIZE;
    int Height = LINEBLUR_BUFSIZE;
    int MipLevels = 1;
    string Format = "A8R8G8B8";
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
static float ScnMipLevel1 = log2(ViewportSize.y / LINEBLUR_GRIDSIZE) + 0.5;
static float ScnMipLevel2 = log2(ViewportSize.y / LINEBLUR_BUFSIZE) + 0.5;


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



////////////////////////////////////////////////////////////////////////////////////////////////
// ���ʒ��_�V�F�[�_
struct VS_OUTPUT {
    float4 Pos            : POSITION;
    float2 Tex            : TEXCOORD0;
};

VS_OUTPUT VS_passDraw( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    
    return Out;
}


////////////////////////////////////////////////////////////////////////////////////////////////
//DOF�ڂ������x�}�b�v�擾�֐��Q

float DOF_GetDepthMap(float2 screenPos){
    return tex2Dlod( DVSampler, float4(screenPos, 0, 0) ).z;
}

#if DOF_HIGHQUALITY==0
    
    #define DOF_GetDepthMapMix DOF_GetDepthMap
#else
    
    float DOF_GetDepthMapBlr(float2 screenPos){
        return tex2Dlod( DpSampY, float4(screenPos, 0, 0) ).r;
    }
    float DOF_GetDepthMapMix(float2 screenPos){
        float depth1 = DOF_GetDepthMap(screenPos);
        float depth2 = DOF_GetDepthMapBlr(screenPos);
        
        float blrval = (depth1 - (1.0 / SCALE_VALUE));
        
        return lerp(depth1, depth2, saturate(blrval * 2));
        
    }
#endif

float DOF_DepthToBlur(float depth){
    float blrval = abs(depth - (1.0 / SCALE_VALUE));
    //��O���̃u���[���x�͂�����ƉR��
    if(depth < (1.0 / SCALE_VALUE)) blrval = pow(blrval * 15, 2) / 15; 
    return blrval;
}
float DOF_DepthComp(float dsrc, float ddst){
    return ((ddst < (1.0 / SCALE_VALUE)) && (DOF_DepthToBlur(dsrc) < DOF_DepthToBlur(ddst))) ? ddst : 1000;
}
float DOF_GetBlurMap(float2 screenPos){
    float depth = DOF_GetDepthMapMix(screenPos);
    float depth2 = depth;
    
    depth2 = min(depth2, DOF_DepthComp(depth, DOF_GetDepthMap(screenPos + float2( SampStepScaled.x * 2 , 0))));
    depth2 = min(depth2, DOF_DepthComp(depth, DOF_GetDepthMap(screenPos + float2(-SampStepScaled.x * 2 , 0))));
    depth2 = min(depth2, DOF_DepthComp(depth, DOF_GetDepthMap(screenPos + float2(0,  SampStepScaled.y * 2 ))));
    depth2 = min(depth2, DOF_DepthComp(depth, DOF_GetDepthMap(screenPos + float2(0, -SampStepScaled.y * 2 ))));
    
    depth2 = min(BlurLimitScaled, depth2);
    
    return DOF_DepthToBlur(depth2);
}


////////////////////////////////////////////////////////////////////////////////////////////////
//�[�x�t���x���V�e�B�}�b�v�Q�Ɗ֐��Q

#define VELMAP_SAMPLER  DVSampler
#define MB_DEPTH w

//�}�b�v�i�[��񂩂瑬�x�x�N�g���𓾂�
float2 MB_VelocityPreparation(float4 rawvec){
    float2 vel = rawvec.xy - 0.5;
    float len = length(vel);
    vel = max(0, len - VelocityUnderCut) * normalize(vel);
    
    vel = min(vel, float2(VelocityLimit, VelocityLimit));
    vel = max(vel, float2(-VelocityLimit, -VelocityLimit));
    
    return vel;
}

float2 MB_GetBlurMap(float2 Tex){
    return MB_VelocityPreparation(tex2Dlod( VELMAP_SAMPLER, float4(Tex, 0, 0) ));
}

float MB_GetDepthMap(float2 Tex){
    return tex2Dlod( VELMAP_SAMPLER, float4(Tex, 0, 0) ).MB_DEPTH;
}

float2 MB_GetBlurMapAround(float2 Tex){
    float4 vm, vms;
    const float step = 4.5 / LINEBLUR_BUFSIZE;
    float z0, n = 1;
    
    vms = tex2Dlod( VELMAP_SAMPLER, float4(Tex, 0, 0) );
    
    z0 = vms.MB_DEPTH;
    
    vm = tex2Dlod( VELMAP_SAMPLER, float4( Tex.x + step, Tex.y , 0, 0) );
    vms += vm * (vm.MB_DEPTH >= z0);
    n += (vm.MB_DEPTH >= z0);
    
    vm = tex2Dlod( VELMAP_SAMPLER, float4( Tex.x - step, Tex.y , 0, 0) );
    vms += vm * (vm.MB_DEPTH >= z0);
    n += (vm.MB_DEPTH >= z0);
    
    vm = tex2Dlod( VELMAP_SAMPLER, float4( Tex.x, Tex.y + step , 0, 0) );
    vms += vm * (vm.MB_DEPTH >= z0);
    n += (vm.MB_DEPTH >= z0);
    
    vm = tex2Dlod( VELMAP_SAMPLER, float4( Tex.x, Tex.y - step , 0, 0) );
    vms += vm * (vm.MB_DEPTH >= z0);
    n += (vm.MB_DEPTH >= z0);
    
    vms /= n;
    
    return MB_VelocityPreparation(vms);
}


////////////////////////////////////////////////////////////////////////////////////////////////
//�[�x�}�b�v�ڂ���

#if DOF_HIGHQUALITY!=0
    
    
    //�[�x�}�b�v�ڂ����p�����[�^
    #define SAMP_NUM_D  3
    const float ext2 = 0.0015;
    static const float2 SampStepD = (float2(ext2, ext2)/ViewportSize*ViewportSize.y);
    
    float4 PS_passDX( VS_OUTPUT IN ) : COLOR {   
        float e, n = 0, sum = 0;
        
        [unroll] //���[�v�W�J
        for(int i = -SAMP_NUM_D; i <= SAMP_NUM_D; i++){
            float2 stex = IN.Tex + float2(SampStepD.x * (float)i, 0);
            e = exp(-pow((float)i / (SAMP_NUM_D / 2.0), 2) / 2); //���K���z
            sum += tex2Dlod( DVSampler, float4(stex, 0, 0) ).z * e;
            n += e;
        }
        
        return float4(sum / n, 0, 0, 1);
    }
    
    float4 PS_passDY( VS_OUTPUT IN ) : COLOR {   
        float e, n = 0, sum = 0;
        
        [unroll] //���[�v�W�J
        for(int i = -SAMP_NUM_D; i <= SAMP_NUM_D; i++){
            float2 stex = IN.Tex + float2(0, SampStepD.y * (float)i);
            e = exp(-pow((float)i / (SAMP_NUM_D / 2.0), 2) / 2); //���K���z
            sum += tex2Dlod( DpSampX, float4(stex, 0, 0) ).r * e;
            n += e;
        }
        
        return float4(sum / n, 0, 0, 1);
    }
#endif

////////////////////////////////////////////////////////////////////////////////////////////////
// DOF X�����ڂ���

#define DOF_X_SAMPLER ScnSamp

float4 PS_DOF_X( VS_OUTPUT IN ) : COLOR {   
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    float step = SampStepScaled.x * DOF_GetBlurMap(IN.Tex);
    float depth, centerdepth = DOF_GetDepthMap(IN.Tex) - 0.01;
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
        e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
        stex = IN.Tex + float2(step * (float)i, 0);
        
        if(i!=0){
            //��O���s���g�̍����Ă��镔������̃T���v�����O�͎キ
            depth = DOF_GetDepthMap(stex);
            if(depth < centerdepth) e *= saturate(DOF_DepthToBlur(depth) * 2);
        }
        
        sum += tex2Dlod( DOF_X_SAMPLER, float4(stex, 0, 0) ) * e;
        n += e;
    }
    
    Color = sum / n;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// DOF Y�����ڂ���

#define DOF_Y_SAMPLER ScnSamp2

float4 PS_DOF_Y( VS_OUTPUT IN ) : COLOR {   
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    float step = SampStepScaled.y * DOF_GetBlurMap(IN.Tex);
    float depth, centerdepth = DOF_GetDepthMap(IN.Tex) - 0.01;
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
        e = exp(-pow((float)i / (SAMP_NUM / 2.0 ), 2) / 2); //���K���z
        stex = IN.Tex + float2(0, step * (float)i);
        
        if(i!=0){
            //��O���s���g�̍����Ă��镔������̃T���v�����O�͎キ
            depth = DOF_GetDepthMap(stex);
            if(depth < centerdepth) e *= saturate(DOF_DepthToBlur(depth) * 2);
        }
        
        sum += tex2Dlod( DOF_Y_SAMPLER, float4(stex, 0, 0) ) * e;
        n += e;
    }
    
    Color = sum / n;
    
    //�ȈՐF���␳
    Color.rgb *= ColorCorrection;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�x���V�e�B�}�b�v�ɏ]���������u���[��������

float4 PS_DirectionalBlur( float2 Tex: TEXCOORD0 ) : COLOR {   
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    float2 vel = MB_GetBlurMap(Tex);
    
    float4 info;
    float2 step = (MBlurSampStepScaled / SAMP_NUM) * vel;
    float depth, centerdepth = MB_GetDepthMap(Tex) - 0.01;
    
    float bp = saturate(length(vel) * 10);
    
    step *= (!IsSceneChange); //�V�[���؂�ւ��̓u���[����
    
    float4 samps[SAMP_NUM * 2 + 1];
    
    
    //���ߐ�������Ȃ̂ŁA�������򂵂���������
    [branch]
    if(length(step) <= 0){
        Color = tex2Dlod( ScnSamp, float4(Tex, 0, 0) );
        
    }else{
        
        [unroll] //���[�v�W�J
        for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
            e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
            stex = Tex + (step * (float)i);
            
            //��O�����܂蓮���Ă��Ȃ���������̃T���v�����O�͎キ
            if(i != 0){
                depth = MB_GetDepthMap(stex);
                e *= max(saturate(length(MB_GetBlurMap(stex)) / 0.02), (depth > centerdepth));
            }
            
            //�T���v�����O
            sum += tex2Dlod( ScnSamp, float4(stex, 0, 0) ) * e;
            n += e;
        }
        
        Color = sum / n;
        
    }
    
    return Color;
    
}



////////////////////////////////////////////////////////////////////////////////////////////////
//���C���u���[�o�̓o�b�t�@�̏����l�ݒ�


struct PS_OUTPUT_CLB
{
   float4 Color : COLOR0;
   float4 Info  : COLOR1;
};

PS_OUTPUT_CLB PS_ClearLineBluer( float2 Tex: TEXCOORD0 ) {
    
    PS_OUTPUT_CLB OUT = (PS_OUTPUT_CLB)0;
    
    //�A���t�@�l��0�ɂ������X�N���[���摜�Ŗ��߂�
    OUT.Color = tex2Dlod( ScnSamp, float4(Tex, 0, ScnMipLevel2) );
    OUT.Color.a = 0;
    
    //���C���u���[�Ŏg�p������}�b�v���o��
    OUT.Info.xy = MB_GetBlurMapAround( Tex );
    OUT.Info.z = MB_GetDepthMap( Tex );
    OUT.Info.w = 1;
    
    return OUT;
}


/////////////////////////////////////////////////////////////////////////////////////
//���C���u���[�`��

struct VS_OUTPUT3 {
    float4 Pos: POSITION;
    float4 Color: COLOR0;
    float3 Tex: TEXCOORD0;
    float2 BaseVel : TEXCOORD1;
    
};

VS_OUTPUT3 VS_LineBluer(float4 Pos : POSITION, int index: _INDEX)
{
    VS_OUTPUT3 Out;
    float2 PosEx = Pos.xy;
    bool IsTip = (Pos.x > 0); //���C���̐L�т���[
    
    float findex = Pos.z;
    
#if LINEBLUR_QUAD!=0
    findex += loopindex * (128 * 128);
#endif
    
    float2 findex_xy = float2(findex % LINEBLUR_GRIDSIZE, trunc(findex / LINEBLUR_GRIDSIZE));
    
    float2 TexPos = findex_xy / LINEBLUR_GRIDSIZE;
    float2 ScreenPos = (TexPos * 2 - 1) * float2(1,-1);
    
    //�x���V�e�B�}�b�v�Q��
    float4 VelMap = tex2Dlod( VELMAP_SAMPLER, float4(TexPos, 0, 0) );
    float2 Velocity = MB_VelocityPreparation(VelMap);
    float VelLen = length(Velocity) * alpha1;
    
    Out.BaseVel = Velocity; //PS�ɑ��x��n���B
    
    //���x�x�N�g���Ɣ��Α��Ƀ��C����L�΂�
    Velocity = -Velocity;
    
    //���C����
    PosEx *= (1.0 / LINEBLUR_GRIDSIZE);
    //���C������
    PosEx.x += VelLen * IsTip * LineBlurLength;
    //���C���L����
    PosEx.y *= 1 + 0.2 * IsTip;
    
    //�΂߃��C���͑���
    //PosEx.y *= 1 + 0.4 * abs(sin(atan2(Velocity.x, Velocity.y) * 2));
    
    //���C����]
    float2 AxU = normalize(Velocity);
    float2 AxV = float2(AxU.y, -AxU.x);
    
    PosEx = PosEx.x * AxU + PosEx.y * AxV;
    
    //���_�ʒu�ɂ��T���v�����O�ʒu�̃I�t�Z�b�g
    //TexPos += (-Pos.y * AxV) / (LINEBLUR_GRIDSIZE * 2);
    
    //���X�N���[���Q��
    Out.Color = tex2Dlod( ScnSamp, float4(TexPos, 0, ScnMipLevel1) );
    
    //�u���[���x����A���t�@�ݒ�E���C����[�͓�����
    Out.Color.a *= saturate(VelLen * 250) * (1 - IsTip);
    
    Out.Color.a *= (!IsSceneChange); //�V�[���؂�ւ��̓u���[����
    
    //�o�b�t�@�o��
    Out.Pos.xy = ScreenPos + PosEx;
    Out.Pos.z = 0;
    Out.Pos.w = 1;
    
    //�X�N���[���e�N�X�`�����W
    Out.Tex.xy = (Out.Pos.xy * float2(1,-1) + 1) * 0.5 + (0.5 / LINEBLUR_BUFSIZE);
    Out.Tex.z = VelMap.MB_DEPTH; //TEXCOORD0��Z���؂�āA�c���̔�������Z�l��n��
    
    return Out;
}

float4 PS_LineBluer( VS_OUTPUT3 IN ) : COLOR0
{
    float4 Color = IN.Color;
    
    float4 Info = tex2Dlod( LineBluerInfoSamp, float4(IN.Tex.xy, 0, 0));
    
    float BaseZ = Info.z; //���摜�̐[�x
    float AfImZ = IN.Tex.z; //�c���̐[�x
    
    //��O�̃I�u�W�F�N�g��̎c���͉B��
    Color.a *= saturate(1 - (AfImZ - BaseZ) * 200);
    
    float2 vel = Info.xy;
    
    //�w�i�̑��x�x�N�g������v���Ă���Ƃ��͔���
    float vdrate = max(length(vel), length(IN.BaseVel));
    vdrate = (vdrate == 0) ? 0 : (1 / vdrate);
    float VelDif = length(vel - IN.BaseVel) * vdrate;
    Color.a *= saturate(VelDif);
    
    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
//���C���u���[�̍���

VS_OUTPUT VS_MixLineBluer( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + (0.5 / LINEBLUR_BUFSIZE);
    
    return Out;
}

#define LBSAMP LineBluerSamp

float4 PS_MixLineBluer( float2 Tex: TEXCOORD0 ) : COLOR {   
    float2 step = 1.1 / LINEBLUR_BUFSIZE;
    float4 Color = tex2D( LineBluerSamp, Tex);
    
    //������𑜓x�Ȃ̂ŁA�W���M�[�����̂��߂Ɍy���ڂ���
    [unroll] for(int j = -1; j <= 1; j++){
        [unroll] for(int i = -1; i <= 1; i++){
            Color += tex2D( LineBluerSamp, Tex + step * float2(i,j) );
            
        }
    }
    
    Color /= 10;
    
    Color.a *= LineBlurStrength;
    
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
// ���Ꮘ��

#if FISHEYE_ENABLE!=0

float4 PS_FishEye( float2 Tex: TEXCOORD0 ) : COLOR {   
    float4 Color;
    float2 tex_conv;
    
    if(true){
        tex_conv = Tex - 0.5;
        tex_conv.x *= ViewportAspect;
        
        float D = 1;
        float r = length(tex_conv);
        float2 dir = normalize(tex_conv);
        
        float vang1 = viewangle * 2 * FishEyeStregth;
        float resize = 1;
        
        #if AUTO_RESIZE!=0
            resize = (1 + vang1 * vang1 / 9 * ViewportAspect);
            r /= resize;
        #endif
        
        float phai = r * vang1;
        r = asin(phai);
        r /= (vang1);
        
        tex_conv = r * dir;
        tex_conv.x /= ViewportAspect;
        tex_conv += 0.5;
        
        Color = tex2D( ScnSamp2, tex_conv );
        
        //�\���̈�O�͍��œh��Ԃ�
        Color = (0 <= phai && phai <= 1) ? Color : float4(0,0,0,1);
        Color = (0 <= tex_conv.x && tex_conv.x <= 1 && 0 <= tex_conv.y && tex_conv.y <= 1) ? Color : float4(0,0,0,1);
        
        #if AUTO_RESIZE==0
            Color = (BetaSize <= Tex.x && Tex.x <= (1 - BetaSize) && BetaSize <= Tex.y && Tex.y <= (1 - BetaSize)) ? Color : float4(0,0,0,1);
            //Color = (BetaSize <= Tex.y && Tex.y <= (1 - BetaSize) ) ? Color : float4(0,0,0,1);
        #endif
        
    }else{
        
        Color = tex2D( ScnSamp2, Tex );
        
    }
    
    return Color;
}

#endif

////////////////////////////////////////////////////////////////////////////////////////////////

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor2 = {0,0,0,0};
float ClearDepth  = 1.0;


technique TrueCamera <
    string Subset = "0";
    string Script = 
        
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=BackColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"
        
        #if DOF_HIGHQUALITY!=0
            "RenderColorTarget0=DpMapX;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor2;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=Gaussian_DX;"
             
            "RenderColorTarget0=DpMapY;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor2;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=Gaussian_DY;"
            
        #endif
        
        "RenderColorTarget0=ScnMap2;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=BackColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=DOF_X;"
        
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=BackColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=DOF_Y;"
        
        #if FISHEYE_ENABLE==0
            "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
        #else
            "RenderColorTarget0=ScnMap2;"
            "RenderDepthStencilTarget=DepthBuffer;"
        #endif
        "ClearSetColor=BackColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=DirectionalBlur;"
        
        "RenderColorTarget0=LineBluerTex;"
        "RenderColorTarget1=LineBluerInfoTex;"
        "RenderDepthStencilTarget=LineBluerDepthBuffer;"
        "ClearSetColor=ClearColor2; Clear=Color;"
        "ClearSetDepth=ClearDepth; Clear=Depth;"
        "Pass=ClearLineBluer;"
        
        "RenderColorTarget0=LineBluerTex;"
        "RenderColorTarget1=;"
        "Clear=Depth;"
        
        #if LINEBLUR_QUAD==0
            //1�񂾂�
            "Pass=DrawLineBluer;"
        #else
            //4��J��Ԃ�
            "LoopByCount=loopcount;"
            "LoopGetIndex=loopindex;"
            "Pass=DrawLineBluer;"
            "LoopEnd=;"
        #endif
        
        
        #if FISHEYE_ENABLE==0
            "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
        #else
            "RenderColorTarget0=ScnMap2;"
            "RenderDepthStencilTarget=DepthBuffer;"
        #endif
        "Pass=MixLineBluer;"
        
        #if FISHEYE_ENABLE!=0
            "RenderColorTarget=;"
            "RenderDepthStencilTarget=;"
            "Pass=FishEye;"
        #endif
        
        
        "RenderColorTarget=CameraBufferTex;"
        "RenderDepthStencilTarget=CameraBufferMB;"
        "Pass=DrawCameraBuffer;"
        
    ;
    
> {
    
    
    //DOF
    
    #if DOF_HIGHQUALITY!=0
        pass Gaussian_DX < string Script= "Draw=Buffer;"; > {
            AlphaBlendEnable = FALSE;
            VertexShader = compile vs_3_0 VS_passDraw();
            PixelShader  = compile ps_3_0 PS_passDX();
        }
        pass Gaussian_DY < string Script= "Draw=Buffer;"; > {
            AlphaBlendEnable = FALSE;
            VertexShader = compile vs_3_0 VS_passDraw();
            PixelShader  = compile ps_3_0 PS_passDY();
        }
    #endif
    
    pass DOF_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_DOF_X();
    }
    pass DOF_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_DOF_Y();
    }
    
    
    
    
    //�������u���[
    pass DirectionalBlur < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_DirectionalBlur();
    }
    
    
    
    //���C���u���[
    pass ClearLineBluer < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_ClearLineBluer();
    }
    
    pass DrawLineBluer < string Script= "Draw=Geometry;"; > {
        DestBlend = InvSrcAlpha; SrcBlend = SrcAlpha; //���Z�����̃L�����Z��
        AlphaBlendEnable = true;
        AlphaTestEnable = true;
        CullMode = none;
        ZEnable = false;
        VertexShader = compile vs_3_0 VS_LineBluer();
        PixelShader  = compile ps_3_0 PS_LineBluer();
    }
    
    pass MixLineBluer < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = true;
        //AlphaBlendEnable = false;AlphaTestEnable = false;
        DestBlend = InvSrcAlpha; SrcBlend = SrcAlpha; //���Z�����̃L�����Z��
        
        VertexShader = compile vs_3_0 VS_MixLineBluer();
        PixelShader  = compile ps_3_0 PS_MixLineBluer();
    }
    
    
    
    //�J�����ʒu�ۑ�
    pass DrawCameraBuffer < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_CameraBuffer();
        PixelShader  = compile ps_3_0 PS_CameraBuffer();
    }
    
    #if FISHEYE_ENABLE!=0
        //����
        pass FishEye < string Script= "Draw=Buffer;"; > {
            AlphaBlendEnable = false;
            AlphaTestEnable = false;
            VertexShader = compile vs_3_0 VS_passDraw();
            PixelShader  = compile ps_3_0 PS_FishEye();
        }
    #endif
    
}
////////////////////////////////////////////////////////////////////////////////////////////////

