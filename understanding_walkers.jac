/*
walker second_walker { // jac run understanding_walkers.jac -walk second_walker
    std.out("This is from second walker. \n");
}

walker init { // jac run understanding_walkers.jac
    std.out("This is from init walker.");
    root {
        spawn here walker::second_walker;
    }
}
*/

node plain: has name;

## defining the graph
graph example {
    has anchor head;
    spawn {
        n=[];
        for i=0 to i<7 by i+=1 {
        n.l::append(spawn node::plain(name=i+1));
        }
        n[0] --> n[1] --> n[2];
        n[1] --> n[3];
        n[0] --> n[4] --> n[5];
        n[4] --> n[6];
        head=n[0];
        }
    }

## walker for breadth first search
walker walk_with_breadth {
    has anchor node_order = [];
    node_order.l::append(here.name);
    take:bfs -->; #can be replaced with take:b -->
    }

walker walk_with_depth {
    has anchor node_order = [];
    node_order.l::append(here.name);
    take:dfs -->; #can be replaced with take:d -->
    }

walker init {
    start = spawn here ++> graph::example;
    b_order = spawn start walker::walk_with_breadth;
    d_order = spawn start walker::walk_with_depth;
    std.out("Walk with Breadth:",b_order,"\nWalk with Depth:",d_order);
    }