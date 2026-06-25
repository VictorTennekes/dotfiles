// Lightning bolt cursor trail.
// Color derived from iCurrentCursorColor: halo → inner → hot-white core.
// 12-segment bolt with secondary branch attached to actual bolt path.

vec3 sRGBToLinear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

vec2 toNorm(vec2 v, float isPos) {
    return (v * 2.0 - iResolution.xy * isPos) / iResolution.y;
}

float sdSeg(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    return length(pa - ba * clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0));
}

float sdRect(vec2 p, vec2 c, vec2 h) {
    vec2 d = abs(p - c) - h;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// 12-segment jagged bolt from a to b.
// Returns min SDF distance; sets branchPt to the actual bolt position at seg 5 (~42%).
float boltDist(vec2 vu, vec2 a, vec2 b, vec2 perp, float px, float s, out vec2 branchPt) {
    float minD = 1e9;
    vec2 prev = a;
    branchPt = mix(a, b, 0.42); // safe fallback
    for (int i = 1; i <= 12; i++) {
        float t        = float(i) / 12.0;
        // pow < 1.0 = flatter envelope = deviation spreads further from endpoints.
        float envelope = pow(sin(t * 3.14159265), 0.75);
        float noise    = (hash(s * 7.31 + float(i) * 4.17) - 0.5) * 2.0;
        vec2  pt       = mix(a, b, t) + perp * noise * 18.0 * px * envelope;
        minD = min(minD, sdSeg(vu, prev, pt));
        if (i == 5) branchPt = pt; // pin branch to real bolt path
        prev = pt;
    }
    return minD;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    vec4 origColor = fragColor;

    vec2 vu = toNorm(fragCoord, 1.0);
    vec4 cc = vec4(toNorm(iCurrentCursor.xy,  1.0), toNorm(iCurrentCursor.zw,  0.0));
    vec4 cp = vec4(toNorm(iPreviousCursor.xy, 1.0), toNorm(iPreviousCursor.zw, 0.0));

    vec2 a = cc.xy - cc.zw * vec2(-0.5, 0.5);
    vec2 b = cp.xy - cp.zw * vec2(-0.5, 0.5);

    float dist       = distance(a, b);
    float cursorSize = max(cc.z, cc.w);
    // Require the jump to cross multiple lines vertically.
    // Prompt-draw sequence (CR → col 0 → draw prompt → col N) is same-row:
    // vDist ≈ 0. Real jumps (mouse click, search, vim G) always change rows.
    float vDist = abs((b - a).y);

    if (dist > 4.0 * cursorSize && vDist > 1.5 * cursorSize) {
        const float DURATION = 0.42;
        float elapsed  = iTime - iTimeCursorChange;
        float progress = clamp(elapsed / DURATION, 0.0, 1.0);

        if (progress < 1.0) {
            float px   = 2.0 / iResolution.y;
            float seed = iTimeCursorChange;
            vec2  dir  = (b - a) / dist;
            vec2  perp = vec2(-dir.y, dir.x);

            // Smooth crackle: crossfade between adjacent 15fps frames.
            float f     = elapsed * 15.0;
            float s0    = seed + floor(f) * 1.337;
            float s1    = seed + (floor(f) + 1.0) * 1.337;
            float blend = smoothstep(0.0, 1.0, fract(f));

            vec2  bp0, bp1;
            float d0    = boltDist(vu, a, b, perp, px, s0, bp0);
            float d1    = boltDist(vu, a, b, perp, px, s1, bp1);
            float mainD = mix(d0, d1, blend);

            // Branch: origin tracks actual bolt path, tip crossfades between frames.
            vec2 bOrigin = mix(bp0, bp1, blend);
            vec2 tip0    = bp0 + perp * (hash(s0*5.77)-0.5)*16.0*px + dir*(hash(s0*2.33)-0.5)*10.0*px;
            vec2 tip1    = bp1 + perp * (hash(s1*5.77)-0.5)*16.0*px + dir*(hash(s1*2.33)-0.5)*10.0*px;
            float branchD = sdSeg(vu, bOrigin, mix(tip0, tip1, blend));

            // Fade + smooth flicker.
            float fade    = 1.0 - progress * progress;
            float flicker = 0.78 + 0.22 * sin(elapsed * 55.0 + seed * 137.0);
            fade *= flicker;
            float fadeB = fade * 0.60; // branch is dimmer

            // Colors from cursor color.
            vec3 cursorLin = sRGBToLinear(iCurrentCursorColor.rgb);
            vec3 cOuter = cursorLin;
            vec3 cInner = mix(cursorLin, vec3(1.0), 0.45);
            vec3 cCore  = mix(cursorLin, vec3(1.0), 0.88);

            vec3 bolt =
                // main bolt
                cOuter * smoothstep(10.0 * px, 0.0, mainD)   * fade  * 0.40 +
                cInner * smoothstep( 2.5 * px, 0.0, mainD)   * fade  * 0.80 +
                cCore  * smoothstep( 0.8 * px, 0.0, mainD)   * fade        +
                // branch (dimmer)
                cOuter * smoothstep( 8.0 * px, 0.0, branchD) * fadeB * 0.35 +
                cInner * smoothstep( 2.0 * px, 0.0, branchD) * fadeB * 0.70 +
                cCore  * smoothstep( 0.8 * px, 0.0, branchD) * fadeB;

            fragColor.rgb = min(fragColor.rgb + bolt, vec3(1.0));

            float sdfCursor = sdRect(vu, a, cc.zw * 0.5);
            fragColor = mix(fragColor, origColor, step(sdfCursor, 0.0));
        }
    }
}
