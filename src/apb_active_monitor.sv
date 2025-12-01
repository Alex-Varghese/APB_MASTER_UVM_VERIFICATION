class apb_active_monitor extends uvm_monitor;
  
  `uvm_component_utils(apb_active_monitor)
  
  virtual apb_intf vif;
  apb_master_seq_item act_req;
  uvm_analysis_port#(apb_master_seq_item)act_mon_port;
  uvm_analysis_port#(apb_master_seq_item)act_mon_cg_port;
  
  
	extern function new(string name = "apb_active_monitor",uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern task monitor_inputs();  
  extern task run_phase(uvm_phase phase);
  
endclass

	function apb_active_monitor::new(string name = "apb_active_monitor",uvm_component parent);
    super.new(name,parent);
    act_mon_port = new("act_mon_port",this);
    act_mon_cg_port = new("act_mon_cg_port",this);
	endfunction

  function void apb_active_monitor::build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", vif))
      `uvm_error(get_type_name(), "Failed to get Interface");   
  endfunction

  task apb_active_monitor::monitor_inputs();  
    act_req.prdata = vif.prdata;
    act_req.pready = vif.pready;
    act_req.presetn = vif.presetn;
		act_req.pslverr = vif.pslverr;
    act_mon_port.write(act_req);
		act_req.print_inputs();
    //act_mon_cg_port.write(act_req);
  endtask

  task apb_active_monitor::run_phase(uvm_phase phase);
    repeat(1)@(vif.act_mon_cb);
    forever begin
      act_req = apb_master_seq_item::type_id::create("act_req");
      repeat(1)@(vif.act_mon_cb);
      `uvm_info(get_type_name(),"---------- Started -------------",UVM_MEDIUM);
      monitor_inputs();
      repeat(2)@(vif.act_mon_cb);
			`uvm_info(get_type_name(),"---------- Ended -------------",UVM_MEDIUM);
    end
  endtask
