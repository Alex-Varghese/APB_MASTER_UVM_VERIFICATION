`uvm_analysis_imp_decl(_mon)

class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)

  apb_master_seq_item act_mon_queue[$];

  uvm_analysis_imp_mon#(apb_master_seq_item, apb_scoreboard) mon_imp;

  typedef enum {IDLE, SETUP, ACCESS} state_t;
  state_t current_state;

  logic [`ADDR_WIDTH-1:0] stored_addr;
  logic [`DATA_WIDTH-1:0] stored_wdata;
  logic stored_write;

  int match_count;
  int mismatch_count;
  int transaction_count;

  extern function new(string name = "apb_scoreboard", uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void write_mon(apb_master_seq_item req);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void get_current_state(apb_master_seq_item act);
  extern virtual function void update_next_state(apb_master_seq_item act);
  extern function void report_phase(uvm_phase phase);
endclass

  function apb_scoreboard::new(string name = "apb_scoreboard", uvm_component parent);
    super.new(name, parent);
    current_state = IDLE;
  endfunction

  function void apb_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_imp = new("act_mon_imp", this);
  endfunction

  function void apb_scoreboard::write_mon(apb_master_seq_item req);
    act_mon_queue.push_back(req);
  endfunction

  task apb_scoreboard::run_phase(uvm_phase phase);
    apb_master_seq_item act_seq, exp_seq;

    forever begin
      wait(act_mon_queue.size() > 0);

      act_seq  = act_mon_queue.pop_front();
      act_seq.sprint_inputs("Driver");
      get_current_state(act_seq);
      update_next_state(act_seq);
      transaction_count++;
    end
  endtask

  function void apb_scoreboard::get_current_state(apb_master_seq_item act);
    apb_master_seq_item exp = apb_master_seq_item::type_id::create("exp");

    if(act.presetn == 0) begin
      exp.psel = 0;
      exp.penable = 0;
    end
    else begin
      case(current_state)
        IDLE: begin
          exp.psel = 0;
          exp.penable = 0;
        end
        SETUP: begin
          exp.psel = 1;
          exp.penable = 0;
          exp.paddr = stored_addr;
          exp.pwdata = stored_wdata;
          exp.pwrite = stored_write;
        end
        ACCESS: begin
          exp.psel = 1;
          exp.penable = 1;
          exp.paddr = stored_addr;
          exp.pwdata = stored_wdata;
          exp.pwrite = stored_write;
        end
      endcase
    end

    if(exp.psel !== act.psel || exp.penable !== act.penable) begin
       `uvm_error("SCB_FAIL", $sformatf("State: %s | Reset: %0b | PSEL Exp/Act: %b/%b | PENABLE Exp/Act: %b/%b", current_state.name(), act.presetn, exp.psel, act.psel, exp.penable, act.penable));
       mismatch_count++;
    end
    else begin
       `uvm_info("SCB_PASS", $sformatf("State: %s | Reset: %0b | PSEL Exp/Act: %b/%b | PENABLE Exp/Act: %b/%b", current_state.name(), act.presetn, exp.psel, act.psel, exp.penable, act.penable), UVM_MEDIUM);
       match_count++;
    end
    
    if(exp.psel && act.presetn) begin
        if(exp.paddr !== act.paddr) begin
            `uvm_error("SCB_ADDR", $sformatf("Addr matching: Exp = %0d | Act = %0d", exp.paddr, act.paddr));
        end else begin
            `uvm_info("SCB_ADDR", $sformatf("Addr matching: Exp = %0d | Act = %0d", exp.paddr, act.paddr), UVM_MEDIUM);
        end
        
        if(exp.pwrite !== act.pwrite) begin
            `uvm_error("SCB_WR", "Write/Read Mismatch");
        end else begin
            `uvm_info("SCB_PWRITE", $sformatf("pwrite matching: Exp = %0b | Act = %0b", exp.pwrite, act.pwrite), UVM_MEDIUM);
        end
        
        if(exp.pwrite && (exp.pwdata !== act.pwdata)) begin
            `uvm_error("SCB_WDATA", $sformatf("WData Mismatch : Exp = %0d | Act = %0d", exp.pwdata, act.pwdata));
        end else if (exp.pwrite) begin
            `uvm_info("SCB_PWDATA", $sformatf("WData match : Exp = %0d | Act = %0d", exp.pwdata, act.pwdata), UVM_MEDIUM);
        end
        
        if(!exp.pwrite && (exp.prdata !== act.prdata)) begin
            `uvm_error("SCB_RDATA", $sformatf("RData Mismatch : Exp = %0d | Act = %0d", exp.prdata, act.prdata));
        end else if (!exp.pwrite) begin
            `uvm_info("SCB_PRDATA", $sformatf("RData match : Exp = %0d | Act = %0d", exp.prdata, act.prdata), UVM_MEDIUM);
        end
    end
  endfunction

  function void apb_scoreboard::update_next_state(apb_master_seq_item act);
    if(act.presetn == 0) begin
      current_state = IDLE;
      return;
    end
    case(current_state)
      IDLE: begin
        if (act.transfer) begin
          current_state = SETUP;
          stored_addr  = act.addr_in;
          stored_wdata = act.wdata_in;
          stored_write = act.write_read;
        end
      end

      SETUP: begin
        current_state = ACCESS;
      end

      ACCESS: begin
        if(act.pready) begin
           current_state = IDLE;
        end 
        else begin
           current_state = ACCESS;
        end
      end
    endcase
  endfunction

  function void apb_scoreboard::report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB_SUMMARY", $sformatf("TOTAL TRANSACTION : %0d", transaction_count), UVM_NONE);
      
    if(mismatch_count == 0) begin
      `uvm_info("SCB_SUMMARY", $sformatf("TEST PASSED: %0d Matches Captured", match_count), UVM_NONE);
    end
    else begin
      `uvm_error("SCB_SUMMARY", $sformatf("TEST FAILED: %0d Mismatches Found", mismatch_count));
    end
  endfunction



