////////////////////////////////////////////////////////////////////////////////////////////////
//
// Material Selector for ObjectLuminous.fx
//    �w�肳�ꂽ�I�u�W�F�N�g�����ׂĒP��F�ŕ`�悵�܂�
//    MME��GUI����A�T�u�Z�b�g���Ƃ̊��蓖�ĂɎg�p�ł��܂�
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ���[�U�[�p�����[�^

//�����F (RGBA�e�v�f 0.0�`1.0)
float4 Emittion_Color
<
   string UIName = "Emittion Color1";
   string UIWidget = "Color";
   bool UIVisible =  true;
   float UIMin = 0.0; float UIMax = 1.0;
> = float4( 0, 0, 1, 1 );

//�Q�C��
float Gain
<
   string UIName = "Gain 1";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0; float UIMax = 5.0;
> = float( 1 );

////////////////////////////////////////////////////////////////////////////////////////////////

float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
static float alpha1 = MaterialDiffuse.a;

bool use_texture;  //�e�N�X�`���̗L��

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state
{
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);


////////////////////////////////////////////////////////////////////////////////////////////////
//�s�N�Z���V�F�[�_

float4 PS_Selected1(float2 Tex : TEXCOORD1) : COLOR {
    float4 color = Emittion_Color;
    float alpha = alpha1;
    if ( use_texture ) alpha *= tex2D( ObjTexSampler, Tex ).a;
    color.rgb *= (Gain * alpha);
    return color;
}

float4 PS_Black(float2 Tex : TEXCOORD1) : COLOR {
    float alpha = alpha1;
    if ( use_texture ) alpha *= tex2D( ObjTexSampler, Tex ).a;
    return float4(0.0, 0.0, 0.0, alpha);
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�e�N�j�b�N

//�Z���t�V���h�E�Ȃ�
technique Tec1 {
    pass Single_Pass {
        AlphaBlendEnable = FALSE;
        PixelShader = compile ps_2_0 PS_Selected1();
    }
}

//�Z���t�V���h�E����
technique Tec1SS < string MMDPass = "object_ss"; > {
    pass Single_Pass {
        AlphaBlendEnable = FALSE;
        PixelShader = compile ps_2_0 PS_Selected1();
    }
}

//�e��֊s�͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

