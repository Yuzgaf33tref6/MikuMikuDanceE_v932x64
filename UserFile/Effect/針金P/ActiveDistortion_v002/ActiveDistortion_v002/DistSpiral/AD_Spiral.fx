////////////////////////////////////////////////////////////////////////////////////////////////
//
//  AD_Spiral.fx ��Ԙc�݃G�t�F�N�g(�X�N�����[�Ռ��g���ۂ��G�t�F�N�g,�@���E�[�x�}�b�v�쐬)
//  ( ActiveDistortion.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

float SpiralThick = 0.1;        // �����������̑���
float SpiralScaleUp = 0.2;      // �������̑����g��x
float SpiralPos = 0.2;          // ���������ʒu�̒��S����
float SpiralRotSpeed = 2.0;     // ������]�X�s�[�h
float SpiralDiffuseSpeed = 1.0; // �����g�U�X�s�[�h
float SpiralDiffuseExp = 2.0;   // �����g�U�X�s�[�h(�w���W��)

float SpiralLife = 1.5;         // �����̎���(�b)
float SpiralDecrement = 0.3;    // �������������J�n���鎞��(0.0�`1.0:SpiralLife�Ƃ̔�)

float SpiralLenParRot = 10.0;   // �������]������̐i�s����
float SpiralDirMax = 15.0;      // ����1�X�e�b�v�̍ő��]�p

int SpiralCount = 4;            // �����z�u��

// �I�v�V�����̃R���g���[���t�@�C����
#define BackgroundCtrlFileName  "BackgroundControl.x" // �w�i���W�R���g���[���t�@�C����
#define TimrCtrlFileName        "TimeControl.x"       // ���Ԑ���R���g���[���t�@�C����

// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define TEX_WIDTH     4   // ���W���e�N�X�`���s�N�Z����
#define TEX_HEIGHT  512   // �z�u��������e�N�X�`���s�N�Z������

#define DEPTH_FAR  5000.0f   // �[�x�ŉ��l

#define PAI 3.14159265f   // ��

int SpiralIndex;

float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
static float Scaling = AcsSi * 0.1f;

////////////////////////////////////////////////////////////////////////////////////////////////

// �I�v�V�����̃R���g���[���p�����[�^
bool IsBack : CONTROLOBJECT < string name = BackgroundCtrlFileName; >;
float4x4 BackMat : CONTROLOBJECT < string name = BackgroundCtrlFileName; >;

// MMD���[���h���W���w�i�A�N�Z��̃��[���h���W
float3 BackWorldCoord(float3 pos)
{
    if( IsBack ){
        float scaling = 1.0f / length(BackMat._11_12_13);
        float3x3 mat3x3_inv = transpose((float3x3)BackMat) * scaling;
        pos = mul( float4(pos, 1), float4x4( mat3x3_inv[0], 0, 
                                             mat3x3_inv[1], 0, 
                                             mat3x3_inv[2], 0, 
                                            -mul(BackMat._41_42_43,mat3x3_inv), 1 ) ).xyz;
    }
    return pos;
}

