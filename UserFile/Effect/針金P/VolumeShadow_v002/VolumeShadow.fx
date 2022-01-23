////////////////////////////////////////////////////////////////////////////////////////////////
//
//  VolumeShadow.fx ver0.0.1  �V���h�E�{�����[���@�ɂ��Z���t�V���h�E�`��
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

#define UseMLAA  1   // MLAA�@�ɂ��e���E�̃A���`�G�C���A�V���O����
// 0 : �������Ȃ��A�`�摬�x�D��A�e���E�ɃW���M�[���c��B
// 1 : ��������A�e���E�̃W���M�[�͊ɘa�����B
// ��32bit��MME�ł̓G���[�ɂȂ�̂�0�ɂ��Ă�������


#define MLAA_SampNum   8   // MLAA�����̈�����̃T���v�����O��


#define MODE_HQ  0   // �V���h�E�{�����[���v�Z���ʂ��L�^����o�b�t�@�T�C�Y
// 0 : �X�N���[�����{�T�C�Y
// 1 : �X�N���[����2�{�T�C�Y,�e���E�����ꂢ�łȂ߂炩�ɂȂ�(���Ȃ�d���ł�)


/* �e�X�g�p�V���h�E�{�����[���̉��� */
//#define TestDrawShadowVolume  /* ���s�擪�� // ���������V���h�E�{�����[�����`�悳��܂� */


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,1};
float ClearDepth  = 1.0f;

#if MODE_HQ==1
    #define BUFFRATIO  2.0
#else
    #define BUFFRATIO  1.0
#endif

// �V���h�E�{�����[���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
shared texture2D VolumeShadow_VolumeMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {BUFFRATIO, BUFFRATIO};
    int MipLevels = 0;
    string Format = "D3DFMT_A8R8G8B8";
