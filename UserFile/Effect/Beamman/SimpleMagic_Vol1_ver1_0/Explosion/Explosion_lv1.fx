//���C���F�ݒ�
float3 MainColor = float3(0,1.25,2);

int ParticleNum = 64;
int SmokeNum = 64;
int FireNum = 64;
int FlashNum = 1;

#define CONTROLLER "Explosion_ColorController.pmx"

float morph_r : CONTROLOBJECT < string name = CONTROLLER; string item = "��"; >;
float morph_g : CONTROLOBJECT < string name = CONTROLLER; string item = "��"; >;
float morph_b : CONTROLOBJECT < string name = CONTROLLER; string item = "��"; >;
float morph_add_si : CONTROLOBJECT < string name = CONTROLLER; string item = "���Z�{��"; >;
float morph_a : CONTROLOBJECT < string name = CONTROLLER; string item = "�����x"; >;
bool bController : CONTROLOBJECT < string name = CONTROLLER; >;

//�[�x�}�b�v�ۑ��e�N�X�`��
shared texture2D SPE_DepthTex : RENDERCOLORTARGET;
sampler2D SPE_DepthSamp = sampler_state {
    texture = <SPE_DepthTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
//�\�t�g�p�[�e�B�N���G���W���g�p�t���O
bool use_spe : CONTROLOBJECT < string name = "SoftParticleEngine.x"; >;


//�����e�N�X�`��
texture2D rndtex <
    string ResourceName = "../Texture/random256x256.bmp";
>;

texture TexLine<
    string ResourceName = "../Texture/Line.png";
>;
sampler SampLine = sampler_state {
    texture = <TexLine>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};
texture TexParticle<
    string ResourceName = "../Texture/Particle.png";
>;
sampler SampParticle = sampler_state {
    texture = <TexParticle>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV  = WRAP;
};
texture TexSmoke<
    string ResourceName = "../Texture/Smoke.png";
>;
sampler SampSmoke = sampler_state {
    texture = <TexSmoke>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV  = WRAP;
};
texture ShockWaveTex<
    string ResourceName = "../Texture/ShockWave.png";
>;
sampler SampShockWave = sampler_state {
    texture = <ShockWaveTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV  = CLAMP;
};
texture NoizeTex<
    string ResourceName = "../Texture/Noize.png";
>;
sampler SampNoize = sampler_state {
    texture = <NoizeTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV  = WRAP;
};
float Tr : CONTROLOBJECT < string name = "(self)";string item = "Tr";>;
float Si : CONTROLOBJECT < string name = "(self)";string item = "Si";>;



sampler rnd = sampler_state {
    texture = <rndtex>;
    MINFILTER = NONE;
    MAGFILTER = NONE;
};

//�����e�N�X�`���T�C�Y
#define RNDTEX_WIDTH  256
#define RNDTEX_HEIGHT 256

//�����擾
float4 getRandom(float rindex)
{
    float2 tpos = float2(rindex % RNDTEX_WIDTH, trunc(rindex / RNDTEX_WIDTH));
    tpos += float2(0.5,0.5);
    tpos /= float2(RNDTEX_WIDTH, RNDTEX_HEIGHT);
    return tex2Dlod(rnd, float4(tpos,0,1));
}


struct VS_OUTPUT {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD1;   // �e�N�X�`��
    float3 Normal     : TEXCOORD2;   // �@��
    float3 Eye        : TEXCOORD3;   // �J�����Ƃ̑��Έʒu
    float index		  : TEXCOORD4;
    float2 AddTex	  : TEXCOORD5;
    float Alpha		  : TEXCOORD6;
	float3 WPos		: TEXCOORD7;
	float4 LastPos	: TEXCOORD8;
};



// ���@�ϊ��s��
float4x4 WorldViewProjMatrix    : WORLDVIEWPROJECTION;
float4x4 WorldMatrix            : WORLD;
float4x4 ViewMatrix				: VIEW;
float4x4 WorldViewMatrixInverse : WORLDVIEWINVERSE;
float4x4 ViewProjMatrix    		: VIEWPROJECTION;

float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float    SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;
float3   MaterialToon      : TOONCOLOR;
float4   EdgeColor         : EDGECOLOR;
float4x4 view_trans_matrix : ViewTranspose;
// ���C�g�F
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = saturate(MaterialAmbient  * LightSpecular + MaterialEmmisive*1);
static float3 SpecularColor = MaterialSpecular * LightSpecular;

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

static float3x3 BillboardMatrix = {
    normalize(WorldViewMatrixInverse[0].xyz),
    normalize(WorldViewMatrixInverse[1].xyz),
    normalize(WorldViewMatrixInverse[2].xyz),
};

float Time : TIME;

////////////////////////////////////////////////////////////////////////////////////////////////
// ���W��2D��]
float2 Rotation2D(float2 pos, float rot)
{
    float x = pos.x * cos(rot) - pos.y * sin(rot);
    float y = pos.x * sin(rot) + pos.y * cos(rot);

    return float2(x,y);
}

VS_OUTPUT ParticleFunc(int index,float4 Pos,float3 Normal,float2 Tex)
{
	float t = 1-Tr;
	t = smoothstep(0,0.5,t);
    VS_OUTPUT Out = (VS_OUTPUT)0;
    Out.Alpha = 1-t;
    Pos.z = 0;
    
	//�ʏ��]
	//��]�s��̍쐬
	float rad = Time;
	float4x4 matRot;
	matRot[0] = float4(cos(rad),sin(rad),0,0); 
	matRot[1] = float4(-sin(rad),cos(rad),0,0); 
	matRot[2] = float4(0,0,1,0); 
	matRot[3] = float4(0,0,0,1); 
	//Pos.xyz = mul(Pos.xyz,matRot);

	//�r���{�[�h��]
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );
	float3 rnd2 = getRandom(index+123);
	Pos.xyz *= 2+rnd2.x*5;

	float3 rnd = getRandom(index);
	float3 add;
	add.x = cos(rnd.x*2*3.1415)*rnd.z*(1-pow(1-t,4));
	add.z = sin(rnd.x*2*3.1415)*rnd.z*(1-pow(1-t,4));
	add.y = (rnd.y)*16*(1-pow(1-t,4));
	
	add.xz *= 32;
	
	add.xyz = (1-pow(1-t,3))*normalize(rnd.xyz-0.5)*rnd2.x*32;



	Pos.xyz += add*0.1;
    
    
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    Out.Tex = Tex;
    
    return Out;
}
VS_OUTPUT FireFunc(int index,float4 Pos,float3 Normal,float2 Tex)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    Pos.xyz = Pos.xzy;
	float t = 1-Tr;
    Out.Alpha = 1.0;
	
	//���[�J�����W��0�_�ɏ�����
	Out.Pos = float4(0,0,0,1);
	
	float4x4 matRot;
	float3 r_rnd = getRandom(index*2);   

	float3 rnd = getRandom(index);
	
	//���[���h���W
	float3 world_pos = WorldMatrix[3].xyz;

	

	//���[���h�̐i�s�x�N�g��
	float3 vec = normalize(WorldMatrix[1].xyz);

	//X����]
	float radx = 1.0+r_rnd.x*0.25;
	matRot[0] = float4(1,0,0,0); 
	matRot[1] = float4(0,cos(radx),sin(radx),0); 
	matRot[2] = float4(0,-sin(radx),cos(radx),0); 
	matRot[3] = float4(0,0,0,1); 

	//vec = mul(vec,matRot);
	
	float3 addrotpos = float3(0,0,1);

	
	//Y����] 
	float rady = r_rnd.y*2*3.1415*180.0;
	matRot[0] = float4(cos(rady),0,-sin(rady),0); 
	matRot[1] = float4(0,1,0,0); 
	matRot[2] = float4(sin(rady),0,cos(rady),0); 
	matRot[3] = float4(0,0,0,1); 
	//vec = mul(vec,matRot);
	addrotpos = mul(addrotpos,matRot);
	//world_pos += addrotpos*15;
	addrotpos = mul(addrotpos,WorldMatrix);
	addrotpos /= Si;
	
	//vec = normalize(vec + addrotpos*5*(r_rnd.z+0.25));
	
	vec = normalize(r_rnd-0.5);
	
	//�J�����̈ʒu
	float3 eyepos = view_trans_matrix[3].xyz;

	//�J��������̃x�N�g��
	float3 eyevec = view_trans_matrix[2].xyz;//normalize(world_pos - eyepos);

	//�i�s�x�N�g���ƃJ�����x�N�g���̊O�ςŉ������𓾂�
	float3 side = normalize(cross(vec,eyevec));

	//�����ɍ��킹�Ċg��
	side *= 0.5+rnd.y*2;
	
	float len = 100*rnd.y;
	//len += pow(sin(t*2*3.1415),1)*50;
	len += (1-pow(1-t,16))*50;
	
	side *= Si*0.1;
	len *= Si*0.1;
	
	//���͍��W��X�l�Ń��[�J���ȍ��E����
	if(Pos.x > 0)
	{
	    //����
	    Out.Pos += float4(side,0);
	}else{
	    //�E��
	    Out.Pos -= float4(side,0);
	}

	//�����ɍ��킹�Đi�s�x�N�g����L�΂�

	//���[�J����Z�l���{�̏ꍇ�A�i�s�x�N�g����������
	if(Pos.z > 0)
	{
	    Out.Pos += float4(vec*len,0);
	}else{
		Out.Pos.y -= 10;
	}
	Out.Pos += float4(world_pos*10,0);
	
	Pos = Out.Pos;
	Pos.xyz *= 0.1;
	
    Out.Pos = mul( Pos, ViewProjMatrix );
    Out.WPos = Pos;
    Out.LastPos = Out.Pos;
    //Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    Out.Tex = Tex;
    
	int Index0 = index;
	
	Index0 %= 8;
	int tw = Index0%2;
	int th = Index0/2;

	Out.AddTex.x += tw*0.5;
	Out.AddTex.y += th*0.5;
    
    Out.Alpha = pow(Tr,8);
    
    return Out;
}
VS_OUTPUT FlashFunc(int index,float4 Pos,float3 Normal,float2 Tex)
{
	float t = 1-Tr;
	t = smoothstep(0,0.5,t);
	//index += ParticleNum;
	
    VS_OUTPUT Out = (VS_OUTPUT)0;
    Out.Alpha = 1-t;
    Pos.z = 0;
	Pos.xyz *= 5+(1-pow(1-t,16))*100;
	Pos.xyz *= 0.2;
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    Out.Tex = Tex;
    
	Out.AddTex.x += 0.5;
	Out.AddTex.y += 0.5;
    
    Out.WPos = mul(Pos,WorldMatrix);
    Out.LastPos = Out.Pos;
    return Out;
}
VS_OUTPUT SmokeFunc(int index,float4 Pos,float3 Normal,float2 Tex)
{
	float t = 1-Tr;
    VS_OUTPUT Out = (VS_OUTPUT)0;
    Pos.z = 0;
    
	//�ʏ��]
	//��]�s��̍쐬
	float rad = Time;
	float4x4 matRot;
	matRot[0] = float4(cos(rad),sin(rad),0,0); 
	matRot[1] = float4(-sin(rad),cos(rad),0,0); 
	matRot[2] = float4(0,0,1,0); 
	matRot[3] = float4(0,0,0,1); 
	//Pos.xyz = mul(Pos.xyz,matRot);

	//�r���{�[�h��]
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );
	float3 rnd = getRandom(index+12.345);
	Pos.xyz *= 5+5*rnd.z;

	float3 add;

	add = normalize(cos(rnd*2*3.1415))*10;
	Pos.xyz *= 10*rnd.z;
	
	Pos.xyz += lerp(0,add,(1-pow(1-t,8)));
    
    
	Pos.xyz *= 0.1;
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    Out.Tex = Tex;
    Out.Alpha = t;
    Out.Alpha *= 1-smoothstep(0,0.75,t);
    
	int Index0 = index;
	
	Index0 %= 16;
	int tw = Index0%4;
	int th = Index0/4;

	Out.AddTex.x += tw*0.25;
	Out.AddTex.y += th*0.25;

    Out.WPos = mul(Pos,WorldMatrix);
    Out.LastPos = Out.Pos;

    return Out;
}
VS_OUTPUT BomFunc(int index,float4 Pos,float3 Normal,float2 Tex)
{
	Normal.xyz = normalize(Pos.xyz);
	float t = 1-Tr;
	
    VS_OUTPUT Out = (VS_OUTPUT)0;
    Out.Alpha = 1.0;
	float3 TexPos = normalize(Pos.xyz);
	Out.Tex.y = TexPos.z / 2 + 0.5;
	
	float par = 2;
    Out.Tex=Tex;
	
	float t2 = smoothstep(0,0.1,t);

	Pos.xyz *= t2*5+t*5;
	Pos.xyz *= 0.1;
	

    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    Out.Normal = normalize(Normal);//normalize( mul( Normal, (float3x3)WorldMatrix ) );
    Out.Alpha = 1-t;

    Out.WPos = mul(Pos,WorldMatrix);
    Out.LastPos = Out.Pos;
    return Out;
}
VS_OUTPUT NoizeFunc(int index,float4 Pos,float3 Normal,float2 Tex)
{
	float t = 1-Tr;	
    
    VS_OUTPUT Out = (VS_OUTPUT)0;
    Out.Alpha = 1.0;
	float3 TexPos = normalize(Pos.xyz);
	Out.Tex.y = TexPos.z / 2 + 0.5;
	
	float par = 2;
    Out.Tex=Tex;
    Out.Tex.y -= t*0.5;
	
	float t2 = smoothstep(0,0.1,t);
	Pos.xyz *= t2*5+t*5;
	Pos.xyz *= 0.1;
	

    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    Out.Normal = normalize(Normal);//normalize( mul( Normal, (float3x3)WorldMatrix ) );
	
	Out.Alpha = 1-t;
    Out.Alpha = lerp(Out.Alpha,0,saturate(Pos.y-4));

    Out.WPos = mul(Pos,WorldMatrix);
    Out.LastPos = Out.Pos;
    return Out;
}