// �w�i�A�N�Z��̕ϊ��s��MMD���[���h�ϊ��s��
float4x4 InvBackWorldMatrix(float4x4 mat)
{
    if( IsBack ){
        float scaling = 1.0f / length(BackMat._11_12_13);
        mat = mul( mat, float4x4( BackMat[0]*scaling,
                                  BackMat[1]*scaling,
                                  BackMat[2]*scaling,
                                  BackMat[3] )      );
    }
    return mat;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ���Ԑݒ�

// ���Ԑ���R���g���[���p�����[�^
bool IsTimeCtrl : CONTROLOBJECT < string name = TimrCtrlFileName; >;
float TimeSi : CONTROLOBJECT < string name = TimrCtrlFileName; string item = "Si"; >;
float TimeTr : CONTROLOBJECT < string name = TimrCtrlFileName; string item = "Tr"; >;
static bool TimeSync = IsTimeCtrl ? ((TimeSi>0.001f) ? true : false) : true;
static float TimeRate = IsTimeCtrl ? TimeTr : 1.0f;

float time1 : Time;
float time2 : Time < bool SyncInEditMode = true; >;
static float time0 = TimeSync ? time1 : time2;

// �X�V�����L�^�p
texture TimeTex : RENDERCOLORTARGET
<
   int Width=1;
   int Height=1;
   string Format = "D3DFMT_A32B32G32R32F" ;
>;
sampler TimeTexSmp : register(s0) = sampler_state
{
   Texture = <TimeTex>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
};
texture TimeDepthBuffer : RenderDepthStencilTarget <
   int Width=1;
   int Height=1;
    string Format = "D3DFMT_D24S8";
>;
#ifndef MIKUMIKUMOVING
float4 TimeBufArray[1] : TEXTUREVALUE <
    string TextureName = "TimeTex";
>;
static float time = TimeBufArray[0].y;
static float Dt = TimeBufArray[0].z;
#else
static float4 TimeBuf = tex2Dlod(TimeTexSmp, float4(0.5f,0.5f,0,0));
static float time = TimeBuf.y;
static float Dt = TimeBuf.z;
#endif

float4 UpdateTime_VS(float4 Pos : POSITION) : POSITION
{
    return Pos;
}

float4 UpdateTime_PS() : COLOR
{
   float2 timeDat = tex2D(TimeTexSmp, float2(0.5f,0.5f)).xy;
   float dt = clamp(time0 - timeDat.x, 0.0f, 0.1f) * TimeRate;
   float etime = timeDat.y + dt;
   if(time0 < 0.001f) etime = 0.0;
   return float4(time0, etime, dt, 1);
}


////////////////////////////////////////////////////////////////////////////////////////////////

// ���W�ϊ��s��
float4x4 WorldMatrix      : WORLD;
float4x4 ViewMatrix       : VIEW;
float4x4 ProjMatrix       : PROJECTION;
float4x4 ViewProjMatrix   : VIEWPROJECTION;

float3 CameraPosition : POSITION  < string Object = "Camera"; >;

// �������[���h�ϊ��s��L�^�p
texture CoordTex : RENDERCOLORTARGET
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler CoordSmp : register(s1) = sampler_state
{
   Texture = <CoordTex>;
    AddressU  = CLAMP;
    AddressV  = WRAP;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
};
texture CoordDepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format = "D24S8";
>;


// �I�u�W�F�N�g�̃��[���h�ϊ��s��L�^�p
texture WorldMatrixTex : RENDERCOLORTARGET
<
   int Width=TEX_WIDTH;
   int Height=1;
   string Format="A32B32G32R32F";
>;
sampler WorldMatrixSmp = sampler_state
{
   Texture = <WorldMatrixTex>;
   AddressU  = CLAMP;
   AddressV = CLAMP;
   MinFilter = NONE;
   MagFilter = NONE;
   MipFilter = NONE;
};
texture WorldMatrixDepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WIDTH;
   int Height=1;
    string Format = "D24S8";
>;
float4 MatrixBufArray[TEX_WIDTH] : TEXTUREVALUE <
    string TextureName = "WorldMatrixTex";
>;

//�O�t���[���̃��[���h�s��
static float4x4 prevWorldMatrix = float4x4( MatrixBufArray[0].xyz, 0.0f,
                                            MatrixBufArray[1].xyz, 0.0f,
                                            MatrixBufArray[2].xyz, 0.0f,
                                            MatrixBufArray[3].xyz, 1.0f );

static float prevCount = MatrixBufArray[0].w;
static float prevRot   = MatrixBufArray[1].w;
static float prevTime  = MatrixBufArray[2].w;


////////////////////////////////////////////////////////////////////////////////////////////////

// ���������ʒu�̃��[���h�ϊ��s��
float4x4 GetWorldMatrix(int index)
{
    float y = (0.5f+index)/TEX_HEIGHT;
    return InvBackWorldMatrix(
           float4x4( tex2Dlod(CoordSmp, float4(0.5f/TEX_WIDTH, y, 0, 0)).xyz, 0.0f,
                     tex2Dlod(CoordSmp, float4(1.5f/TEX_WIDTH, y, 0, 0)).xyz, 0.0f,
                     tex2Dlod(CoordSmp, float4(2.5f/TEX_WIDTH, y, 0, 0)).xyz, 0.0f,
                     tex2Dlod(CoordSmp, float4(3.5f/TEX_WIDTH, y, 0, 0)).xyz, 1.0f ) );
}

// ������������̎���
float GetTime(int index)
{
    return tex2Dlod(CoordSmp, float4(0.5f/TEX_WIDTH, (0.5f+index)/TEX_HEIGHT, 0, 0)).w - 1.0f;
}

// �������C�����̂̐i�s����(���[�J�����W)
float3 GetVec(int index, float s0, float s1)
{
    float len = tex2Dlod(CoordSmp, float4(1.5f/TEX_WIDTH, (0.5f+index)/TEX_HEIGHT, 0, 0)).w; // 1�X�e�b�v�̐i�s����
    float rot = tex2Dlod(CoordSmp, float4(2.5f/TEX_WIDTH, (0.5f+index)/TEX_HEIGHT, 0, 0)).w; // 1�X�e�b�v�̐i�s�p�x
    float3 vec = float3(s1*cos(rot)-s0, s1*sin(rot), -len);
    return (len > 0.001f) ? normalize(vec) : float3(0,0,-1);
}

// 1�t���[���Ԃ̃X�e�b�v��
int GetCount(int index)
{
    return (int)tex2Dlod(CoordSmp, float4(0.5f/TEX_WIDTH, (3.5f+index)/TEX_HEIGHT, 0, 0)).w;
}

// ���W��2D��]
float2 Rotation2D(float2 pos, float rot)
{
    float x = pos.x * cos(rot) - pos.y * sin(rot);
    float y = pos.x * sin(rot) + pos.y * cos(rot);

    return float2(x,y);
}

////////////////////////////////////////////////////////////////////////////////////////////////

// �N�H�[�^�j�I���̐ώZ
float4 MulQuat(float4 q1, float4 q2)
{
    return float4(cross(q1.xyz, q2.xyz)+q1.xyz*q2.w+q2.xyz*q1.w, q1.w*q2.w-dot(q1.xyz, q2.xyz));
}

// �N�H�[�^�j�I���̉�](v1,v2�͐��K�x�N�g��)
float3 RotQuat(float3 v1, float3 v2, float3 pos, float slerp)
{
    float4 p =  float4(pos, 0.0f);

    if(dot(v1, v2) > -0.9999f){
        if(distance(v1,v2) > 0.0001f){
            float3 v = normalize( cross(v1, v2) );
            float rot = acos( dot(v1, v2) ) * slerp;
            float sinHD = sin(0.5f * rot);
            float cosHD = cos(0.5f * rot);
            float4 q1 = float4(v*sinHD, cosHD);
            float4 q2 = float4(-v*sinHD, cosHD);
            p = MulQuat( MulQuat(q2, p), q1);
        }
    }else{
       p.x = -p.x;
    }
    return p.xyz;
}

// v����]���Ƃ���rot��]�������]�s��(v�͐��K�x�N�g��)
float3x3 RotMat1(float3 v, float rot)
{
    float3x3 m = float3x3(1,0,0, 0,1,0, 0,0,1);

    if(abs(rot) > 0.0001f){
        float sinHD = sin(0.5f * rot);
        float cosHD = cos(0.5f * rot);
        float4 q = float4(v*sinHD, cosHD);
        m = float3x3( 1-2*q.y*q.y-2*q.z*q.z,   2*q.x*q.y+2*q.w*q.z,   2*q.x*q.z-2*q.w*q.y,
                        2*q.x*q.y-2*q.w*q.z, 1-2*q.x*q.x-2*q.z*q.z,   2*q.y*q.z+2*q.w*q.x,
                        2*q.x*q.z+2*q.w*q.y,   2*q.y*q.z-2*q.w*q.x, 1-2*q.x*q.x-2*q.y*q.y );
    }

    return m;
}

// v1��v2�x�N�g���Ԃ̉�]�s��(v1,v2�͐��K�x�N�g��)
float3x3 RotMat2(float3 v1, float3 v2)
{
    float3x3 m = float3x3(1,0,0, 0,1,0, 0,0,1);

    if(distance(v1,v2) > 0.0001f){
        float3 v = normalize( cross(v1, v2) );
        float rot = acos( dot(v1, v2) );
        float sinHD = sin(0.5f * rot);
        float cosHD = cos(0.5f * rot);
        float4 q = float4(v*sinHD, cosHD);
        m = float3x3( 1-2*q.y*q.y-2*q.z*q.z,   2*q.x*q.y+2*q.w*q.z,   2*q.x*q.z-2*q.w*q.y,
                        2*q.x*q.y-2*q.w*q.z, 1-2*q.x*q.x-2*q.z*q.z,   2*q.y*q.z+2*q.w*q.x,
                        2*q.x*q.z+2*q.w*q.y,   2*q.y*q.z-2*q.w*q.x, 1-2*q.x*q.x-2*q.y*q.y );
    }

    return m;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �����̔����E�ϊ��s��X�V�v�Z

struct VS_OUTPUT {
   float4 Pos : POSITION;
   float2 Tex : TEXCOORD0;
};

// ���_�V�F�[�_
VS_OUTPUT UpdatePos_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
   VS_OUTPUT Out;
   Out.Pos = Pos;
   Out.Tex = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
   return Out;
}

// �s�N�Z���V�F�[�_
float4 UpdatePos_PS(float2 Tex: TEXCOORD0) : COLOR
{
    float4 Pos;
    int i = floor( Tex.x*TEX_WIDTH );

    // �����̍��W
    float w = tex2D(CoordSmp, float2(0.5f/TEX_WIDTH, Tex.y)).w;

    if(w < 1.001f){
    // �����������̒�����ړ������ɉ����ĐV���ɗ����𔭐�������
        float4x4 Mat = prevWorldMatrix;
        Mat._44 = 0.0f;
        // �I�u�W�F�N�g�̃��[���h���W
        float3 WPos0 = prevWorldMatrix._41_42_43;
        float3 WPos1 = BackWorldCoord(WorldMatrix._41_42_43);

        float len = length( WPos1 - WPos0 );
        if(len>0.0001f){
            // 1�t���[���Ԃ̉�]�p�x
            float p_rot = 2.0f * PAI * len / (SpiralLenParRot * Scaling);
            // 1�t���[���Ԃ̗��������X�e�b�v��
            int p_count = ceil((p_rot-0.0001f) / radians(SpiralDirMax));
            if(prevTime > time || AcsTr < 0.0001f) p_count = min(p_count, 1);

            // �����C���f�b�N�X
            int p_index = floor( Tex.y*TEX_HEIGHT );

            // �V���ɗ����𔭐������邩�ǂ����̔���
            if(p_index < round(prevCount)) p_index += TEX_HEIGHT;
            if(p_index < round(prevCount)+p_count && prevTime < time && AcsTr > 0.0001f){
                // ���������ϊ��s��
                float s = float(p_index - prevCount) / float(p_count);
                float3 Pos1 = lerp(WPos0, WPos1, s);
                float3 wVec = normalize(WPos1 - WPos0);
                float3x3 dirRotMat = RotMat1(wVec, prevRot+p_rot*s);
                float4x4 newRotMat = float4x4(dirRotMat[0], 0.0f,
                                              dirRotMat[1], 0.0f,
                                              dirRotMat[2], 0.0f,
                                              Pos1 - mul(WPos0, dirRotMat), 1.0f );
                Mat = mul(prevWorldMatrix, newRotMat);
                Mat._14 = 1.0011f + Dt * s;       // w>1.001�ŗ�������
                Mat._24 = len / float(p_count);   // 1�X�e�b�v�̐i�s����
                Mat._34 = p_rot / float(p_count); // 1�X�e�b�v�̐i�s�p�x
                Mat._44 = p_count;                // 1�t���[���Ԃ̃X�e�b�v��
            }
        }
        Pos = Mat[i % TEX_WIDTH];
    }else{
    // �����������̍��W
        Pos = tex2D(CoordSmp, Tex);

        if(i == 0){
            // ���łɔ������Ă��闆���͌o�ߎ��Ԃ�i�߂�
            Pos.w += Dt;
            Pos.w *= step(Pos.w-1.0f, SpiralLife); // �w�莞�Ԃ𒴂����0(��������)
        }
    }

    if(time < 0.001f){
        float4x4 initWldMat = float4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, BackWorldCoord(WorldMatrix._41_42_43),0);
        Pos = initWldMat[i % TEX_WIDTH];
    }

    return Pos;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�̃��[���h���W�L�^

// ���_�V�F�[�_
VS_OUTPUT WorldMatrix_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + float2(0.5f/TEX_WIDTH, 0.5f);

    return Out;
}

// �s�N�Z���V�F�[�_
float4 WorldMatrix_PS(float2 Tex: TEXCOORD0) : COLOR
{
    // �I�u�W�F�N�g�̃��[���h���W
    float3 WPos0 = prevWorldMatrix._41_42_43;
    float3 WPos1 = BackWorldCoord(WorldMatrix._41_42_43);

    float3 dirVec0 = any(prevWorldMatrix._31_32_33) ? normalize(-prevWorldMatrix._31_32_33) : float3(0,0,-1);
    float3 dirVec1 = (distance(WPos1, WPos0) > 0.001f) ? normalize(WPos1 - WPos0) : dirVec0;

    float3x3 dirRotMat = RotMat2(dirVec0, dirVec1);
    float4x4 newRotMat = float4x4(dirRotMat[0], 0.0f,
                                  dirRotMat[1], 0.0f,
                                  dirRotMat[2], 0.0f,
                                  WPos1 - mul(WPos0, dirRotMat), 1.0f );
    float4x4 newWldMat = mul(prevWorldMatrix, newRotMat);

    // 1�t���[���Ԃ̉�]�p�x
    float p_rot = 2.0f * PAI * distance(WPos1, WPos0) / (SpiralLenParRot * Scaling);
    // 1�t���[���Ԃ̔���������
    int p_count = ceil((p_rot-0.0001f) / radians(SpiralDirMax));
    if(prevTime > time || AcsTr < 0.0001f) p_count = min(p_count, 1);

    float rot = prevRot + p_rot;
    float w = prevCount + p_count;
    if(w >= float(TEX_HEIGHT)) w -= float(TEX_HEIGHT);

    newWldMat._14 = w;
    newWldMat._24 = rot;
    newWldMat._34 = time;

    if(time < 0.001f || !any(newWldMat._11_22_33)){
        newWldMat = float4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, WPos1,0);
    }

    int i = floor( Tex.x * TEX_WIDTH );

    return newWldMat[i % TEX_WIDTH];
}


