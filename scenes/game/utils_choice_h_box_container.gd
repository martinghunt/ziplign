extends HBoxContainer


func _ready():
	$FilterButton.set_pressed_no_signal(true)
	$SearchButton.set_pressed_no_signal(false)
	$"../SearchVBoxContainer".hide()
	$"../FilterVBoxContainer".show()


func _on_filter_button_toggled(toggled_on):
	if not toggled_on:
		$FilterButton.set_pressed(true)
	else:
		$SearchButton.set_pressed_no_signal(false)
		$"../SearchVBoxContainer".hide()
		$"../FilterVBoxContainer".show()

func _on_search_button_toggled(toggled_on):
	if not toggled_on:
		$SearchButton.set_pressed(true)
	else:
		$FilterButton.set_pressed_no_signal(false)
		$"../FilterVBoxContainer".hide()
		$"../SearchVBoxContainer".show()
