// FSR.v
//
// Takes the ADC readings for one FSR pad and outputs:
//   - hit_pulse : goes high for exactly 1 clock cycle when a hit starts
//   - velocity  : how hard the pad was hit (the peak ADC code during the hit)
//
// How it works: this is a simple state machine with 3 states.
//   IDLE    -> waiting, watching for the sample to go above THRESHOLD
//   TRACK   -> a hit is happening, keep track of the biggest sample seen
//   LOCKOUT -> hit is done, wait a bit before allowing the next hit
//              (this is needed because the pad bounces a little after
//              being pressed, and we don't want that to look like
//              several separate hits)
//
// Note: a separate module somewhere else needs to be scanning the
// ADC/mux across all the pads and feeding this module adc_sample and
// sample_valid for THIS pad only.

module FSR (
    clk,
    rst,
    adc_sample,
    sample_valid,
    hit_pulse,
    velocity
);

    // how wide the ADC reading is. 12 = Basys 3's onboard XADC (0-4095)
    parameter ADC_WIDTH = 12;

    // rest-noise floor. anything below this counts as "not touched"
    // 160 on a 12-bit (0-4095) range -- retune once real FSR readings
    // are in hand
    parameter THRESHOLD = 160;

    // how many samples to watch during a hit before we decide the peak is final
    parameter PEAK_WINDOW = 200;

    // how many samples to wait after a hit before allowing a new one
    // (absorbs the pad's mechanical bounce)
    parameter LOCKOUT_SAMPLES = 400;

    input clk;
    input rst;
    input [ADC_WIDTH-1:0] adc_sample;   // latest ADC reading for this pad
    input sample_valid;                 // goes high for 1 cycle when adc_sample is new

    output hit_pulse;                   // 1 cycle pulse, high when a new hit starts
    output [ADC_WIDTH-1:0] velocity;    // peak ADC code from the last completed hit

    reg hit_pulse;
    reg [ADC_WIDTH-1:0] velocity;

    // state names
    parameter IDLE    = 2'd0;
    parameter TRACK   = 2'd1;
    parameter LOCKOUT = 2'd2;

    reg [1:0] state;

    reg [ADC_WIDTH-1:0] peak_reg;   // running max sample while in TRACK
    reg [15:0] win_count;           // counts samples spent in TRACK
    reg [15:0] lock_count;          // counts samples spent in LOCKOUT

    always @(posedge clk) begin
        if (rst) begin
            state      <= IDLE;
            hit_pulse  <= 1'b0;
            velocity   <= 0;
            peak_reg   <= 0;
            win_count  <= 0;
            lock_count <= 0;
        end
        else begin
            // hit_pulse should only be high for 1 cycle, so default it
            // low here and only set it high in the exact spot a hit starts
            hit_pulse <= 1'b0;

            case (state)

                // ---- IDLE: waiting for a hit to start ----
                IDLE: begin
                    if (sample_valid && adc_sample > THRESHOLD) begin
                        peak_reg  <= adc_sample;
                        win_count <= 1;
                        hit_pulse <= 1'b1;   // tell everyone a hit just started
                        state     <= TRACK;
                    end
                end

                // ---- TRACK: hit in progress, watching for the peak ----
                TRACK: begin
                    if (sample_valid) begin
                        // keep the biggest sample seen so far
                        if (adc_sample > peak_reg)
                            peak_reg <= adc_sample;

                        win_count <= win_count + 1;

                        // window is over, lock in the peak as this hit's velocity
                        if (win_count >= PEAK_WINDOW) begin
                            velocity   <= peak_reg;
                            lock_count <= 0;
                            state      <= LOCKOUT;
                        end
                    end
                end

                // ---- LOCKOUT: ignore bounce, wait before next hit ----
                LOCKOUT: begin
                    if (sample_valid) begin
                        lock_count <= lock_count + 1;
                        if (lock_count >= LOCKOUT_SAMPLES)
                            state <= IDLE;
                    end
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule