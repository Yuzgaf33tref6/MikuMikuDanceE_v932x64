// �ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
};


// ���_�V�F�[�_

struct OutVS
{
	float4 Pos : POSITION;
	float2 Tex : TEXCOORD0;
};

OutVS Test_VS(float4 Pos : POSITION,float2 Tex : TEXCOORD0)
{
	OutVS Out;
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.Tex = Tex;
    return Out;
}

float time : TIME;

// �s�N�Z���V�F�[�_
float4 Test_PS(OutVS IN) : COLOR
{
	float4 col = 0;
	float spd = 0.1;
	
	float2 step[4]=
	{
		{0.2,-1},
		{-0.2,-1.5},
		{0.1,-2.0},
		{-0.3,-3.0},
	};
	
	for(int i=0;i<4;i++)
	{
		col += tex2D(ObjTexSampler,IN.Tex + step[i]*(1+time)*spd)*(i+1);
	}
	col.rgb /= 3;
	col.a = 1;
	float a = MaterialDiffuse.a*2;
	a += IN.Tex.y;
	col.a = saturate(sin(-3.1415 + a*3.1415));
	col.a *= pow(MaterialDiffuse.a,8)*cos(IN.Tex.x);
	col.rgb = pow(col.rgb*2,5*MaterialDiffuse.a);
	
    return col;
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainPass {
    pass DrawObject {
    	ZENABLE = true;
    	ZWRITEENABLE = false;
    	SRCBLEND = SRCALPHA;
    	DESTBLEND = ONE;
    	CULLMODE = NONE;
        VertexShader = compile vs_2_0 Test_VS();
        PixelShader  = compile ps_2_0 Test_PS();
    }
}