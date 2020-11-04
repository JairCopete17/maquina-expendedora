////////////////////////////////////////////////////////////////////////////////
// Fecha de Creación: 20/10/2020
// Nombre del diseño: Maquina_Expendedora_De_Gaseosas.
// Nombre del módulo: vendingmachine.v
// 
// Descripción:
//		El modulo vendingmachine tendrá todo el funcionamiento de la maquina 
// expendedora basado en los diagramas de estados hechos anteriormente.
// 
// Comentarios adicionales:
//    selProducto tomará los valores de:
//			000[0] para cuando no hay selección,
//			001[1] para Seven Up,
//			010[2] para Manzana y
//			100[3] para Pepsi.
// 	selDinero y selVueltas tomará los valores de:
//			0[0] para cuando no hay selección,
//			1[1] para monedas de 100,
//			2[2] para monedas de 200,
//			4[3] para monedas de 500,
//			8[4] para billetes de 1000,
//			16[5] para billetes de 2000,
//			32[6] para billetes de 5000.
// 	selMensaje tomará los valores de:
//			00000[0] para cuando no hay selección,
//			00001[1] para decir: Ingresar dinero: ,
//			00010[2] para decir: Seleccionar producto: ,
//			00100[3] para decir: No hay existencias.,
//			01000[4] para decir: El dinero ingresado es: ,
//			10000[5] para decir: Gracias! Vuelva pronto.
////////////////////////////////////////////////////////////////////////////////
module vendingMachine(clk, rst, cancel, selproducto, seldinero, sensrr, selMensaje, selVueltas, devolver);
input clk, rst, cancel;
input [2:0] selproducto; input [6:0] seldinero; input [2:0] sensrr;
output reg [5:0] selMensaje; output reg [6:0] selVueltas; output reg devolver;
reg [5:0] state, stateO, sens, cancelar, selProducto, selDinero, sensor;
reg c100, c200, c500, c1000, c2000, c5000, lectura;
integer cnt;
assign cancel = cancelar;
assign selproducto = selProducto;
assign seldinero = selDinero;
assign sensrr = sensor;

always @(posedge clk) begin
	 if(rst == 1)begin
		selProducto = 0; selDinero = 0; sensor = 0;
		selMensaje = 0; selVueltas = 0; state = 0;
		stateO = 0; sens = 0; cnt = 0; devolver = 0;
	 end
	 if(cancelar == 1)begin
		selProducto = 0; selDinero = 0; sensor = 0;
		selMensaje = 0; selVueltas = 0; state = 0;
		stateO = 0; sens = 0; cnt = 0; devolver = 1;
	 end
    case(state)
        0: begin//Espere
			  selMensaje[1] = 1;
			  if(selDinero != 0)state = 1;
					else state = 0;
		  end
        1: begin//Contar hasta 1600 o mas
			  if(selDinero == 1) cnt = cnt + 100;
			  if(selDinero == 2) cnt = cnt + 200;
			  if(selDinero == 4) cnt = cnt + 200;
			  if(selDinero == 8) cnt = cnt + 1000;
			  if(selDinero == 16) cnt = cnt + 2000;
			  if(selDinero == 32) cnt = cnt + 5000;
			  if(cnt >= 1600) state = 2;
					else state = 1;
		  end
        2: begin //Esperar seleccion
			  selMensaje[4] = 1;
			  if(selProducto == 0)begin
					state = 2;
					selMensaje[2] = 1;
			  end 
					else state = 3;
			  if(cancelar == 1) state = 6;
		  end
        3: begin //Verificar existencia
			  case(selProducto)	
				  001:sens = sensor[0];
				  010:sens = sensor[1];
				  100:sens = sensor[2];
			  endcase
			  if(sens != 0) state = 5;
					else state = 4;
			  if(cancelar == 1) state = 6;
		  end
        4: begin //No existencia
			  if(selProducto == 0)begin
					state = 4;
					selMensaje[3] = 1;
			  end 
					else begin
						cancelar = 1;
						state = 0;
					end
		  end
        5: begin //Entregar producto
			  if(sens != 0)begin
					state = 6;
					selMensaje[5] = 1;
			  end 
					else state = 5;
		  end
        6: begin //Devolución de dinero
					case (stateO)
						 0: //Inicio
						 stateO = 1;
						 1: begin //Lectura y suma
							 if(cnt == 2000) stateO = 2;
								  else stateO = 1;
							 if(cnt == 5000) stateO = 3;
								  else stateO = 1;
							 if(cnt == 1700) stateO = 4;
								  else stateO = 1;
						 end
						 2: begin //Caso cuando pagan con un billete de 2000
							 if(cnt == 2000) begin
								  case (selVueltas)
										00: c100 = 4;
										01: c200 = 2;
										10: begin c100 = 2; c200 = 1; end
								  endcase
										stateO = 5;
							 end
						 end
						 3: begin // Caso cuando pagan con un billete de 5000
							 if(cnt == 5000) begin
								  case (selVueltas)
										0000: begin c1000 = 3; c100 = 4; end
										0001: begin c1000 = 3; c200 = 2; end
										0010: begin c1000 = 3; c100 = 2; c200 = 1; end
										0011: begin c1000 = 1; c2000 = 1; c100 = 4; end
										0100: begin c1000 = 1; c2000 = 1; c200 = 2; end
										0101: begin c1000 = 1; c2000 = 1; c100 = 2; c200 = 1; end
										0110: begin c500 = 2; c2000 = 1; c100 = 4; end
										0111: begin c500 = 2; c2000 = 1; c200 = 2; end
										1000: begin c500 = 2; c2000 = 1; c100 = 2; c200 = 1; end
										1001: begin c500 = 6; c100 = 4; end
										1010: begin c500 = 6; c200 = 2; end
										1011: begin c500 = 6; c100 = 2; c200 = 1; end
								  endcase
										stateO = 5;
							 end
						 end
						 4: begin // Caso cuando pagan con 1700
							 if(lectura == 1700) begin
								  case (selVueltas)
										00: c100 = 1;
								  endcase
										stateO = 5;
							 end
						 end
						 5: begin//Salida/Vueltas
							 devolver = 1;
							 selVueltas = c100 + c200 + c500 + c1000 + c2000;
						 end
					endcase
				state = 0;
				end
    endcase
end
endmodule
