class apb_env extends uvm_env;
  
  `uvm_component_utils(apb_env)
  
  apb_agent agt;
  apb_scoreboard scb;  
  //apb_master_coverage cov;
  
  extern function new(string name = "apb_env", uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass

function apb_env::new(string name = "apb_env", uvm_component parent);
  super.new(name,parent);
endfunction

function void apb_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  agt.mon.mon_port.connect(scb.mon_imp);
  //agt.mon.mon_cg_port.connect(cov.a_mon_cov_imp);
endfunction 
  
function void apb_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  agt = apb_agent::type_id::create("agt",this);
  scb = apb_scoreboard::type_id::create("scb",this);
  //cov = apb_coverage::type_id::create("cov",this);
endfunction