VS_OUTPUT WaveFunc(float4 Pos,float3 Normal,float2 Tex)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
	float t = smoothstep(0,0.75,1-Tr);
	
	float3 PosBuf = Pos;
	
	float in_t = 1-pow(1-t,16);
	t = 1-pow(1-t,32);
	float OutSize = t*15;//((PosBuf.x*0.5+0.5)*0.5);
	float InSize = lerp(0,OutSize,in_t);
	
	if(PosBuf.x > 0)
	{
		Pos.x = cos(PosBuf.z*2*3.1415)*(OutSize);
		Pos.z = sin(PosBuf.z*2*3.1415)*(OutSize);
	}else{
		Pos.x = cos(PosBuf.z*2*3.1415)*(InSize);
		Pos.z = sin(PosBuf.z*2*3.1415)*(InSize);
	}
	Pos.y = 0;
		
	Pos.xyz *= 0.1;
		
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    Out.Tex = Tex;
	
	Out.Alpha = smoothstep(0,0.25,1-t);
    Out.WPos = mul(Pos,WorldMatrix);
    Out.LastPos = Out.Pos;
    return Out;
}
// ���_�V�F�[�_
VS_OUTPUT Main_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0,uniform int mode,int vi: _INDEX)
{
    int index = Pos.z+0.1;
    VS_OUTPUT Out = (VS_OUTPUT)0;
    Out.Alpha = 1.0;
   
    if(mode == 0)
	{
	    Out = ParticleFunc(index,Pos,Normal,Tex);
	    
		if(ParticleNum-1 < index)
		{
			Out.Pos.z = -2;
		}
    }
    if(mode == 1)
    {
	    Out = FireFunc(index,Pos,Normal,Tex);
	    
		if(FireNum-1 < index)
		{
			Out.Pos.z = -2;
		}
    }
    if(mode == 2)
    {
	    Out = FlashFunc(index,Pos,Normal,Tex);
	    
		if(FlashNum-1 < index)
		{
			Out.Pos.z = -2;
		}
    }
    if(mode == 3)
    {
	    Out = SmokeFunc(index,Pos,Normal,Tex);
	    
		if(SmokeNum-1 < index)
		{
			Out.Pos.z = -2;
		}
    }
    if(mode == 4)
    {
	    Out = BomFunc(vi,Pos,Normal,Tex);
    }
    if(mode == 5)
    {
	    Out = NoizeFunc(vi,Pos*float4(1.005,1.005,1.005,1),Normal,Tex*float2(8,1));
    }
    if(mode == 6)
    {
	    Out = WaveFunc(Pos,Normal,Tex);
    }
    Out.index = index;
	return Out;
}

