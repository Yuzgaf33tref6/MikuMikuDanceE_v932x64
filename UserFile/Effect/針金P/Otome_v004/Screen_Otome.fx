////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Screen_Otome.fx ver0.0.4  �����t�B���^�[�G�t�F�N�g��X�N���[���Œ��
//  �쐬: �j��P( ���͉��P����laughing_man.fx,FireParticleSystem.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// ���ʕ`��p�����[�^�ݒ�
int BallCount = 30;           // ���ʂ̕`��I�u�W�F�N�g��
float3 BallColor = {1.0, 1.0, 1.0}; // ���ʂ̏�Z�F(RBG)
float BallRandamColor = 0.6;  // ���ʐF�̂΂���x(0.0�`1.0)
float BallScale = 3.0;        // ���ʑ傫��
float BallSpeed = 0.07;       // ���ʃX�s�[�h
float BallAlpha = 0.5;        // ����Tr=1�̎��̃��l
float BallPosParam = 0.4;     // ���ʏ㉺��蕪���p�����[�^(0�ŋϓ�,1�ɋ߂Â��قǏ㉺�ɂ�蕪������)


// �����q�`��p�����[�^�ݒ�
int LightCount = 50;          // �����q�̕`��I�u�W�F�N�g��
float3 LightColor = {1.0, 1.0, 0.8}; // ���ʂ̏�Z�F(RBG)
float LightRandamColor = 0.2; // ���q�F�̂΂���x(0.0�`1.0)
float LightScale = 1.0;       // �����q�傫��
float LightSpeed = 0.03;      // �����q�X�s�[�h
float LightRotSpeed = 0.2;    // �����q��]�X�s�[�h
float LightPower = 0.5;       // �����q�̋P�����x
float LightAmp = 1.0;         // �����q�u���U��
float LightFreq = 1.0;        // �����q�u�����g��
// �L���L���`��p�����[�^�ݒ�
int GlareCount = 2;           // ���䊂̐�(���̐���2�{�����ۂ̌�䊐�)
int SubGlareCount = 8;        // ����䊂̐�(���䊂̊Ԃ̒Z����䊂̐�)
float GlareThick = 3.0;       // ���䊂̑���
float SubGlareThick = 1.0;    // ����䊂̑���
float SubGlareLength = 0.5;   // ����䊂̒���(���䊒����Ƃ̔�)
float LightCenter = 0.5;      // �����q�������̑傫��(���䊒����Ƃ̔�)


// �����V�[�h�ݒ�
int BallSeedXY = 18;          // ���ʔz�u�Ɋւ��闐���V�[�h
int BallSeedSize = 12;        // ���ʃT�C�Y�Ɋւ��闐���V�[�h
int BallSeedSpeed = 17;       // ���ʃX�s�[�h�Ɋւ��闐���V�[�h
int BallSeedColor = 5;        // ���ʐF�Ɋւ��闐���V�[�h
int LightSeedXY = 9;          // �����q�z�u�Ɋւ��闐���V�[�h
int LightSeedSize = 13;       // �����q�T�C�Y�Ɋւ��闐���V�[�h
int LightSeedSpeed = 17;      // �����q�X�s�[�h�Ɋւ��闐���V�[�h
int LightSeedBlink = 13;      // �����q�u���Ɋւ��闐���V�[�h
int LightSeedCross = 19;      // �����q�\���x�����Ɋւ��闐���V�[�h


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define TEX_WORK_SIZE  512 // �L���L�����q�e�N�X�`���쐬�̍�ƃ��C���T�C�Y

#define PAI 3.14159265f   // ��

int GlareIndex;      // ���䊕`��C���f�b�N�X
int SubGlareIndex;   // ����䊕`��C���f�b�N�X

float Xmin = -1.3f;
float Xmax = 1.3f;
float Ymin = -1.1f;
float Ymax = 1.1f;

float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

int Index;

float time : Time;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

texture2D BallTex <
    string ResourceName = "ball.png";
