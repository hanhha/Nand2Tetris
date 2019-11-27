#include <Vchip.h>
#include "testbench.h"

int main (int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  TESTBENCH<Vchip> *tb = new TESTBENCH<Vchip>();
	int i;

  tb->opentrace("trace.vcd");

	tb->reset ();
	for (i = 0; i < 2000010; i++ ) {
    tb->tick();
  }

	tb->close ();
	exit (EXIT_SUCCESS);
}
