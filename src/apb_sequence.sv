class apb_sequence extends uvm_sequence #(apb_master_seq_item);
    `uvm_object_utils(apb_sequence)
    
    rand bit [`ADDR_WIDTH-1:0] addr;
    rand bit [`DATA_WIDTH-1:0] data;
    rand bit write_read;
    
    function new(string name = "apb_sequence");
        super.new(name);
    endfunction
    
    task body();
        apb_master_seq_item req;
        bit [`ADDR_WIDTH-1:0] local_addr;
        bit [`DATA_WIDTH-1:0] local_data;
        bit local_write_read;
        
        // Randomize sequence variables
        if (!this.randomize()) begin
            `uvm_error(get_type_name(), "Failed to randomize sequence")
        end
        local_addr = addr;
        local_data = data;
        local_write_read = write_read;
        
        // **APB Protocol Phases:**
        
        // 1. IDLE Phase (PSEL=0, PENABLE=0)
        `uvm_info(get_type_name(), "IDLE Phase", UVM_HIGH)
        `uvm_do_with(req, {
            presetn == 1;
            transfer == 0;
            pready == 0;
        })
        
        // 2. SETUP Phase (PSEL=1, PENABLE=0)
        `uvm_info(get_type_name(), "SETUP Phase", UVM_HIGH)
        `uvm_do_with(req, {
            presetn == 1;
            transfer == 1;
            addr_in == local_addr;
            write_read == local_write_read;
            if (local_write_read == 1) wdata_in == local_data;
            pready == 0;  // Slave not ready yet
        })
        
        // 3. ACCESS Phase (PSEL=1, PENABLE=1, PREADY=1)
        `uvm_info(get_type_name(), "ACCESS Phase", UVM_HIGH)
        `uvm_do_with(req, {
            presetn == 1;
            transfer == 1;
            addr_in == local_addr;
            write_read == local_write_read;
            if (local_write_read == 1) wdata_in == local_data;
            pready == 1;  // Slave ready for transfer
        })
        
    endtask
    
endclass


