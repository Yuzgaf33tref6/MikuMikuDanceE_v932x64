////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Post_Appeal.fx ver0.0.3  �A�s�[���G�t�F�N�g(�|�X�g�t�F�N�g�L�����Z����)  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// ���ˌ��`��p�����[�^�ݒ�
#define RADIANT_TYPE   1        // ���ˌ��̎��(�Ƃ肠����1�`3�őI��)
float3 RadiantColor = {1.0, 1.0, 0.5};  // ���ˌ��̏�Z�F(RBG)
float RadiantSizeMin = 0.2;     // ���ˌ��ŏ��T�C�Y
float RadiantSizeMax = 25.0;    // ���ˌ��ő�T�C�Y
float RadiantAlpha = 1.0;       // ���ˌ��̃��l

// �L���L���`��p�����[�^�ݒ�
float3 KiraColor = {0.5, 1.0, 1.0};  // �L���L�����q�̏�Z�F(RBG)
int KiraCount = 17;             // �L���L�����q�̕`��I�u�W�F�N�g��
float KiraSize = 1.8;           // �L���L�����q�̃T�C�Y
float KiraStartPos = 0.2;       // �L���L�����q�̊J�n�ʒu
float KiraEndPos = 0.8;         // �L���L�����q�̏I���ʒu
float KiraRotSpeed = 2.0;       // �L���L�����q�̉�]�X�s�[�h
float KiraCross = 1.0;          // �L���L�����q�̏\���x(�傫������Ə\�����N���ɂȂ�)
float KiraAlpha = 1.0;          // �L���L�����q�̃��l

// �p�[�e�B�N���`��p�����[�^�ݒ�
#define PARTICLE_TYPE   1         // �p�[�e�B�N���̎��(�Ƃ肠����1�`3�őI��, 1:��, 2:�n�[�g, 3:����)
int ParticleCount = 22;           // �p�[�e�B�N���̕`��I�u�W�F�N�g��
float3 ParticleColor = {1.0, 0.8, 1.0};  // �p�[�e�B�N���̏�Z�F(RBG)
float ParticleRandamColor = 0.5;  // �p�[�e�B�N���F�̂΂���x(0.0�`1.0)
float ParticleSize = 2.0;         // �p�[�e�B�N���̃T�C�Y
float ParticleStartPos = 0.6;     // �p�[�e�B�N���̊J�n�ʒu
float ParticleEndPos = 0.9;       // �p�[�e�B�N���̏I���ʒu
float ParticleRotSpeed = 2.0;     // �p�[�e�B�N���̉�]�X�s�[�h
float ParticleAlpha = 1.0;        //�p�[�e�B�N���̃��l

// �����V�[�h�ݒ�
int SeedXY = 5;         // �z�u�Ɋւ��闐���V�[�h
int SeedSize = 5;       // �T�C�Y�Ɋւ��闐���V�[�h
int SeedRotSpeed = 13;  // ��]�X�s�[�h�Ɋւ��闐���V�[�h
int SeedColor = 7;      // �p�[�e�B�N���F�̂΂���Ɋւ��闐���V�[�h
int SeedView = 11;      // �t�F�[�h�C����A�E�g�Ɋւ��闐���V�[�h



// �K�v�ɉ����ĕ��ˌ��̃e�N�X�`���������Œ�`
#if RADIANT_TYPE == 1
    #define RadiantTexFile  "����1.png"     // ���ˌ��̃e�N�X�`���t�@�C����
#endif

#if RADIANT_TYPE == 2
    #define RadiantTexFile  "����2.png"     // ���ˌ��̃e�N�X�`���t�@�C����
#endif

#if RADIANT_TYPE == 3
    #define RadiantTexFile  "����3.png"     // ���ˌ��̃e�N�X�`���t�@�C����
#endif


