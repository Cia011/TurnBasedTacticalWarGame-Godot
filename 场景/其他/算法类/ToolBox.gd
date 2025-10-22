class_name ToolBox

# 将字符串转换为Vector2i和Vector2
# 支持格式: "(1,2)", "1,2", "(1.5,2.3)", "1.5,2.3"
static func string_to_vector(str_input: String) -> Dictionary:
	var result = {
		"vector2i": Vector2i.ZERO,
		"vector2": Vector2.ZERO,
		"success": false
	}
	
	# 去除字符串中的空格和括号
	var cleaned_str = str_input.replace(" ", "").replace("(", "").replace(")", "")
	
	# 按逗号分割
	var parts = cleaned_str.split(",")
	
	if parts.size() == 2:
		# 尝试解析为整数（Vector2i）
		var x_int = parts[0].to_int()
		var y_int = parts[1].to_int()
		
		# 尝试解析为浮点数（Vector2）
		var x_float = parts[0].to_float()
		var y_float = parts[1].to_float()
		
		# 检查是否成功转换
		if x_int != 0 or parts[0] == "0":
			result.vector2i = Vector2i(x_int, y_int)
			result.success = true
		else:
			# 如果整数转换失败，尝试浮点数
			if x_float != 0 or parts[0] == "0" or parts[0] == "0.0":
				result.vector2i = Vector2i(int(x_float), int(y_float))
				result.success = true
		
		# 设置Vector2
		if x_float != 0 or parts[0] == "0" or parts[0] == "0.0":
			result.vector2 = Vector2(x_float, y_float)
			result.success = true
		else:
			# 如果浮点数转换失败，使用整数
			result.vector2 = Vector2(x_int, y_int)
			result.success = true
	
	return result

# 简化的方法，只返回Vector2i
static func string_to_vector2i(str_input: String) -> Vector2i:
	var result = string_to_vector(str_input)
	return result.vector2i

# 简化的方法，只返回Vector2
static func string_to_vector2(str_input: String) -> Vector2:
	var result = string_to_vector(str_input)
	return result.vector2
