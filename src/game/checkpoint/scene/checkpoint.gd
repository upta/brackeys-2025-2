extends PanelContainer

@onready var checkpoint_service: CheckpointService = Provider.inject(self, CheckpointService)
@onready var checkpoint_state: CheckpointState = Provider.inject(self, CheckpointState)
@onready var wheel_service: WheelService = Provider.inject(self, WheelService)

@onready var risk_it: Button = %RiskIt
@onready var cash_out: Button = %CashOut
@onready var cash_out_label: Label = %CashOutLabel
@onready var ticks_label: Label = %TicksLabel

func _ready() -> void:
	risk_it.pressed.connect(_on_risk_it_pressed)
	cash_out.pressed.connect(_on_cash_out_pressed)
	checkpoint_state.checkpoint_state_changed.connect(_on_checkpoint_state_changed)
	checkpoint_state.ticks_changed.connect(_on_ticks_changed)
	
	cash_out_label.visible = false
	_update_visibility()
	_update_ticks_label()


func _on_cash_out_pressed() -> void:
	risk_it.visible = false
	cash_out.visible = false
	cash_out_label.visible = true


func _on_checkpoint_state_changed(_is_at_checkpoint: bool) -> void:
	if not _is_at_checkpoint:
		cash_out_label.visible = false
	_update_visibility()


func _on_risk_it_pressed() -> void:
	var item: MakeMoneyWheelItemResource = MakeMoneyWheelItemResource.new()
	item.name = "Checkpoint"
	item.amount = 1

	wheel_service.add_item(item)

	checkpoint_service.reset()


func _update_visibility() -> void:
	var is_at_checkpoint = checkpoint_state.is_at_checkpoint()
	
	# Show ticks label when NOT at checkpoint
	ticks_label.visible = not is_at_checkpoint
	
	# Show buttons when AT checkpoint (and cash out label is not visible)
	if is_at_checkpoint and not cash_out_label.visible:
		risk_it.visible = true
		cash_out.visible = true
	else:
		risk_it.visible = false
		cash_out.visible = false


func _on_ticks_changed(_ticks_remaining: int) -> void:
	_update_ticks_label()


func _update_ticks_label() -> void:
	ticks_label.text = "Ticks to next checkpoint: " + str(checkpoint_state.ticks_to_checkpoint)
