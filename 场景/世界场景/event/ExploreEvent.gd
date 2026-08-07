class_name ExploreEvent extends BaseEvent
## 探索事件：一次性，触发后获得奖励并自动移除。

@export var reward_gold: int = 20

func _init() -> void:
	type = "explore"
	duration = 1
	auto_resolve = true
	name = "探索"
	description = "探索未知区域，可能有所收获。"

func apply_effect() -> void:
	PartyWallet.earn(reward_gold)
	print("[探索事件] %s 获得 %d 金币" % [name, reward_gold])
	WorldEventManager.unregister_event(self)

func serialize() -> Dictionary:
	var data := super.serialize()
	data["reward_gold"] = reward_gold
	return data

func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	reward_gold = data.get("reward_gold", reward_gold)
