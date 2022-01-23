////////////////////////////////////////////////////////////////////////////////////////////////
//
//  MangaShader.fx ver0.0.6  ���f���̖��敗�`����s���܂�
//  �쐬: �j��P( ���͉��P����full.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

#define TexFile1  "ScreenToon1.png"  // �Z���X�N���[���g�[���e�N�X�`���t�@�C����1
#define TexFile2  "ScreenToon2.png"  // �����X�N���[���g�[���e�N�X�`���t�@�C����2
float ToonLevel1 = 0.4;          // ���ƃg�[���̋��l(0�`1)
float ToonLevel2 = 0.8;          // �g�[���Ɣ��̋��l(0�`1)
float ToonScaling1 = 0.014;      // �Z���g�[���̃X�P�[�����O
float ToonScaling2 = 0.012;      // �����g�[���̃X�P�[�����O
float ToonScalingShadow = 0.012; // �n�ʉe�g�[���̃X�P�[�����O
float EdgeThick = 1.0;           // �Ǝ��`��̃G�b�W����

float3 ToonColor1 = {0.0, 0.0, 0.0};  // �Z���X�N���[���g�[���̐F(RGB)
float3 ToonColor2 = {0.0, 0.0, 0.0};  // �����X�N���[���g�[���̐F(RGB)
float3 FillColor = {0.0, 0.0, 0.0};   // �ׂ��h��̐F(RGB)
float3 ShadowColor = {0.0, 0.0, 0.0}; // �n�ʉe�g�[���̐F(RGB)

#define UseDither  1   // �����g�[���ɑ΂���f�B�U���� 0:���Ȃ�,1;����


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�
////////////////////////////////////////////////////////////////////////////////////////////////

// ���W�ϊ��s��
float4x4 WorldViewProjMatrix  : WORLDVIEWPROJECTION;
float4x4 WorldMatrix          : WORLD;
float4x4 ViewMatrix           : VIEW;
float4x4 ProjMatrix           : PROJECTION;
float4x4 ViewProjMatrix       : VIEWPROJECTION;

float3 LightDirection  : DIRECTION < string Object = "Light"; >;
float3 CameraPosition  : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4 MaterialDiffuse  : DIFFUSE  < string Object = "Geometry"; >;
float3 MaterialAmbient  : AMBIENT  < string Object = "Geometry"; >;
float3 MaterialEmmisive : EMISSIVE < string Object = "Geometry"; >;
float4 EdgeColor        : EDGECOLOR;
static float4 DiffuseColor = MaterialDiffuse;
static float3 AmbientColor = saturate(MaterialAmbient + MaterialEmmisive);

// �e�N�X�`���ގ����[�t�l
float4 TextureAddValue  : ADDINGTEXTURE;
float4 TextureMulValue  : MULTIPLYINGTEXTURE;
float4 SphereAddValue   : ADDINGSPHERETEXTURE;
float4 SphereMulValue   : MULTIPLYINGSPHERETEXTURE;

bool use_subtexture;    // �T�u�e�N�X�`���t���O

bool spadd;    // �X�t�B�A�}�b�v���Z�����t���O

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

