module("Badge", package.seeall)

Index = 1
List = List or {}
Lookup = Lookup or {}


function Add(id, name, mat, callback)
	local data = {
		ID = id,
		Name = name,
		Material = Material(mat),
		Callback = callback,
		Automated = tobool(callback)
	}

	List[Index] = data
	Lookup[id] = data

	Index = Index + 1
end


function Get(id)
	return Lookup[id]
end