// �K�v�ɉ����ăp�[�e�B�N���̃e�N�X�`���������Œ�`
#if PARTICLE_TYPE == 1
    #define ParticleTexFile  "��.png"  // �p�[�e�B�N���ɓ\��t����e�N�X�`���t�@�C����
    #define TEX_PARTICLE_XNUM  2       // �p�[�e�B�N���e�N�X�`����x�������q��
    #define TEX_PARTICLE_YNUM  1       // �p�[�e�B�N���e�N�X�`����y�������q��
    #define USE_MIPMAP  0              // �e�N�X�`���̃~�b�v�}�b�v����,0:���Ȃ�,1:����
#endif

#if PARTICLE_TYPE == 2
    #define ParticleTexFile  "�n�[�g.png"  // �p�[�e�B�N���ɓ\��t����e�N�X�`���t�@�C����
    #define TEX_PARTICLE_XNUM  2       // �p�[�e�B�N���e�N�X�`����x�������q��
    #define TEX_PARTICLE_YNUM  1       // �p�[�e�B�N���e�N�X�`����y�������q��
    #define USE_MIPMAP  0              // �e�N�X�`���̃~�b�v�}�b�v����,0:���Ȃ�,1:����
#endif

#if PARTICLE_TYPE == 3
    #define ParticleTexFile  "����.png"  // �p�[�e�B�N���ɓ\��t����e�N�X�`���t�@�C����
    #define TEX_PARTICLE_XNUM  8       // �p�[�e�B�N���e�N�X�`����x�������q��
    #define TEX_PARTICLE_YNUM  1       // �p�[�e�B�N���e�N�X�`����y�������q��
    #define USE_MIPMAP  0              // �e�N�X�`���̃~�b�v�}�b�v����,0:���Ȃ�,1:����
#endif


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float3 AcsPos : CONTROLOBJECT < string name = "(self)"; string item = "XYZ"; >;
float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

#define PAI 3.14159265f   // ��

int Index;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,1};
float ClearDepth  = 1.0;

// ���ˌ��e�N�X�`��
texture2D RadiantTex <
    string ResourceName = RadiantTexFile;
