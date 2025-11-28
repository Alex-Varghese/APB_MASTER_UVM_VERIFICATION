class apb_master_seq_item extends uvm_sequence_item;
 

	////////////////////////////////////////////////////
	//
  // Input signals
	//
	////////////////////////////////////////////////////
	rand bit presetn;                   // PRESETn is the reset signal and is active-LOW. 	

  rand bit pslverr;                   // error bit
	rand bit pready;                    // PREADY is used to extend an APB transfer by the completer	
	bit [`DATA_SIZE-1:0] prdata;        // Read data from the slave

	////////////////////////////////////////////////////
	//
  // Output signals
	//
	////////////////////////////////////////////////////
  bit [`PSEL_WIDTH-1:0]psel;     // Gives the slave to be chosen
	bit [`ADDR_WIDTH-1:0] paddr;  // address where data has to be written
	bit pwrite;                    // to check the mode of transfer
  bit penable;                   // to check the mode of transferBLE indicates the second and subsequent cycles of an APB transfer.	
				
	bit [`DATA_WIDTH-1:0] pwdata; // Write data for the slave
  bit [(`DATA_WIDTH/8)-1:0]pstrb;//Used to transfer the data to pwdata bus

  // Timing Control signals for slave inputs 
	int slave_drive_time; 
  int transfer_size;
	
	// field automation macros and factory registeration	  
  `uvm_object_utils(apb_master_seq_item)
 

	//-------------------------------------------------------
	// Externally defined Tasks and Functions
	//-------------------------------------------------------	
  extern virtual function new(string name = "apb_master_seq_item");

	 //-------------------------------------------------------
	 // Constraints defined on variables pselx,
	 //-------------------------------------------------------
	 
   // Constraint to set default values
	 constraint default_values {
      soft pslverr == 0;
		  soft presetn == 1;
			soft pready == 0;
	 }

   // Constraint for the wait time for asserting pready
	 constraint wait_time {
			slave_drive_time inside {[0:20]};
	 }

	 // Constraining the input data range
	 constraint input_data {
			pwdata inside {[0:2**`DATA_SIZE]};	 
	 }

	 // Constraint to set the transfer size
	 constraint size_of_transfer {
      transfer_size inside {8, 16, 32, 64};
	 }

   //This constraint is used to decide the pwdata size based om transfer size
   constraint pstrb_decl {
      if(transfer_size == 8)
        $countones(pstrb) == 1;
      else if(transfer_size == 16)
        $countones(pstrb) == 2;
      else if(transfer_size == 32)
        $countones(pstrb) == 3;
      else 
        $countones(pstrb) == 4;
   }		

endclass


// new constructor 
function apb_master_seq_item::new(string name = "apb_master_seq_item");
   super.new(name);
endfunction : new
