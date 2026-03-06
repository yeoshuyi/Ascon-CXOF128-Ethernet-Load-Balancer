set project_name "Ascon"
set proj_dir "./vivado"
set part_number "xcku3p-ffva676-2-e"

create_project -force $project_name $proj_dir -part $part_number

set my_project [get_projects $project_name]

set_property target_language Verilog $my_project
set_property simulator_language Mixed $my_project

file mkdir src
file mkdir xdc

puts "Done"
