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
  

				constraint val { if(psel && penable) pready == 1; presetn == 1; pslverr == 0; }	

	//-------------------------------------------------------
	// Externally defined Tasks and Functions
	//-------------------------------------------------------	
  extern function new(string name = "apb_master_seq_item");
  extern function void print_inputs(string name);
  extern function void sprint_inputs(string name);
	extern function void sprint_outputs(string name);
  extern function void print_outputs(string name);
  extern function void print_all(string name);
  extern function string get_transaction_type();
endclass


// new constructor 
function apb_master_seq_item::new(string name = "apb_master_seq_item");
   super.new(name);
endfunction : new

function string apb_master_seq_item::get_transaction_type();
  return (write_read == 1) ? "WRITE" : "READ";
endfunction

function void apb_master_seq_item::print_inputs(string name);
	$display("\n=== %s @(%0t) ===",name,$time);
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

function void apb_master_seq_item::sprint_inputs(string name);
  $write("\n%s @(%0t) Type: %s | PRESETn: %0d | Transfer: %0b | Address: %0d | ", 
         name,$time,get_transaction_type(), presetn, transfer, addr_in);
  if(get_transaction_type() == "WRITE")
    $write("WDATA: %0d | ", wdata_in);
  else
    $write("PRDATA: %0d | ", prdata);
  $write("Strobe: %0b | Status: %s | Slave Ready: %0b | Slave Error: %0b \n", 
         strb_in, (error ? "ERROR" : (transfer_done ? "COMPLETE" : "IN_PROGRESS")), pready, pslverr);
endfunction

function void apb_master_seq_item::print_outputs(string name);
	$display("\n=== %s @(%0t) ===",name,$time);
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

function void apb_master_seq_item::sprint_outputs(string name);
  $write("\n%s @(%0t) | Type: %s | Slave: %0d | Address: 0x%0h | ", 
         name, $time, get_transaction_type(), psel, paddr);
  if(get_transaction_type() == "WRITE")
    $write("WDATA: 0x%0h | ", pwdata);
  else
    $write("PRDATA: 0x%0h | ", rdata_out);
  $write("Strobe: 0x%0h | Status: %s |", 
         pstrb, (error ? "ERROR" : (transfer_done ? "COMPLETE" : "IN_PROGRESS")));
endfunction

function void apb_master_seq_item::print_all(string name);
	$display("\n=== %s @(%0t) ===",name,$time);
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
