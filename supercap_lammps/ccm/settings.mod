# set boundary in main script because ffield is periodic
units 	real

atom_style 	full	
pair_style 	lj/cut/coul/long 16
bond_style 	harmonic
angle_style 	harmonic
kspace_style 	pppm 1e-7
# kspace_modify in main script

read_data 	"data.graph-il"

# replicate 4 4 1 # test different sys sizes

variable 	zpos atom "z > 0"
group 		zpos variable zpos
group 		ele type 5
group 		top intersect ele zpos
group 		bot subtract ele top
group       cation type 4
group       anion type 1

compute        den1 cation chunk/atom bin/1d z center 0.5  units box
fix            chunk1 cation ave/chunk 10 1 100 den1 density/number ave running file cat_density.txt overwrite
compute        den2 anion chunk/atom bin/1d z center 0.5 units box
fix            chunk2 anion ave/chunk 10 1 100 den2 density/number ave running file an_density.txt overwrite

dump            1 all custom 100 system.dump id type q xs ys zs ix iy iz
dump            2 top custom 5000 anode.dump id type q xs ys zs 
dump            3 bot custom 5000 cathode.dump id type q xs ys zs 
group 		      bmi type 1 2 3
group 		      electrolyte type 1 2 3 4


fix 		        nvt electrolyte nvt temp 500.0 500.0 100
fix 		        shake bmi shake 1e-4 20 0 b 1 2 a 1
variable        time equal step 
variable       	q atom q
compute 	      qtop top reduce sum v_q
compute 	      qbot bot reduce sum v_q
compute 	      ctemp electrolyte temp
variable        qtop equal c_qtop
variable        qbot equal c_qbot
fix             elec_char all print 10 "${time} ${qtop} ${qbot}" file elec_char.txt screen no title "time anode_char cathode_char"
