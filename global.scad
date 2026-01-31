module xmirror(copy=false,condition=true){
	if(condition){
		mirror([1,0,0])
		children();
		
		if(copy){
			children();
		}
	}else{
		children();
	}
}

module ymirror(copy=false,condition=true){
	if(condition){
		mirror([0,1,0])
		children();
		
		if(copy){
			children();
		}
	}else{
		children();
	}
}

module zmirror(copy=false,condition=true){
	if(condition){
		mirror([0,0,1])
		children();
		
		if(copy){
			children();
		}
	}else{
		children();
	}
}

module xrot(v,copy=false,condition=true){
	if(condition){
		rotate([v,0,0])
		children();
		
		if(copy){
			children();
		}
	}else{
		children();
	}
}

module yrot(v,copy=false,condition=true){
	if(condition){
		rotate([0,v,0])
		children();
		
		if(copy){
			children();
		}
	}else{
		children();
	}
}

module zrot(v,copy=false,condition=true){
	if(condition){
		rotate([0,0,v])
		children();
		
		if(copy){
			children();
		}
	}else{
		children();
	}
}

module xtran(dist,copy=false,condition=true){
	if(condition){
		translate([dist,0,0])
		children();
		
		if(copy){
			children();
		}
	}else{
		children();
	}
}

module ytran(dist,copy=false,condition=true){
	if(condition){
		translate([0,dist,0])
		children();
		
		if(copy){
			children();
		}
	}else{
		children();
	}
}

module ztran(dist,copy=false,condition=true){
	if(condition){
		translate([0,0,dist])
		children();
		
		if(copy){
			children();
		}
	}else{
		children();
	}
}

module repeat_axis(count, spacing, axis) {
    for (i = [0 : count-1]) {
        translate(axis * spacing * i)
            children();
    }
}

module smooth_shape(r = 0.25) {
  offset(delta = r)
  offset(delta = -r)
  children();
}
