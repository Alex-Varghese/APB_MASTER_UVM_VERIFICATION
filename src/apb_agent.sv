class apb_agent extends uvm_agent;
  
  `uvm_component_utils(apb_agent)
  apb_driver drv;
  apb_monitor mon;
	apb_sequencer seqr;
    
  extern function new(string name = "apb_agent",uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass

function apb_agent::new(string name = "apb_agent",uvm_component parent);
  super.new(name,parent);
endfunction : new 

function void apb_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(get_is_active() == UVM_ACTIVE) begin
    drv = apb_driver::type_id::create("drv",this);
    seqr = apb_sequencer::type_id::create("seqr",this);
    mon = apb_monitor::type_id::create("mon",this);      
  end
endfunction : build_phase

function void apb_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if(get_is_active() == UVM_ACTIVE) 
    drv.seq_item_port.connect(seqr.seq_item_export);
endfunction : connect_phase

