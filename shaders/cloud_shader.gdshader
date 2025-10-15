shader_type canvas_item;

// 云彩参数
uniform float time : hint_range(0.0, 10.0) = 0.0;
uniform float cloud_speed : hint_range(0.0, 2.0) = 0.5;
uniform float cloud_density : hint_range(0.0, 1.0) = 0.3;
uniform float darkness_intensity : hint_range(0.0, 1.0) = 0.4;
uniform vec4 cloud_color = vec4(0.8, 0.8, 0.9, 1.0);

// 噪声函数
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for(int i = 0; i < 4; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    
    return value;
}

void fragment() {
    // 获取原始颜色
    vec4 original_color = texture(TEXTURE, UV);
    
    // 计算云彩位置（随时间移动）
    vec2 cloud_uv = UV * 3.0;
    cloud_uv.x += time * cloud_speed * 0.1;
    cloud_uv.y += time * cloud_speed * 0.05;
    
    // 生成云彩噪声
    float cloud_noise = fbm(cloud_uv);
    
    // 添加更多层次的噪声
    float cloud_noise2 = fbm(cloud_uv * 2.0 + 10.0);
    float cloud_noise3 = fbm(cloud_uv * 0.5 - 5.0);
    
    // 合并噪声
    float final_cloud = (cloud_noise + cloud_noise2 * 0.5 + cloud_noise3 * 0.3) / 1.8;
    
    // 应用密度阈值
    float cloud_mask = smoothstep(0.3, 0.7, final_cloud) * cloud_density;
    
    // 计算阴影效果（云彩越厚，阴影越深）
    float shadow = cloud_mask * darkness_intensity;
    
    // 应用阴影到原始颜色
    COLOR.rgb = original_color.rgb * (1.0 - shadow);
    COLOR.a = original_color.a;
}