//==============================================================================
// APB Master RTL Design - Updated Version
// Description: APB master with proper protocol compliance and zero-delay control
// Features: Back-to-back transfers, PREADY support, Error handling, No control delay
//==============================================================================
 
module apb_master #(
    parameter ADDR_WIDTH = 8,      // Address bus width
    parameter DATA_WIDTH = 32      // Data bus width
)(
    // Global Signals
    input  wire                    PCLK,       // Clock
    input  wire                    PRESETn,    // Active-low reset
    // APB Master Interface (to slave)
    output reg  [ADDR_WIDTH-1:0]   PADDR,      // Address
    output reg                     PSEL,       // Slave select
    output reg                     PENABLE,    // Enable
    output reg                     PWRITE,     // Write control (1=Write, 0=Read)
    output reg  [DATA_WIDTH-1:0]   PWDATA,     // Write data
    output reg  [DATA_WIDTH/8-1:0] PSTRB,      // Write strobe
    input  wire [DATA_WIDTH-1:0]   PRDATA,     // Read data
    input  wire                    PREADY,     // Ready signal from slave
    input  wire                    PSLVERR,    // Error signal from slave
    // User Interface (to initiate transactions)
    input  wire                    transfer,   // Start transfer request
    input  wire                    write_read, // 1=Write, 0=Read
    input  wire [ADDR_WIDTH-1:0]   addr_in,    // Input address
    input  wire [DATA_WIDTH-1:0]   wdata_in,   // Input write data
    input  wire [DATA_WIDTH/8-1:0] strb_in,    // Input write strobe
    output reg  [DATA_WIDTH-1:0]   rdata_out,  // Output read data
    output reg                     transfer_done, // Transfer complete flag
    output reg                     error        // Error flag
);
 
    //==========================================================================
    // Local Parameters - FSM States
    //==========================================================================
    localparam IDLE   = 2'b00;
    localparam SETUP  = 2'b01;
    localparam ACCESS = 2'b10;
    //==========================================================================
    // Internal Signals
    //==========================================================================
    reg [1:0] state, next_state;
    // Registered inputs for transaction
    reg [ADDR_WIDTH-1:0]   addr_reg;
    reg [DATA_WIDTH-1:0]   wdata_reg;
    reg [DATA_WIDTH/8-1:0] strb_reg;
    reg                    write_read_reg;
    //==========================================================================
    // State Register
    //==========================================================================
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            state <= IDLE;
        else
            state <= next_state;
    end
    //==========================================================================
    // Next State Logic - Supports Back-to-Back Transfers
    //==========================================================================
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (transfer)
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end
            SETUP: begin
                // Always move to ACCESS phase after SETUP (one cycle in SETUP)
                next_state = ACCESS;
            end
            ACCESS: begin
                // Wait for PREADY, then check for back-to-back transfers
                if (PREADY) begin
                    // If new transfer request, go directly to SETUP for back-to-back transfers
                    if (transfer)
                        next_state = SETUP;
                    else
                        next_state = IDLE;
                end
                else begin
                    // Stay in ACCESS if slave is not ready (wait states)
                    next_state = ACCESS;
                end
            end
            default: next_state = IDLE;
        endcase
    end
    //==========================================================================
    // Capture Input Signals at Start of Transfer
    //==========================================================================
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            addr_reg       <= {ADDR_WIDTH{1'b0}};
            wdata_reg      <= {DATA_WIDTH{1'b0}};
            strb_reg       <= {(DATA_WIDTH/8){1'b0}};
            write_read_reg <= 1'b0;
        end
        else if ((state == IDLE && transfer) || (state == ACCESS && PREADY && transfer)) begin
            // Capture inputs when:
            // 1. Transfer request arrives in IDLE state, OR
            // 2. Back-to-back transfer: current transfer completing and new one starting
            addr_reg       <= addr_in;
            wdata_reg      <= wdata_in;
            strb_reg       <= strb_in;
            write_read_reg <= write_read;
        end
    end
    //==========================================================================
    // APB Control Signal Generation - Using next_state for Zero Delay
    //==========================================================================
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PADDR   <= {ADDR_WIDTH{1'b0}};
            PSEL    <= 1'b0;
            PENABLE <= 1'b0;
            PWRITE  <= 1'b0;
            PWDATA  <= {DATA_WIDTH{1'b0}};
            PSTRB   <= {(DATA_WIDTH/8){1'b0}};
        end
        else begin
            case (next_state)
                IDLE: begin
                    // Bus idle - deassert control signals
                    PSEL    <= 1'b0;
                    PENABLE <= 1'b0;
                end
                SETUP: begin
                    // SETUP phase: Assert PSEL, drive address and control signals
                    PADDR   <= addr_reg;
                    PSEL    <= 1'b1;
                    PENABLE <= 1'b0;
                    PWRITE  <= write_read_reg;
                    if (write_read_reg) begin
                        PWDATA <= wdata_reg;
                        PSTRB  <= strb_reg;
                    end
                    else begin
                        PWDATA <= {DATA_WIDTH{1'b0}};
                        PSTRB  <= {(DATA_WIDTH/8){1'b0}};
                    end
                end
                ACCESS: begin
                    // ACCESS phase: Keep PSEL high, assert PENABLE
                    // All address and data signals remain stable
                    PSEL    <= 1'b1;
                    PENABLE <= 1'b1;
                end
                default: begin
                    PSEL    <= 1'b0;
                    PENABLE <= 1'b0;
                end
            endcase
        end
    end
    //==========================================================================
    // Read Data Capture
    //==========================================================================
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            rdata_out <= {DATA_WIDTH{1'b0}};
        end
        else if (state == ACCESS && PREADY && !write_read_reg) begin
            // Capture read data when PREADY is asserted during read operation
            rdata_out <= PRDATA;
        end
    end
    //==========================================================================
    // Transfer Done Flag
    //==========================================================================
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            transfer_done <= 1'b0;
        end
        else begin
            // Assert transfer_done for one cycle when transaction completes
            if (state == ACCESS && PREADY)
                transfer_done <= 1'b1;
            else
                transfer_done <= 1'b0;
        end
    end
    //==========================================================================
    // Error Flag
    //==========================================================================
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            error <= 1'b0;
        end
        else begin
            // Capture error when PSLVERR is asserted
            if (state == ACCESS && PREADY && PSLVERR)
                error <= 1'b1;
            else if (state == IDLE)
                error <= 1'b0;
        end
    end
 
endmodule
