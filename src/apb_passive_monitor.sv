
class apb_passive_monitor extends uvm_monitor;
  
  `uvm_component_utils(apb_passive_monitor)
  
  virtual apb_intf vif;
  apb_master_seq_item pass_req;
  uvm_analysis_port#(apb_master_seq_item)pass_mon_port;
  uvm_analysis_port#(apb_master_seq_item)pass_mon_cg_port;
  
  extern function new(string name = "apb_active_monitor",uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern task monitor_outputs();
  extern task run_phase(uvm_phase phase);
  
endclass

  function apb_passive_monitor::new(string name = "apb_active_monitor",uvm_component parent);
    super.new(name,parent);
    pass_mon_port = new("pass_mon_port",this);
    pass_mon_cg_port = new("pass_mon_cg_port",this);
  endfunction

	function void apb_passive_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", vif))
      `uvm_error(get_type_name(), "Failed to get Interface");   
	endfunction

	task apb_passive_monitor::monitor_outputs();
    pass_req.psel = vif.psel;
		//pass_req.pwdata = vif.pwdata;
		pass_req.penable = vif.penable;
		pass_req.pwrite = vif.pwrite;
		pass_req.pstrb = vif.pstrb;
    pass_req.paddr = vif.paddr;
    //`uvm_info(get_type_name(), $sformatf("psel = %0d | pwrite = %0b | penable  =%0b | paddr = %0d | pwadta = %0d | pstrb = %0d",pass_req.psel,pass_req.pwrite,pass_req.penable,pass_req.paddr,pass_req.wdata,pass_req.pstrb),UVM_MEDIUM);
    pass_mon_port.write(pass_req);
    pass_mon_cg_port.write(pass_req);
  endtask

  task apb_passive_monitor::run_phase(uvm_phase phase);
    repeat(1)@(vif.pass_mon_cb);
    forever begin
      pass_req = apb_master_seq_item::type_id::create("pass_req");
      repeat(1)@(vif.pass_mon_cb);
      monitor_outputs();
      repeat(2)@(vif.pass_mon_cb);
    end
  endtask
