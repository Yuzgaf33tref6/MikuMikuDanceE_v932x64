//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//�@o_DLAA v0.1
//�@�@�@by ��������iuser/5145841�j
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//�@���[�U�[�p�����[�^

//�@�񓧉߃��[�h�i 0: ���������͂��̂܂܏o�́A1: ���������𔒔w�i�Ƃ��ďo�́j
#define NON_TRANSPARENT 0

//�@�������[�h�i 0: �V���[�g�G�b�W�̂ݏ������܂��i�ᕉ�ׁj�A1: �����O�G�b�W���������܂��i�����l�j�j
#define USE_LONG_RANGE_PROC 0

//�@�g�p�e�N�X�`���i 0: �����e�N�X�`�����g�p�i�ᕉ�ׁj�A1: ���������_���e�N�X�`�����g�p�i��덷�j�j
#define USE_FLOAT_TEXTURE 1


#define lambda 1.0
#define colorThreshold 0.1
#define Epsilon 0.1

//�@�����O�G�b�W�ڂ����̍����䗦
#define DLAA_LONG_ALPHA (1.0/3.0)
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//�@������`

//�@�����_�����O�^�[�Q�b�g�̃N���A�l
#if NON_TRANSPARENT
float4 ClearColor = {1,1,1,1};
#else
float4 ClearColor = {0,0,0,0};
#endif
float ClearDepth  = 1.0;

//�@���m�N�����W��
float3 LumiFactor = {0.29891, 0.58661, 0.11448};

//�@�|�X�g�G�t�F�N�g�錾
float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
> = 0.8;

//�@�X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

static float2 halfPixel = float2(1.0f, 1.0f) / (ViewportSize * 2.0);
static float2 fullPixel = float2(1.0f, 1.0f) / (ViewportSize);

//�@�A�N�Z�T������ݒ�l���擾
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
static float alpha = MaterialDiffuse.a;

float Si : CONTROLOBJECT <string name="(self)"; string item="Si";>;
static const float Scale = Si * 0.1f;

//�@�[�x�o�b�t�@
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	float2 ViewPortRatio = {1.0,1.0};
	string Format = "D24S8";
>;

//�@�I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
	float2 ViewPortRatio = {1.0,1.0};
	int MipLevels = 1;
	bool AntiAlias = true;
#if USE_FLOAT_TEXTURE
	string Format = "A16B16G16R16F";
#else
	string Format = "A8R8G8B8";
