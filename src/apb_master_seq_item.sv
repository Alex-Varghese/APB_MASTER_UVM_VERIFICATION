class apb_master_seq_item extends uvm_sequence_item;
 

	////////////////////////////////////////////////////
	//
  // Input signals
	//
	////////////////////////////////////////////////////
	rand bit presetn;                   // PRESETn is the reset signal and is active-LOW. 	
  rand bit transfer;
	rand bit write_read;
  rand bit [`ADDR_WIDTH-1:0] addr_in;
	rand bit [`DATA_WIDTH-1:0] wdata_in;
	rand bit [(`DATA_WIDTH/8)-1:0] strb_in;
  rand bit pslverr;            	 			 // error bit
	rand bit pready;                     // PREADY is used to extend an APB transfer by the completer	
	rand bit [`DATA_WIDTH-1:0] prdata;        // Read data from the slave

	////////////////////////////////////////////////////
	//
  // Output signals
	//
	////////////////////////////////////////////////////
  bit psel;     // Gives the slave to be chosen
	bit [`ADDR_WIDTH-1:0] paddr;  // address where data has to be written
	bit pwrite;                    // to check the mode of transfer
  bit penable;                   // to check the mode of transferBLE indicates the second and subsequent cycles of an APB transfer.	
	bit error;
	bit transfer_done;
	bit [`DATA_WIDTH-1:0] rdata_out;
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
  extern function new(string name = "apb_master_seq_item");
  extern function void print_inputs();
  extern function void print_outputs();
  extern function void print_all();
  extern function string get_transaction_type();
endclass


// new constructor 
function apb_master_seq_item::new(string name = "apb_master_seq_item");
   super.new(name);
endfunction : new

function string apb_master_seq_item::get_transaction_type();
  return (write_read == 1) ? "WRITE" : "READ";
endfunction

function void apb_master_seq_item::print_inputs();
	$display("\n=== APB INPUTS ===");
  $display("Type:          %s", get_transaction_type());
  $display("PRESETn:       %0d", presetn);
  $display("Transfer:      %0b", transfer);
  $display("Address:       %0d", addr_in);
  if(get_transaction_type() == "WRITE")
	  $display("WDATA:       %0d", wdata_in);
  else
		$display("PRDATA:        %0d", prdata);
  $display("Strobe:        %0b", strb_in);
  $display("Status:        %s", (error ? "ERROR" : (transfer_done ? "COMPLETE" : "IN_PROGRESS")));
  $display("Slave Ready:   %0b", pready);
  $display("Slave Error:   %0b", pslverr);
  $display("================================"); 
endfunction


function void apb_master_seq_item::print_outputs();
	$display("\n=== APB INPUTS ===");
  $display("Type:          %s", get_transaction_type());
  $display("Slave:         %0d", psel);
  $display("Address:       0x%0h", paddr);
  if(get_transaction_type() == "WRITE")
	  $display("WDATA:    0x%0h", pwdata);
  else
		$display("PRDATA:     0x%0h", rdata_out);
  $display("Strobe:        0x%0h", pstrb);
  $display("Status:        %s", (error ? "ERROR" : (transfer_done ? "COMPLETE" : "IN_PROGRESS")));
  $display("================================"); 
endfunction


function void apb_master_seq_item::print_all();
	$display("\n=== APB INPUTS ===");
  $display("Type:          %s", get_transaction_type());
  $display("PRESETn:       %0d", presetn);
  $display("Transfer:      %0b", transfer);
  $display("Address:       0x%0h", addr_in);
  if(get_transaction_type() == "WRITE")
	  $display("WDATA:    0x%0h", wdata_in);
  else
		$display("PRDATA:     0x%0h", prdata);
  $display("Strobe:        0x%0h", strb_in);
  $display("Status:        %s", (error ? "ERROR" : (transfer_done ? "COMPLETE" : "IN_PROGRESS")));
  $display("Slave Ready:   %0b", pready);
  $display("Slave Error:   %0b", pslverr);
  $display("================================"); 
endfunction
