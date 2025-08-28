/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

module tt_um_alif_single_channel (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Internal signals for system interface
    wire reset = ~rst_n;           // Convert active-low reset to active-high
    wire enable = ena;             // Use enable signal
    
    // Input signal assignments from TinyTapeout interface
    wire input_enable = ui_in[0];  // Neuron operation control
    wire load_mode   = ui_in[1];   // Configuration mode control
    wire serial_data = ui_in[2];   // Serial configuration data input
    wire [5:0] chan_a = {uio_in[0], ui_in[7:3]}; // Channel A (6-bit single channel input)
    
    // Internal output wires from system module
    wire spike_out;
    wire [6:0] v_mem_out;
    wire params_ready;
    
    // ALIF single channel system instantiation
    alif_single_channel_system system_inst (
        // System signals
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .input_enable(input_enable),
        
        // Single input channel (6-bit)
        .chan_a(chan_a),
        
        // Configuration interface
        .load_mode(load_mode),
        .serial_data(serial_data),
        
        // Outputs
        .spike_out(spike_out),
        .v_mem_out(v_mem_out),
        .params_ready(params_ready)
    );
    
    // Output signal assignments to TinyTapeout interface
    assign uo_out[0] = spike_out;           // Spike output signal
    assign uo_out[7:1] = v_mem_out;         // 7-bit membrane potential output
    
    // Bidirectional I/O configuration
    assign uio_out[0] = params_ready;       // Parameter ready status as output
    assign uio_out[7:1] = 7'b0;             // Unused bidirectional outputs set to 0
    
    // Set bidirectional pin directions
    assign uio_oe[0] = 1'b1;                // uio[0] used for params_ready output
    assign uio_oe[7:1] = 7'b0;              // uio[7:1] set as inputs (chan_a[5] uses uio_in[0])
    
    // List unused inputs to prevent warnings
    wire _unused = &{uio_in[7:1], 1'b0};

endmodule