// �X�t�B�A�}�b�v�̃e�N�X�`��
texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state {
    texture = <ObjectSphereMap>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

// �g�D�[���}�b�v�̃e�N�X�`��
texture ObjectToonTexture: MATERIALTOONTEXTURE;
sampler ObjToonSampler = sampler_state {
    texture = <ObjectToonTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = NONE;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

// �Z���X�N���[���g�[���e�N�X�`��(�~�b�v�}�b�v������)
texture2D screen_tex1 <
    string ResourceName = TexFile1;
    int MipLevels = 0;
>;
sampler TexSampler1 = sampler_state {
    texture = <screen_tex1>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV = WRAP;
};

// �����X�N���[���g�[���e�N�X�`��(�~�b�v�}�b�v������)
texture2D screen_tex2 <
    string ResourceName = TexFile2;
    int MipLevels = 0;
>;
sampler TexSampler2 = sampler_state {
    texture = <screen_tex2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV = WRAP;
};

#if(UseDither==1)
// �f�B�U�p�^�[���e�N�X�`��1
texture2D dither_tex1 <
    string ResourceName = "DitherPattern1.png";
    int MipLevels = 0;
>;
sampler DitherSmp1 = sampler_state {
    texture = <dither_tex1>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV = WRAP;
};

// �f�B�U�p�^�[���e�N�X�`��2
texture2D dither_tex2 <
    string ResourceName = "DitherPattern2.png";
    int MipLevels = 0;
>;
sampler DitherSmp2 = sampler_state {
    texture = <dither_tex2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV = WRAP;
};

// �f�B�U�p�^�[���e�N�X�`��3
texture2D dither_tex3 <
    string ResourceName = "DitherPattern3.png";
    int MipLevels = 0;
>;
sampler DitherSmp3 = sampler_state {
    texture = <dither_tex3>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV = WRAP;
};

// �f�B�U�p�^�[���e�N�X�`��4
texture2D dither_tex4 <
    string ResourceName = "DitherPattern4.png";
    int MipLevels = 0;
>;
sampler DitherSmp4 = sampler_state {
    texture = <dither_tex4>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV = WRAP;
};

// �f�B�U�p�^�[���e�N�X�`��5
texture2D dither_tex5 <
    string ResourceName = "DitherPattern5.png";
    int MipLevels = 0;
>;
sampler DitherSmp5 = sampler_state {
    texture = <dither_tex5>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV = WRAP;
};

// �f�B�U�p�^�[���e�N�X�`��6
texture2D dither_tex6 <
    string ResourceName = "DitherPattern6.png";
    int MipLevels = 0;
>;
sampler DitherSmp6 = sampler_state {
    texture = <dither_tex6>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV = WRAP;
};

// �f�B�U�p�^�[���e�N�X�`��7
texture2D dither_tex7 <
    string ResourceName = "DitherPattern7.png";
    int MipLevels = 0;
>;
sampler DitherSmp7 = sampler_state {
    texture = <dither_tex7>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV = WRAP;
};
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// �X�N���[���g�[���̓\��t��

// �Z���X�N���[���g�[��
float3 SetToonColor1(float4 VPos)
{
    // �X�N���[���̍��W
    VPos.x = ( VPos.x/VPos.w + 1.0f ) * 0.5f;
    VPos.y = 1.0f - (VPos.y/VPos.w + 1.0f ) * 0.5f;

    // �\��t����e�N�X�`���̐F
    float2 texCoord = float2( VPos.x*ViewportSize.x/ViewportSize.y/ToonScaling1, VPos.y/ToonScaling1 );
    float3 Color = tex2D( TexSampler1, texCoord ).rgb;
    Color += ToonColor1;
    Color = saturate(Color);

    return Color;
}

// �����X�N���[���g�[��
float3 SetToonColor2(float4 VPos, float lightNormal)
{
    // �X�N���[���̍��W
    VPos.x = ( VPos.x/VPos.w + 1.0f ) * 0.5f;
    VPos.y = 1.0f - (VPos.y/VPos.w + 1.0f ) * 0.5f;

    // �\��t����e�N�X�`���̐F
    float2 texCoord = float2( VPos.x*ViewportSize.x/ViewportSize.y/ToonScaling2, VPos.y/ToonScaling2 );
    float4 Color = tex2D( TexSampler2, texCoord );

#if(UseDither==1)
    // �f�B�U�����̒ǉ�
    texCoord = float2( VPos.x*ViewportSize.x/ViewportSize.y/ToonScaling2*0.5f, VPos.y/ToonScaling2*0.5f );
    if(lightNormal > 0.6f){
       Color += tex2D( DitherSmp1, texCoord );
    }else if(lightNormal > 0.55f){
       Color += tex2D( DitherSmp2, texCoord );
    }else if(lightNormal > 0.5f){
       Color += tex2D( DitherSmp3, texCoord );
    }else if(lightNormal > 0.45f){
       Color += tex2D( DitherSmp4, texCoord );
    }else if(lightNormal > 0.4f){
       Color += tex2D( DitherSmp5, texCoord );
    }else if(lightNormal > 0.35f){
       Color += tex2D( DitherSmp6, texCoord );
    }else if(lightNormal > 0.3f){
       Color += tex2D( DitherSmp7, texCoord );
    }
#endif

    Color.rgb += ToonColor2;
    Color = saturate(Color);

    return Color.rgb;
}

// �n�ʉe�g�[��
float4 SetToonColor3(float4 VPos)
{
    // �X�N���[���̍��W
    VPos.x = ( VPos.x/VPos.w + 1.0f ) * 0.5f;
    VPos.y = 1.0f - (VPos.y/VPos.w + 1.0f ) * 0.5f;

    // �\��t����e�N�X�`���̐F
    float2 texCoord = float2( VPos.x*ViewportSize.x/ViewportSize.y/ToonScalingShadow, VPos.y/ToonScalingShadow );
    float4 c = tex2D( TexSampler2, texCoord );
    float alpha = 1.0f - (c.r + c.g + c.b) * 0.33333f;

    return float4(ShadowColor, alpha);
}

////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
    float4 Pos    : POSITION;    // �ˉe�ϊ����W
    float2 Tex    : TEXCOORD1;   // �e�N�X�`��
    float3 Normal : TEXCOORD2;   // �@��
    float2 SpTex  : TEXCOORD3;   // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 VPos   : TEXCOORD4;   // �X�N���[�����W�擾�p�ˉe�ϊ����W
    float4 Color  : COLOR0;      // �f�B�t���[�Y�F
};


////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��(�Ǝ��`��,�G�b�WOFF�ގ��E�A�N�Z�T���ɂ��G�b�W��t����)

// ���_�V�F�[�_
VS_OUTPUT Edge_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // �f�ރ��f���̃��[���h���W�ϊ�
    Pos = mul( Pos, WorldMatrix );

    // ���[���h���W�ϊ��ɂ�钸�_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

    // �J�����Ƃ̋���
    float len = max( length( CameraPosition - Pos.xyz ), 5.0f );

    // ���_��@�������ɉ����o��
    Pos.xyz += Out.Normal * ( pow( len, 0.9f ) * EdgeThick * 0.003f * pow(2.4142f / ProjMatrix._22, 0.7f) );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, ViewProjMatrix );

    // �������ގ��ɃG�b�W��t���Ȃ����߂�alpha�l�����߂Ă���
    Out.Color = DiffuseColor;

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Edge_PS(VS_OUTPUT IN, uniform bool useTexture) : COLOR0
{
    float4 Color = IN.Color;
    if ( useTexture ) {
        // �e�N�X�`���K�p
        Color *= tex2D( ObjTexSampler, IN.Tex );
    }
    // �������ɂ̓G�b�W��t���Ȃ�
    float alpha = Color.a;
    alpha *= step( 0.98f, alpha );
    clip(alpha - 0.005f);

    // �֊s�F�œh��Ԃ�
    return float4(EdgeColor.rgb, alpha);
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, float2 Tex2 : TEXCOORD1, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );

    // ���_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    if ( !useToon ) {
        Out.Color.rgb += max(0, dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb;
    }
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate( Out.Color );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    if ( useSphereMap ) {
        if ( use_subtexture ) {
            // PMX�T�u�e�N�X�`�����W
            Out.SpTex = Tex2;
        } else {
            // �X�t�B�A�}�b�v�e�N�X�`�����W
            float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix ).xy;
            Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
            Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
        }
    }

    // �X�N���[�����W�擾�p
    Out.VPos = Out.Pos;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS(VS_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon, uniform bool useSelfShadow) : COLOR0
{
    float4 Color = IN.Color;

    if ( useTexture ) {
        // �e�N�X�`���K�p
        float4 TexColor = tex2D( ObjTexSampler, IN.Tex );
        // �e�N�X�`���ގ����[�t��
        if ( useSelfShadow ) {
            TexColor.rgb = lerp(1, TexColor * TextureMulValue + TextureAddValue, TextureMulValue.a + TextureAddValue.a).rgb;
        }
        Color *= TexColor;
    }
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�K�p
        float4 TexColor = tex2D(ObjSphareSampler,IN.SpTex);
        // �e�N�X�`���ގ����[�t��
        if ( useSelfShadow ) {
            TexColor.rgb = lerp(spadd?0:1, TexColor * SphereMulValue + SphereAddValue, SphereMulValue.a + SphereAddValue.a).rgb;
        }
        if(spadd) Color.rgb += TexColor.rgb;
        else      Color.rgb *= TexColor.rgb;
        Color.a *= TexColor.a;
    }

    // ���m�N���ɕϊ�
    float v = (Color.r + Color.g + Color.b) * 0.3333f;
    Color.rgb = float3(v, v, v);

    // ���x�Ńx�^,��,�X�N���[���g�[���ɕ�����
    if(v < ToonLevel1){
       Color.rgb = FillColor;
    }else if(v < ToonLevel2){
       // �X�N���[���g�[���F
       if( useToon ) {
           Color.rgb = float3(1.0f, 1.0f, 1.0f);
           float LightNormal = dot( IN.Normal, -LightDirection );
           if(saturate(LightNormal * 16 + 0.5) < 0.5f){
               Color.rgb = saturate( float3(0.8f, 0.8f, 0.8f) + ToonColor1 );
           }
       }
       Color.rgb *= SetToonColor1(IN.VPos);
    }else{
       // ���̓g�[���V�F�[�h�Ŕ�,���X�N���[���g�[���ɕ�����
       Color.rgb = float3(1.0f, 1.0f, 1.0f);
       if( useToon ) {
           float LightNormal = dot( IN.Normal, -LightDirection );
#if(UseDither==1)
           // �f�B�U��������
           if(saturate(LightNormal + 0.45) < 0.7f){
               Color.rgb = SetToonColor2(IN.VPos, LightNormal+0.45);
           }
#else
           // �f�B�U�����Ȃ�
           if(saturate(LightNormal * 16 + 0.5) < 0.5f){
               Color.rgb = SetToonColor2(IN.VPos, 1.0f);
           }
#endif
       }
    }

    return Color;
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
technique MainTec01 < string MMDPass = "object"; bool UseTexture = false; bool useSphereMap = false; bool UseToon = false; >
{
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, false, false);
        PixelShader  = compile ps_2_0 Basic_PS(false, false, false, false);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_2_0 Edge_VS();
        PixelShader  = compile ps_2_0 Edge_PS(false);
    }
}

