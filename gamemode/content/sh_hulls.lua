Hull.Default = {
	Hull = Hull.Standard(16, 72),
	DuckHull = Hull.Standard(16, 36),
	View = {Vector(0, 0, 64), Vector(0, 0, 28)}
}

Hull.Define("antlion", {
	Hull = Hull.Standard(18, 36),
	DuckHull = Hull.Standard(18, 36),
	View = {Vector(0, 0, 32), Vector(0, 0, 32)}
})

Hull.Add("antlion", {"models/antlion.mdl", "models/antlion_worker.mdl"})
