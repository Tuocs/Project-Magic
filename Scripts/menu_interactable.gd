extends StaticBody3D

@onready var interaction_area: InteractionArea = $InteractionArea
@export var menu: MenuManager.MENU


func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact() -> void:
	MenuManager.open_menu(menu)
