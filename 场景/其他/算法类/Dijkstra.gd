
class_name Dijkstra

# 表示网格中的一个节点
class GridNode:
	var position: Vector2i
	var cost: float
	var previous: Vector2i
	var visited: bool
	
	func _init(pos: Vector2i, c: float = INF, prev: Vector2i = Vector2i(-1, -1)):
		position = pos
		cost = c
		previous = prev
		visited = false



#构建 二维数组，表示网格的通行成本

#所有移动相关逻辑可在构建数组时实现
static func _build_grid(rect:Rect2i,grid_data_dict : Dictionary[Vector2i,BattleGrid])->Array[Array]:
	#rect.position
	#rect.end

	var grid_width = rect.size.x
	var grid_height = rect.size.y

	var grid:Array[Array]
	#创建空数组
	for y in grid_height:
		var row :Array[float] = []
		row.resize(grid_width)
		row.fill(INF)
		grid.append(row)
	#构造数组
	for y in grid_height:
		for x in grid_width:
			var grid_position:Vector2i = Vector2i(x,y)
			if grid_data_dict.has(grid_position):
				grid[y][x] = grid_data_dict[grid_position].move_cost
	return grid


# 计算从起点到所有可达点的最短路径
# grid: 二维数组，表示网格的通行成本（INF 表示不可通行）
# start: 起始位置
# max_cost: 最大移动成本（可选，用于限制移动范围）
# 返回: 包含所有可达位置和路径的字典/
static func find_all_paths(grid: Array, start: Vector2i, max_cost: float = INF) -> Dictionary:
	var grid_width = grid.size()
	if grid_width == 0:
		return {}
	var grid_height = grid[0].size()
	
	# 初始化节点网格
	var nodes:Dictionary[Vector2i,GridNode] = {}
	for x in range(grid_width):
		for y in range(grid_height):
			nodes[Vector2i(x, y)] = GridNode.new(Vector2i(x, y))
	
	# 设置起点
	nodes[start].cost = 0.0
	
	# 未访问节点集合
	var unvisited = []
	unvisited.append(start)
	
	# 主循环
	while not unvisited.is_empty():
		# 找到成本最低的未访问节点
		var current_pos = _find_lowest_cost_node(unvisited, nodes)
		var current_node = nodes[current_pos]
		
		# 标记为已访问
		current_node.visited = true
		unvisited.erase(current_pos)
		
		# 如果达到最大成本，停止探索
		if current_node.cost > max_cost:
			continue
		
		# 检查所有相邻节点
		var neighbors = _get_neighbors(current_pos, grid_width, grid_height)
		for neighbor_pos in neighbors:
			var neighbor_node = nodes[neighbor_pos]
			
			# 跳过已访问节点
			if neighbor_node.visited:
				continue
			
			# 检查是否可通行
			var move_cost = grid[neighbor_pos.x][neighbor_pos.y]
			if move_cost == INF:
				continue
			
			# 计算新成本
			var new_cost = current_node.cost + move_cost
			
			# 如果找到更短的路径，更新节点
			if new_cost < neighbor_node.cost:
				neighbor_node.cost = new_cost
				neighbor_node.previous = current_pos
				
				# 添加到未访问列表
				if not unvisited.has(neighbor_pos):
					unvisited.append(neighbor_pos)
	
	# 构建结果
	return _build_result(nodes, start, max_cost)

