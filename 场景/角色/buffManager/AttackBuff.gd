extends BaseBuff
class_name AttackBuff
# 应用Buff时的效果
func apply_effect() -> void:
	target.data_manager.add_modifier("defense",100)
# 移除Buff时的效果
func remove_effect() -> void:
	target.data_manager.remove_modifier("defense",100)
