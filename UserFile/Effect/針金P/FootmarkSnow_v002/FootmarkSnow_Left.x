xof 0302txt 0064
template Header {
 <3D82AB43-62DA-11cf-AB39-0020AF71E433>
 WORD major;
 WORD minor;
 DWORD flags;
}

template Vector {
 <3D82AB5E-62DA-11cf-AB39-0020AF71E433>
 FLOAT x;
 FLOAT y;
 FLOAT z;
}

template Coords2d {
 <F6F23F44-7686-11cf-8F52-0040333594A3>
 FLOAT u;
 FLOAT v;
}

template Matrix4x4 {
 <F6F23F45-7686-11cf-8F52-0040333594A3>
 array FLOAT matrix[16];
}

template ColorRGBA {
 <35FF44E0-6C7C-11cf-8F52-0040333594A3>
 FLOAT red;
 FLOAT green;
 FLOAT blue;
 FLOAT alpha;
}

template ColorRGB {
 <D3E16E81-7835-11cf-8F52-0040333594A3>
 FLOAT red;
 FLOAT green;
 FLOAT blue;
}

template IndexedColor {
 <1630B820-7842-11cf-8F52-0040333594A3>
 DWORD index;
 ColorRGBA indexColor;
}

template Boolean {
 <4885AE61-78E8-11cf-8F52-0040333594A3>
 WORD truefalse;
}

template Boolean2d {
 <4885AE63-78E8-11cf-8F52-0040333594A3>
 Boolean u;
 Boolean v;
}

template MaterialWrap {
 <4885AE60-78E8-11cf-8F52-0040333594A3>
 Boolean u;
 Boolean v;
}

template TextureFilename {
 <A42790E1-7810-11cf-8F52-0040333594A3>
 STRING filename;
}

template Material {
 <3D82AB4D-62DA-11cf-AB39-0020AF71E433>
 ColorRGBA faceColor;
 FLOAT power;
 ColorRGB specularColor;
 ColorRGB emissiveColor;
 [...]
}

template MeshFace {
 <3D82AB5F-62DA-11cf-AB39-0020AF71E433>
 DWORD nFaceVertexIndices;
 array DWORD faceVertexIndices[nFaceVertexIndices];
}

template MeshFaceWraps {
 <4885AE62-78E8-11cf-8F52-0040333594A3>
 DWORD nFaceWrapValues;
 Boolean2d faceWrapValues;
}

template MeshTextureCoords {
 <F6F23F40-7686-11cf-8F52-0040333594A3>
 DWORD nTextureCoords;
 array Coords2d textureCoords[nTextureCoords];
}

template MeshMaterialList {
 <F6F23F42-7686-11cf-8F52-0040333594A3>
 DWORD nMaterials;
 DWORD nFaceIndexes;
 array DWORD faceIndexes[nFaceIndexes];
 [Material]
}

template MeshNormals {
 <F6F23F43-7686-11cf-8F52-0040333594A3>
 DWORD nNormals;
 array Vector normals[nNormals];
 DWORD nFaceNormals;
 array MeshFace faceNormals[nFaceNormals];
}

template MeshVertexColors {
 <1630B821-7842-11cf-8F52-0040333594A3>
 DWORD nVertexColors;
 array IndexedColor vertexColors[nVertexColors];
}

template Mesh {
 <3D82AB44-62DA-11cf-AB39-0020AF71E433>
 DWORD nVertices;
 array Vector vertices[nVertices];
 DWORD nFaces;
 array MeshFace faces[nFaces];
 [...]
}

Header{
1;
0;
1;
}