# 计算从起点到终点的最短路径
# grid: 二维数组，表示网格的通行成本
# start: 起始位置
# end: 目标位置
# 返回: 路径数组（从起点到终点）和总成本，如果不可达则返回空数组和INF
static func find_path(grid: Array, start: Vector2i, end: Vector2i) -> Dictionary:
	var grid_width = grid.size()
	if grid_width == 0:
		return {"path": [], "cost": INF}
	var grid_height = grid[0].size()
	
	# 检查目标是否在网格内
	if end.x < 0 or end.x >= grid_width or end.y < 0 or end.y >= grid_height:
		return {"path": [], "cost": INF}
	
	# 检查目标是否可通行
	if grid[end.x][end.y] == INF:
		return {"path": [], "cost": INF}
	
	# 初始化节点网格
	var nodes:Dictionary[Vector2i,GridNode] = {}
	for x in range(grid_width):
		for y in range(grid_height):
			nodes[Vector2i(x, y)] = GridNode.new(Vector2i(x, y))
	
	# 设置起点
	nodes[start].cost = 0.0
	
	# 未访问节点集合
	var unvisited = []
	unvisited.append(start)
	
	# 主循环
	while not unvisited.is_empty():
		# 找到成本最低的未访问节点
		var current_pos = _find_lowest_cost_node(unvisited, nodes)
		var current_node = nodes[current_pos]
		
		# 如果到达目标，提前结束
		if current_pos == end:
			break
		
		# 标记为已访问
		current_node.visited = true
		unvisited.erase(current_pos)
		
		# 检查所有相邻节点
		var neighbors = _get_neighbors(current_pos, grid_width, grid_height)
		for neighbor_pos in neighbors:
			var neighbor_node = nodes[neighbor_pos]
			
			# 跳过已访问节点
			if neighbor_node.visited:
				continue
			
			# 检查是否可通行
			var move_cost = grid[neighbor_pos.x][neighbor_pos.y]
			if move_cost == INF:
				continue
			
			# 计算新成本
			var new_cost = current_node.cost + move_cost
			
			# 如果找到更短的路径，更新节点
			if new_cost < neighbor_node.cost:
				neighbor_node.cost = new_cost
				neighbor_node.previous = current_pos
				
				# 添加到未访问列表
				if not unvisited.has(neighbor_pos):
					unvisited.append(neighbor_pos)
	
	# 构建路径
	return _build_path(nodes, start, end)

# 找到成本最低的未访问节点
static func _find_lowest_cost_node(unvisited: Array, nodes: Dictionary) -> Vector2i:
	var lowest_cost = INF
	var lowest_node = unvisited[0]
	
	for pos in unvisited:
		if nodes[pos].cost < lowest_cost:
			lowest_cost = nodes[pos].cost
			lowest_node = pos
	
	return lowest_node

# 获取相邻的网格位置（四方向）
static func _get_neighbors(pos: Vector2i, width: int, height: int) -> Array:
	var neighbors = []
	var directions = [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]
	
	for dir in directions:
		var neighbor = pos + dir
		if neighbor.x >= 0 and neighbor.x < width and neighbor.y >= 0 and neighbor.y < height:
			neighbors.append(neighbor)
	
	return neighbors

# 构建从起点到终点的路径
static func _build_path(nodes: Dictionary, start: Vector2i, end: Vector2i) -> Dictionary:
	var path:Array[Vector2i] = []
	var current:Vector2i = end
	
	# 如果终点不可达
	if nodes[end].cost == INF:
		return {"path": [], "cost": INF}
	
	# 从终点回溯到起点
	while current != start:
		path.append(current)
		current = nodes[current].previous
		if current == Vector2i(-1, -1):  # 无效位置
			return {"path": [], "cost": INF}
	
	# 添加起点
	path.append(start)
	
	# 反转路径，使其从起点到终点
	path.reverse()
	
	return {"path": path, "cost": nodes[end].cost}

# 构建所有可达位置的结果
static func _build_result(nodes: Dictionary, start: Vector2i, max_cost: float) -> Dictionary:
	var result = {
		"reachable": [] as Array[Vector2i],  # 所有可达位置
		"costs": {} as Dictionary,      # 每个位置的成本
		"paths": {} as Dictionary      # 到每个位置的路径
	}
	
	for pos :Vector2i in nodes:
		var node = nodes[pos]
		
		# 跳过不可达位置和起点
		if node.cost == INF or pos == start:
			continue
		
		# 跳过超过最大成本的位置
		if node.cost > max_cost:
			continue
		
		# 添加到可达列表
		result["reachable"].append(pos)
		result["costs"][pos] = node.cost
		
		# 构建路径
		var path = []
		var current = pos
		
		while current != start:
			path.append(current)
			current = node.previous
			node = nodes[current]
		
		path.append(start)
		path.reverse()
		result["paths"][pos] = path
	
	return result
