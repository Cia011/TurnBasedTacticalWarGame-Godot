# 战旗项目重构 - AI Agent 指南

## 项目概览

| 属性 | 值 |
|------|-----|
| 项目名称 | 战旗项目重构 |
| 游戏类型 | 回合制战旗游戏 (Tactical SRPG) |
| Godot 版本 | 4.7 |
| 渲染模式 | Forward Plus |
| 主场景 | `res://场景/世界场景/WorldScenes.tscn` |

---

## 文档资源

### 官方文档
- **Godot 4.7 官方文档**: `D:\Godot\Godot 4.7 Dooc\Godot Engine 4.7 documentation in English MD`

### 技能入口
- **技能使用指南**: `./.trae/skills/using-godot-prompter/SKILL.md` — 包含完整的技能发现和使用说明

---

## 项目架构

### 场景结构
```
场景/
├── 全局/                      # 自动加载全局管理器
│   ├── OthersGlobal/          # 通用全局系统
│   │   ├── GameState.gd       # 游戏状态管理（角色、战斗状态）
│   │   ├── UiManager.gd       # UI 界面统一管理
│   │   └── PopManager.gd      # 弹窗管理
│   ├── WorldGlobal/           # 世界场景全局系统
│   │   ├── WorldGridManager.gd # 世界地图网格管理
│   │   └── WorldEventManager.gd # 世界事件总线
│   └── BattleGlobal/          # 战斗场景全局系统
│       ├── BattleGridManager.gd # 战斗网格（A*寻路、Dijkstra寻路）
│       ├── BattleActionManager.gd # 战斗行动管理
│       ├── BattleTurnManager.gd # 回合管理（敏捷制行动顺序）
│       ├── BattleUnitManager.gd # 单位管理
│       └── BattleEventBus.gd    # 战斗事件总线
├── 世界场景/                  # 世界地图场景 (蓝色标记)
│   ├── WorldScenes.tscn       # 主场景（地图、相机、UI）
│   ├── world_scenes.gd        # 世界场景逻辑
│   ├── data_layer.gd          # 地图数据层
│   ├── grid_indicator.gd      # 网格指示器
│   └── 队伍/Baseteam.tscn     # 玩家队伍
└── 战斗场景/                  # 战斗场景 (红色标记)
	└── 根节点/battle_map.tscn # 战斗地图
```

---

## 核心游戏机制

### 战斗系统
- **回合制**: 基于敏捷属性 (agility) 的行动顺序，敏捷越高行动越频繁
- **网格移动**: 2D TileMap 网格系统，支持八方向移动（斜向消耗 1.4 距离）
- **寻路算法**: A* 寻路（最短路径）+ Dijkstra 寻路（带权重成本）
- **回合流程**: 
  1. 准备阶段 — 放置角色位置
  2. 战斗阶段 — 单位轮流行动（移动→攻击/技能）
  3. 结算阶段 — 胜负判定

### 单位系统
- **UnitData**: 角色数据（名称、属性、装备）
- **BaseEquipment**: 装备系统（武器、盔甲、靴子、饰品）

### 场景切换
```
世界场景 (WorldScenes) ↔ 战斗场景 (battle_map)
	↓                          ↓
 GameState.change_scene_to()  (存档系统已移除)
```

---

## MCP 插件配置

### 插件信息
- **插件路径**: `res://addons/godot_mcp/plugin.cfg`
- **插件状态**: 已启用

### 使用方式
1. **启动 Godot 编辑器**（MCP 服务器需要在编辑器内运行）
2. **手动启动**: 在 MCP 面板中点击 Start 按钮
3. **命令行**: `Godot_v4.7-dev1_win64.exe --mcp-server`
4. **自动启动**: 项目设置 → 插件 → Godot MCP Native → 勾选 Auto Start

### 注意事项
- Trae IDE 需要连接到运行中的 Godot 编辑器
- MCP 默认 HTTP 模式，端口 9080
- Godot 关闭后 MCP 服务器也会停止

---

## 可用技能（按类别）
对场景进行操作时请使用mcp
### 核心开发流程
| 技能 | 用途 |
|------|------|
| `godot-project-setup` | 项目初始化和配置 |
| `godot-brainstorming` | 功能设计和架构规划 |
| `godot-code-review` | 代码审查和最佳实践 |
| `godot-debugging` | 调试和问题定位 |
| `godot-testing` | 测试用例编写 |

