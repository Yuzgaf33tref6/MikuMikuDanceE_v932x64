////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Post_MangaLines_Parallel.fx ver0.0.3  ���楃A�j���̌��ʐ��G�t�F�N�g(���s��,�|�X�g�t�F�N�g��)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

int LineCount = 87;       // ���ʐ��̖{��
float LineThick = 0.5;    // ���ʐ��̊����
float LineAlpha = 0.7;    // ���ʐ��̍ő哧�ߒl
float PosParam = 0.65;     // ��蕪���p�����[�^(0�ŋϓ�,1�ɋ߂Â��قǊO���ɂ�蕪������)
float AreaScale = 1.0;    // ���ʐ����`�悳���͈�(���S�ʒu�ύX�Ō��ʐ��O�[�������鎞�͂�����傫������)
float3 LineColor = {0.0, 0.0, 0.0}; // ���ʐ��F(RBG)

int SeedThick = 9;     // �����Ɋւ��闐���V�[�h
int SeedPos = 14;      // �z�u�Ɋւ��闐���V�[�h
int SeedAnime = 108;   // �A�j���[�V�����Ɋւ��闐���V�[�h


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define PAI 3.14159265f   // ��

bool flagCenterControl   : CONTROLOBJECT < string name = "CentetControl.pmx"; >;
float4x4 CenterControlMat  : CONTROLOBJECT < string name = "CentetControl.pmx"; string item = "�Z���^�["; >;
static float2 CenterCtrlRzVec = flagCenterControl ? normalize(CenterControlMat._11_12) : float2(1,0); // Z����]�x�N�g��

float AcsX  : CONTROLOBJECT < string name = "(self)"; string item = "X"; >;
float AcsY  : CONTROLOBJECT < string name = "(self)"; string item = "Y"; >;
float AcsZ  : CONTROLOBJECT < string name = "(self)"; string item = "Z"; >;
float AcsRx : CONTROLOBJECT < string name = "(self)"; string item = "Rx"; >;
float AcsRz : CONTROLOBJECT < string name = "(self)"; string item = "Rz"; >;
float AcsRy : CONTROLOBJECT < string name = "(self)"; string item = "Ry"; >;
float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
static float xAlpha = saturate( 1.0f - degrees(AcsRx) );

float time : Time;

int Index;

// ���W�ϊ��s��
float4x4 ViewProjMatrix : VIEWPROJECTION;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

static float R = length( float2( ViewportSize.x/ViewportSize.y, 1.0f) )*AreaScale;  // ��ʑΊp�������ƍ����̔�

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,0};
float ClearDepth  = 1.0;


////////////////////////////////////////////////////////////////////////////////////////////////
// ���W��2D��]
float2 Rotation2D(float2 pos, float rot)
{
    float x1 = pos.x * cos(rot) - pos.y * sin(rot);
    float y1 = pos.x * sin(rot) + pos.y * cos(rot);
    float x2 = x1 * CenterCtrlRzVec.x - y1 * CenterCtrlRzVec.y;
    float y2 = x1 * CenterCtrlRzVec.y + y1 * CenterCtrlRzVec.x;

    return float2(x2, y2);
}

///////////////////////////////////////////////////////////////////////////////////////
// ���ʐ��`��

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 VPos       : TEXCOORD0;   // ���[�J����A�j���[�V�������W
    float2 Tex        : TEXCOORD1;   // �e�N�X�`�����W
};

// ���_�V�F�[�_
VS_OUTPUT Line_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // �����ݒ�
    float rand1 = 0.5f * (0.66f * sin(22.1f * SeedThick * Index) + 0.33f * cos(33.6f * SeedThick * Index) + 1.0f);
    float rand2 = 0.5f * (0.31f * sin(45.3f * SeedPos * Index) + 0.69f * cos(73.4f * SeedPos * Index) + 1.0f);
    float rand3 = 0.5f * (0.38f * sin(55.1f * SeedAnime * Index) + 0.62f * cos(44.4f * SeedAnime * Index) + 1.0f);

    // ���[�J����A�j���[�V�������W
    Out.VPos.x = Pos.x;
    Out.VPos.y = step(0.0, AcsZ)*(2.0f*R+abs(AcsZ))
               - sign(AcsZ)*fmod(lerp(0.0f, 2.0f*(R+abs(AcsZ)), rand3)+time*AcsSi, 2.0f*(R+abs(AcsZ)));

    // ���̑���
    Pos.y *= max((LineThick+degrees(AcsRy)*0.2f)*(0.5+rand1)*(1.0f+Pos.x)*0.1f, 0.3f);

    // ���s���z�u
    float2 Pos0 = float2(-R-0.4*rand2, lerp(-R, R, (float)Index/(float)LineCount) + ((rand2-0.5f) * 1.5f * R / LineCount));
    Pos0.y = sign(Pos0.y)*R*pow(abs(Pos0.y/R), max(1.0f-PosParam, 0.0f));
    Pos.xy += Pos0;

    // ���W��]
    Pos.xy = Rotation2D(Pos.xy, AcsRz);

    // �z�u�ړ�
    if ( flagCenterControl ){
       float4 centerPos = mul(CenterControlMat[3], ViewProjMatrix);
       Pos.x += centerPos.x / centerPos.w * ViewportSize.x/ViewportSize.y;
       Pos.y += centerPos.y / centerPos.w;
    } else {
       Pos.x += AcsX*ViewportSize.x/ViewportSize.y;
       Pos.y += AcsY;
    }

    // �X�N���[�����W�ɕϊ�
    Pos.x *= ViewportSize.y/ViewportSize.x;
    Out.Pos = Pos;

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Line_PS( VS_OUTPUT IN ) : COLOR0
{
    // ����[���ߒl�ݒ�
    float alpha1 = smoothstep((1.0f-AcsTr)*(1.0f+R), 1.0f+(1.0f-AcsTr)*5.0f, IN.VPos.x)*AcsTr;
    // �A�j���[�V�������ߒl�ݒ�
    float alpha2 = smoothstep(-max(abs(AcsZ),0.0001f), 0.0f, -abs(IN.VPos.x-IN.VPos.y));
    if( abs(AcsZ) < 0.0001f ) alpha2 = 1.0f;
    // �������E���ߒl�ݒ�
    float alpha3 = 1.0f - smoothstep(0.0f, 0.5f, abs(IN.Tex.y-0.5f));

    // ���ʐ��̐F
    float4 Color = float4( LineColor, alpha1*alpha2*alpha3*LineAlpha*xAlpha );

    return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
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
            "LoopByCount=LineCount;"
               "LoopGetIndex=Index;"
               "Pass=DrawObject;"
            "LoopEnd=;"; >
{
    pass DrawObject {
        ZENABLE = false;
        AlphaBlendEnable = TRUE;
        VertexShader = compile vs_1_1 Line_VS();
        PixelShader  = compile ps_2_0 Line_PS();
    }
}

