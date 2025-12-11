class apb_monitor extends uvm_monitor;
  
  `uvm_component_utils(apb_monitor)
  
  virtual apb_intf vif;
  apb_master_seq_item act_req;
  uvm_analysis_port#(apb_master_seq_item)mon_port;
  uvm_analysis_port#(apb_master_seq_item)mon_cg_port;
  
  
	extern function new(string name = "apb_monitor",uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern task monitor_inputs();  
  extern task run_phase(uvm_phase phase);
  
endclass

	function apb_monitor::new(string name = "apb_monitor",uvm_component parent);
    super.new(name,parent);
    mon_port = new("mon_port",this);
    mon_cg_port = new("mon_cg_port",this);
	endfunction

  function void apb_monitor::build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", vif))
      `uvm_error(get_type_name(), "Failed to get Interface");   
  endfunction

  task apb_monitor::monitor_inputs();  
		act_req.transfer = vif.transfer;
		act_req.wdata_in = vif.wdata_in;
		act_req.addr_in = vif.addr_in;
		act_req.strb_in = vif.strb_in;
		act_req.prdata = vif.prdata;
    act_req.pready = vif.pready;
    act_req.presetn = vif.presetn;
		act_req.pslverr = vif.pslverr;
    // Passive out 
    act_req.psel = vif.psel;
		act_req.pwdata = vif.pwdata;
		act_req.penable = vif.penable;
		act_req.pwrite = vif.pwrite;
		act_req.pstrb = vif.pstrb;
    act_req.paddr = vif.paddr;
		act_req.transfer_done = vif.transfer_done;
		act_req.error = vif.error;
		act_req.rdata_out = vif.rdata_out;
    // end passive
    mon_port.write(act_req);
    //mon_cg_port.write(act_req);
  endtask

  task apb_monitor::run_phase(uvm_phase phase);
    repeat(1)@(vif.act_mon_cb);
    forever begin
      act_req = apb_master_seq_item::type_id::create("act_req");
      monitor_inputs();
      repeat(1)@(vif.act_mon_cb);
    end
  endtask
