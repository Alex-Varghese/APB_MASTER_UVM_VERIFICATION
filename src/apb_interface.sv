interface apb_intf(input logic pclk);
  
  logic presetn;                 // PRESETn is the reset signal and is active-LOW. PRESETn is normally connected directly to the system bus reset signal.	
  logic [`ADDR_WIDTH-1:0] paddr; // address where data has to be written
	logic [`DATA_SIZE-1:0] pwdata; // Write data for the slave
	logic [`DATA_SIZE-1:0] prdata; // Read data from the slave
	logic pwrite;                  // to check the mode of transfer
  logic penable;                 // to check the mode of transferBLE indicates the second and subsequent cycles of an APB transfer.	
  logic [`PSEL_WIDTH-1:0]psel;   // Gives the slave to be chosen

  // Slave side signals
  logic pslverr;                 // error bit
	logic pready;                  // PREADY is used to extend an APB transfer by the completer	
	
  // driver clocking block
  clocking drv_cb@(posedge pclk);
    default input #0 output #0;
    output paddr, pwdata, paddr, pwrite, penable, ;
    
  endclocking
  
  // monitor clocking block
  clocking mon_cb@(posedge PCLK);
    default input #0 output #0;    
    input READ_WRITE, apb_write_paddr, apb_read_paddr, apb_write_data, apb_read_data_out, PSLVERR, transfer, PRESETn;    
  endclocking
  
  // modport for driver  
  modport DRV(clocking drv_cb, input PCLK, transfer, PRESETn);
  
  // modport for monitor
    
  modport MON(clocking mon_cb, input PCLK, transfer, PRESETn);
  
 // clock toggle  
  property p1;
    @(posedge PCLK) PCLK != $past(1, PCLK);
  endproperty
  assert property(p1)begin
    $info("PCLK is toggling");
  end
  else begin
    $error("PCLK is not toggling");
  end
  
  //valid inputs
  property p2;
    @(posedge PCLK) disable iff(!PRESETn )transfer |-> not($isunknown({READ_WRITE, apb_write_paddr, apb_read_paddr, apb_write_data}));
  endproperty
  assert property(p2)begin
    $info("VALID INPUTS");
  end
  else begin
    $error("INVALID INPUTS");
  end
    
  //RESET CHECK
    
  property p3;
    @(posedge PCLK) !PRESETn |-> ({PSLVERR, apb_read_data_out} == 'b0);
  endproperty
  assert property(p3)
    $info("RESET passed");
  else begin
    $error("RESET failed");
  end 
    
endinterface
