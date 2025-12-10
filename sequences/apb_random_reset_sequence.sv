class apb_sequence extends uvm_sequence #(apb_master_seq_item);
  `uvm_object_utils(apb_sequence)

  function new(string name = "apb_sequence");
    super.new(name);
  endfunction

  task body();
    apb_master_seq_item seq;
   
    repeat(`TXNS) begin

      seq = apb_master_seq_item::type_id::create("seq");
      // IDLE state
      `uvm_do_with(seq, {
        transfer == 1;
        pready == 0;
      })
      // Constant values
      seq.transfer.rand_mode(0);
      seq.addr_in.rand_mode(0);
      seq.write_read.rand_mode(0);
      seq.wdata_in.rand_mode(0);
      seq.prdata.rand_mode(0);
      // Setup State
      start_item(seq);
        seq.pready = 0;
      finish_item(seq);
      // Access State
      start_item(seq);
        seq.pready = 1;
      finish_item(seq);
    
    end
  endtask
endclass
