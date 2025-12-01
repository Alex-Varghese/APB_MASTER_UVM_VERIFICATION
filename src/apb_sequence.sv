`include "defines.svh"

class apb_base_sequence extends uvm_sequence#(apb_master_seq_item);
  
  // declaring a seq_item that has to be sent to the driver
  apb_master_seq_item req;
  
  // factory registeration
  `uvm_object_utils(apb_base_sequence)
  
  //new constructor
  function new(string name = "apb_base_sequence");
    super.new("apb_base_sequence");
  endfunction
  
  virtual task body();
    req = apb_master_seq_item::type_id::create("req");//creating seq_item
		`uvm_do_with(req, {presetn == 0;})
		repeat(`TXNS) begin
      start_item(req);
      assert(req.randomize());
		  finish_item(req);   
	  end
  endtask
endclass

