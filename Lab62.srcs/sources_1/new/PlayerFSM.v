module PlayerFSM(
        input clk,
        input noLives,
        input releas,
        input peak,
        input grounded,
        input press,
        output fall,
        output rise,
        output increaseBar,
        output [3:0] state
    );

    parameter Idle = 4'b0001;
    parameter Jumping = 4'b0010;
    parameter Falling = 4'b0100;
    parameter Dead  = 4'b1000;

    wire [3:0] cs;
    wire [3:0] ns;


    assign ns[0] = (cs[0] & ~releas & grounded & ~noLives) | (cs[2] & grounded);
    assign ns[1] = (cs[1] & ~peak) | (cs[0] & releas);
    assign ns[2] = (cs[2] & ~grounded) | (cs[1] & peak) | (cs[0] & ~grounded);
    assign ns[3] = (cs[0] & noLives) | (cs[3]);


    FDRE #(.INIT(1'b1)) ff  (.C(clk), .R(1'b0), .CE(1'b1), .D(ns[0]), .Q(cs[0]));
    FDRE #(.INIT(1'b0)) ff1 (.C(clk), .R(1'b0), .CE(1'b1), .D(ns[1]), .Q(cs[1]));
    FDRE #(.INIT(1'b0)) ff2 (.C(clk), .R(1'b0), .CE(1'b1), .D(ns[2]), .Q(cs[2]));
    FDRE #(.INIT(1'b0)) ff3 (.C(clk), .R(1'b0), .CE(1'b1), .D(ns[3]), .Q(cs[3]));

    assign fall = cs[2];
    assign rise = cs[1];

    assign increaseBar = press & cs[0];
    assign state = cs;

endmodule