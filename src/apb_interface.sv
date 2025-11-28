interface apb_intf(input logic pclk);
  
	
  logic presetn;                 // PRESETn is the reset signal and is active-LOW. PRESETn is normally connected directly to the system bus reset signal.	
  logic [`ADDR_WIDTH-1:0] paddr; // address where data has to be written
	logic [`DATA_SIZE-1:0] pwdata; // Write data for the slave
	logic [`DATA_SIZE-1:0] prdata; // Read data from the slave
	logic pwrite;                  // to check the mode of transfer
  logic penable;                 // to check the mode of transferBLE indicates the second and subsequent cycles of an APB transfer.	
  logic [`PSEL_WIDTH-1:0]psel;   // Gives the slave to be chosen
  logic [3:0] pstrb;

  // Slave side signals
  logic pslverr;                 // error bit
	logic pready;                  // PREADY is used to extend an APB transfer by the completer	

  // driver clocking block
  clocking drv_cb@(posedge pclk);
    default input #0 output #0;
    output presetn, prdata, pready, pslverr;
  endclocking
  
  // active monitor clocking block
  clocking act_mon_cb@(posedge pclk);
    default input #0 output #0;    
    input presetn, prdata, pready, pslverr;    
  endclocking

	// passive monitor clocking block
	clocking pass_mon_cb@(posedge pclk);
		default input #0 output #0;
	  input psel, pwdata, pwrite, penable, paddr, pstrb;
	endclocking
  
  // modport for driver  
  modport DRV(clocking drv_cb);
  
	// modport for passive monitor
	modport PASS_MON(clocking act_mon_cb);
  
  // modport for active monitor
  modport ACT_MON(clocking pass_mon_cb);
  
endinterface
