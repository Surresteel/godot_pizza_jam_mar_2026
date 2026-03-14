extends StaticBody3D
class_name DirtHurdle




func _on_drillbug_detector_body_entered(body: Node3D) -> void:
	var drillbug: DrillBug = body
	drillbug.start_drilling()


func _on_drillbug_detector_body_exited(body: Node3D) -> void:
	var drillbug: DrillBug = body
	drillbug.stop_drilling()