>;
sampler2D VolumeMapSamp = sampler_state {
    texture = <VolumeShadow_VolumeMap>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �V���h�E�{�����[���̌v�Z�ɗp����[�x�X�e���V���o�b�t�@
shared texture2D VolumeShadow_DepthStencilBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {BUFFRATIO, BUFFRATIO};
    string Format = "D3DFMT_D24S8";
>;

// �V���h�E�{�����[���̃X�e���V���������s���I�t�X�N���[���o�b�t�@
// (�[�x�X�e���V���o�b�t�@�̍X�V�����ŃI�t�X�N���[���o�b�t�@�̓_�~�[,�V���h�E�{�����[���̃e�X�g�`�悠��)
texture VS_StencilRT : OFFSCREENRENDERTARGET <
    string Description = "VolumeShadow.fx�̃I�t�X�N���[���o�b�t�@";
    int Width  = 1;
    int Height = 1;
    int Miplevels = 1;
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "* = VolumeShadow_Stencil.fxsub;";
>;

// �[�x�o�b�t�@���X�V���邽�߂̃I�t�X�N���[���o�b�t�@
// (�[�x�X�e���V���o�b�t�@�̍X�V�����ŃI�t�X�N���[���o�b�t�@�̓_�~�[)
texture VS_DepthRT : OFFSCREENRENDERTARGET <
    string Description = "VolumeShadow.fx�̃I�t�X�N���[���o�b�t�@";
    int Width  = 1;
    int Height = 1;
    int Miplevels = 1;
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "* = VolumeShadow_Depth.fxsub;"
    ;
>;

#ifdef TestDrawShadowVolume
// �V���h�E�{�����[���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D TestVolumeDrawMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    int MipLevels = 1;
    string Format = "D3DFMT_R16F";
>;
sampler2D TestVolumeDrawSamp = sampler_state {
    texture = <TestVolumeDrawMap>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};
#endif

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize/BUFFRATIO);
static float2 SampStep = (float2(1,1)/ViewportSize/BUFFRATIO);


////////////////////////////////////////////////////////////////////////////////////////////////
// ���ʂ̒��_�V�F�[�_

struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

VS_OUTPUT VS_Common( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �X�e���V���o�b�t�@���e���������o��

float4 PS_ShadowDraw() : COLOR
{
    return float4(1,1,1,1);
//    return float4(0,0,1,1);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �e���E�̕␳
// (�[�x�o�b�t�@�X�V���ɒ��_�������o�������ƂŃI�u�W�F�N�g���E�̉e�Ɍ��Ԃ��o���Ă��܂��ւ̑Ώ�)

float4 PS_ShadowEdgeDraw( float2 Tex: TEXCOORD0 ) : COLOR
{
    // �F�f�[�^
    float color0 = tex2D( VolumeMapSamp, Tex ).b;
    float colorL = tex2D( VolumeMapSamp, Tex-float2(SampStep.x,0) ).b;
    float colorR = tex2D( VolumeMapSamp, Tex+float2(SampStep.x,0) ).b;
    float colorB = tex2D( VolumeMapSamp, Tex+float2(0,SampStep.y) ).b;
    float colorT = tex2D( VolumeMapSamp, Tex-float2(0,SampStep.y) ).b;
    float color = color0;

    // ��e�s�N�Z���̗אڕ���2�s�N�Z���ȏ�e�̏ꍇ�͉e�ɂ���
    if(color0 < 0.5){
        color = step(1.5f, colorL+colorR+colorB+colorT);
    }
    // �e�s�N�Z���̗אڕ����S�Ĕ�e�̏ꍇ�͔�e�ɂ���(�v�Z�덷�ɂ��S�~�_�̏���)
    if(color0 > 0.5){
        color = step(0.5f, colorL+colorR+colorB+colorT);
    }

    return float4(color, color, color0, 1);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// MLAA�@�ɂ��e���E�̃A���`�G�C���A�V���O����

#if UseMLAA==1

// �֊s���o���ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D OutlineMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {BUFFRATIO, BUFFRATIO};
    int MipLevels = 1;
    string Format = "D3DFMT_A8R8G8B8";
>;
sampler2D OutlineMapSamp = sampler_state {
    texture = <OutlineMap>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


// �֊s���o
float4 PS_PickupOutline( float2 Tex: TEXCOORD0 ) : COLOR
{
    // �F�f�[�^
    float color0 = tex2D( VolumeMapSamp, Tex ).r;
    float colorL = tex2D( VolumeMapSamp, Tex-float2(SampStep.x,0) ).r;
    float colorR = tex2D( VolumeMapSamp, Tex+float2(SampStep.x,0) ).r;
    float colorB = tex2D( VolumeMapSamp, Tex+float2(0,SampStep.y) ).r;
    float colorT = tex2D( VolumeMapSamp, Tex-float2(0,SampStep.y) ).r;

    // �֊s�t���O
    float bflagL = step(0.5f, abs(color0 - colorL));
    float bflagR = step(0.5f, abs(color0 - colorR));
    float bflagB = step(0.5f, abs(color0 - colorB));
    float bflagT = step(0.5f, abs(color0 - colorT));

    return float4(bflagL, bflagR, bflagB, bflagT);
}


// ���E�F�̃u�����h
float AAColorBlend(float color0, float color1, float2 linePt1, float2 linePt2)
{
    float Color = color0;

    if(linePt1.y * linePt2.y == 0.0f){
        // L�^���E�̏���
        float x1 = (linePt1.y == 0.0f) ? max(linePt1.x, linePt2.x-MLAA_SampNum-1) : linePt1.x;
        float x2 = (linePt2.y == 0.0f) ? min(linePt2.x, linePt1.x+MLAA_SampNum+1) : linePt2.x;
        float h1 = lerp(linePt1.y, linePt2.y, (-0.5f-x1)/(x2-x1));
        float h2 = lerp(linePt1.y, linePt2.y, ( 0.5f-x1)/(x2-x1));
        if(h1 >= 0.0f && h2 >= 0.0f){
            Color = lerp(color0, color1, 0.5f*(h1+h2));
        }else if(h1 > 0.0f){
            Color = lerp(color0, color1, 0.25f*h1);
        }else if(h2 > 0.0f){
            Color = lerp(color0, color1, 0.25f*h2);
        }
    }else if(linePt1.y * linePt2.y < 0.0f){
        // Z�^���E�̏���
        float h1 = lerp(linePt1.y, linePt2.y, (-0.5f-linePt1.x)/(linePt2.x-linePt1.x));
        float h2 = lerp(linePt1.y, linePt2.y, ( 0.5f-linePt1.x)/(linePt2.x-linePt1.x));
        if(h1 >= 0.0f && h2 >= 0.0f){
            Color = lerp(color0, color1, 0.5f*(h1+h2));
        }else if(h1 > 0.0f){
            Color = lerp(color0, color1, 0.25f*h1);
        }else if(h2 > 0.0f){
            Color = lerp(color0, color1, 0.25f*h2);
        }
    }else if(linePt1.y > 0.0f && linePt2.y > 0.0f){
        // U�^���E�̏���
        float h1, h2;
        float x0 = (linePt1.x + linePt2.x) * 0.5f;
        if(x0 >= 0.5f){
            h1 = lerp(linePt1.y, 0.0f, (-0.5f-linePt1.x)/(x0-linePt1.x));
            h2 = lerp(linePt1.y, 0.0f, ( 0.5f-linePt1.x)/(x0-linePt1.x));
            Color = lerp(color0, color1, 0.5f*(h1+h2));
        }else if(x0 <= -0.5f){
            h1 = lerp(0.0f, linePt2.y, (-0.5f-x0)/(linePt2.x-x0));
            h2 = lerp(0.0f, linePt2.y, ( 0.5f-x0)/(linePt2.x-x0));
            Color = lerp(color0, color1, 0.5f*(h1+h2));
        }else{
            h1 = lerp(linePt1.y, 0.0f, (-0.5f-linePt1.x)/(-linePt1.x));
            h2 = lerp(0.0f, linePt2.y,   0.5f           /( linePt2.x));
            Color = lerp(color0, color1, 0.25f*(h1+h2));
        }
    }

    return Color;
}


// LeftRight���E��AA����
float4 PS_MLAA_LeftRight(float2 Tex: TEXCOORD0) : COLOR
{
    float Color  = tex2D( VolumeMapSamp, Tex ).r;
    float colorL = tex2D( VolumeMapSamp, Tex-float2(SampStep.x,0) ).r;
    float colorR = tex2D( VolumeMapSamp, Tex+float2(SampStep.x,0) ).r;
    float Color1 = Color;

    float4 bflag = tex2D( OutlineMapSamp, Tex ); // �֊s�t���O

    // Left���E��AA����
    if(bflag.x > 0.5f){
        // Left���E�̃W���M�[�`����
        float4 bflag0, bflagL;
        float2 linePt1 = float2(-0.5f-MLAA_SampNum, 0.0f);
        float2 linePt2 = float2( 0.5f+MLAA_SampNum, 0.0f);
        [unroll] //���[�v�W�J
        for(int i=MLAA_SampNum; i>=0; i--){
            bflag0 = tex2D( OutlineMapSamp, Tex+float2( 0         , SampStep.y*i) );
            bflagL = tex2D( OutlineMapSamp, Tex+float2(-SampStep.x, SampStep.y*i) );
            if(bflag0.x < 0.5f){
                linePt1 = float2( 0.5f-i, 0.0f);
            }else if(bflag0.z > 0.5f){
                linePt1 = float2(-0.5f-i, 0.5f);
            }else if(bflagL.z > 0.5f){
                linePt1 = float2(-0.5f-i,-0.5f);
            }

            bflag0 = tex2D( OutlineMapSamp, Tex+float2( 0         ,-SampStep.y*i) );
            bflagL = tex2D( OutlineMapSamp, Tex+float2(-SampStep.x,-SampStep.y*i) );
            if(bflag0.x < 0.5f){
                linePt2 = float2(-0.5f+i, 0.0f);
            }else if(bflag0.w > 0.5f){
                linePt2 = float2( 0.5f+i, 0.5f);
            }else if(bflagL.w > 0.5f){
                linePt2 = float2( 0.5f+i,-0.5f);
            }
        }
        // Left���E�F�u�����h
        Color1 = AAColorBlend(Color, colorL, linePt1, linePt2);
    }

    // Right���E��AA����
    if(bflag.y > 0.5f){
        // Right���E�̃W���M�[�`����
        float4 bflag0, bflagR;
        float2 linePt1 = float2(-0.5f-MLAA_SampNum, 0.0f);
        float2 linePt2 = float2( 0.5f+MLAA_SampNum, 0.0f);
        [unroll] //���[�v�W�J
        for(int i=MLAA_SampNum; i>=0; i--){
            bflag0 = tex2D( OutlineMapSamp, Tex+float2( 0         , SampStep.y*i) );
            bflagR = tex2D( OutlineMapSamp, Tex+float2( SampStep.x, SampStep.y*i) );
            if(bflag0.y < 0.5f){
                linePt1 = float2( 0.5f-i, 0.0f);
            }else if(bflag0.z > 0.5f){
                linePt1 = float2(-0.5f-i, 0.5f);
            }else if(bflagR.z > 0.5f){
                linePt1 = float2(-0.5f-i,-0.5f);
            }

            bflag0 = tex2D( OutlineMapSamp, Tex+float2( 0         ,-SampStep.y*i) );
            bflagR = tex2D( OutlineMapSamp, Tex+float2( SampStep.x,-SampStep.y*i) );
            if(bflag0.y < 0.5f){
                linePt2 = float2(-0.5f+i, 0.0f);
            }else if(bflag0.w > 0.5f){
                linePt2 = float2( 0.5f+i, 0.5f);
            }else if(bflagR.w > 0.5f){
                linePt2 = float2( 0.5f+i,-0.5f);
            }
        }
        // Right���E�F�u�����h
        Color1 = AAColorBlend(Color, colorR, linePt1, linePt2);
    }

    return float4(Color, Color1, 0, 1);
}


// BottomTop���E��AA����
float4 PS_MLAA_BottomTop(float2 Tex: TEXCOORD0) : COLOR
{
    float Color  = tex2D( VolumeMapSamp, Tex ).g;
    float colorB = tex2D( VolumeMapSamp, Tex+float2(0,SampStep.y) ).g;
    float colorT = tex2D( VolumeMapSamp, Tex-float2(0,SampStep.y) ).g;
    float Color1 = Color;

    float4 bflag = tex2D( OutlineMapSamp, Tex ); // �֊s�t���O

    // Bottom���E��AA����
    if(bflag.z > 0.5f){
        // Bottom���E�̃W���M�[�`����
        float4 bflag0, bflagB;
        float2 linePt1 = float2(-0.5f-MLAA_SampNum, 0.0f);
        float2 linePt2 = float2( 0.5f+MLAA_SampNum, 0.0f);
        [unroll] //���[�v�W�J
        for(int i=MLAA_SampNum; i>=0; i--){
            bflag0 = tex2D( OutlineMapSamp, Tex+float2(-SampStep.x*i, 0         ) );
            bflagB = tex2D( OutlineMapSamp, Tex+float2(-SampStep.x*i, SampStep.y) );
            if(bflag0.z < 0.5f){
                linePt1 = float2( 0.5f-i, 0.0f);
            }else if(bflag0.x > 0.5f){
                linePt1 = float2(-0.5f-i, 0.5f);
            }else if(bflagB.x > 0.5f){
                linePt1 = float2(-0.5f-i,-0.5f);
            }

            bflag0 = tex2D( OutlineMapSamp, Tex+float2( SampStep.x*i, 0         ) );
            bflagB = tex2D( OutlineMapSamp, Tex+float2( SampStep.x*i, SampStep.y) );
            if(bflag0.z < 0.5f){
                linePt2 = float2(-0.5f+i, 0.0f);
            }else if(bflag0.y > 0.5f){
                linePt2 = float2( 0.5f+i, 0.5f);
            }else if(bflagB.y > 0.5f){
                linePt2 = float2( 0.5f+i,-0.5f);
            }
        }
        // Bottom���E�F�u�����h
        Color1 = AAColorBlend(Color, colorB, linePt1, linePt2);
    }

    // Top���E��AA����
    if(bflag.w > 0.5f){
        // Top���E�̃W���M�[�`����
        float4 bflag0, bflagT;
        float2 linePt1 = float2(-0.5f-MLAA_SampNum, 0.0f);
        float2 linePt2 = float2( 0.5f+MLAA_SampNum, 0.0f);
        [unroll] //���[�v�W�J
        for(int i=MLAA_SampNum; i>=0; i--){
            bflag0 = tex2D( OutlineMapSamp, Tex+float2(-SampStep.x*i, 0         ) );
            bflagT = tex2D( OutlineMapSamp, Tex+float2(-SampStep.x*i, SampStep.y) );
            if(bflag0.w < 0.5f){
                linePt1 = float2( 0.5f-i, 0.0f);
            }else if(bflag0.x > 0.5f){
                linePt1 = float2(-0.5f-i, 0.5f);
            }else if(bflagT.x > 0.5f){
                linePt1 = float2(-0.5f-i,-0.5f);
            }

            bflag0 = tex2D( OutlineMapSamp, Tex+float2( SampStep.x*i, 0         ) );
            bflagT = tex2D( OutlineMapSamp, Tex+float2( SampStep.x*i, SampStep.y) );
            if(bflag0.w < 0.5f){
                linePt2 = float2(-0.5f+i, 0.0f);
            }else if(bflag0.y > 0.5f){
                linePt2 = float2( 0.5f+i, 0.5f);
            }else if(bflagT.y > 0.5f){
                linePt2 = float2( 0.5f+i,-0.5f);
            }
        }
        // Top���E�F�u�����h
        Color1 = AAColorBlend(Color, colorT, linePt1, linePt2);
    }

    return float4(Color1, Color, 0, 1);
}

#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// �e�X�g�p�V���h�E�{�����[���̕`��

#ifdef TestDrawShadowVolume

// �V���h�E�{�����[���̕`�挋�ʂ��o�b�N�A�b�v
float4 PS_CopyDraw( float2 Tex: TEXCOORD0 ) : COLOR
{
    return tex2D( VolumeMapSamp, Tex );
}

// �V���h�E�{�����[����`��
float4 PS_TestDraw( float2 Tex: TEXCOORD0 ) : COLOR
{
    //float4 Color = tex2D( VolumeMapSamp, Tex );
    float4 Color = float4(0.8f, 1.0f, 0.0f, 0.7f*tex2D( TestVolumeDrawSamp, Tex ).r);
    return Color;
}

#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTech <
    string Script = 
        #ifdef TestDrawShadowVolume
        // �V���h�E�{�����[���̕`�挋�ʂ��o�b�N�A�b�v(�e�X�g�p)
        "RenderColorTarget0=TestVolumeDrawMap;"
            "RenderDepthStencilTarget=VolumeShadow_DepthStencilBuffer;"
            "ClearSetColor=ClearColor;"
            "Clear=Color;"
            "Pass=CopyDraw;"
        #endif

        // �X�e���V���o�b�t�@�̌��ʂ������o��(�Օ��}�b�v�쐬)
        "RenderColorTarget0=VolumeShadow_VolumeMap;"
            "RenderDepthStencilTarget=VolumeShadow_DepthStencilBuffer;"
            "ClearSetColor=ClearColor;"
            "Clear=Color;"
            "Pass=DrawShadowVolume;"
            "Pass=ShadowEdgeDraw;"

        #if UseMLAA==1
        // �e���E�̃A���`�G�C���A�V���O����
        "RenderColorTarget0=OutlineMap;"
        "RenderDepthStencilTarget=VolumeShadow_DepthStencilBuffer;"
            "ClearSetColor=ClearColor;"
            "Clear=Color;"
            "Pass=PickupOutline;"
        "RenderColorTarget0=VolumeShadow_VolumeMap;"
        "RenderDepthStencilTarget=VolumeShadow_DepthStencilBuffer;"
            "Pass=MLAA_LeftRight;"
            "Pass=MLAA_BottomTop;"
        #endif

        // �I���W�i���̕`��
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "ScriptExternal=Color;"
            #ifdef TestDrawShadowVolume
            // �V���h�E�{�����[����`��(�e�X�g�p)
            "Pass=TestDraw;"
            #endif

        // ���t���[���̂��ߐ[�x�X�e���V���o�b�t�@���N���A
        "RenderColorTarget0=VolumeShadow_VolumeMap;"
            "RenderDepthStencilTarget=VolumeShadow_DepthStencilBuffer;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Depth;"
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
        ; >
{
    pass DrawShadowVolume < string Script= "Draw=Buffer;"; > {
        // �X�e���V���o�b�t�@�̌��ʂ������o��
        ZEnable = FALSE;
        StencilEnable = TRUE;
        StencilRef = 0x1;
        StencilMask = 0xffffffff;
        StencilWriteMask = 0xffffffff;
        StencilFunc = LESS;
        StencilFail = KEEP;
        StencilZFail = KEEP;
        StencilPass = KEEP;
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Common();
        PixelShader  = compile ps_2_0 PS_ShadowDraw();
    }
    pass ShadowEdgeDraw < string Script= "Draw=Buffer;"; > {
        ZEnable = FALSE;
        ZWriteEnable = FALSE;
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Common();
        PixelShader  = compile ps_2_0 PS_ShadowEdgeDraw();
    }

    #if UseMLAA==1
    pass PickupOutline < string Script= "Draw=Buffer;"; > {
        ZEnable = FALSE;
        ZWriteEnable = FALSE;
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Common();
        PixelShader  = compile ps_2_0 PS_PickupOutline();
    }
    pass MLAA_LeftRight < string Script= "Draw=Buffer;"; > {
        ZEnable = FALSE;
        ZWriteEnable = FALSE;
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_MLAA_LeftRight();
    }
    pass MLAA_BottomTop < string Script= "Draw=Buffer;"; > {
        ZEnable = FALSE;
        ZWriteEnable = FALSE;
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_MLAA_BottomTop();
    }
    #endif

    #ifdef TestDrawShadowVolume
    pass CopyDraw < string Script= "Draw=Buffer;"; > {
        ZEnable = FALSE;
        ZWriteEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Common();
        PixelShader  = compile ps_2_0 PS_CopyDraw();
    }
    pass TestDraw < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = TRUE;
        VertexShader = compile vs_2_0 VS_Common();
        PixelShader  = compile ps_2_0 PS_TestDraw();
    }
    #endif
}

////////////////////////////////////////////////////////////////////////////////////////////////