Mesh {
 26;
 -0.03886;-0.00727;0.03430;,
 -0.04110;-0.00727;-0.00034;,
 -0.04113;0.04600;-0.00039;,
 -0.03890;0.04600;0.03425;,
 0.03032;-0.00727;0.04319;,
 -0.00516;-0.00727;0.05698;,
 -0.00520;0.04600;0.05693;,
 0.03028;0.04600;0.04314;,
 0.05110;-0.00727;-0.00998;,
 0.05107;0.04600;-0.01003;,
 -0.02751;-0.00727;-0.06601;,
 -0.02755;0.04600;-0.06606;,
 0.05863;-0.00727;-0.11126;,
 0.05859;0.04600;-0.11131;,
 -0.04661;-0.00727;-0.12116;,
 -0.04665;0.04600;-0.12121;,
 0.05144;-0.00727;-0.17972;,
 0.05140;0.04600;-0.17976;,
 -0.05472;-0.00727;-0.17759;,
 -0.05476;0.04600;-0.17764;,
 0.03019;-0.00727;-0.23433;,
 0.03016;0.04600;-0.23438;,
 -0.04413;-0.00727;-0.22974;,
 -0.04417;0.04600;-0.22979;,
 -0.01209;-0.00727;-0.25519;,
 -0.01212;0.04600;-0.25524;;
 
 35;
 4;0,1,2,3;,
 3;1,0,4;,
 4;5,0,3,6;,
 4;4,5,6,7;,
 3;0,5,4;,
 4;8,4,7,9;,
 3;1,4,8;,
 4;1,10,11,2;,
 3;10,1,8;,
 4;12,8,9,13;,
 3;10,8,12;,
 4;10,14,15,11;,
 3;14,10,12;,
 4;16,12,13,17;,
 3;14,12,16;,
 4;14,18,19,15;,
 3;18,14,16;,
 4;20,16,17,21;,
 3;18,16,20;,
 4;18,22,23,19;,
 3;22,18,20;,
 4;22,24,25,23;,
 4;24,20,21,25;,
 3;24,22,20;,
 3;2,3,7;,
 3;3,6,7;,
 3;2,7,9;,
 3;11,2,9;,
 3;11,9,13;,
 3;15,11,13;,
 3;15,13,17;,
 3;19,15,17;,
 3;19,17,21;,
 3;23,19,21;,
 3;25,23,21;;
 
 MeshMaterialList {
  3;
  35;
  1,
  0,
  1,
  1,
  0,
  1,
  0,
  1,
  0,
  1,
  0,
  1,
  0,
  1,
  0,
  1,
  0,
  1,
  0,
  1,
  0,
  1,
  1,
  0,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2;;
  Material {
   0.700000;0.700000;0.700000;1.000000;;
   5.000000;
   0.100000;0.100000;0.100000;;
   0.100000;0.100000;0.100000;;
  }
  Material {
   0.787451;0.774902;0.800000;1.000000;;
   5.000000;
   0.100000;0.100000;0.100000;;
   0.393725;0.387451;0.400000;;
  }
  Material {
   0.800000;0.800000;0.800000;0.010000;;
   5.000000;
   0.000000;0.000000;0.000000;;
   0.000000;0.000000;0.000000;;
  }
 }
 MeshNormals {
  14;
  0.110679;-0.000810;-0.993856;,
  -0.706383;-0.001112;-0.707829;,
  -0.975148;-0.000862;-0.221551;,
  -0.999884;-0.000668;0.015233;,
  -0.971854;-0.000453;0.235583;,
  -0.737298;0.000099;0.675567;,
  0.106158;0.000958;0.994349;,
  0.852531;0.001047;0.522675;,
  0.999585;0.000707;0.028790;,
  0.971795;0.000453;-0.235827;,
  0.997907;0.000623;-0.064670;,
  0.997565;0.000742;0.069739;,
  0.867121;0.000148;-0.498098;,
  0.000000;1.000000;0.000000;;
  35;
  4;12,11,11,12;,
  3;13,13,13;,
  4;0,12,12,0;,
  4;1,0,0,1;,
  3;13,13,13;,
  4;2,1,1,2;,
  3;13,13,13;,
  4;11,10,10,11;,
  3;13,13,13;,
  4;3,2,2,3;,
  3;13,13,13;,
  4;10,9,9,10;,
  3;13,13,13;,
  4;4,3,3,4;,
  3;13,13,13;,
  4;9,8,8,9;,
  3;13,13,13;,
  4;5,4,4,5;,
  3;13,13,13;,
  4;8,7,7,8;,
  3;13,13,13;,
  4;7,6,6,7;,
  4;6,5,5,6;,
  3;13,13,13;,
  3;13,13,13;,
  3;13,13,13;,
  3;13,13,13;,
  3;13,13,13;,
  3;13,13,13;,
  3;13,13,13;,
  3;13,13,13;,
  3;13,13,13;,
  3;13,13,13;,
  3;13,13,13;,
  3;13,13,13;;
 }
 MeshTextureCoords {
  26;
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;,
  0.000000;0.000000;;
 }
}
