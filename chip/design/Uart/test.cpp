#include <VUART_LB.h>
#include "testbench.h"

void transfer_byte (TESTBENCH<VUART_LB>*, char);
void wait_baud (TESTBENCH<VUART_LB>*);

int main (int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  TESTBENCH<VUART_LB> *tb = new TESTBENCH<VUART_LB>();
	int i;

  tb->opentrace("trace.vcd");

	tb->m_core->uart_rx = 1;
	tb->reset ();

	transfer_byte (tb, 0xA5);
	for (int i = 0; i < 20; i++) wait_baud (tb);
	tb->close ();
	exit (EXIT_SUCCESS);
}

void wait_baud (TESTBENCH<VUART_LB> *tb) {
	for (int i = 0; i < 8; i++ ) {
    tb->tick();
  }
}

void transfer_byte (TESTBENCH<VUART_LB> *tb, char a) {
    tb->m_core->uart_rx = 0;   // START
		wait_baud (tb);
    tb->m_core->uart_rx = a & 1; a = a >> 1;
		wait_baud (tb);
    tb->m_core->uart_rx = a & 1; a = a >> 1;
		wait_baud (tb);
    tb->m_core->uart_rx = a & 1; a = a >> 1;
		wait_baud (tb);
    tb->m_core->uart_rx = a & 1; a = a >> 1;
		wait_baud (tb);
    tb->m_core->uart_rx = a & 1; a = a >> 1;
		wait_baud (tb);
    tb->m_core->uart_rx = a & 1; a = a >> 1;
		wait_baud (tb);
    tb->m_core->uart_rx = a & 1; a = a >> 1;
		wait_baud (tb);
    tb->m_core->uart_rx = a & 1;
		wait_baud (tb);
    tb->m_core->uart_rx = 1;   // STOP
		wait_baud (tb);
}