### 架构与模式
| 技能 | 用途 |
|------|------|
| `scene-organization` | 场景树结构设计 |
| `state-machine` | 状态机实现 |
| `event-bus` | 事件总线通信 |
| `component-system` | 组件化设计 |
| `resource-pattern` | 资源数据容器 |
| `dependency-injection` | 依赖管理 |

### 游戏系统
| 技能 | 用途 |
|------|------|
| `player-controller` | 角色控制和移动 |
| `input-handling` | 输入系统设计 |
| `animation-system` | 动画系统实现 |
| `tween-animation` | 补间动画 |
| `dialogue-system` | 对话系统 |
| `ai-navigation` | AI 导航和行为树 |
| `ability-system` | 技能和 Buff/Debuff |

### UI/UX
| 技能 | 用途 |
|------|------|
| `godot-ui` | UI 界面设计 |
| `responsive-ui` | 响应式布局 |
| `hud-system` | 战斗 HUD 和状态栏 |

### 物理与寻路
| 技能 | 用途 |
|------|------|
| `physics-system` | 物理碰撞和射线检测 |
| `2d-essentials` | 2D 网格和粒子 |
| `math-essentials` | 游戏数学和路径计算 |

### 性能优化
| 技能 | 用途 |
|------|------|
| `godot-optimization` | 性能分析和优化 |
| `multithreading` | 多线程和后台任务 |
| `gdscript-advanced` | GDScript 高级技巧 |

> **完整技能列表**: 参见 `./.trae/skills/using-godot-prompter/SKILL.md`

---

## 代码规范

### 版本要求
- 使用 **Godot 4.7 语法**
- 使用 4.7 新增特性（如 Forward Plus 渲染）
- 遵循官方文档最佳实践

### 命名规范
- 文件: 中文命名，如 `GameState.gd`
- 类名: PascalCase，如 `GameState`
- 变量: snake_case，如 `player_health`
- 常量: UPPER_SNAKE_CASE，如 `MAX_HEALTH`
- 信号: snake_case，如 `health_changed`

### 代码风格
- 使用静态类型标注：`var name: Type`
- 使用 `await` 进行异步操作
- 使用信号进行解耦通信
- 遵循现有代码的缩进和空行风格

---

## 工作流程

### 新功能开发
1. 使用 `godot-brainstorming` 设计功能架构
2. 使用 `scene-organization` 规划场景结构
3. 实现代码，遵循 `gdscript-patterns`
4. 使用 `godot-testing` 编写测试
5. 使用 `godot-code-review` 审查代码

### Bug 修复
1. 使用 `godot-debugging` 定位问题
2. 分析代码逻辑
3. 修复并验证
4. 添加回归测试

### 性能优化
1. 使用 `godot-optimization` 分析瓶颈
2. 根据分析结果优化
3. 使用 profiler 验证效果

---

## 自动加载列表

| 名称 | 路径 | 用途 |
|------|------|------|
| `GBIS` | `res://addons/grid_base_inventory_system/core/grid_base_inventory_system.gd` | 网格背包系统核心（名称必须为 GBIS） |
| `GameState` | `res://场景/全局/OthersGlobal/GameState.gd` | 游戏全局状态、角色管理 |
| `UiManager` | `res://场景/全局/OthersGlobal/UiManager.gd` | UI 界面管理 |
| `PopManager` | `res://场景/全局/OthersGlobal/PopManager.gd` | 弹窗管理 |
| `WorldGridManager` | `res://场景/全局/WorldGlobal/WorldGridManager.gd` | 世界网格 |
| `WorldEventManager` | `res://场景/全局/WorldGlobal/WorldEventManager.gd` | 世界事件 |
| `BattleGridManager` | `res://场景/全局/BattleGlobal/BattleGridManager.gd` | 战斗网格与寻路 |
| `BattleActionManager` | `res://场景/全局/BattleGlobal/BattleActionManager.gd` | 战斗行动 |
| `BattleTurnManager` | `res://场景/全局/BattleGlobal/BattleTurnManager.gd` | 回合管理 |
| `BattleUnitManager` | `res://场景/全局/BattleGlobal/BattleUnitManager.gd` | 单位管理 |
| `BattleEventBus` | `res://场景/全局/BattleGlobal/BattleEventBus.gd` | 战斗事件总线 |

---

## 编辑器插件

- **CodeEditorSwitch**: 外部代码编辑器切换
- **Godot MCP**: MCP 服务器插件（用于 Trae IDE 连接）

---

## GBIS 网格背包系统

