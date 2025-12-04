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

	typedef enum {RESET, IDLE, SETUP, ACCESS, ERROR} state_t;
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
			if(write_read) prdata == 0;
			else wdata_in == 0;
	}

  extern function new(string name = "apb_master_seq_item");
  extern function void sprint_inputs(string name);
	extern function void sprint_outputs(string name);
  extern function void print_all(string name, apb_master_seq_item tmp);
  extern function string get_transaction_type(bit n);
  extern function void get_current_state(apb_master_seq_item tmp);
endclass


// new constructor 
function apb_master_seq_item::new(string name = "apb_master_seq_item");
   super.new(name);
endfunction : new

function void apb_master_seq_item::get_current_state(apb_master_seq_item tmp);
 case({presetn,tmp.psel,tmp.penable,pready}) 
	 4'b0000: state = RESET;
	 4'b1000: state = IDLE;
	 4'b1111: state = ACCESS;
	 4'b1100: state = SETUP;
   default: state = ERROR;
 endcase
endfunction

function string apb_master_seq_item::get_transaction_type(bit n);
  return (n) ? "WRITE" : "READ";
endfunction

function void apb_master_seq_item::print_all(string name, apb_master_seq_item tmp);
	get_current_state(tmp);
	$display("\n|--------------------------------------------------------|");
	$display("|\t\t    %s @(%0t) ",name,$time);
	$display("|--------------------------------------------------------|");
  $display("|\tType    \t\t:\t%s", get_transaction_type(tmp.pwrite));
  $display("|\tState   \t\t:\t%s", state);
	$display("|--------------------------------------------------------|");
	$display("|\tINPUTS : ");
  $display("|\t\tpresetn \t\t:\t%0d", presetn);
  $display("|\t\ttransfer\t\t:\t%0b", transfer);
  $display("|\t\taddr_in \t\t:\t%0d", addr_in);
  if(get_transaction_type(write_read) == "WRITE")
	  $display("|\t\twdata_in  \t\t:\t%0d", wdata_in);
  else
		$display("|\t\tprdata  \t\t:\t%0d", prdata);
  $display("|\t\tstrb_in \t\t:\t%0b", strb_in);
  $display("|\t\tpslverr \t\t:\t%0b", pslverr);
	$display("|--------------------------------------------------------|");
	$display("|\tOUTPUTS : ");
  $display("|\t\tpaddr   \t\t:\t%0d", tmp.paddr);
  if(get_transaction_type(tmp.pwrite) == "WRITE")
	  $display("|\t\tpwdata   \t\t:\t%0d", tmp.pwdata);
  else
		$display("|\t\trdata_out\t\t:\t%0d", tmp.rdata_out);
	$display("|--------------------------------------------------------|");
  $display("|\t\tpsel    \t\t:\t%0b", tmp.psel);
  $display("|\t\tpenable \t\t:\t%0b", tmp.penable);
  $display("|\t\tpready  \t\t:\t%0b", tmp.pready);
  $display("|\t\tStatus  \t\t:\t%s", (tmp.error ? "ERROR" : (tmp.transfer_done ? "TRANSFER_DONE" : "IN_PROGRESS")));
	$display("|--------------------------------------------------------|\n");
endfunction

function void apb_master_seq_item::sprint_outputs(string name);
  $display("%s @(%0t) : Type : %s\n\t\tpsel = %0b | pwrite = %s",name, $time, get_transaction_type(pwrite),psel,get_transaction_type(pwrite));
	//if(get_transaction_type(pwrite) == "WRITE")
		$display("\t\tpaddr = %0d | pwdata = %0d | rdata_out = %0d",paddr,pwdata,rdata_out);
	//else
	//	$display("\t\tpaddr = 0x%0h | rdata_out = 0x%0h ",paddr,rdata_out);
	$display("\n\t\tpenable = %0b | pstrb = %0b | error = %0b | transfer_done = %0b\n", penable, pstrb, error, transfer_done);
	$display("***********************************************************************\n");
endfunction

function void apb_master_seq_item::sprint_inputs(string name);
  $display("\n%s @(%0t) Type: %s\n\t\tpresetn = %0b | transfer = %0b ", name,$time,get_transaction_type(write_read), presetn, transfer);
  //if(get_transaction_type(write_read) == "WRITE")
    $display("\t\taddr_in = %0d | wdata_in = %0d | prdata = %0d  ",addr_in, wdata_in,prdata);
	//else
    //$display("\t\taddr_in = %0d | prdata = %0d  ", addr_in, prdata);
  $display("\t\tstrb_in = %0b | pready = %0b | pslverr = %0b", strb_in, pready, pslverr);
	$display("***********************************************************************\n");
endfunction

