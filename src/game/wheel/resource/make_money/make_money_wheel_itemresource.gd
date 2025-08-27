class_name MakeMoneyWheelItemResource
extends WheelItemResource

@export var amount: int = 100

func apply(node: Node) -> void:
    var player_service: PlayerService = Provider.inject(node, PlayerService)
    player_service.add_resources(amount)