### 插件概述
- **插件路径**: `res://addons/grid_base_inventory_system/`
- **插件类型**: 运行时框架（非编辑器插件）
- **核心类**: `grid_base_inventory_system.gd`（自动加载名为 `GBIS`）

### 架构说明
采用类 MVC 设计，分离展示层和数据层：
- **Model**: `core/model/item/` — 物品数据类（ItemData, ConsumableData, EquipmentData, StackableData）
- **Service**: `core/service/` — 业务逻辑（InventoryService, ShopService, EquipmentSlotService）
- **View**: `core/view/` — UI 展示（InventoryView, ShopView, ItemView）

### 输入配置

| 输入名称 | 默认按键 | 功能 |
|----------|---------|------|
| `inv_click` | 鼠标左键 | 点击物品 |
| `inv_use` | 鼠标右键 | 使用物品 |
| `inv_quick_move` | Shift + 鼠标右键 | 快速移动物品 |
| `inv_split` | 鼠标中键 | 分割物品 |

### 使用方法

**添加物品到背包:**
```gdscript
var my_item = preload("res://path/to/your_item.tres")
GBIS.add_item("Inventory", my_item)
```

**配置背包间快速移动关系:**
```gdscript
GBIS.add_quick_move_relation("Inventory", "Equipment Slot")
```

**监听物品信息显示:**
```gdscript
GBIS.sig_item_focused.connect(your_display_method)
GBIS.sig_item_focus_lost.connect(your_clear_method)
```

**保存/加载:**
```gdscript
GBIS.save()    # 保存背包和装备槽
await GBIS.load()  # 加载背包和装备槽
```

### 物品类型

| 类型 | 说明 |
|------|------|
| `ItemData` | 基础物品类 |
| `ConsumableData` | 消耗品（可使用） |
| `EquipmentData` | 装备（可装备到槽位） |
| `StackableData` | 可堆叠物品 |

### 资源文件

- **插件文档**: `res://addons/grid_base_inventory_system/readme.md`
- **示例场景**: `res://addons/grid_base_inventory_system/GBIS_demos/`（如需要可参考）
---

## Codex 配置

### 技能 (Skills)

本项目使用 **GodotPrompter** 技能库。所有 Godot 开发技能已从 `.trae/skills/` 安装到 Codex 技能目录中，可直接使用。

在开发时，系统会自动根据任务匹配合适的技能（如 `state-machine`、`event-bus`、`scene-organization` 等），在实现前请确保相关技能已加载。

完整技能列表参见 `.trae/skills/using-godot-prompter/SKILL.md`。

### MCP (Model Context Protocol)

**Godot MCP Native** 插件已安装在 `res://addons/godot_mcp/`，在 Godot 编辑器中启动后会自动运行 MCP 服务器。

**连接方式（二选一）:**

1. **HTTP 模式（推荐）** — 已配置 `http://localhost:9080/mcp`
   - 在 Codex 桌面应用中配置 MCP 服务器：
	 - 设置 → MCP Servers → 添加 `godot-editor`
	 - URL: `http://localhost:9080/mcp`
   - 或在 `~/.codex/config.toml` 中添加：
	 ```toml
	 [mcp_servers.godot_editor]
	 url = "http://localhost:9080/mcp"
	 ```
   - 确保 **Godot 编辑器正在运行**且已打开本项目

2. **STDIO 模式** — 通过命令行启动 Godot MCP：
   ```bash
   Godot_v4.7-dev1_win64.exe --path . --mcp-server
   ```
   适用于无编辑器的 CI/CD 场景

**可用的 MCP 工具（部分）:**
| 类别 | 工具数 | 说明 |
|------|--------|------|
| 节点工具 | 9+11 | 创建/修改/管理场景节点 |
| 脚本工具 | 7+8 | 编辑/创建/分析 GDScript |
| 场景工具 | 4+4 | 操作场景结构 |
| 编辑器工具 | 4+12 | 编辑器控制 |
| 调试工具 | 3+68 | 调试/断点/分析器 |
| 项目工具 | 3+23 | 项目设置/资源管理 |

**Vibe Coding 模式**: MCP 支持 Vibe Coding 模式（在插件设置中启用），可防止 AI 操作打断编辑器焦点。

### 项目本地配置

- `.codex-plugin/plugin.json` — 项目 Codex 插件清单
- `.mcp.json` — 项目级 MCP 服务器配置（兼容标准 MCP 发现格式）
- `.codex/` — 项目级 Codex 配置目录
