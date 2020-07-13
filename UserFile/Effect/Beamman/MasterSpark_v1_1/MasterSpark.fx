//�p�����[�^

float param_size : CONTROLOBJECT < string name = "MasterSparkController.pmd"; string item = "����"; >;
float param_length : CONTROLOBJECT < string name = "MasterSparkController.pmd"; string item = "����"; >;


//�����ő�l
float fLen = 0.01;

//����
float fSize = 1.0;

//�L����W��
float fSpread = 1;

//�T�C�Y�����_����
float2 SizeRnd = float2(0.9,1.2);

//�����_�����x
float fRndSpd = 100.0;

//UV�J��Ԃ�
float2 UVRap = float2(1,1);
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;

texture OutTex
<
   string ResourceName = "OutTex.png";
>;
sampler OutTexSamp = sampler_state
{
   Texture = (OutTex);
   ADDRESSU = WRAP;
   ADDRESSV = WRAP;
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
};
texture InTex
<
   string ResourceName = "InTex.png";
>;
sampler InTexSamp = sampler_state
{
   Texture = (InTex);
   ADDRESSU = WRAP;
   ADDRESSV = WRAP;
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
};
//�����e�N�X�`��
texture2D rndtex <
    string ResourceName = "random256x256.bmp";
>;
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

//����
float Time : TIME;


// �ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix      : WORLD;
//�J�������W
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// ���_�V�F�[�_
struct OutVS
{
	float4 Pos : POSITION;
	float2 UV  : texCoord0;
	float2 RevUV : texCoord1;
	float3 Normal : texCoord2;
	float4 LocalPos : texCoord3;
	float  Len		: texCoord4;
};

OutVS Outer_VS(float4 Pos : POSITION, float2 UV : texCoord0, float3 Normal : NORMAL)
{
	OutVS Out;
    float4 bufpos = Pos;
    Out.LocalPos = Pos;
    
    //--�ގ��ԍ�1�@�O����
    //���[�J��Z�����ɐL�΂�
    Pos.z += -pow(bufpos.z*2,8)*fLen*(1-param_length);
    float l = -(bufpos.z/2);
    Pos.xy = lerp(bufpos.xy,normalize(bufpos.xy),l);
    Pos.xy *= (fSize+l*fSpread)*(1-param_size);
    //UV�X�N���[��
    Out.UV = (UV+float2(Time,0))*UVRap;
    Out.RevUV = (0.25+UV-float2(Time,0))*UVRap;
    
    //�@���̏o��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    
    Out.Len = l;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Outer_PS(OutVS IN) : COLOR
{
    // �J�����Ƃ̑��Έʒu
    float3 Eye = CameraPosition - mul( IN.LocalPos, WorldMatrix );
    
    //�e�N�X�`������摜���擾
	float4 Color = tex2D(OutTexSamp,IN.UV);
	
	Color.rgb *= 0.5;
	
	//�������قǐF���キ
	float d = saturate(abs(1-max(0,dot( IN.Normal, normalize(Eye) ))));

	Color.rgb = Color.rgb*0.1 + Color.rgb * pow(d,8);
	Color.rgb *= 20*MaterialDiffuse.a;
	float out_col = tex2D(InTexSamp,IN.UV+float2(0,-Time)).r+tex2D(InTexSamp,IN.RevUV+float2(0,-Time)).r;
	out_col *= 0.5;
	out_col = pow(1-IN.Len,8)*5*pow(out_col,1);
	Color.rgb += out_col;
	return Color;
}

float4 Black_PS(OutVS IN) : COLOR
{
    // �J�����Ƃ̑��Έʒu
    float3 Eye = CameraPosition - mul( IN.LocalPos, WorldMatrix );

	//�������قǐF���キ
	float d = abs(1-max(0,dot( IN.Normal, normalize(Eye) )));

	float4 Color = float4(0,0,0,1);
	return Color;
}
OutVS Inner_VS(float4 Pos : POSITION, float2 UV : texCoord0, float3 Normal : NORMAL)
{
	OutVS Out;
    float4 bufpos = Pos;
    Out.LocalPos = Pos;
    
    //--�ގ��ԍ�1�@�O����
    //���[�J��Z�����ɐL�΂�
    float l = -(bufpos.z/2);
    Pos.z += -pow(bufpos.z*2,8)*fLen*(1-param_length);
    Pos.xy = lerp(bufpos.xy,normalize(bufpos.xy),l);
    Pos.xy *= (fSize+l*fSpread)*(1-param_size);

    Pos.xy *= saturate(l-0.1);
    Pos.xy *= SizeRnd.x + getRandom(Time*fRndSpd)*(SizeRnd.y - SizeRnd.x);
    
    //UV�X�N���[��
    UV.x += -Time;
    UV.y += -Time;
    
    Out.UV = UV*float2(2,2);
    Out.RevUV = -Out.UV;
    //�@���̏o��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    
    Out.Len = l;
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Inner_PS(OutVS IN) : COLOR
{
	float4 Color = tex2D(InTexSamp,IN.UV);
	Color.rgb = saturate(pow(Color.rgb,5)*10)+0.5;
	return Color;
}
// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainPass  < string MMDPass = "object"; > {
    pass DrawBlack {
		ZENABLE = TRUE;
		ZWRITEENABLE = FALSE;
		ALPHABLENDENABLE = TRUE;
		SRCBLEND=SRCALPHA;
		DESTBLEND=INVSRCALPHA;
        VertexShader = compile vs_3_0 Outer_VS();
        PixelShader  = compile ps_3_0 Black_PS();
    }
    pass DrawOuter {
		ZENABLE = TRUE;
		ZWRITEENABLE = FALSE;
		ALPHABLENDENABLE = TRUE;
		SRCBLEND=ONE;
		DESTBLEND=ONE;
        VertexShader = compile vs_3_0 Outer_VS();
        PixelShader  = compile ps_3_0 Outer_PS();
    }
    pass DrawInner {
		ZENABLE = TRUE;
		ZWRITEENABLE = FALSE;
		ALPHABLENDENABLE = TRUE;
		SRCBLEND=ONE;
		DESTBLEND=ONE;
        VertexShader = compile vs_3_0 Inner_VS();
        PixelShader  = compile ps_3_0 Inner_PS();
    }
}
technique MainPass_SS  < string MMDPass = "object_ss"; > {
    pass DrawObject {
		ZENABLE = TRUE;
		ZWRITEENABLE = FALSE;
		ALPHABLENDENABLE = TRUE;
		SRCBLEND=ONE;
		DESTBLEND=ONE;
        VertexShader = compile vs_3_0 Outer_VS();
        PixelShader  = compile ps_3_0 Outer_PS();
    }
}
// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {}
// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {}
// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {}