#endif
>;
sampler2D ScnSamp = sampler_state {
	texture = <ScnMap>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

//�@�F���iRBG�j�ƃG�b�W����iA�j���i�[���郌���_�[�^�[�Q�b�g
texture2D ScnMap2 : RENDERCOLORTARGET <
	float2 ViewPortRatio = {1.0,1.0};
	int MipLevels = 1;
	bool AntiAlias = true;
#if USE_FLOAT_TEXTURE
	string Format = "A16B16G16R16F";
#else
	string Format = "A8R8G8B8";
#endif
>;
sampler2D ScnSamp2 = sampler_state {
	texture = <ScnMap2>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//�@���_�V�F�[�_
struct VS_OUTPUT {
	float4 Pos			: POSITION;
	float2 Tex			: TEXCOORD0;
};

VS_OUTPUT VS_passDraw( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 
	
	Out.Pos = Pos;
	Out.Tex = Tex + ViewportOffset;
	
	return Out;
}

//�@�P�x�����߂�
#define calcIntensity(a) dot(a,LumiFactor)

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//�@�����O�����W�p�ɃG���W�𔻒肵�ăe�N�X�`���̓����x�Ɋi�[����
float4 PS_passDlaaEdge(float2 inTex: TEXCOORD0) : COLOR
{
	// ���S�Ƃ��̏㉺���E�̃J���[���擾����
	float4	center = tex2D(ScnSamp, inTex);
	float4	left   = tex2D(ScnSamp, inTex + float2(-fullPixel.x, 0.0));
	float4	right  = tex2D(ScnSamp, inTex + float2( fullPixel.x, 0.0));
	float4	top    = tex2D(ScnSamp, inTex + float2(0.0, -fullPixel.y));
	float4	bottom = tex2D(ScnSamp, inTex + float2(0.0,  fullPixel.y));


	// �F�̍��𐮌`���ă��l�Ƃ��ĕ`������
	float4	edge = 4.0 * abs( (left + top + right + bottom) - 4.0 * center );

	//�@�����x�� 0 �ɂȂ�Ȃ��悤�␳
#if USE_FLOAT_TEXTURE
	float a = calcIntensity(edge.rgb) + 0.01;
#else
	float a = calcIntensity(edge.rgb) * (254.0 / 255.0) + (1.0 / 255.0);
#endif

	return float4(center.rgb, a);
}

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//�@Directionally Localized Anti-Aliasing

float4 PS_passDlaaProc(float2 inTex: TEXCOORD0) : COLOR
{
	float4 Color, ColorOrg = tex2D(ScnSamp, inTex);	//�@�����O�̃s�N�Z���J���[���i�[

	float4 center    = tex2D(ScnSamp2, inTex);
	float3 workColor = center.rgb;	//�@�������̃s�N�Z���J���[���i�[

	//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	//�@�V���[�g�G�b�W
	float4 left_s	= tex2D(ScnSamp, inTex + float2(halfPixel.x * -3.0, 0.0));
	float4 right_s	= tex2D(ScnSamp, inTex + float2(halfPixel.x *  3.0, 0.0));
	float4 top_s	= tex2D(ScnSamp, inTex + float2(0.0, halfPixel.y * -3.0));
	float4 bottom_s	= tex2D(ScnSamp, inTex + float2(0.0, halfPixel.y *  3.0));

	float4 w_h = 2.0 * (left_s + right_s);
	float4 w_v = 2.0 * (top_s + bottom_s);

	float4 edge_h = abs(w_h - 4.0 * center) * 0.25;
	float4 edge_v = abs(w_v - 4.0 * center) * 0.25;

	float4 blurred_h = (w_h + 2.0 * center) * (1.0/6.0);
	float4 blurred_v = (w_v + 2.0 * center) * (1.0/6.0);

	float	edge_h_int = calcIntensity(edge_h.rgb);
	float	edge_v_int = calcIntensity(edge_v.rgb);
	float	blurred_h_int = calcIntensity(blurred_h.rgb);
	float	blurred_v_int = calcIntensity(blurred_v.rgb);

	float edge_mask_h = saturate((lambda * edge_h_int - Epsilon) / blurred_v_int);
	float edge_mask_v = saturate((lambda * edge_v_int - Epsilon) / blurred_h_int);

	workColor = lerp(workColor, blurred_h.rgb, edge_mask_v);
	workColor = lerp(workColor, blurred_v.rgb, edge_mask_h);

	float3 shortColor = workColor;	//�@������̃s�N�Z���J���[���i�[

	//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	//�@�����O�G�b�W
#if USE_LONG_RANGE_PROC
	float4	h0 = tex2D(ScnSamp2, inTex + float2(halfPixel.x * -15.0, 0.0));
	float4	h1 = tex2D(ScnSamp2, inTex + float2(halfPixel.x * -11.0, 0.0));
	float4	h2 = tex2D(ScnSamp2, inTex + float2(halfPixel.x * -7.0 , 0.0));
	float4	h3 = tex2D(ScnSamp2, inTex + float2(halfPixel.x * -3.0 , 0.0));
	float4	h4 = tex2D(ScnSamp2, inTex + float2(halfPixel.x *  3.0 , 0.0));
	float4	h5 = tex2D(ScnSamp2, inTex + float2(halfPixel.x *  7.0 , 0.0));
	float4	h6 = tex2D(ScnSamp2, inTex + float2(halfPixel.x *  11.0, 0.0));
	float4	h7 = tex2D(ScnSamp2, inTex + float2(halfPixel.x *  15.0, 0.0));
	float4	v0 = tex2D(ScnSamp2, inTex + float2(0.0, halfPixel.y * -15.0));
	float4	v1 = tex2D(ScnSamp2, inTex + float2(0.0, halfPixel.y * -11.0));
	float4	v2 = tex2D(ScnSamp2, inTex + float2(0.0, halfPixel.y * -7.0 ));
	float4	v3 = tex2D(ScnSamp2, inTex + float2(0.0, halfPixel.y * -3.0 ));
	float4	v4 = tex2D(ScnSamp2, inTex + float2(0.0, halfPixel.y *  3.0 ));
	float4	v5 = tex2D(ScnSamp2, inTex + float2(0.0, halfPixel.y *  7.0 ));
	float4	v6 = tex2D(ScnSamp2, inTex + float2(0.0, halfPixel.y *  11.0));
	float4	v7 = tex2D(ScnSamp2, inTex + float2(0.0, halfPixel.y *  15.0));

	blurred_h = (h0 + h1 + h2 + h3 + h4 + h5 + h6 + h7) / 8.0;
	blurred_v = (v0 + v1 + v2 + v3 + v4 + v5 + v6 + v7) / 8.0;

#if USE_FLOAT_TEXTURE
	blurred_h.a = blurred_h.a - 0.01;
	blurred_v.a = blurred_v.a - 0.01;
#else
	blurred_h.a = (blurred_h.a - (1.0 / 255.0)) / (254.0 / 255.0);
	blurred_v.a = (blurred_v.a - (1.0 / 255.0)) / (254.0 / 255.0);
#endif

	edge_mask_h = saturate( blurred_h.a * 2.0 - 1.0 );
	edge_mask_v = saturate( blurred_v.a * 2.0 - 1.0 );

	if((edge_mask_h > 0.01) || (edge_mask_v > 0.01)) {
		// ���S�Ƃ��̏㉺���E�̃J���[���擾����
		float4	center = tex2D(ScnSamp2, inTex);
		float4	left   = tex2D(ScnSamp2, inTex + float2(-fullPixel.x, 0.0));
		float4	right  = tex2D(ScnSamp2, inTex + float2( fullPixel.x, 0.0));
		float4	top    = tex2D(ScnSamp2, inTex + float2(0.0, -fullPixel.y));
		float4	bottom = tex2D(ScnSamp2, inTex + float2(0.0,  fullPixel.y));

		float	blurred_h_int = calcIntensity( blurred_h.rgb );
		float	blurred_v_int = calcIntensity( blurred_v.rgb );

		float	center_int = calcIntensity( center.rgb );
		float	left_int   = calcIntensity( left.rgb );
		float	right_int  = calcIntensity( right.rgb );
		float	top_int    = calcIntensity( top.rgb );
		float	bottom_int = calcIntensity( bottom.rgb );

		float3	Color_v = shortColor;
		float3	Color_h = shortColor;

		float	hx = saturate( 0.0 + (blurred_h_int - top_int)    / (center_int - top_int) );
		float	hy = saturate( 1.0 + (blurred_h_int - center_int) / (center_int - bottom_int) );
		float	vx = saturate( 0.0 + (blurred_v_int - left_int)   / (center_int - left_int) );
		float	vy = saturate( 1.0 + (blurred_v_int - center_int) / (center_int - right_int) );

		float4	vhxy = float4(vx, vy, hx, hy);
		if( dot(vhxy, 1.0) == 0.0 )
		{
			vhxy = float4(1.0, 1.0, 1.0, 1.0);
		}

		Color_v = lerp( left.rgb,   Color_v, vhxy.x );
		Color_v = lerp( right.rgb,  Color_v, vhxy.y );
		Color_h = lerp( top.rgb,    Color_h, vhxy.z );
		Color_h = lerp( bottom.rgb, Color_h, vhxy.w );

		workColor = lerp( workColor, Color_v, edge_mask_v );
		workColor = lerp( workColor, Color_h, edge_mask_h );

		//�@�����O�����W���Z���ʂ�ݒ�l�Ŏ�߂�
		workColor = lerp(shortColor, workColor, DLAA_LONG_ALPHA * Scale);
	}
#endif

	Color = float4(workColor, ColorOrg.a);

	//�@�A�N�Z�T���̕s�����x�����ɃI���W�i���ƍ���
	return lerp(ColorOrg, Color, alpha);
}

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
technique DLAA <
	string Script = 
		
		"RenderColorTarget0=ScnMap;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
		"ScriptExternal=Color;"
		
		"RenderColorTarget0=ScnMap2;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
		"Pass=DlaaEdgeExec;"

		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
		"Pass=DlaaExec;"
	;
	
> {
	pass DlaaEdgeExec < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		VertexShader = compile vs_2_0 VS_passDraw();
		PixelShader  = compile ps_2_0 PS_passDlaaEdge();
	}
	pass DlaaExec < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		VertexShader = compile vs_3_0 VS_passDraw();
		PixelShader  = compile ps_3_0 PS_passDlaaProc();
	}
}
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
