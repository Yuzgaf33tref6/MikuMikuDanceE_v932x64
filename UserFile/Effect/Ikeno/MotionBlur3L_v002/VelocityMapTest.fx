
float Emphasize = 15;

///////////////////////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float ViewportAspect = ViewportSize.x / ViewportSize.y;

static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);


//�[�x�t���x���V�e�B�}�b�v�쐬
texture VelocityRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for MotionBlur.fx";
    float4 ClearColor = { 0.5, 0.5, 0, 1 };
    float ClearDepth = 1.0;
    string Format = "A32B32G32R32F" ;
    bool AntiAlias = false;
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
//�x���V�e�B�}�b�v�o�̓e�X�g

float4 PS_VelocityCopy( float2 Tex: TEXCOORD0 ) : COLOR {   
    
    float4 Color = tex2D( VelocitySampler, Tex );
    Color.rg -= 0.5;
    Color.rg *= Emphasize;
    Color.rg += 0.5;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////


// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,0};
float4 ClearColor2 = {0,0,0,0};
float ClearDepth  = 1.0;


technique VelocityMapTest <
    string Script = 
        
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"
        
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=VelocityCopy;"
        
        
    ;
    
> {
    
    //�x���V�e�B�}�b�v�o�̓e�X�g
    pass VelocityCopy < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_VelocityCopy();
    }
    
    
}
////////////////////////////////////////////////////////////////////////////////////////////////

