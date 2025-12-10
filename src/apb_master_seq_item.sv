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

	typedef enum {IDLE, SETUP, ACCESS, ERROR} state_t;
  state_t state;
	
  `uvm_object_utils(apb_master_seq_item)
  
	constraint data_range { 
			addr_in inside {[0:1000]};
			wdata_in inside {[0:1000]};
			prdata inside {[0:1000]};
	}
	
	constraint default_values {
			soft transfer == 1;
			soft presetn == 1;
			soft pslverr == 0;
			soft pready == 0;
			write_read == 1;
			if(write_read) prdata == 0;
			else wdata_in == 0;
	}

  extern function new(string name = "apb_master_seq_item");
  extern function void sprint_inputs(string name);
	extern function void sprint_outputs(string name);
  extern function string get_transaction_type(bit n);
  extern function void get_current_state(ref apb_master_seq_item tmp);
endclass

function apb_master_seq_item::new(string name = "apb_master_seq_item");
   super.new(name);
endfunction : new

function void apb_master_seq_item::get_current_state(ref apb_master_seq_item tmp);
 case({presetn,tmp.psel,tmp.penable,pready}) 
	 4'b0000: tmp.state = IDLE;
	 4'b1000: tmp.state = IDLE;
	 4'b1111: tmp.state = ACCESS;
	 4'b1100: tmp.state = SETUP;
   default: tmp.state = ERROR;
 endcase
endfunction

function string apb_master_seq_item::get_transaction_type(bit n);
  return (n) ? "WRITE" : "READ";
endfunction

function void apb_master_seq_item::sprint_outputs(string name);
  $display("%s @(%0t) : Type : %s\n\t\tpsel = %0b | pwrite = %s",name, $time, get_transaction_type(pwrite),psel,get_transaction_type(pwrite));
	$display("\t\tpaddr = %0d | pwdata = %0d | rdata_out = %0d",paddr,pwdata,rdata_out);
	$display("\t\tpenable = %0b | pstrb = %0b | error = %0b | transfer_done = %0b\n", penable, pstrb, error, transfer_done);
	$display("***********************************************************************\n");
endfunction

function void apb_master_seq_item::sprint_inputs(string name);
  $display("\n%s @(%0t) Type: %s\n\t\tpresetn = %0b | transfer = %0b ", name,$time,get_transaction_type(write_read), presetn, transfer);
  $display("\t\taddr_in = %0d | wdata_in = %0d | prdata = %0d  ",addr_in, wdata_in,prdata);
  $display("\t\tstrb_in = %0b | pready = %0b | pslverr = %0b", strb_in, pready, pslverr);
	$display("***********************************************************************\n");
endfunction

