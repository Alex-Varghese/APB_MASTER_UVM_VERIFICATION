`uvm_analysis_imp_decl(_act_mon)
`uvm_analysis_imp_decl(_pass_mon)

class apb_scoreboard extends uvm_scoreboard;
  
	typedef enum{IDLE,SETUP,ACCESS}state;

	apb_master_seq_item act_mon_queue[$];
  apb_master_seq_item pass_mon_queue[$];
  
  `uvm_component_utils(apb_scoreboard)
 
  uvm_analysis_imp_act_mon#(apb_master_seq_item, apb_scoreboard) act_mon_imp;
  uvm_analysis_imp_pass_mon#(apb_master_seq_item, apb_scoreboard) pass_mon_imp;

  
  extern function new(string name = "apb_scoreboard", uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void write_pass_mon(apb_master_seq_item req);
  extern virtual function void write_act_mon(apb_master_seq_item req);
  extern virtual task run_phase(uvm_phase phase);

endclass

  function apb_scoreboard::new(string name = "apb_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
	function void apb_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    act_mon_imp = new("act_mon_imp", this);
    pass_mon_imp = new("pass_mon_imp",this);
  endfunction : build_phase

  function void apb_scoreboard::write_act_mon(apb_master_seq_item req);
    act_mon_queue.push_back(req);
  endfunction : write_act_mon
  
	function void apb_scoreboard::write_pass_mon(apb_master_seq_item req);
    pass_mon_queue.push_back(req);
  endfunction : write_pass_mon
  
	task apb_scoreboard::run_phase(uvm_phase phase);
    apb_master_seq_item active_seq;
    apb_master_seq_item passive_seq;
    forever begin : forever_block
      wait(pass_mon_queue.size() > 0 && act_mon_queue.size()>0); 
      active_seq = pass_mon_queue.pop_front();
      passive_seq = act_mon_queue.pop_front();
			active_seq.sprint_inputs("Scoreboard");
			passive_seq.sprint_outputs("Scoreboard");
    end : forever_block
  endtask
