class apb_master_coverage extends uvm_subscriber #(apb_master_seq_item);
  `uvm_component_utils(apb_master_coverage)

	covergroup cg;
	//Error condition bins
	coverpoint tr.PSLVERR{
     bins pslverr_assert = {1};
		 bins pslverr_not_assert = {0};
	 }

	//Ready condition bins
	coverpoint tr.PREADY{
     bins pready_assert = {1};
	 	 bins pready_not_assert = {0};
	 }
  endgroup

  function new(string name ="apb_coverage_model", uvm_component parent);
  	super.new(name,parent);
  	cg =new;
  endfunction

  //Build Phase
  function void build_phase(uvm_phase phase);
  super.build_phase(phase);
    cm_export_write = new("cm_export_write", this);
    cm_export_read = new("cm_export_read", this);
  endfunction

  virtual function void write(apb_transaction tr);
  endfunction 

  virtual function void write_W(apb_transaction tr1);
  	tr =tr1;
   	`uvm_info("COVERAGE",$sformatf("Got write transaction for coverage"),UVM_LOW)
  	cg.sample();
  endfunction 

  virtual function void write_R(apb_transaction tr2);
  	tr = tr2;
  	`uvm_info("COVERAGE",$sformatf("Got read transaction for coverage"),UVM_LOW)
  	cg.sample();
  endfunction
endclass	
