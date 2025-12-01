class apb_env extends uvm_env;
  
  `uvm_component_utils(apb_env)
  
  apb_agent act_agt;
  apb_agent pass_agt;
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
  act_agt.act_mon.act_mon_port.connect(scb.act_mon_imp);
  pass_agt.pass_mon.pass_mon_port.connect(scb.pass_mon_imp);
  //act_agt.act_mon.act_mon_cg_port.connect(cov.a_mon_cov_imp);
  //pass_agt.pass_mon.pass_mon_cg_port.connect(cov.p_mon_cov_imp);
endfunction 
  
function void apb_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
	set_config_int("act_agt","is_active",UVM_ACTIVE);
  set_config_int("pass_agt","is_active",UVM_PASSIVE);
  act_agt = apb_agent::type_id::create("act_agt",this);
  pass_agt = apb_agent::type_id::create("pass_agt",this);
  scb = apb_scoreboard::type_id::create("scb",this);
  //cov = apb_coverage::type_id::create("cov",this);
endfunction
