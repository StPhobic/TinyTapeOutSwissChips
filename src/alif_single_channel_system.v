`timescale 1ns / 1ps

module alif_single_channel_system (
    // System signals
    input wire clk,
    input wire reset,
    input wire enable,
    input wire input_enable,  // Neuron operation control
    
    // Single input channel
    input wire [5:0] chan_a,  // 3-bit precision (single channel only)
    
    // Configuration interface
    input wire load_mode,
    input wire serial_data,
    
    // Outputs
    output wire spike_out,
    output wire [6:0] v_mem_out,
    output wire params_ready
);

// Internal parameter wires
wire [2:0] weight_a;
wire [7:0] leak_rate;
wire [7:0] threshold_min;
wire [3:0] leak_cycles;
wire loader_params_ready;

// Data loader instance
alif_single_channel_data_loader loader (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .serial_data_in(serial_data),
    .load_enable(load_mode),
    .weight_a(weight_a),
    .leak_rate(leak_rate),
    .threshold_min(threshold_min),
    .leak_cycles(leak_cycles),
    .params_ready(loader_params_ready)
);

// LIF neuron instance
alif_single_channel_neuron neuron (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .input_enable(input_enable),
    .chan_a(chan_a),
    .weight_a(weight_a),
    .leak_rate(leak_rate),
    .threshold_min(threshold_min),
    .leak_cycles(leak_cycles),
    .params_ready(loader_params_ready),
    .spike_out(spike_out),
    .v_mem_out(v_mem_out)
);

assign params_ready = loader_params_ready;

endmodule