technique MainTec02 < string MMDPass = "object"; bool UseTexture = false; bool useSphereMap = true; bool UseToon = false; >
{
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, true, false);
        PixelShader  = compile ps_2_0 Basic_PS(false, true, false, false);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_2_0 Edge_VS();
        PixelShader  = compile ps_2_0 Edge_PS(false);
    }
}

technique MainTec03 < string MMDPass = "object"; bool UseTexture = true; bool useSphereMap = false; bool UseToon = false; >
{
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, false, false);
        PixelShader  = compile ps_2_0 Basic_PS(true, false, false, false);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_2_0 Edge_VS();
        PixelShader  = compile ps_2_0 Edge_PS(true);
    }
}

technique MainTec04 < string MMDPass = "object"; bool UseTexture = true; bool useSphereMap = true; bool UseToon = false; >
{
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, true, false);
        PixelShader  = compile ps_2_0 Basic_PS(true, true, false, false);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_2_0 Edge_VS();
        PixelShader  = compile ps_2_0 Edge_PS(true);
    }
}

technique MainTec05 < string MMDPass = "object_ss"; bool UseTexture = false; bool useSphereMap = false; bool UseToon = false; >
{
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, false, false);
        PixelShader  = compile ps_2_0 Basic_PS(false, false, false, true);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_2_0 Edge_VS();
        PixelShader  = compile ps_2_0 Edge_PS(false);
    }
}

