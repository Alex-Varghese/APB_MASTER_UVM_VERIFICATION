class apb_base_test extends uvm_test;
  `uvm_component_utils(apb_base_test)
  
  apb_env env;

	apb_sequence seq;

  extern function new(string name = "apb_base_test", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);

endclass : apb_base_test

function apb_base_test::new(string name = "apb_base_test",uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void apb_base_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
  env = apb_env::type_id::create("env",this);
endfunction : build_phase

task apb_base_test::run_phase(uvm_phase phase);
  phase.raise_objection(this);
  super.run_phase(phase);
	seq = apb_sequence::type_id::create("seq");
	seq.start(env.act_agt.seqr);
  phase.drop_objection(this);
  phase.phase_done.set_drain_time(this,100);
endtask : run_phase