///////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�
#ifndef MIKUMIKUMOVING
    #define GET_VPMAT(p) (ViewProjMatrix)
#else
    #define GET_VPMAT(p) (MMM_IsDinamicProjection ? mul(ViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-p.xyz))) : ViewProjMatrix)
#endif


///////////////////////////////////////////////////////////////////////////////////////
// �����`��

struct VS_OUTPUT2
{
    float4 Pos    : POSITION;    // �ˉe�ϊ����W
    float3 Normal : TEXCOORD1;   // �@��
    float4 VPos   : TEXCOORD2;   // �r���[���W
    float  Alpha  : COLOR0;      // �����̓��ߓx
};

// ���_�V�F�[�_
VS_OUTPUT2 Spiral_VS(float4 Pos : POSITION, float3 Normal : NORMAL)
{
    VS_OUTPUT2 Out = (VS_OUTPUT2)0;

    int Index = round( Pos.z * 100.0f );
    Pos.z = 0.0f;
    float4x4 wldMat = GetWorldMatrix(Index);  // ������[�̃��[���h�ϊ��s��

    float sgn = (dot(Pos.xy, Normal.xy) > 0.0f) ? 1.0f : -1.0f; // �@���� 1:�O����, -1:������

    // �o�ߎ���
    float etime = GetTime(Index);
    float etimePrev2 = GetTime(Index-GetCount(Index)-2);
    float etimePrev  = GetTime(Index-1);
    float etimeNext  = GetTime(Index+1);
    float etimeNext2 = GetTime(Index+2);

    // �i�s�ɂ�錸���x
    float alpha = smoothstep(-SpiralLife, -SpiralLife*SpiralDecrement, -etime);

    // �o�ߎ��Ԃɑ΂��闆�������g��x
    float scale = SpiralScaleUp * etime + SpiralThick;
//    scale *= alpha;
    Pos.xyz *= scale * Scaling;

    // �����̈ʒu�E��]
    float s0 = SpiralPos + SpiralDiffuseSpeed * pow(abs(etime), SpiralDiffuseExp);
    float s1 = SpiralPos + SpiralDiffuseSpeed * pow(abs(etimeNext), SpiralDiffuseExp);
    float3 vec = GetVec(Index, s0, s1);
    Pos.xyz = RotQuat(float3(0,0,-1), vec, Pos.xyz, 1.0f);
    Pos.x += s0 * Scaling;
    Pos.xy = Rotation2D(Pos.xy, 2.0f*PAI*float(SpiralIndex)/float(SpiralCount));

    // �����̈ړ�������̎��ԕω��ɑ΂����]
    float3 rotVec = normalize(wldMat._31_32_33);
    float3x3 dirRotMat = RotMat1(rotVec, -SpiralRotSpeed*time);
    float4x4 newRotMat = float4x4(dirRotMat[0], 0.0f,
                                  dirRotMat[1], 0.0f,
                                  dirRotMat[2], 0.0f,
                                  wldMat._41_42_43 - mul(wldMat._41_42_43, dirRotMat), 1.0f );
    wldMat = mul(wldMat, newRotMat);

    // �����̃��[���h���W
    Pos = mul(Pos, wldMat);
    if(etime < 0.001f) Pos.xyz *= wldMat._41_42_43;
    Pos.w = 1.0f;

    // �@����]
    Normal = RotQuat(float3(0,0,-1), vec, Normal, 1.0f);
    Normal.xy = Rotation2D(Normal.xy, 2.0f*PAI*float(SpiralIndex)/float(SpiralCount));
    Normal = mul(Normal, (float3x3)wldMat) * sgn;
    //Out.Normal = Normal;
    Out.Normal = mul(Normal, (float3x3)ViewMatrix);

    // �J�������_�̃r���[�ϊ�
    Out.VPos = mul( Pos, ViewMatrix );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_VPMAT(Pos) );

    // ��\���ɂ��闆���̃`�F�b�N
    alpha *= step(0.001, etime);
    alpha *= step(0.001, etimePrev2);
    alpha *= step(0.001, etimePrev);
    alpha *= step(0.001, etimeNext);
    alpha *= step(0.001, etimeNext2);

    Out.Alpha = alpha*alpha;
    Out.Alpha = saturate( Out.Alpha );

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Spiral_PS( VS_OUTPUT2 IN ) : COLOR0
{
    // ���������ʂ͕`�悵�Ȃ�
    clip( IN.Alpha - 0.001f );

    // �@��(0�`1�ɂȂ�悤�␳)
    float3 Normal = normalize(IN.Normal);
    //Normal = RotQuat(Normal, float3(0,0,-1), Normal, 1-IN.Alpha); // ����ł�肽�����ǉ��̂����܂������Ȃ�
    Normal = (Normal + 1.0f) / 2.0f;
    Normal = lerp(float3(0.5, 0.5, 0.0f), Normal, IN.Alpha * AcsTr);

    // �[�x(0�`DEPTH_FAR��0.5�`1.0�ɐ��K��)
    float dep = length(IN.VPos.xyz / IN.VPos.w);
    dep = (saturate(dep / DEPTH_FAR) + 1.0f) * 0.5f;

    return float4(Normal, dep);
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTec0 < string MMDPass = "object";
    string Script = 
        "RenderColorTarget0=TimeTex;"
            "RenderDepthStencilTarget=TimeDepthBuffer;"
            "Pass=UpdateTime;"
        "RenderColorTarget0=CoordTex;"
	    "RenderDepthStencilTarget=CoordDepthBuffer;"
	    "Pass=UpdateCoord;"
        "RenderColorTarget0=WorldMatrixTex;"
	    "RenderDepthStencilTarget=WorldMatrixDepthBuffer;"
	    "Pass=UpdateWorldMatrix;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
             "LoopByCount=SpiralCount;"
             "LoopGetIndex=SpiralIndex;"
                 "Pass=DrawObject;"
             "LoopEnd=;";
>{
    pass UpdateTime < string Script= "Draw=Buffer;"; > {
        ZEnable = FALSE;
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_1_1 UpdateTime_VS();
        PixelShader  = compile ps_2_0 UpdateTime_PS();
    }
    pass UpdateCoord < string Script= "Draw=Buffer;"; > {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 UpdatePos_VS();
        PixelShader  = compile ps_3_0 UpdatePos_PS();
    }
    pass UpdateWorldMatrix < string Script= "Draw=Buffer;"; > {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 WorldMatrix_VS();
        PixelShader  = compile ps_3_0 WorldMatrix_PS();
    }
    pass DrawObject {
        ALPHABLENDENABLE = FALSE;
        VertexShader = compile vs_3_0 Spiral_VS();
        PixelShader  = compile ps_3_0 Spiral_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �n�ʉe�͕\�����Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }
// MMD�W���̃Z���t�V���h�E�͕\�����Ȃ�
technique ZplotTec < string MMDPass = "zplot"; > { }