technique MainTec06 < string MMDPass = "object_ss"; bool UseTexture = false; bool useSphereMap = true; bool UseToon = false; >
{
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, true, false);
        PixelShader  = compile ps_2_0 Basic_PS(false, true, false, true);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_2_0 Edge_VS();
        PixelShader  = compile ps_2_0 Edge_PS(false);
    }
}

technique MainTec07 < string MMDPass = "object_ss"; bool UseTexture = true; bool useSphereMap = false; bool UseToon = false; >
{
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, false, false);
        PixelShader  = compile ps_2_0 Basic_PS(true, false, false, true);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_2_0 Edge_VS();
        PixelShader  = compile ps_2_0 Edge_PS(true);
    }
}

technique MainTec08 < string MMDPass = "object_ss"; bool UseTexture = true; bool useSphereMap = true; bool UseToon = false; >
{
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, true, false);
        PixelShader  = compile ps_2_0 Basic_PS(true, true, false, true);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_2_0 Edge_VS();
        PixelShader  = compile ps_2_0 Edge_PS(true);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD���f���p�j
technique MainTec09 < string MMDPass = "object"; bool UseTexture = false; bool useSphereMap = false; bool UseToon = true; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, false, true, false);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_2_0 Edge_VS();
        PixelShader  = compile ps_2_0 Edge_PS(false);
    }
}