// �s�N�Z���V�F�[�_
float4 Main_PS(VS_OUTPUT IN,uniform int mode) : COLOR0
{
	float t = 1-Tr;
	float4 Col = 1;	
	
	if(bController)
	{
		MainColor.rgb = float3(morph_r,morph_g,morph_b)*(1+morph_add_si);
	}
	
	
	if(mode == 0)
	{
		Col = tex2D(SampParticle,(IN.Tex*0.5)+float2(0.5,0.0));
		Col.a *= (pow(1-t,4));
		Col.rgb *= MainColor;
	}
	if(mode == 1)
	{
		IN.Tex = (IN.Tex.yx*float2(1,0.25));
		IN.Tex.x = 1-IN.Tex.x;
		Col = tex2D(SampLine,IN.Tex);
		Col.a *= (pow(1-t,8));
		Col.rgb *= MainColor*2;
		Col.a *= length(Col.rgb);
	}
	if(mode == 2)
	{
		Col = tex2D(SampParticle,(IN.Tex*0.5)+IN.AddTex);
		Col.a *= (pow(1-t,3));
		Col.rgb *= MainColor;
	}
	if(mode == 3)
	{
		Col = tex2D(SampSmoke,(IN.Tex*0.25)+IN.AddTex);
		Col.a *= (pow(1-t,2));
		Col.rgb *= 0.25;
		Col.rgb += MainColor*pow(Col.a,4)*5;
	}
	if(mode == 4)
	{
		Col.rgb = MainColor;
		float d = tex2D(SampNoize,IN.Tex+float2(1-pow(1-t,2)*0.5,1-pow(1-t,2)*0.5)).r;
		d += tex2D(SampNoize,IN.Tex+float2(0.5+1-pow(1-t,2)*-0.25,1-pow(1-t,2)*0.5)*-0.25).r;
		
		IN.Alpha -= pow(d,4)*pow(t,1.1);
		
		//IN.Alpha = (IN.Alpha > 0.25);
	}
	if(mode == 5)
	{
		Col = tex2D(SampNoize,IN.Tex);
		Col.a = 1-Col.r;
		
		float d = tex2D(SampNoize,IN.Tex+float2(1-pow(1-t,2)*0.5,0)).r;
		d += tex2D(SampNoize,IN.Tex+float2(0.5+1-pow(1-t,2)*-0.25,0)).r;
		IN.Alpha -= d*smoothstep(0.25,1,t);

		Col.a *= tex2D(SampNoize,IN.Tex*0.5).r;
		
		IN.Alpha -= pow(d,4)*pow(t,1.25);

		Col.a *= saturate(1-t*1);
		//IN.Alpha = saturate(pow(IN.Alpha*1,1));
	}
	if(mode == 6)
	{
		IN.Tex.yx = IN.Tex.xy;
		IN.Tex.x *= 8;
		IN.Tex.y *= 0.98;
		Col = tex2D(SampShockWave,IN.Tex);
		Col.a = pow(Col.r,2);
	}
	Col.a *= IN.Alpha;
	Col.a = saturate(lerp(0,Col.a,t*10));
	
	if(use_spe)
	{
		float2 ScTex = IN.LastPos.xyz/IN.LastPos.w;
		ScTex.y *= -1;
		ScTex.xy += 1;
		ScTex.xy *= 0.5;
		
	    // �[�x
	    float dep = length(CameraPosition - IN.WPos);
	    float scrdep = tex2D(SPE_DepthSamp,ScTex).r;
	    
	    float adddep = 1-saturate(length(abs(frac(IN.Tex*4)-0.5)));
	    dep = length(dep-scrdep);
	    dep = smoothstep(0,10,dep);
	    //return float4(dep,0,0,1);
	    Col.a *= dep;
    }
	
	Col.a *= 1-morph_a;
	
    return Col;
}

