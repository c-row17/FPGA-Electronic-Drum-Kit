// FSR_tb.v
//
// Testbench for FSR (in FSR.v). We don't have the real FSR pads yet, so
// this just feeds in fake adc_sample values that look like what a real
// hit would produce: low while idle, ramps up past THRESHOLD, peaks,
// then ramps back down as the pad releases.
//
// What to look for in the waveform:
//   - hit_pulse should go high for exactly 1 cycle, right when adc_sample
//     first goes above THRESHOLD
//   - velocity should latch to the highest adc_sample value seen during
//     that hit (900 for hit #1, 650 for hit #2 below), and hold that
//     value until the next hit finishes
//
// Note: PEAK_WINDOW and LOCKOUT_SAMPLES are overridden to small numbers
// (5 and 15) here just so the sim finishes fast and the waveform is easy
// to read. The real design will use the bigger defaults. Because of this,
// the window doesn't actually "close" until a few samples into each hit's
// ramp -- that's expected, not a bug. Shrinking PEAK_WINDOW to 5 (instead
// of 10) also lets hit #2's velocity latch happen before the simulation's
// hard stop, so both hits fully resolve in the waveform.

`include "FSR.v"

module FSR_tb;

    parameter ADC_WIDTH = 10;

    reg clk;
    reg rst;
    reg [ADC_WIDTH-1:0] adc_sample;
    reg sample_valid;

    wire hit_pulse;
    wire [ADC_WIDTH-1:0] velocity;

    // device under test, with small windows so the sim runs fast
    FSR #(
        .ADC_WIDTH(ADC_WIDTH),
        .THRESHOLD(40),
        .PEAK_WINDOW(5),
        .LOCKOUT_SAMPLES(15)
    ) UUT (
        .clk(clk),
        .rst(rst),
        .adc_sample(adc_sample),
        .sample_valid(sample_valid),
        .hit_pulse(hit_pulse),
        .velocity(velocity)
    );

    // free running clock, 10ns period
    always begin
        #5 clk = ~clk;
    end

    // drives one ADC sample onto the DUT: sets adc_sample, pulses
    // sample_valid for 1 cycle, then waits a bit (mimics the real ADC
    // scan being slower than clk)
    task send_sample;
        input [ADC_WIDTH-1:0] value;
        begin
            @(posedge clk);
            adc_sample   = value;
            sample_valid = 1'b1;
            @(posedge clk);
            sample_valid = 1'b0;
            #20;
        end
    endtask

    integer i;

    initial begin
        $dumpfile("FSR_tb.vcd");
        $dumpvars(0, FSR_tb);

        clk          = 0;
        rst          = 1;
        adc_sample   = 0;
        sample_valid = 0;

        #20;
        rst = 0;

        // idle samples, pad not touched, stays below THRESHOLD (40)
        send_sample(10);
        send_sample(15);
        send_sample(12);

        // ---- hit #1: ramps up, peaks at 900, ramps back down ----
        send_sample(60);
        send_sample(200);
        send_sample(500);
        send_sample(900);   // peak of this hit -> should become velocity
        send_sample(700);
        send_sample(400);
        send_sample(100);
        send_sample(20);

        // idle samples, also lets the TRACK window finish and LOCKOUT
        // run out before the next hit
        for (i = 0; i < 20; i = i + 1)
            send_sample(10);

        // ---- hit #2: smaller hit, checks the FSM re-triggers fine ----
        send_sample(50);
        send_sample(300);
        send_sample(650);   // peak of this hit -> should become velocity
        send_sample(200);
        send_sample(15);

        for (i = 0; i < 20; i = i + 1)
            send_sample(10);

        $finish;
    end

endmodule