technique MainTec10 < string MMDPass = "object"; bool UseTexture = false; bool useSphereMap = true; bool UseToon = true; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, true, true, false);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_2_0 Edge_VS();
        PixelShader  = compile ps_2_0 Edge_PS(false);
    }
}

technique MainTec11 < string MMDPass = "object"; bool UseTexture = true; bool useSphereMap = false; bool UseToon = true; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, false, true, false);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_2_0 Edge_VS();
        PixelShader  = compile ps_2_0 Edge_PS(true);
    }
}

technique MainTec12 < string MMDPass = "object"; bool UseTexture = true; bool useSphereMap = true; bool UseToon = true; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, true, true, false);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_2_0 Edge_VS();
        PixelShader  = compile ps_2_0 Edge_PS(true);
    }
}

technique MainTec13 < string MMDPass = "object_ss"; bool UseTexture = false; bool useSphereMap = false; bool UseToon = true; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, false, true, true);
    }
}

technique MainTec14 < string MMDPass = "object_ss"; bool UseTexture = false; bool useSphereMap = true; bool UseToon = true; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, true, true, true);
    }
}

technique MainTec15 < string MMDPass = "object_ss"; bool UseTexture = true; bool useSphereMap = false; bool UseToon = true; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, false, true, true);
    }
}

technique MainTec16 < string MMDPass = "object_ss"; bool UseTexture = true; bool useSphereMap = true; bool UseToon = true; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, true, true, true);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��

struct VS_OUTPUT2 {
    float4 Pos   : POSITION;    // �ˉe�ϊ����W
    float4 VPos  : TEXCOORD4;   // �X�N���[�����W�擾�p�ˉe�ϊ����W
};

// ���_�V�F�[�_
VS_OUTPUT2 Shadow_VS(float4 Pos : POSITION)
{
    VS_OUTPUT2 Out = (VS_OUTPUT2)0;

    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );

    // �X�N���[�����W�擾�p
    Out.VPos = Out.Pos;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Shadow_PS(VS_OUTPUT2 IN) : COLOR
{
    float4 Color = SetToonColor3(IN.VPos);
    return Color;
}

// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {
    pass DrawShadow {
        VertexShader = compile vs_2_0 Shadow_VS();
        PixelShader  = compile ps_2_0 Shadow_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////