>;
sampler RadiantSamp = sampler_state {
    texture = <RadiantTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �L���L���e�N�X�`��1
texture2D KiraTex1 <
    string ResourceName = "kira1.png";
>;
sampler KiraSamp1 = sampler_state {
    texture = <KiraTex1>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �L���L���e�N�X�`��1
texture2D KiraTex2 <
    string ResourceName = "kira2.png";
>;
sampler KiraSamp2 = sampler_state {
    texture = <KiraTex2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �p�[�e�B�N���e�N�X�`��
#if(USE_MIPMAP == 1)
texture2D ParticleTex <
    string ResourceName = ParticleTexFile;
    int MipLevels = 0;
>;
sampler ParticleSamp = sampler_state {
    texture = <ParticleTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};
#else
texture2D ParticleTex <
    string ResourceName = ParticleTexFile;
    int MipLevels = 1;
>;
sampler ParticleSamp = sampler_state {
    texture = <ParticleTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};
#endif

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

////////////////////////////////////////////////////////////////////////////////////////////////
// ���W��2D��]
float2 Rotation2D(float2 pos, float rot)
{
    float x = pos.x * cos(rot) - pos.y * sin(rot);
    float y = pos.x * sin(rot) + pos.y * cos(rot);

    return float2(x,y);
}

///////////////////////////////////////////////////////////////////////////////////////////////
// ���ˌ��`��
struct VS_OUTPUT
{
    float4 Pos   : POSITION;    // �ˉe�ϊ����W
    float2 Tex   : TEXCOORD0;   // �e�N�X�`��
    float4 Color : COLOR0;      // alpha�l
};

// ���_�V�F�[�_
VS_OUTPUT Radiant_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // ���ˌ��z�u
    float scale = (RadiantSizeMin * (1.0f - AcsTr) + RadiantSizeMax * AcsTr);
    Pos.x *= scale*ViewportSize.y/ViewportSize.x;
    Pos.y *= scale;
    Pos.xy += AcsPos.xy;
    Out.Pos = Pos;

    // �e�N�X�`���̏�Z�F
    float alpha = (1.0f - smoothstep(0.05f, 0.5f, abs(AcsTr - 0.5f))) * RadiantAlpha;
    Out.Color = saturate( float4(RadiantColor*alpha, 1.0f) );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Radiant_PS( VS_OUTPUT IN ) : COLOR0
{
    float4 Color = tex2D( RadiantSamp, IN.Tex.xy );
    Color *= IN.Color;
    return Color;
}

///////////////////////////////////////////////////////////////////////////////////////
// �L���L���`��
struct VS_OUTPUT2
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float3 Tex        : TEXCOORD0;   // �e�N�X�`��
    float4 Color      : COLOR0;      // alpha�l
};

// ���_�V�F�[�_
VS_OUTPUT2 Kira_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT2 Out;

    // �p�[�e�B�N���T�C�Y
    float scale = KiraSize * (sin(44 * SeedSize * Index + 13) + cos(87 * SeedSize * Index + 17) + 3.0f) * 0.25f;
    Pos.xy *= scale;

    // �p�[�e�B�N����]�z�u
    float rot = KiraRotSpeed * AcsTr;
    Pos.xy = Rotation2D( Pos.xy, rot );

    // �p�[�e�B�N���z�u
    float r = (sin(124 * SeedXY * Index*2 + 13) + cos(235 * SeedXY * Index + 17) + 1.5f) * 0.2f;
    float s = (sin(83 * SeedXY * Index*2 + 9) + cos(91 * SeedXY * Index + 11) + 3.0f) * 0.25f;
    float2 Pos0 = float2( 0.0f, lerp(r * KiraStartPos, (r + s) * KiraEndPos, AcsTr) );
    Pos.xy += Rotation2D(Pos0, ((float)Index/(float)KiraCount)*2.0f*PAI );
    Pos.x *= ViewportSize.y/ViewportSize.x;
    Pos.xy += AcsPos.xy;
    Out.Pos = Pos;

    // �e�N�X�`���̏�Z�F
    float alpha = (1.0f - smoothstep(0.05f, 0.5f, abs(AcsTr - 0.5f))) * KiraAlpha;
    Out.Color = saturate( float4(KiraColor*alpha, 1.0f) );

    // �e�N�X�`�����W
    float rand = (sin(47 * SeedSize * Index + 13) + cos(81 * SeedSize * Index + 17) + 3.0f) * 0.1f;
    Out.Tex = float3(Tex, 1.0f+KiraCross*rand);

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Kira_PS( VS_OUTPUT2 IN ) : COLOR0
{
    float4 Color = tex2D( KiraSamp2, IN.Tex.xy );
    float2 Tex1 = (IN.Tex.xy-0.5f)*IN.Tex.z+0.5f;
    float4 Color1 = tex2D( KiraSamp1, Tex1 );
    Color += Color1;
    Color.xyz *= IN.Color.xyz*0.5f;
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// HSV����RGB�ւ̕ϊ� H:0.0�`360.0, S:0.0�`1.0, V:0.0�`1.0 (S==0���͏ȗ�)
float3 HSV2RGB(float h, float s, float v)
{
   h = fmod(h, 360.0f);
   int hi = floor(fmod(floor(h/60.0f), 6.0f));
   float f = h/60.0f - (float)hi;
   float p = v*(1.0f - s);
   float q = v*(1.0f - f*s);
   float t = v*(1.0f - (1.0f-f)*s);
   float3 Color;
   if(hi == 0){
      Color = float3(v, t, p);
   }else if(hi == 1){
      Color = float3(q, v, p);
   }else if(hi == 2){
      Color = float3(p, v, t);
   }else if(hi == 3){
      Color = float3(p, q, v);
   }else if(hi == 4){
      Color = float3(t, p, v);
   }else if(hi == 5){
      Color = float3(v, p, q);
   }
   return Color;
}

///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��

// ���_�V�F�[�_
VS_OUTPUT Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // �p�[�e�B�N���T�C�Y
    float scale = ParticleSize * (sin(37 * SeedSize * Index + 13) + cos(71 * SeedSize * Index + 17) + 3.0f) * 0.25f;
    Pos.xy *= scale * AcsSi*0.1f;

    // �p�[�e�B�N����]�z�u
    float rot = ParticleRotSpeed * (sin(53 * SeedRotSpeed * Index + 13) + cos(61 * SeedRotSpeed * Index + 17)) * AcsTr;
    Pos.xy = Rotation2D( Pos.xy, rot );

    // �p�[�e�B�N���z�u
    float r = (sin(124 * SeedXY * Index + 13) + cos(235 * SeedXY * Index + 17) + 2.1f) * 0.25f;
    float s = (sin(83 * SeedXY * Index + 13) + cos(91 * SeedXY * Index + 17) + 3.0f) * 0.25f;
    Pos.x += lerp(r * ParticleStartPos, (r + s) * ParticleEndPos, AcsTr);
    Pos.xy = Rotation2D(Pos.xy, ((float)Index/(float)ParticleCount)*2.0f*PAI );
    Pos.x *= ViewportSize.y/ViewportSize.x;
    Pos.xy += AcsPos.xy;
    Out.Pos = Pos;

    // �e�N�X�`���̏�Z�F
    float a = (sin(47 * SeedView * Index + 13) + cos(19 * SeedView * Index + 17)) * 0.04f;
    float alpha = (1.0f - smoothstep(0.25f+a, 0.5f, abs(AcsTr - 0.5f))) * ParticleAlpha;
    float rand = abs(0.6f*sin(83 * SeedColor * Index + 23) + 0.4f*cos(91 * SeedColor * Index + 29));
    float3 randColor = HSV2RGB(rand*360.0f, 1.0f, 1.0f);
    randColor = ParticleRandamColor * (randColor - 1.0f) + 1.0f;
    Out.Color = float4(ParticleColor * randColor, alpha);

    // �e�N�X�`�����W
    int texIndex = Index % (TEX_PARTICLE_XNUM * TEX_PARTICLE_YNUM);
    int tex_i = texIndex % TEX_PARTICLE_XNUM;
    int tex_j = texIndex / TEX_PARTICLE_XNUM;
    Out.Tex = float2((Tex.x + tex_i)/TEX_PARTICLE_XNUM, (Tex.y + tex_j)/TEX_PARTICLE_YNUM);

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT IN ) : COLOR0
{
    float4 Color = tex2D( ParticleSamp, IN.Tex );
    Color *= IN.Color;
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N
technique MainTec1 < string MMDPass = "object";
    string Script = 
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "ScriptExternal=Color;"
            "Pass=DrawRadiant;"
            "LoopByCount=KiraCount;"
               "LoopGetIndex=Index;"
               "Pass=DrawKira;"
            "LoopEnd=;"
            "LoopByCount=ParticleCount;"
               "LoopGetIndex=Index;"
               "Pass=DrawParticle;"
            "LoopEnd=;" ; >
{
    pass DrawRadiant {
        ZENABLE = false;
        AlphaBlendEnable = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
        VertexShader = compile vs_2_0 Radiant_VS();
        PixelShader  = compile ps_2_0 Radiant_PS();
    }
    pass DrawKira {
        ZENABLE = false;
        AlphaBlendEnable = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
        VertexShader = compile vs_2_0 Kira_VS();
        PixelShader  = compile ps_2_0 Kira_PS();
    }
    pass DrawParticle {
        ZENABLE = false;
        AlphaBlendEnable = TRUE;
        DestBlend = INVSRCALPHA;
        SrcBlend = SRCALPHA;
        VertexShader = compile vs_2_0 Particle_VS();
        PixelShader  = compile ps_2_0 Particle_PS();
    }
}



