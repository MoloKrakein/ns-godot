extends Node

var database: Dictionary={}

func _ready():
    print("ItemDB Initialize...")
    _scan_directory("res://Resources/")
    print("Load ", database.size(),"item to db")

# Scanner for tscn
func _scan_directory(path: String):
    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.begins_with("."):
                file_name = dir.get_next()
                continue

            if dir.current_is_dir():
                _scan_directory(path + "/" + file_name)
            elif file_name.ends_with(".tres"):
                var file_path = path + "/" + file_name
                var resource = ResourceLoader.load(file_path, "", ResourceLoader.CACHE_MODE_IGNORE)

                if resource and "id" in resource and resource.id != "":
                    database[resource.id] = resource

            file_name = dir.get_next()
# Helper function
func get_item(id:String) -> Resource:
    if database.has(id):
        return database[id]
    else:
        printerr("ERROR: Item ID not found in database: ",id)
        return null

func find_chain_reaction(primer: int, trigger: int) -> StatusEffect:
    for resource in database.values():
        if resource is StatusEffect and resource.matches_reaction_recipe(primer, trigger):
            return resource
    return null

func get_reaction_id(primer: int, trigger: int) -> String:
    var reaction = find_chain_reaction(primer, trigger)
    if reaction != null:
        return reaction.id
    return ""

