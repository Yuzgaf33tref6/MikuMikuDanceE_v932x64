

//�g�e�N�X�`���@�R�����g�A�E�g�Řg�Ȃ�
#define MAPFLAME "MapFrame.png"

//�}�b�v�w�i�F
#define MapBackColor   float4(1, 1, 1, 1)


///////////////////////////////////////////////////////////////////////////////////////////////
// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 ViewMatrix               : VIEW;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;


//�A���t�@�l�擾
float alpha1 : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

// �X�P�[���l�擾
float scaling0 : CONTROLOBJECT < string name = "(self)"; >;
static float scaling = scaling0 * 0.1;


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float ViewportAspect = ViewportSize.x / ViewportSize.y;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
static float2 OnePx = (float2(1,1)/ViewportSize);





///////////////////////////////////////////////////////////////////////////////////////////////
// �}�b�v�I�u�W�F�N�g�`���

texture MapDrawRT: OFFSCREENRENDERTARGET <
    string Description = "MapDrawRenderTarget for Map.fx";
    int Width = 512;
    int Height = 512;
    float4 ClearColor = MapBackColor;
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    int MipLevels = 0;
    string Format = "A8R8G8B8";
    string DefaultEffect = 
        "self = hide;"
        "Map.x = hide;"
        "PostMap.x = hide;"
        
        "* = MapDraw.fxsub;" 
    ;
>;


sampler MapView = sampler_state {
    texture = <MapDrawRT>;
    MINFILTER = ANISOTROPIC;
    MAGFILTER = ANISOTROPIC;
    MIPFILTER = LINEAR;
    AddressU  = Clamp;
    AddressV = Clamp;
    MAXANISOTROPY = 16;
};

////////////////////////////////////////////////////////////////////////////////////////////////

#ifdef MAPFLAME

//�g�e�N�X�`��
texture2D MapFrame <
    string ResourceName = MAPFLAME;
    int MipLevels = 0;
>;
sampler MapFrameSamp = sampler_state {
    texture = <MapFrame>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    MAXANISOTROPY = 16;
};

#endif
///////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD1;   // �e�N�X�`��
    
};

// ���_�V�F�[�_
VS_OUTPUT VS_Map(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    float4 pos = Pos;
    
    pos.xy /= 2;
    pos.x /= ViewportAspect;
    
    pos.z = 0;
    pos.w = 1;
    
    Out.Pos = pos;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 PS_Map(VS_OUTPUT IN) : COLOR0
{
    
    float4 Color;
    
    Color = tex2D( MapView, IN.Tex );
    
    #ifdef MAPFLAME
    float4 FrameColor = tex2D( MapFrameSamp, IN.Tex );
    Color.rgb = lerp(Color.rgb, FrameColor.rgb, FrameColor.a);
    #endif
    
    Color.a *= alpha1;
    
    return Color;
}

///////////////////////////////////////////////////////////////////////////////////////////////

technique MainTec < string MMDPass = "object"; > {
    pass DrawObject {
        VertexShader = compile vs_2_0 VS_Map();
        PixelShader  = compile ps_2_0 PS_Map();
    }
}

technique MainTecSS < string MMDPass = "object_ss"; > {
    pass DrawObject {
        VertexShader = compile vs_2_0 VS_Map();
        PixelShader  = compile ps_2_0 PS_Map();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {
    
}

// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {
    
}

// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {
    
}

