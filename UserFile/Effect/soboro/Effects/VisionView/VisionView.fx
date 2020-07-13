


//�Đ����͉B���悤�ɂ���
bool HideInPlaying = true;
//bool HideInPlaying = false;

////////////////////////////////////////////////////////////////////////////////////////////////

//�t���[�����ԂƃV�X�e�����Ԃ���v������Đ����Ƃ݂Ȃ�
float elapsed_time1 : ELAPSEDTIME<bool SyncInEditMode=true;>;
float elapsed_time2 : ELAPSEDTIME<bool SyncInEditMode=false;>;
static bool IsPlaying = (abs(elapsed_time1 - elapsed_time2) < 0.01) && HideInPlaying;


//�r���[�ˉe�s��
float4x4 ViewProjMatrix : VIEWPROJECTION;
float4x4 InvViewProjMatrix : VIEWPROJECTIONINVERSE;

//�A���t�@�l�擾
float alpha1 : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

//�}�E�X
float4 LeftButton : LEFTMOUSEDOWN;
float4 RightButton : RIGHTMOUSEDOWN;

//�o�b�t�@�̕�
#define INFOBUFSIZE 4

//�s��̋L�^
texture DepthBufferMB : RenderDepthStencilTarget <
   int Width=INFOBUFSIZE;
   int Height=1;
    string Format = "D24S8";
>;
texture MatrixBufTex : RenderColorTarget
<
    int Width=INFOBUFSIZE;
    int Height=1;
    bool AntiAlias = false;
    int Miplevels = 1;
    string Format="A32B32G32R32F";
>;

float4 MatrixBufArray[INFOBUFSIZE] : TEXTUREVALUE <
    string TextureName = "MatrixBufTex";
>;

////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float4 Color      : COLOR0;
    
};

VS_OUTPUT Object_VS(float4 Pos : POSITION, float3 Normal : NORMAL)
{
    VS_OUTPUT Out;
    
    //�L�^�����r���[�ˉe�t�s������[�h
    float4x4 savedMatrix = float4x4(MatrixBufArray[0], MatrixBufArray[1], MatrixBufArray[2], MatrixBufArray[3]);
    
    //Out.Pos = mul( Pos, InvViewProjMatrix );
    Out.Pos = mul( Pos, savedMatrix );
    Out.Pos = mul( Out.Pos, ViewProjMatrix );
    
    Out.Color = float4(abs(Normal), 0.16 * alpha1);
    
    if(IsPlaying) Out.Pos.z = -1; //�Đ����͉B��
    
    return Out;
}


float4 Object_PS( VS_OUTPUT IN , uniform bool wire) : COLOR0
{
    float4 Color;
    
    if(wire){
        Color = float4(0, 0, 0, 0.4 * alpha1);
    }else{
        Color = IN.Color;
    }
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT2 {
    float4 Pos: POSITION;
    float2 Tex: TEXCOORD0;
};


VS_OUTPUT2 DrawMatrixBuf_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD) {
    VS_OUTPUT2 Out;
    
    Out.Tex = Tex;
    Out.Pos = Pos;
    
    //�{�^�����������ȊO�͉�ʊO�ɐ�����΂��ď��X�V���Ȃ�
    Out.Pos.y += 100 * (LeftButton.z == 0 || RightButton.z == 0); 
    
    return Out;
}

float4 DrawMatrixBuf_PS(float2 Tex: TEXCOORD0) : COLOR {
    int dindex = (int)(Tex * INFOBUFSIZE); //�e�N�Z���ԍ�
    
    //�r���[�ˉe�t�s����L�^
    float4 Color = InvViewProjMatrix[min(dindex, 3)];
    
    return Color;
}


/////////////////////////////////////////////////////////////////////////////////////

// �I�u�W�F�N�g�`��p�e�N�j�b�N

stateblock objectState = stateblock_state
{
    CullMode = NONE;
    ZWriteEnable = false;
    VertexShader = compile vs_2_0 Object_VS();
    PixelShader  = compile ps_2_0 Object_PS(false);
};
stateblock objectState2 = stateblock_state
{
    CullMode = NONE;
    ZWriteEnable = false;
    FillMode = WIREFRAME;
    VertexShader = compile vs_2_0 Object_VS();
    PixelShader  = compile ps_2_0 Object_PS(true);
};

stateblock makeMatrixBufState = stateblock_state
{
    AlphaBlendEnable = false;
    AlphaTestEnable = false;
    VertexShader = compile vs_2_0 DrawMatrixBuf_VS();
    PixelShader  = compile ps_2_0 DrawMatrixBuf_PS();
};

technique MainTec1 < 
    string MMDPass = "object"; 
    string Script =
        
        "RenderColorTarget=MatrixBufTex;"
        "RenderDepthStencilTarget=DepthBufferMB;"
        "Pass=DrawMatrixBuf;"
        
        "RenderColorTarget=;"
        "RenderDepthStencilTarget=;"
        "Pass=DrawObject;"
        "Pass=DrawObjectWire;"
        
    ;
> {
    
    pass DrawMatrixBuf  < string Script = "Draw=Buffer;";>   { StateBlock = (makeMatrixBufState); }
    pass DrawObject     < string Script = "Draw=Geometry;";> { StateBlock = (objectState);  }
    pass DrawObjectWire < string Script = "Draw=Geometry;";> { StateBlock = (objectState2);  }
    
}

