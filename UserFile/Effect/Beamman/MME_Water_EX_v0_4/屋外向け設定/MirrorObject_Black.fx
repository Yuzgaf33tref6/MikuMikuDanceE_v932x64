///////////////////////////////////////////////////////////////////////////////////////////////
// �ݒ�

// ���A�N�Z�T���̃T�C�Y�i�����c�j
//   �����̒l��ύX�����ꍇ�A�K��Mirror.fx�̓����̐ݒ�����킹�ĕύX���邱��
float2 MirrorSize = { 1, 1 };

////////////////////////////////////////////////////////////////////////////////////////////////
// ���֘A

// ���[���h�E�r���[�ϊ��s�����ŁA�t�s����v�Z����B
// - �s�񂪁A���{�X�P�[�����O�A��]�A���s�ړ������܂܂Ȃ����Ƃ�O������Ƃ���B
float4x4 inverseWorldMatrix(float4x4 mat) {
    float scaling = length(mat[0].xyz);
    float scaling_inv2 = 1.0 / (scaling * scaling);
    
    float3x3 mat3x3_inv = transpose((float3x3)mat) * scaling_inv2;
    return float4x4(
        mat3x3_inv[0], 0, 
        mat3x3_inv[1], 0, 
        mat3x3_inv[2], 0, 
        -mul(mat._41_42_43,mat3x3_inv), 1
    );
}

// ���ʂ�`�悷��ꍇ�̃r���[�ϊ��s����v�Z����B
// - ���ʂ�Ώ̖ʂƂ��āA���_�̈ʒu����ѕ����𔽓]�����A�r���[�ϊ��s����v�Z����B
// - �������A���̂܂܂ł͉E��n�ɂȂ��Ă��܂��A�`��ɉe�����o��̂ŁAX�������]���Ă����B
float4x4 calcViewMatrixInMirror(float4x4 matWorld, float4x4 matView) {
    float4x4 res = inverseWorldMatrix(matWorld);
    res._13_23_33_43 *= -1;
    res = mul( res, matWorld );
    res = mul( res, matView );
    res._11_21_31_41 *= -1;
    return res;
}

// D3DXMatrixPerspectiveOffCenterLH�֐����̂܂�
float4x4 calcPerspectiveMatrixOffCenterLH(float l, float r, float b, float t, float zn, float zf) {
    return float4x4(
        2*zn/(r-l) , 0          , 0         ,    0,
        0          , 2*zn/(t-b) , 0         ,    0,
        (l+r)/(l-r), (t+b)/(b-t), zf/(zf-zn),    1,
        0          , 0          , zn*zf/(zn-zf), 0
    );
}

// ���ʂ�`�悷��ꍇ�̎ˉe�ϊ��s����v�Z����B
// - ���̒����`���A������̑O���N���b�v�ʂƂ���悤�ȁA�ˉe�s����v�Z����B
float4x4 calcProjMatrixInMirror(float4x4 matWorld, float4x4 matView, float2 mirror_size) {
    float4x4 matWVinMirror = mul( matWorld, matView );
    
    // �n�_���猩����̂͋��̕\������
    bool face = dot(matWVinMirror[2].xyz,matWVinMirror[3].xyz) < 0;
    
    // ���������ʂɑ΂��Đ����ɂȂ�悤�A��]����B
    float4x4 mirrorVerticalView = 0;
    mirrorVerticalView._11_22_33_44 = 1;
    if ( face ) {
        mirrorVerticalView._11_33 = -1;
    }
    mirrorVerticalView = mul(mirrorVerticalView, matWVinMirror);
    mirrorVerticalView = transpose(mirrorVerticalView);
    mirrorVerticalView = float4x4(
        normalize(mirrorVerticalView[0].xyz), 0, 
        normalize(mirrorVerticalView[1].xyz), 0, 
        normalize(mirrorVerticalView[2].xyz), 0, 
        0,0,0, 1
    );
    
    float4x4 mirrorVerticalWV = mul( matWVinMirror, mirrorVerticalView);
    
    float4 mirror_lb = float4( -mirror_size/2, 0, 1);
    float4 mirror_rt = float4( mirror_size/2, 0, 1);
    if ( face ) {
        mirror_lb.x *= -1;
        mirror_rt.x *= -1;
    }
    
    // ��]��̍��W��ł́A���̊e���_�̍��W�����߂�B
    mirror_lb = mul( mirror_lb, mirrorVerticalWV);
    mirror_rt = mul( mirror_rt, mirrorVerticalWV);
    
    // �ˉe�s����v�Z����
    float4x4 ProjInMirror = calcPerspectiveMatrixOffCenterLH( mirror_lb.x, mirror_rt.x, mirror_lb.y, mirror_rt.y, mirror_lb.z, mirror_lb.z+65535 );
    return mul( mirrorVerticalView, ProjInMirror);
}

float4x4 WorldMatrix  : WORLD;
float4x4 OriginalViewMatrix  : VIEW;
float4x4 MirrorWorldMatrix: CONTROLOBJECT < string Name = "(OffscreenOwner)"; >;

static float4x4 ViewMatrix = calcViewMatrixInMirror(MirrorWorldMatrix, OriginalViewMatrix);
static float4x4 ProjMatrix = calcProjMatrixInMirror(MirrorWorldMatrix, ViewMatrix, MirrorSize );
static float4x4 WorldViewProjMatrix = mul( mul(WorldMatrix, ViewMatrix), ProjMatrix) ;

float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float  Z 		  : TEXCOORD0;    // Z�l
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.Z = length(CameraPosition - mul( Pos, WorldMatrix ));
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS( VS_OUTPUT IN ) : COLOR0
{
    return float4(0,0,0,1);
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec < string MMDPass = "object"; > {
    pass DrawObject
    {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTecBS  < string MMDPass = "object_ss"; > {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}
technique EdgeTec < string MMDPass = "edge"; > {

}
technique ShadowTech < string MMDPass = "shadow";  > {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////
