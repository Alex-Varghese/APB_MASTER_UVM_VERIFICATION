class apb_driver extends uvm_driver#(apb_master_seq_item);
  
  `uvm_component_utils(apb_driver)

  virtual apb_intf vif;
  apb_master_seq_item req;
  
  extern function new(string name = "apb_driver", uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
	extern virtual task drive_inputs();
	extern virtual task run_phase(uvm_phase phase);
      
endclass

function apb_driver::new(string name = "apb_driver", uvm_component parent);
  super.new(name,parent);
endfunction

function void apb_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", vif))
    `uvm_error(get_type_name(), "Failed to get Interface");
endfunction : build_phase

task apb_driver::run_phase(uvm_phase phase);
  repeat(1)@(posedge vif.drv_cb);
  forever begin : forever_b
    seq_item_port.get_next_item(req);
		drive_inputs();
	  req.sprint_inputs("Driver");
    seq_item_port.item_done();
  end : forever_b
endtask : run_phase  

task apb_driver::drive_inputs();
	vif.presetn <= req.presetn;
  vif.pslverr <= req.pslverr;
	vif.pready <= req.pready;
	vif.prdata <= req.prdata;
	vif.addr_in <= req.addr_in;
	vif.wdata_in <= req.wdata_in;
	vif.transfer <= req.transfer;
	vif.write_read <= req.write_read;
	vif.strb_in <= req.strb_in;
	repeat(1)@(posedge vif.drv_cb);
endtask : drive_inputs
