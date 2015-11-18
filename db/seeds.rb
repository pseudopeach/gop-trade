# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
cdts = Candidate.create([
  {name:"Donald Trump", id_name:"trump"},
  {name:"Ben Carson", id_name:"carson"},
  {name:"Marco Rubio", id_name:"rubio"},
  {name:"Ted Cruz", id_name:"cruz"},
  {name:"Jeb Bush", id_name:"bush"},
  {name:"Rand Paul", id_name:"paul"},
  {name:"John Kasich", id_name:"kasich"},
  {name:"Carley Fiorina", id_name:"fiorina"},
  {name:"Mike Huckabee", id_name:"huckabee"},
  {name:"Chris Christie", id_name:"christie"},
  {name:"Bobby Jindal", id_name:"jindal"},
  {name:"George Pataki", id_name:"pataki"},
  {name:"Lindsey Graham", id_name:"graham"},
  {name:"All Others", id_name:"FIELD"}
])
