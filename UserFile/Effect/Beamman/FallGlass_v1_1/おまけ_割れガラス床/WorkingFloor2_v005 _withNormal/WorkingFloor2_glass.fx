////////////////////////////////////////////////////////////////////////////////////////////////
//
//  WorkingFloor2.fx ver0.0.5  �I�t�X�N���[�������_���g�������ʋ����`��C���Ɏd���������܂�
//  �쐬: �j��P( ���͉��P����Mirror.fx, full.fx,���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////

// ���ʋ����`��̃I�t�X�N���[���o�b�t�@
texture WorkingFloorRT : OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for WorkingFloor.fx";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;"

//********** �����ɋ����`�悳����I�u�W�F�N�g���w�肵�Ă������� **********

        "*.pmd = WF_Object.fx;"
        "*.pmx = WF_Object.fx;"
        "*.vac = WF_Object.fx;"
        "negi.x = WF_Object.fx;"

//************************************************************************

        "* = hide;" 
    ;
>;

// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�


texture2D GlassTex <
    string ResourceName = "tex.png";
>;

sampler GlassSamp = sampler_state {
    texture = <GlassTex>;
	FILTER = LINEAR;
};
texture2D Glass_AddTex <
    string ResourceName = "add.png";
>;

sampler Glass_AddSamp = sampler_state {
    texture = <Glass_AddTex>;
	FILTER = LINEAR;
};
texture2D Glass_NormalTex <
    string ResourceName = "normal.png";
>;

sampler Glass_NormalSamp = sampler_state {
    texture = <Glass_NormalTex>;
	FILTER = LINEAR;
};


////////////////////////////////////////////////////////////////////////////////////////////////
sampler WorkingFloorView = sampler_state {
    texture = <WorkingFloorRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// ���W�ϊ��s��
float4x4 WorldMatrix    : WORLD;
float4x4 ViewProjMatrix : VIEWPROJECTION;
float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
static float AcsAlpha = MaterialDiffuse.a;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5f, 0.5f)/ViewportSize);

////////////////////////////////////////////////////////////////////////////////////////////////
//���ʋ����`��

struct VS_OUTPUT {
    float4 Pos  : POSITION;
    float4 VPos : TEXCOORD1;
    float2 Tex	: TEXCOORD2;
    float4 WPos : TEXCOORD3;
};

VS_OUTPUT VS_Mirror(float4 Pos : POSITION,float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    Pos = mul( Pos, WorldMatrix );
    Pos.y += 0.01f;
    Out.WPos = Pos;
    Pos = mul( Pos, ViewProjMatrix );

    Out.Pos = Pos;
    Out.VPos = Pos;
    Out.Tex = Tex;

    return Out;
}

float4 PS_Mirror(VS_OUTPUT IN) : COLOR
{

	IN.Tex *= 16;
    float4 col = tex2D( GlassSamp, IN.Tex );
    float4 nor = tex2D( Glass_NormalSamp, IN.Tex );
    nor.xyz = nor.xyz*2.0-1.0;
    float add = tex2D( Glass_AddSamp, IN.Tex ).r;
    nor.z = 1;
    nor.xy *= 10;
	nor.xyz = normalize(nor.xzy);
	nor.xyz *= nor.a;
    // �J�����Ƃ̑��Έʒu
    float3 Eye = CameraPosition - IN.WPos.xyz;
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(nor) )), 8 ) * 16;
    

    // �����̃X�N���[���̍��W(���E���]���Ă���̂Ō��ɖ߂�)
    float2 texCoord = float2( 1.0f - ( IN.VPos.x/IN.VPos.w + 1.0f ) * 0.5f,
                              1.0f - ( IN.VPos.y/IN.VPos.w + 1.0f ) * 0.5f ) + ViewportOffset;
	
	texCoord += nor.xz*0.02;
    // �����̐F
    float4 Color = tex2D(WorkingFloorView, texCoord);
    Color.a = nor.a;//*= AcsAlpha;
	Color.a = saturate(Color.a);
	Color.rgb *= col.rgb;
	Color.rgb += Specular;
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�e�N�j�b�N

technique MainTec{
    pass DrawObject{
        VertexShader = compile vs_2_0 VS_Mirror();
        PixelShader  = compile ps_2_0 PS_Mirror();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////



