extends Node2D

@onready var BorderWallsPolygon = $BorderWalls/CollisionPolygon2D/Polygon2D
@onready var BorderWallsCollision = $BorderWalls/CollisionPolygon2D
@onready var polygon2D2 = $StaticBody2D5/CollisionPolygon2D/Polygon2D
@onready var collisionPolygon2D2 = $StaticBody2D5/CollisionPolygon2D
@onready var polygon2D3 = $StaticBody2D6/CollisionPolygon2D/Polygon2D
@onready var collisionPolygon2D3 = $StaticBody2D6/CollisionPolygon2D

func _ready():
	BorderWallsPolygon.polygon = BorderWallsCollision.polygon
	polygon2D2.polygon = collisionPolygon2D2.polygon
	polygon2D3.polygon = collisionPolygon2D3.polygon
	
	BorderWallsPolygon.color = Color("0e1c36")
	polygon2D2.color = Color("0e1c36")
	polygon2D3.color = Color("383961")
