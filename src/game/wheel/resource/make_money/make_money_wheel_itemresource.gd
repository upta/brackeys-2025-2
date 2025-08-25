class_name MakeMoneyWheelItemResource
extends WheelItemResource

@export var amount: int = 100

func apply() -> void:
    prints("Applied MakeMoneyWheelItemResource: +%d money" % amount)