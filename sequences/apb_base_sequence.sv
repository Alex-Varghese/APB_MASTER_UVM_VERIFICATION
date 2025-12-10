class apb_sequence extends uvm_sequence #(apb_master_seq_item);
  `uvm_object_utils(apb_sequence)

  function new(string name = "apb_sequence");
    super.new(name);
  endfunction
/*
  task body();
    apb_master_seq_item seq;
    bit [`ADDR_WIDTH-1:0] local_addr;
    bit [`DATA_WIDTH-1:0] local_wdata;
    bit [`DATA_WIDTH-1:0] local_rdata;
    bit local_write_read;

    `uvm_do_with(seq, {
      presetn == 0;
      transfer == 0;
      pready == 0;
    })

    repeat(`TXNS-1) begin
      `uvm_do_with(seq, {
        presetn == 1;
        transfer == 1;
        pready == 0;
      })

      local_addr = seq.addr_in;
      local_wdata = seq.wdata_in;
      local_rdata = seq.prdata;
      local_write_read = seq.write_read;

      `uvm_do_with(seq, {
        presetn == 1;
        transfer == 1;
        pready == 0;
        addr_in == local_addr;
        write_read == local_write_read;
        wdata_in == local_wdata;
        prdata == local_rdata;
      })

      `uvm_do_with(seq, {
        presetn == 1;
        transfer == 1;
        pready == 1;
        addr_in == local_addr;
        write_read == local_write_read;
        wdata_in == local_wdata;
        prdata == local_rdata;
      })
    end
  endtask
*/

  task body();
    apb_master_seq_item seq;
   
    seq = apb_master_seq_item::type_id::create("seq");
    // Reset transaction
    `uvm_do_with(seq, {
      presetn == 0;
      transfer == 0;
      pready == 0;
    })

    repeat(`TXNS) begin

      seq = apb_master_seq_item::type_id::create("seq");
      // IDLE state
      `uvm_do_with(seq, {
        presetn == 1;
        transfer == 1;
        pready == 0;
      })
      // Constant values
      seq.presetn.rand_mode(0);
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
