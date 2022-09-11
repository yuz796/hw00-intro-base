#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Time;
// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.


//float perlin2D(vec2 uv){
//    float surfletSum = 0.f;
//    for(int dx = 0; dx <= 1; ++dx) {
//        for(int dy = 0; dy <= 1; ++dy) {
//            surfletSum += random2(uv);
//        }
//    }
//    return surfletSum;
//}
float random2(vec2 p) {
    return fract(sin(dot(p.xy, vec2(1223.9898, 78435.233))) * 43758.5453);
}

float random(vec2 p)
{
    float x = dot(p,vec2(4371.321,-9137.327));
    return 2.0 * fract(sin(x)*17381.94472) - 1.0;
}

//float fbm(vec2 p){
//    float total = 0.f;
//    float persistence = 1.0f/ 2.0f;
//    float amplitude = persistence;
//    for(int i = 0; i < 8; i++){
//        p = p * 2.0;
//        amplitude *= 0.5;
//        total += random2(p * amplitude);
//   }
//    return total;
//}
float noise(vec2 p){
        return fract(sin(fract(sin(p.x) * (43.13311)) + p.y) * 31.0011);
}

float fbm( vec2 p )
{
    float f = 0.0;
    float gat = 0.0;
    
    for (float octave = 0.; octave < 5.; ++octave)
    {
        float la = pow(2.0, octave);
        float ga = pow(0.5, octave + 1.);
        f += ga*noise( la * p );
        gat += ga;
    }
    
    f = f/gat;
    
    return f;
}

float length2(vec2 p){
    return dot(p,p);
}

float worley(vec2 p) {
    //Set our distance to infinity
        float d = 1e30;
    //For the 9 surrounding grid points
        for (int xo = -1; xo <= 1; ++xo) {
                for (int yo = -1; yo <= 1; ++yo) {
            //Floor our vec2 and add an offset to create our point
                        vec2 tp = floor(p) + vec2(xo, yo);
            //Calculate the minimum distance for this grid point
            //Mix in the noise value too!
                        d = min(d, length2(p - tp - noise(tp)));
                }
        }
        return 3.0*exp(-4.0*abs(2.5*d - 1.0));
}

float fworley(vec2 p) {
    //Stack noise layers
        return sqrt(sqrt(sqrt(
                worley(p*5.0 + 0.05*u_Time) *
                sqrt(worley(p * 50.0 + 0.12 + -0.1*u_Time)) *
                sqrt(sqrt(worley(p * -10.0 + 0.03*u_Time))))));
}

void main()
{
    vec2 pos = fs_Pos.xy;
    float rand = fbm(pos);
    
    float t = fworley(fs_Col.xy / 1500.0);
    
    float r = cos(0.0001 * u_Time + rand) / 2.f + 0.3 * sin(fs_Pos.x * fs_Pos.y) + 0.7;
    float g = sin(0.0010 * u_Time + rand * t) / 3.f + 0.3 * cos(fs_Pos.y) + 0.7;
    float b = sin(0.0016 * u_Time + rand) / 2.f + 0.4 * sin(fs_Pos.z) + 0.7;
    
    vec4 color_final = vec4(r, g, b, 1.0);
    out_Col = color_final;
    
}