>;
sampler BallSamp = sampler_state {
    texture = <BallTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture2D ParticleTex1 <
    string ResourceName = "Particle1.png";
>;
sampler ParticleSamp1 = sampler_state {
    texture = <ParticleTex1>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture2D ParticleTex2 <
    string ResourceName = "Particle2.png";
>;
sampler ParticleSamp2 = sampler_state {
    texture = <ParticleTex2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


// ��ƃ��C���T�C�Y
#define TEX_WORK_WIDTH  TEX_WORK_SIZE
#define TEX_WORK_HEIGHT TEX_WORK_SIZE

// �L���L�����q�e�N�X�`���쐬�̍�ƃ��C��
texture2D WorkLayer : RENDERCOLORTARGET <
    int Width = TEX_WORK_WIDTH;
    int Height = TEX_WORK_HEIGHT;
    int Miplevels = 0;
    string Format = "A8R8G8B8" ;
>;
sampler2D WorkLayerSamp = sampler_state {
    texture = <WorkLayer>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
texture2D WorkDepthBuffer : RENDERDEPTHSTENCILTARGET <
    int Width = TEX_WORK_WIDTH;
    int Height = TEX_WORK_HEIGHT;
    string Format = "D24S8";
>;

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
float ClearDepth  = 1.0f;


////////////////////////////////////////////////////////////////////////////////////////////////
// ���W��2D��]
float2 Rotation2D(float2 pos, float rot)
{
    float x = pos.x * cos(rot) - pos.y * sin(rot);
    float y = pos.x * sin(rot) + pos.y * cos(rot);

    return float2(x,y);
}

////////////////////////////////////////////////////////////////////////////////////////////////
// HSV����RGB�ւ̕ϊ� H:0.0�`360.0, S:0.0�`1.0, V:0.0�`1.0 (S==0���͏ȗ�)
float4 HSV2RGB(float h, float s, float v) : COLOR
{
   h %= 360.0;
   int hi = (int)(h/60.0f) % 6;
   float f = h/60.0f - (float)hi;
   float p = v*(1.0f - s);
   float q = v*(1.0f - f*s);
   float t = v*(1.0f - (1.0f-f)*s);
   float4 Color;
   if(hi == 0){
      Color = float4(v, t, p, 1.0f);
   }else if(hi == 1){
      Color = float4(q, v, p, 1.0f);
   }else if(hi == 2){
      Color = float4(p, v, t, 1.0f);
   }else if(hi == 3){
      Color = float4(p, q, v, 1.0f);
   }else if(hi == 4){
      Color = float4(t, p, v, 1.0f);
   }else if(hi == 5){
      Color = float4(v, p, q, 1.0f);
   }
   return Color;
}

///////////////////////////////////////////////////////////////////////////////////////////////
// ���ʕ`��

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // �e�N�X�`��
    float4 Color      : COLOR0;      // �F
};

// ���_�V�F�[�_
VS_OUTPUT Ball_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out;

    // ������`
    float rand0 = abs(0.6f*sin(35 * BallSeedSize * Index + 13) + 0.4f*cos(73 * BallSeedSize * Index + 17));
    float rand1 = abs(0.4f*sin(51 * BallSeedSpeed * Index + 17) + 0.6f*cos(63 * BallSeedSpeed * Index + 19));
    float rand2 = abs(0.7f*sin(122 * BallSeedXY * Index + 19) + 0.3f*cos(237 * BallSeedXY * Index + 23));
    float rand3 = abs(0.6f*sin(81 * BallSeedXY * Index + 23) + 0.4f*cos(97 * BallSeedXY * Index + 29));
    float rand4 = abs(0.4f*sin(47 * BallSeedColor * Index + 29) + 0.6f*cos(83 * BallSeedColor * Index + 31));

    // ���ʃT�C�Y
    float scale = (0.5f + rand0) * BallScale;
    Pos.x *= scale*ViewportSize.y/ViewportSize.x;
    Pos.y *= scale;

    // ���ʔz�u
    float speed = lerp(-BallSpeed, BallSpeed,rand1);
    float x = lerp(Xmin, Xmax, rand2);
    float y = lerp(Ymin-BallPosParam, Ymax+BallPosParam, rand3);
    Pos.x += ((x+speed*(time+60.0f)-Xmin)%(Xmax-Xmin)+Xmin+step(speed,0.0f)*(Xmax-Xmin));
    Pos.y += sign(y)*pow(abs(y), max(1.0f-BallPosParam, 0.0f));
    Out.Pos = Pos;

    // ���ʂ̐F
    float alpha = AcsTr * BallAlpha;
    float4 Color = HSV2RGB(360.0f*rand4, 1.0f, 1.0f);
    Color = BallRandamColor * (Color - 1.0f) + 1.0f;
    Out.Color = float4(Color.rgb*BallColor, alpha);

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Ball_PS( VS_OUTPUT IN ) : COLOR0
{
    float4 Color = tex2D( BallSamp, IN.Tex.xy );
    Color *= IN.Color;
    return Color;
}

// �e�N�j�b�N
technique MainTec0 < string MMDPass = "object"; string Subset = "0";
    string Script = "LoopByCount=BallCount;"
                        "LoopGetIndex=Index;"
                        "Pass=DrawObject;"
                    "LoopEnd=;"; >
{
    pass DrawObject {
        ZENABLE = false;
        VertexShader = compile vs_1_1 Ball_VS();
        PixelShader  = compile ps_2_0 Ball_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////
// �L���L�����q�e�N�X�`���`��

// ���_�V�F�[�_
VS_OUTPUT LightParticle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD, uniform bool flag)
{
   VS_OUTPUT Out = (VS_OUTPUT)0; 

   // ��䊃C���f�b�N�X
   int index = int(!flag)*(SubGlareIndex + 1) + GlareIndex*(SubGlareCount + 1);

   // �����ݒ�
   float rand0 = 0.5f * (0.66f * sin(22.1f * index) + 0.33f * cos(33.6f * index) + 1.0f);
   float rand1 = 0.5f * (0.38f * sin(55.1f * index) + 0.62f * cos(44.4f * index) + 1.0f);
   float rand2 = 0.5f * (0.31f * sin(45.3f * index) + 0.69f * cos(73.4f * index) + 1.0f);

   // ��䊉�]�p
   float rot = PAI * float(index) / float( (SubGlareCount+1) * GlareCount );

   // ���W�ϊ�
   if(flag){
      Pos.x *= 0.7f + 0.3f * rand0;
      Pos.x *= (1.0f - rand1 * (sin(2.0f*PAI*(LightFreq*time+rand2))+1.0f) * 0.2f);
      Pos.y *= GlareThick / 16.0f;
   }else{
      Pos.x *= 0.1f + 0.9f * rand0;
      Pos.x *= SubGlareLength * (1.0f - rand1 * (sin(2.0f*PAI*(LightFreq*time+rand2))+1.0f) * 0.4f);
      Pos.y *= SubGlareThick / 16.0f;
   }
   Out.Pos.xy = Rotation2D( Pos.xy, rot );
   Out.Pos.zw = float2(0.0f, 1.0f);

   // �e�N�X�`�����W
   Out.Tex = Tex;

   return Out;
}

// �s�N�Z���V�F�[�_
float4 LightParticle_PS( VS_OUTPUT IN ) : COLOR0
{
   // ���q�̐F
   return tex2D( ParticleSamp1, IN.Tex );
}


///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��

struct VS_OUTPUT2
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float3 Tex        : TEXCOORD0;   // �e�N�X�`��
    float4 Color      : COLOR0;      // �F
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT2 Out;

    // ������`
    float rand0 = abs(0.5f*sin(35 * LightSeedSize * Index + 13) + 0.5f*cos(73 * LightSeedSize * Index + 17));
    float rand1 = abs(0.6f*sin(51 * LightSeedSpeed * Index + 17) + 0.4f*cos(63 * LightSeedSpeed * Index + 19));
    float rand2 = abs(0.4f*sin(122 * LightSeedXY * Index + 19) + 0.6f*cos(237 * LightSeedXY * Index + 23));
    float rand3 = abs(0.7f*sin(81 * LightSeedXY * Index + 23) + 0.3f*cos(97 * LightSeedXY * Index + 29));
    float rand4 = 0.5f*sin(53 * LightSeedBlink * Index + 17) + 0.5f*cos(61 * LightSeedBlink * Index + 19);
    float rand5 = (sin(47 * LightSeedCross * Index + 29) + cos(83 * LightSeedCross * Index + 31) + 3.0f) * 0.1f;

    // �p�[�e�B�N����]
    Pos.xy = Rotation2D(Pos.xy, time*LightRotSpeed);

    // �p�[�e�B�N���T�C�Y
    float scale = (0.5f + rand0)*LightScale + LightAmp*sin(LightFreq*time+rand4*6.28f);
    Pos.x *= scale*ViewportSize.y/ViewportSize.x;
    Pos.y *= scale;

    // �p�[�e�B�N���z�u
    float speed = lerp(-LightSpeed, LightSpeed, rand1);
    float x = lerp(Xmin, Xmax, rand2);
    Pos.x += (x+speed*time-Xmin)%(Xmax-Xmin)+Xmin+step(speed,0.0f)*(Xmax-Xmin);
    Pos.y += lerp(Ymin, Ymax, rand3);
    Out.Pos = Pos;

    // �p�[�e�B�N���̐F
    Out.Color = float4(LightColor*AcsTr, 1.0f);
    Out.Color.rgb *= lerp(float3(1.0f,1.0f,1.0f), float3(rand0,rand1,rand2), LightRandamColor);

    // �e�N�X�`�����W
    Out.Tex = float3(Tex, 1.0f / (LightCenter * lerp(0.5f, 1.0f, rand5)));

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
    float4 Color = tex2D( WorkLayerSamp, IN.Tex.xy );
    float2 Tex1 = (IN.Tex.xy - 0.5f) * IN.Tex.z + 0.5f;
    float4 Color1 = tex2D( ParticleSamp2, Tex1 );
    Color += Color1;
    Color.rgb *= IN.Color.rgb*LightPower;
    return Color;
}

// �e�N�j�b�N
technique MainTec1 < string MMDPass = "object"; string Subset = "1-1000";
    string Script = 
       "RenderColorTarget0=WorkLayer;"
            "RenderDepthStencilTarget=WorkDepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "LoopByCount=GlareCount;"
                "LoopGetIndex=GlareIndex;"
                "Pass=DrawLightParticle1;"
                "LoopByCount=SubGlareCount;"
                    "LoopGetIndex=SubGlareIndex;"
                    "Pass=DrawLightParticle2;"
                "LoopEnd=;"
            "LoopEnd=;"
       "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "LoopByCount=LightCount;"
                "LoopGetIndex=Index;"
                "Pass=DrawObject;"
            "LoopEnd=;"
       ;
> {
    pass DrawLightParticle1 < string Script= "Draw=Buffer;"; > {
        ZENABLE = FALSE;
        ALPHABLENDENABLE = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
        VertexShader = compile vs_2_0 LightParticle_VS(true);
        PixelShader  = compile ps_2_0 LightParticle_PS();
    }
    pass DrawLightParticle2 < string Script= "Draw=Buffer;"; > {
        ZENABLE = FALSE;
        ALPHABLENDENABLE = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
        VertexShader = compile vs_2_0 LightParticle_VS(false);
        PixelShader  = compile ps_2_0 LightParticle_PS();
    }
    pass DrawObject {
        ZENABLE = false;
        AlphaBlendEnable = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
        VertexShader = compile vs_1_1 Particle_VS();
        PixelShader  = compile ps_2_0 Particle_PS();
    }
}