float4 Clear_VS() : POSITION
{
	return float4(0,0,0,0);
}

float4 Clear_PS() : COLOR0
{
    return 0;
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec0 < string MMDPass = "object"; string Subset = "1"; 
    string Script = 
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=Paritcle;"
	    "Pass=Smoke;"
	    "Pass=Fire;"
	    "Pass=Flash;"
    ;
> {
    pass Paritcle {
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	ZENABLE = TRUE;
    	ZWRITEENABLE = FALSE;
        VertexShader = compile vs_3_0 Main_VS(0);
        PixelShader  = compile ps_3_0 Main_PS(0);
    }
    pass Fire {
    	SRCBLEND = SRCALPHA;
    	//DESTBLEND = ONE;
    	DESTBLEND = INVSRCALPHA;
    	ZENABLE = TRUE;
    	ZWRITEENABLE = FALSE;
    	CULLMODE = NONE;
        VertexShader = compile vs_3_0 Main_VS(1);
        PixelShader  = compile ps_3_0 Main_PS(1);
    }
    pass Flash {
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	ZENABLE = TRUE;
    	ZWRITEENABLE = FALSE;
    	CULLMODE = NONE;
        VertexShader = compile vs_3_0 Main_VS(2);
        PixelShader  = compile ps_3_0 Main_PS(2);
    }
    pass Smoke {
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = INVSRCALPHA;
    	ZENABLE = TRUE;
    	ZWRITEENABLE = FALSE;
        VertexShader = compile vs_3_0 Main_VS(3);
        PixelShader  = compile ps_3_0 Main_PS(3);
    }
}
technique MainTec1 < string MMDPass = "object"; string Subset = "2"; > {
    pass MainPass {
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	ZENABLE = TRUE;
    	ZWRITEENABLE = FALSE;
    	CULLMODE = NONE;
        VertexShader = compile vs_3_0 Main_VS(6);
        PixelShader  = compile ps_3_0 Main_PS(6);
    }
}
technique MainTec2 < string MMDPass = "object"; string Subset = "0";    string Script = 
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=Sphere;"
	    "Pass=SphereBlack;"
    ;
> {
    pass Sphere {
    	SRCBLEND = SRCALPHA;
    	//DESTBLEND = ONE;
    	DESTBLEND = INVSRCALPHA;
    	ZENABLE = TRUE;
    	ZWRITEENABLE = TRUE;
    	CULLMODE = NONE;
        VertexShader = compile vs_3_0 Main_VS(4);
        PixelShader  = compile ps_3_0 Main_PS(4);
    }
    pass SphereBlack {
    	SRCBLEND = SRCALPHA;
    	//DESTBLEND = ONE;
    	DESTBLEND = INVSRCALPHA;
    	ZENABLE = TRUE;
    	ZWRITEENABLE = FALSE;
    	CULLMODE = NONE;
    	//FILLMODE = WIREFRAME;
        VertexShader = compile vs_3_0 Main_VS(5);
        PixelShader  = compile ps_3_0 Main_PS(5);
    }
}
technique MainTecBS0  < string MMDPass = "object_ss";> {
    pass MainPass {
        VertexShader = compile vs_3_0 Main_VS(0);
        PixelShader  = compile ps_3_0 Main_PS(0);
    }
}

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}
technique ZplotTec < string MMDPass = "zplot"; > {}