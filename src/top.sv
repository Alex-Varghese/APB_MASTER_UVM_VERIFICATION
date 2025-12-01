`include "uvm_macros.svh"
`include "apb_interface.sv"
`include "apb_pkg.sv"
`include "../design/apb_master.sv"

module top;
  import uvm_pkg::*;
  import apb_pkg::*;

  bit pclk;

  always #5 pclk = ~pclk;

  apb_intf intf(pclk);

  apb_master dut(
    .PCLK         (pclk),
    .PRESETn      (intf.presetn),
    .PADDR        (intf.paddr),
    .PSEL         (intf.psel),
    .PENABLE      (intf.penable),
    .PWRITE       (intf.pwrite),
    .PWDATA       (intf.pwdata),
    .PSTRB        (intf.pstrb),
    .PRDATA       (intf.prdata),
    .PREADY       (intf.pready),
    .PSLVERR      (intf.pslverr),
    .transfer     (intf.transfer),
    .write_read   (intf.write_read),
    .addr_in      (intf.addr_in),
    .wdata_in     (intf.wdata_in),
    .strb_in      (intf.strb_in),
    .rdata_out    (intf.rdata_out),
    .transfer_done(intf.transfer_done),
    .error        (intf.error)
); 

  initial begin
    uvm_config_db#(virtual apb_intf)::set(null, "*", "apb_intf", intf);
    run_test("apb_base_test");
  end
endmodule
