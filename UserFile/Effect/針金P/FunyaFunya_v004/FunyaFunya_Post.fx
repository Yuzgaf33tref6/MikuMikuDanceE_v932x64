////////////////////////////////////////////////////////////////////////////////////////////////
//
//  FunyaFunya_Post.fx ver0.0.2  �ӂɂ�ӂɂ�G�t�F�N�g(�|�X�g�G�t�F�N�gver)
//  �쐬: �j��P( ���͉��P����Gaussian.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

bool WaveType <      // �h����̎�ނ�؂�ւ�
   string UIName = "�h����̃^�C�v";
   bool UIVisible =  true;
> = true;

float2 WaveNumber <  // �g���x�N�g��(�傫������Ɣg�`�������݂ɂȂ�܂�)
   string UIName = "�g���x�N�g��";
   string UIHelp = "�傫������Ɣg�`�������݂ɂȂ�܂�";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 100.0;
> = float2(0.0, 20.0);

float AngularFrequency <  // �p���g��(�傫������Ɣg�̐i�s�������Ȃ�܂�)
   string UIName = "�p���g��";
   string UIHelp = "�傫������Ɣg�̐i�s�������Ȃ�܂�";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 30.0;
> = 2.0;

// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////

float Amplitude = 0.01;  // �g�̐U��(��ʕ��̔䗦�œ���)

float time : Time;

// �A�N�Z�T���p�����[�^
float3 AcsPos : CONTROLOBJECT < string name = "(self)"; string item = "XYZ"; >;
float  AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;


float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;

static float2 ViewportOffset = (float2(0.5f, 0.5f)/ViewportSize);
static float2 SampStep = (float2(1,1)/ViewportSize);

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,1};
float ClearDepth  = 1.0;

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    string Format = "D24S8";
>;


////////////////////////////////////////////////////////////////////////////////////////////////
// �ӂɂ�ӂɂ�`��

struct VS_OUTPUT {
    float4 Pos	: POSITION;
    float2 Tex	: TEXCOORD0;
};

// ���_�V�F�[�_
VS_OUTPUT VS_Funya( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
//    Out.Tex = Tex + float2(0, ViewportOffset.y);
    Out.Tex = Tex + ViewportOffset;

    return Out;
}


// �s�N�Z���V�F�[�_
float4 PS_Funya( float2 Tex: TEXCOORD0 ) : COLOR {   
    float4 Color;

    float a = Amplitude * AcsSi*0.1f;
    float kx = WaveNumber.x + AcsPos.x;
    float ky = WaveNumber.y + AcsPos.y;
    float freq = AngularFrequency + AcsPos.z;

    float2 wave;
    if( WaveType ){
        wave.x = a*sin(kx*Tex.x - ky*Tex.y - freq*time);
        wave.y = a*sin(ky*Tex.x + kx*Tex.y - freq*time);
    }else{
        wave.x = a*sin(ky*Tex.y - freq*time);
        wave.y = a*sin(kx*Tex.x - freq*time);
    }

    Color = tex2D( ScnSamp, Tex+wave );

    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique FunyaTech <
    string Script = 
        "RenderColorTarget0=ScnMap;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
	    "ScriptExternal=Color;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=FunyaPass;"
    ;
> {
    pass FunyaPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Funya();
        PixelShader  = compile ps_2_0 PS_Funya();
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
