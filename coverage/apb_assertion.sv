module assertion;

//////////////////////////////////////////////////////////////
//
// ------------------- Sequences ---------------------------//
//
//////////////////////////////////////////////////////////////
  sequence idle_phase;

	endsequence



//////////////////////////////////////////////////////////////
//
// ------------------ Properties ---------------------------//
//
//////////////////////////////////////////////////////////////
	property check_unknown(signal);
		@(posedge clk) disable iff(!presetn)
			!$isunknown(signal);
	endproperty

	property check_stable(signal);
		@(posedge clk) disable iff(!presetn)
			!$stable(signal) |-> setup_phase or idle_phase;
	endproperty

	property psel_stable_in_transfer;
		@(posedge clk) disable iff(!presetn)
			!psel && $past(psel) |-> $past(penable) && $past(pready);
	endproperty
  
	property pwdata_in_write_read;
		@(posedge clk) disable iff(!presetn)
			!$stable(pwdata) |-> !pwrite or setup_phase or idle_phase;
	endproperty
	
	property penable_in_transfer;
		@(posedge clk) disable iff(!presetn)
			$fell(penable) |-> idle_phase or ($past(penable) && $past(pready));
	endproperty

	property idle_state;
		@(posedge clk) disable iff(!presetn)
			idle_phase |-> ##1 idle_phase or setup_phase;
	endproperty

	property setup_state;
		@(posedge clk) disable iff(!presetn)
			setup_phase |-> ##1 access_phase;
	endproperty

	property access_state;
		@(posedge clk) disable iff(!presetn)
			;
	endproperty
	property check_stable;
		@(posedge clk) disable iff(!presetn)
			!psel && $past(psel) |-> $past(penable) && $past(pready);
	endproperty
endmodule
